"""Open files selected in Explorer with their containing folders in Zed."""

import os
from pathlib import Path
import subprocess
import sys


def launch_arguments(paths):
    folders = []
    files = []
    seen = set()
    for raw in paths:
        path = Path(raw).absolute()
        folder = path if path.is_dir() else path.parent
        key = os.path.normcase(str(folder))
        if key not in seen:
            folders.append(str(folder))
            seen.add(key)
        if not path.is_dir():
            files.append(str(path))
    executable = Path(os.environ['LOCALAPPDATA']) / 'Programs/Zed/bin/Zed.exe'
    return ([str(executable), '--new', *folders],
            [str(executable), '--add', *files] if files else None)


if __name__ == '__main__':
    args = sys.argv[1:]
    dry_run = args[:1] == ['--dry-run']
    if dry_run:
        args = args[1:]
    folder_command, file_command = launch_arguments(args)
    if dry_run:
        import json
        print(json.dumps([folder_command, file_command]))
    else:
        subprocess.run(folder_command, check=True, close_fds=True,
                       creationflags=subprocess.CREATE_NO_WINDOW)
        if file_command:
            subprocess.run(file_command, check=True, close_fds=True,
                           creationflags=subprocess.CREATE_NO_WINDOW)
