#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $NilesoftRoot = (Join-Path $env:ProgramFiles 'Nilesoft Shell'),
    [switch] $RestartExplorer
)

$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'This restore script requires Windows.' }

$zedConfig = Join-Path $env:APPDATA 'Zed'
$zedInstall = Join-Path $env:LOCALAPPDATA 'Programs\Zed'
$NilesoftRoot = (Get-Item -LiteralPath $NilesoftRoot).FullName
$shellConfig = Join-Path $NilesoftRoot 'shell.nss'
$shellExe = Join-Path $NilesoftRoot 'shell.exe'

foreach ($required in @("$zedInstall\Zed.exe", "$zedInstall\bin\Zed.exe", $shellConfig, $shellExe)) {
    if (-not [IO.File]::Exists($required)) { throw "Required file is missing: $required" }
}
$shellVersion = (Get-Item -LiteralPath $shellExe).VersionInfo.FileVersion -as [version]
if (-not $shellVersion -or $shellVersion -lt [version]'1.9.15') {
    throw 'Install Nilesoft Shell 1.9.15 or newer.'
}
if (-not (Get-Command pythonw.exe -CommandType Application -ErrorAction SilentlyContinue)) {
    throw 'Install Python 3 with pythonw.exe on PATH before restoring the launcher.'
}

$lock = [Threading.Mutex]::new($false, 'Local\EditorConfigs.RestoreZed')
$locked = $false
try {
    try { $locked = $lock.WaitOne(0) }
    catch [Threading.AbandonedMutexException] { $locked = $true }
    if (-not $locked) { throw 'Another Zed restore is already running.' }

    $targets = [ordered]@{
        'settings.json'       = Join-Path $zedConfig 'settings.json'
        'keymap.json'         = Join-Path $zedConfig 'keymap.json'
        'open-with-tree.pyw'  = Join-Path $zedConfig 'open-with-tree.pyw'
        'zed-folder-tree.nss' = Join-Path $NilesoftRoot 'imports\zed-folder-tree.nss'
    }
    $changes = @(
        foreach ($name in $targets.Keys) {
            $path = $targets[$name]
            $after = [IO.File]::ReadAllBytes((Join-Path $PSScriptRoot $name))
            $before = $null
            if ([IO.File]::Exists($path)) {
                $before = [IO.File]::ReadAllBytes($path)
                if ([Convert]::ToBase64String($before) -ceq [Convert]::ToBase64String($after)) { continue }
            }
            [pscustomobject]@{ Path = $path; Before = $before; After = $after }
        }

        $reader = [IO.StreamReader]::new($shellConfig)
        try {
            $shellText = $reader.ReadToEnd()
            $encoding = $reader.CurrentEncoding
        }
        finally { $reader.Dispose() }
        # Mask comments for detection while keeping the original file bytes.
        $commentOrString = @'
(?s)(?<comment>//[^\r\n]*|/\*.*?\*/)|'[^']*'|"(?:\\.|[^"\\])*"
'@
        $activeShellText = [regex]::Replace($shellText, $commentOrString.Trim(), {
            param($token)
            if ($token.Groups['comment'].Success) { return $token.Value -replace '[^\r\n]', ' ' }
            $token.Value
        })
        $importPattern = @'
(?im)^[ \t]*import[ \t]+(['"])imports[/\\]zed-folder-tree\.nss\1[ \t]*\r?$
'@
        if ($activeShellText -notmatch $importPattern.Trim()) {
            $before = [IO.File]::ReadAllBytes($shellConfig)
            $newline = if ($shellText.Contains("`r`n")) { "`r`n" } else { "`n" }
            $append = $encoding.GetBytes($newline + "import 'imports/zed-folder-tree.nss'" + $newline)
            [pscustomobject]@{ Path = $shellConfig; Before = $before; After = [byte[]]($before + $append) }
        }
    )

    if ($changes.Count -eq 0 -and -not $RestartExplorer) {
        Write-Output 'Zed settings and Explorer menu are already restored.'
        return
    }
    $action = 'Restore Zed settings, keymap and Explorer menu'
    if ($RestartExplorer) { $action += ' and restart Explorer' }
    if (-not $PSCmdlet.ShouldProcess("$zedConfig and $NilesoftRoot", $action)) { return }

    $backup = Join-Path $zedConfig ("restore-backups\" + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
    foreach ($change in $changes) {
        if ($null -eq $change.Before) { continue }
        [IO.Directory]::CreateDirectory($backup) | Out-Null
        [IO.File]::WriteAllBytes((Join-Path $backup (Split-Path $change.Path -Leaf)), $change.Before)
    }

    $attempted = [Collections.Generic.List[object]]::new()
    try {
        foreach ($change in $changes) {
            [IO.Directory]::CreateDirectory((Split-Path $change.Path -Parent)) | Out-Null
            $attempted.Add($change)
            [IO.File]::WriteAllBytes($change.Path, $change.After)
        }
    }
    catch {
        $failure = $_
        $rollbackFailures = @()
        for ($i = $attempted.Count - 1; $i -ge 0; $i--) {
            $change = $attempted[$i]
            try {
                if ($null -eq $change.Before) {
                    if ([IO.File]::Exists($change.Path)) { Remove-Item -LiteralPath $change.Path }
                }
                elseif (-not [IO.File]::Exists($change.Path) -or
                    [Convert]::ToBase64String([IO.File]::ReadAllBytes($change.Path)) -cne
                    [Convert]::ToBase64String($change.Before)) {
                    [IO.File]::WriteAllBytes($change.Path, $change.Before)
                }
            }
            catch { $rollbackFailures += $change.Path }
        }
        if ($rollbackFailures.Count) {
            throw "Restore failed: $failure. Recover these files from $backup : $($rollbackFailures -join ', ')"
        }
        throw "Restore failed and file changes were rolled back: $failure"
    }

    Write-Output 'Zed settings, keymap and Explorer menu restored.'
    if ([IO.Directory]::Exists($backup)) { Write-Output "Backups: $backup" }
    if ($RestartExplorer) {
        $restart = Start-Process -FilePath $shellExe -ArgumentList '-restart' -WindowStyle Hidden -PassThru
        try {
            # Nilesoft returns its Boolean restart result as the process exit code.
            if (-not $restart.WaitForExit(30000) -or $restart.ExitCode -ne 1) {
                throw 'Explorer restart could not be confirmed. Hold Ctrl and right-click an empty taskbar area to reload Nilesoft.'
            }
        }
        finally { $restart.Dispose() }
        Write-Output 'Explorer restarted.'
    }
    else { Write-Output 'Hold Ctrl and right-click an empty taskbar area to reload Nilesoft.' }
}
finally {
    if ($locked) { $lock.ReleaseMutex() }
    $lock.Dispose()
}
