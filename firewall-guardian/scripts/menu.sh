#!/bin/bash

# Source colors
source lib/colors.sh

# Get the absolute path to the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Function to run Python modules with proper environment
run_python_module() {
    local module=$1
    local role=$2
    
    # Create a temporary Python script to set up the environment
    local temp_script=$(mktemp)
    cat > "$temp_script" << EOF
#!/usr/bin/env python3
import sys
import os
from pathlib import Path

# Add project root and user site-packages to Python path
project_root = Path("$PROJECT_ROOT")
user_site = Path.home() / ".local/lib/python3.10/site-packages"
sys.path.insert(0, str(project_root))
sys.path.insert(0, str(user_site))

# Import and run the module
if "$module" == "modules.monitor":
    from modules.monitor import FirewallMonitor
    monitor = FirewallMonitor()
    monitor.start_monitoring()
elif "$module" == "modules.analyze_ia":
    from modules.analyze_ia import AIAnalyzer
    analyzer = AIAnalyzer("$role")
    analyzer.analyze_configuration()
elif "$module" == "modules.rules_generator":
    from modules.rules_generator import RulesGenerator
    generator = RulesGenerator("$role")
    generator.generate_and_apply()
elif "$module" == "modules.backup_manager":
    from modules.backup_manager import BackupManager
    manager = BackupManager()
    if "$role" == "backup":
        manager.create_backup()
    else:
        manager.restore_backup()
elif "$module" == "modules.alert_viewer":
    from modules.alert_viewer import AlertViewer
    viewer = AlertViewer()
    viewer.view_alerts()
EOF

    # Make the script executable and run it
    chmod +x "$temp_script"
    python3 "$temp_script"
    rm "$temp_script"
}

show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════╗"
    echo -e "║   FIREWALL GUARDIAN v1.0   ║"
    echo -e "╚════════════════════════════╝${NC}"
    echo "1. 🖥️  Live Monitoring"
    echo "2. 🧠  AI Config Analysis $(if [ "$ANALYSIS_DONE" = true ]; then echo "[Done]"; fi)"
    echo "3. ⚙️  Generate Firewall Rules $(if [ "$RULES_DONE" = true ]; then echo "[Done]"; fi)"
    echo "4. 💾  Backup Config"
    echo "5. 🔄  Restore Config"
    echo "6. 🚨  View Alerts"
    echo "7. ❌  Exit"
    echo -n "Select [1-7]: "
}

execute_choice() {
    local choice=$1
    case $choice in
        1)
            log_message "INFOS" "Starting live monitoring"
            if $FORK; then
                (run_python_module monitor &)
            elif $SUBSHELL; then
                (run_python_module monitor)
            elif $THREAD; then
                run_python_module monitor &
            else
                run_python_module monitor
            fi
            ;;
        2)
            if [ "$ANALYSIS_DONE" = true ]; then
                log_message "INFOS" "AI analysis already completed"
                echo -e "${GREEN}AI analysis already done. Check logs or proceed.${NC}"
            else
                log_message "INFOS" "Starting AI analysis for role $ROLE"
                if $SUBSHELL; then
                    (run_python_module analyze_ia "$ROLE")
                else
                    run_python_module analyze_ia "$ROLE"
                fi
                ANALYSIS_DONE=true
            fi
            ;;
        3)
            if [ "$RULES_DONE" = true ]; then
                log_message "INFOS" "Rule generation already completed"
                echo -e "${GREEN}Rules already generated. Check logs or proceed.${NC}"
            else
                log_message "INFOS" "Generating rules for role $ROLE"
                run_python_module rules_generator "$ROLE"
                RULES_DONE=true
            fi
            ;;
        4)
            log_message "INFOS" "Backing up configuration"
            run_python_module backup_manager save
            ;;
        5)
            log_message "INFOS" "Restoring configuration"
            run_python_module backup_manager restore
            ;;
        6)
            log_message "INFOS" "Viewing alerts"
            if [ -f "$HISTORY_LOG" ]; then
                # Save terminal state
                tput smcup
                # Use less with proper terminal handling
                LESS=FRX less "$HISTORY_LOG"
                # Restore terminal state
                tput rmcup
                # Clear screen and return to menu
                clear
            else
                echo -e "${YELLOW}No alerts log file found at $HISTORY_LOG${NC}"
                sleep 2
            fi
            ;;
        7)
            log_message "INFOS" "Exiting Firewall Guardian"
            exit 0
            ;;
        *)
            log_message "ERROR" "Invalid choice"
            echo -e "${RED}Invalid choice!${NC}"
            sleep 1
            ;;
    esac
}