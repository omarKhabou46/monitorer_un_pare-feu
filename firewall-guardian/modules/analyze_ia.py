#!/usr/bin/env python3
import sys
import subprocess
import json
from pathlib import Path

# Add project root to Python path
sys.path.append(str(Path(__file__).parent.parent))
from lib.logger import Logger

class AIAnalyzer:
def __init__(self, role):
self.logger = Logger("AIAnalyzer")
self.role = role
self.model = "llama2:7b"

def analyze_configuration(self):
"""Analyse la configuration du pare-feu avec Ollama"""
self.logger.info(f"Starting AI analysis for role {self.role}")

try:
# Collect system info
config = self._collect_system_info()

# Prepare prompt for Ollama
prompt = self._prepare_prompt(config)

# Get AI analysis
analysis = self._get_ai_analysis(prompt)

# Display results
self._display_results(analysis)

except Exception as e:
self.logger.error(f"AI analysis failed: {str(e)}")
return False

return True

def _collect_system_info(self):
"""Collecte les informations système pertinentes"""
config = {
"role": self.role,
"open_ports": self._get_open_ports(),
"services": self._get_running_services()
}
return config

def _get_open_ports(self):
"""Récupère la liste des ports ouverts"""
try:
result = subprocess.run(["netstat", "-tuln"], capture_output=True, text=True)
return result.stdout
except Exception as e:
self.logger.error(f"Failed to get open ports: {e}")
return "Error getting ports"

def _get_running_services(self):
"""Récupère la liste des services en cours d'exécution"""
try:
result = subprocess.run(["systemctl", "list-units", "--type=service", "--state=running"], 
capture_output=True, text=True)
return result.stdout
except Exception as e:
self.logger.error(f"Failed to get running services: {e}")
return "Error getting services"

def _prepare_prompt(self, config):
"""Prépare le prompt pour l'analyse IA"""
return f"""Analyse la configuration de sécurité suivante pour un serveur {self.role} et fournis 3 recommandations en français:
Configuration:
{json.dumps(config, indent=2)}

Recommandations:"""

def _get_ai_analysis(self, prompt):
"""Obtient l'analyse de l'IA via Ollama"""
try:
result = subprocess.run(["ollama", "run", self.model, prompt], 
capture_output=True, text=True)
return result.stdout
except Exception as e:
self.logger.error(f"Failed to get AI analysis: {e}")
return "Erreur lors de l'analyse IA"

def _display_results(self, analysis):
"""Affiche les résultats de l'analyse"""
print("\n=== Analyse de Configuration ===")
print(analysis)
print("\n✅ Analyse terminée")

if __name__ == "__main__":
if len(sys.argv) != 2:
print("Usage: python3 analyze_ia.py <role>")
sys.exit(1)

analyzer = AIAnalyzer(sys.argv[1])
analyzer.analyze_configuration()