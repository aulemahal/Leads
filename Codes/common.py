"""
Fonctions utilitaires pour les autres scripts.
"""
import datetime as dt


class CommandOutputStreams(object):
    """A context manager for running command with subprocess.

    Appends the stdout and stderr of the process to given files.
    Adds a line before stating the command and, if it exits with an error, a line at the end stating the error.
    """

    def __init__(self, command, stdout='stdout.log', stderr='stderr.log'):
        """Initialize the streams with the command to be launched and the file names.

        'command' can be a string or a list of arguments in the style of 'subprocess.Popen'.
        """
        self.command = command if isinstance(command, str) else ' '.join(command)
        self.stderr_file = stderr
        self.stdout_file = stdout

    def __enter__(self):
        self.start = dt.datetime.now()
        self.stdout = open(self.stdout_file, 'a')
        self.stdout.write(f'***[{self.start}] Output stream of command: {self.command}\n')
        self.stdout.flush()
        self.stderr = open(self.stderr_file, 'a')
        self.stderr.write(f'***[{self.start}] Error stream of command: {self.command}\n')
        self.stderr.flush()
        return self.stdout, self.stderr

    def __exit__(self, exc_type, *args):
        duration = dt.datetime.now() - self.start
        self.stdout.write(f'*** Command exited afer {duration}')
        if exc_type is not None:
            self.stderr.write(f'*** Command exited with error of type {exc_type}')
        self.stdout.close()
        self.stderr.close()