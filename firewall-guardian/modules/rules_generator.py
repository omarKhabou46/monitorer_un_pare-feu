#!/usr/bin/env python3
import json, sys
from lib.firewall_utils import apply_rules

ROLES_CONFIG = {
    "web": {"allow": [80, 443], "deny": [22]},
    "db": {"allow": [3306], "deny": [*range(1, 1024)]}
}

def generate_rules(role):
    rules = []
    for port in ROLES_CONFIG[role]["allow"]:
        rules.append(f"iptables -A INPUT -p tcp --dport {port} -j ACCEPT")
    for port in ROLES_CONFIG[role]["deny"]:
        rules.append(f"iptables -A INPUT -p tcp --dport {port} -j DROP")
    return rules

if __name__ == "__main__":
    role = sys.argv[1] if len(sys.argv) > 1 else "web"
    rules = generate_rules(role)
    print("Règles générées :")
    for rule in rules:
        print(rule)
    apply_rules(rules)  # À implémenter dans firewall_utils.py
