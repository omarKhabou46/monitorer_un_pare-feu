#!/usr/bin/env python3
import sys
import subprocess
from pathlib import Path

# Add project root to Python path
project_root = Path(__file__).parent.parent
if str(project_root) not in sys.path:
    sys.path.insert(0, str(project_root))

from lib.logger import Logger
from lib.firewall_utils import apply_rules

class RulesGenerator:
    def __init__(self, role):
        self.logger = Logger("RulesGenerator")
        self.role = role
        self.rules = self._get_role_rules()

    def _get_role_rules(self):
        """Retourne les règles iptables selon le rôle"""
        base_rules = [
            "iptables -F",  # Flush existing rules
            "iptables -X",  # Delete user-defined chains
            "iptables -Z",  # Zero packet counters
            "iptables -P INPUT DROP",  # Default policy
            "iptables -P FORWARD DROP",
            "iptables -P OUTPUT ACCEPT",
            "iptables -A INPUT -i lo -j ACCEPT",  # Allow loopback
            "iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT"  # Allow established connections
        ]

        role_specific = {
            "web": [
                "iptables -A INPUT -p tcp --dport 80 -j ACCEPT",   # HTTP
                "iptables -A INPUT -p tcp --dport 443 -j ACCEPT",  # HTTPS
                "iptables -A INPUT -p tcp --dport 22 -j DROP"      # Block SSH
            ],
            "db": [
                "iptables -A INPUT -p tcp --dport 3306 -j ACCEPT",  # MySQL
                "iptables -A INPUT -p tcp --dport 5432 -j ACCEPT",  # PostgreSQL
                "iptables -A INPUT -p tcp --dport 22 -j DROP"       # Block SSH
            ],
            "ftp": [
                "iptables -A INPUT -p tcp --dport 21 -j ACCEPT",    # FTP
                "iptables -A INPUT -p tcp --dport 20 -j ACCEPT",    # FTP data
                "iptables -A INPUT -p tcp --dport 22 -j DROP"       # Block SSH
            ]
        }

        return base_rules + role_specific.get(self.role, [])

    def generate_and_apply(self):
        """Génère et applique les règles de pare-feu"""
        self.logger.info(f"Generating rules for role {self.role}")

        try:
            # Display rules for confirmation
            print("\n=== Règles de Pare-feu Proposées ===")
            for rule in self.rules:
                print(f"  {rule}")

            # Ask for confirmation
            print("\nVoulez-vous appliquer ces règles? (o/n)")
            response = input().lower()

            if response == 'o':
                apply_rules(self.rules)
                self.logger.info("Rules applied successfully")
                return True
            else:
                self.logger.info("Rules application cancelled")
                return False

        except Exception as e:
            self.logger.error(f"Failed to apply rules: {str(e)}")
            return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 rules_generator.py <role>")
        sys.exit(1)

    generator = RulesGenerator(sys.argv[1])
    generator.generate_and_apply()