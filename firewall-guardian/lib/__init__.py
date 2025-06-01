import os
import sys

# Add the project root directory to Python path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if project_root not in sys.path:
    sys.path.append(project_root)

# Import and expose key functions
from .logger import Logger
from .firewall_utils import apply_rules

__all__ = ['Logger', 'apply_rules']
