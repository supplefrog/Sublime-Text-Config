// Open an individual file with its containing directory in Zed.
modify(type='file' mode='single' find='Open with Zed' vis=vis.remove)
item(type='file' mode='single' title='Open with Zed'
    image=sys.expand('%LOCALAPPDATA%\Programs\Zed\Zed.exe')
    cmd='pythonw.exe'
    args='"' + sys.expand('%APPDATA%\Zed\open-with-tree.pyw') + '" ' + sel.path.quote)
