#!/bin/bash
# Chargement des couleurs
source lib/colors.sh

# Menu interactif
while true; do
  clear
  echo -e "${BLUE}=== Firewall Guardian ==="
  echo -e "${NC}"
  echo -e "1. 🖥️  Surveillance temps réel"
  echo -e "2. 🧠 Analyse IA de configuration"
  echo -e "3. ⚙️  Générer règles de pare-feu"
  echo -e "4. 💾 Sauvegarder configuration"
  echo -e "5. 🔄 Restaurer configuration"
  echo -e "6. 🚨 Voir alertes"
  echo -e "7. ❌ Quitter"
  echo -n "Choix [1-7] : "
  read choice

  case $choice in
    1) python3 modules/monitor.py ;;
    2) python3 modules/analyze_ia.py ;;
    3) python3 modules/rules_generator.py ;;
    4) python3 modules/backup_manager.py save ;;
    5) pyhton3 modules/backup_manager.py restore ;;
    6) less logs/alerts.log ;;
    7) exit 0 ;;
    *) echo -e "${RED}Choix invalide!${NC}"; sleep 1 ;;
  esac
done
