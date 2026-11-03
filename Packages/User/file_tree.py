"""Give standalone files a navigable folder tree without replacing projects."""

import os

import sublime
import sublime_plugin

_history = {}


def navigate(window, directory):
    if not directory or not os.path.isdir(directory):
        return
    project = window.project_data() or {}
    folders = project.get('folders', [])
    target = [{'path': os.path.abspath(directory)}]
    if folders == target:
        window.set_sidebar_visible(True)
        return
    history = _history.setdefault(window.id(), {'back': [], 'forward': []})
    if folders:
        history['back'].append(folders)
    history['forward'] = []
    project['folders'] = target
    window.set_project_data(project)
    window.set_sidebar_visible(True)


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


class BrowseParentDirectoryCommand(sublime_plugin.WindowCommand):
    def is_enabled(self):
        folders = self.window.folders()
        return len(folders) == 1 and os.path.dirname(folders[0]) != folders[0]

    def run(self):
        if not self.is_enabled():
            return
        directory = os.path.dirname(self.window.folders()[0])
        navigate(self.window, directory)


class BrowseDirectoryCommand(sublime_plugin.WindowCommand):
    def run(self):
        folders = self.window.folders()
        start = folders[0] if folders else None
        sublime.select_folder_dialog(
            lambda directory: navigate(self.window, directory), directory=start)


class BrowseDirectoryHistoryCommand(sublime_plugin.WindowCommand):
    def is_enabled(self, direction='back'):
        return bool(_history.get(self.window.id(), {}).get(direction))

    def run(self, direction='back'):
        if not self.is_enabled(direction):
            return
        history = _history[self.window.id()]
        other = 'forward' if direction == 'back' else 'back'
        project = self.window.project_data() or {}
        history[other].append(project.get('folders', []))
        project['folders'] = history[direction].pop()
        self.window.set_project_data(project)
        self.window.set_sidebar_visible(True)
