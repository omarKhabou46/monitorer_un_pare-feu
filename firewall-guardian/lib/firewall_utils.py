#!/usr/bin/env python3
import subprocess
from logger import Logger

logger = Logger("FirewallUtils")

def apply_rules(rules):
    logger.info("Applying firewall rules")
    for rule in rules:
        try:
            subprocess.run(rule, shell=True, check=True)
            logger.info(f"Rule applied: {rule}")
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to apply rule {rule}: {e}")