#!/usr/bin/env python3
import psutil
import time
from pathlib import Path
import sys

# Configuration du path
sys.path.append(str(Path(__file__).parent.parent))
from lib.logger import Logger

class FirewallMonitor:
    def __init__(self):
        self.logger = Logger("FirewallMonitor")
        # Ports à surveiller avec leur description
        self.suspicious_ports = {
            21: "FTP",
            22: "SSH",
            23: "Telnet", 
            3306: "MySQL",
            5432: "PostgreSQL"
        }

    def start(self):
        """Lance la surveillance continue"""
        self.logger.info("Démarrage du monitoring (Ctrl+C pour arrêter)")
        
        try:
            while True:
                self.check_connections()
                time.sleep(3)  # Vérification toutes les 3 secondes
        except KeyboardInterrupt:
            self.logger.info("Arrêt du monitoring")
        except Exception as e:
            self.logger.error(f"ERREUR: {str(e)}")

    def check_connections(self):
        """Vérifie toutes les connexions actives"""
        for conn in psutil.net_connections(kind='inet'):
            if conn.status == 'ESTABLISHED' and hasattr(conn, 'laddr'):
                port = conn.laddr.port
                if port in self.suspicious_ports:
                    self.logger.warning(
                        f"Port suspect {port} ({self.suspicious_ports[port]}) utilisé",
                        metadata={
                            "local": f"{conn.laddr.ip}:{port}",
                            "remote": f"{conn.raddr.ip}:{conn.raddr.port}" if conn.raddr else None
                        }
                    )

if __name__ == "__main__":
    print("=== Firewall Monitoring ===")
    print("Testez en ouvrant ces ports dans un autre terminal:")
    print("  sudo nc -lvnp 21  # FTP")
    print("  sudo nc -lvnp 3306  # MySQL")
    print("\nAppuyez sur Ctrl+C pour arrêter\n")
    
    monitor = FirewallMonitor()
    monitor.start()
