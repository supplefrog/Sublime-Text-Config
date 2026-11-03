"""Give standalone files a navigable folder tree without replacing projects."""

import os

import sublime
import sublime_plugin

def show_file_folder(view):
    if not view or not view.is_valid() or view.is_loading():
        return
    window = view.window()
    filename = view.file_name()
    if not window or not filename or window.folders():
        return
    directory = os.path.dirname(os.path.abspath(filename))
    if not os.path.isdir(directory):
        return
    project = window.project_data() or {}
    project['folders'] = [{'path': directory}]
    window.set_project_data(project)
    window.set_sidebar_visible(True)


def plugin_loaded():
    for window in sublime.windows():
        show_file_folder(window.active_view())


class StandaloneFileTreeListener(sublime_plugin.EventListener):
    def on_load(self, view):
        show_file_folder(view)

    def on_activated(self, view):
        show_file_folder(view)
