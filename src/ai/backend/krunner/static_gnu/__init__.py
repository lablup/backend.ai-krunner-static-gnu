from importlib.metadata import version

try:
    __version__ = version("backend.ai-krunner-static-gnu")
except ImportError:
    __version__ = "0.0.0"
