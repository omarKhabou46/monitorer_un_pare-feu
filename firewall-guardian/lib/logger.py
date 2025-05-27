import os
import json
from datetime import datetime
from enum import Enum

class LogLevel(Enum):
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"

class Logger:
    def __init__(self, name, log_file="logs/firewall.log"):
        self.name = name
        self.log_file = log_file
        self._ensure_log_directory()

    def _ensure_log_directory(self):
        """Crée le dossier de logs si inexistant"""
        os.makedirs(os.path.dirname(self.log_file), exist_ok=True)

    def _write_log(self, level, message, metadata=None):
        """Méthode centrale d'écriture des logs"""
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "level": level.value,
            "module": self.name,
            "message": message,
            "metadata": metadata or {}
        }

        # Écriture formatée
        with open(self.log_file, "a") as f:
            f.write(json.dumps(log_entry) + "\n")

        # Affichage console coloré
        colors = {
            LogLevel.INFO: '\033[94m',     # Bleu
            LogLevel.WARNING: '\033[93m',   # Jaune
            LogLevel.ERROR: '\033[91m',     # Rouge
            LogLevel.CRITICAL: '\033[41m'   # Fond rouge
        }
        print(f"{colors[level]}[{level.value}] {self.name}: {message}\033[0m")

    # Méthodes spécifiques
    def info(self, message, metadata=None):
        self._write_log(LogLevel.INFO, message, metadata)

    def warning(self, message, metadata=None):
        self._write_log(LogLevel.WARNING, message, metadata)

    def error(self, message, metadata=None):
        self._write_log(LogLevel.ERROR, message, metadata)

    def critical(self, message, metadata=None):
        self._write_log(LogLevel.CRITICAL, message, metadata)
