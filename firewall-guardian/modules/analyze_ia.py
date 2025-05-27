#!/usr/bin/env python3
import subprocess, json
from lib.logger import Logger

class FirewallAnalyzer:
    def __init__(self):
        self.log = Logger("ia_analyzer")

    def analyze_config(self):
        config = self._get_system_config()
        analysis = self._ask_ollama(config)
        self._display_results(analysis)

    def _get_system_config(self):
        return {
            "open_ports": self._get_open_ports(),
            "services": self._get_running_services()
        }

    def _ask_ollama(self, config):
        prompt = f"""Analyse cette configuration de pare-feu:
        {json.dumps(config, indent=2)}
        Donne 3 recommandations de sécurité en français."""
        
        cmd = ["ollama", "run", "llama2", prompt]
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.stdout

if __name__ == "__main__":
    analyzer = FirewallAnalyzer()
    analyzer.analyze_config()
