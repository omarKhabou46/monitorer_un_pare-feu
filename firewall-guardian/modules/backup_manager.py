#!/usr/bin/env python3
import sys
import os
import json
import subprocess
from pathlib import Path
from datetime import datetime

# Configuration absolue des chemins
current_dir = Path(__file__).parent
project_root = current_dir.parent
sys.path.insert(0, str(project_root))

from lib.logger import Logger

class BackupManager:
    def __init__(self):
        self.logger = Logger("BackupManager", log_file=str(project_root/"logs"/"backup.log"))
        self.backup_dir = project_root / "backups"
        self.backup_dir.mkdir(exist_ok=True)
        self.logger.info("Initialisation du BackupManager")

    def save_config(self):
        """Sauvegarde complète de la configuration"""
        try:
            config = {
                "timestamp": datetime.now().isoformat(),
                "iptables": self._get_config("sudo iptables-save"),
                "nftables": self._get_config("sudo nft list ruleset"),
                "network": self._get_config("ip a"),
                "services": self._get_config("ss -tulnp")
            }
            
            backup_file = self.backup_dir / f"backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            
            with open(backup_file, 'w') as f:
                json.dump(config, f, indent=2)
            
            self.logger.info(f"Sauvegarde créée: {backup_file}", {
                "size": f"{os.path.getsize(backup_file)/1024:.2f} KB",
                "items": len(config)
            })
            return str(backup_file)

        except Exception as e:
            self.logger.critical(f"Échec de la sauvegarde: {str(e)}")
            raise

    def _get_config(self, cmd):
        """Exécute une commande et retourne son output"""
        try:
            result = subprocess.run(
                cmd.split(),
                capture_output=True,
                text=True,
                check=True
            )
            return result.stdout
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Erreur avec '{cmd}': {e.stderr.strip()}")
            return None
        except Exception as e:
            self.logger.error(f"Erreur inattendue: {str(e)}")
            return None

if __name__ == "__main__":
    print("=== Système de sauvegarde ===")
    manager = BackupManager()
    
    try:
        backup_path = manager.save_config()
        print(f"\n✅ Sauvegarde réussie: {backup_path}")
    except Exception as e:
        print(f"\n❌ Échec: {str(e)}")
        sys.exit(1)
