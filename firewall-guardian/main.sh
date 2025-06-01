#!/bin/bash

# Source modular scripts
source scripts/tool_check.sh
source scripts/log_utils.sh
source scripts/error_handling.sh
source scripts/menu.sh

# Default log directory and fallback
SYSTEM_LOG_DIR="/var/log/firewall-guardian"
USER_LOG_DIR="${HOME}/.firewall-guardian/logs"
LOG_DIR=""
HISTORY_LOG=""
USERNAME=$(whoami)

# Try to use system log directory first, fall back to user directory if needed
setup_log_directory() {
    # Try system directory first
    if mkdir -p "$SYSTEM_LOG_DIR" 2>/dev/null && touch "${SYSTEM_LOG_DIR}/history.log" 2>/dev/null; then
        LOG_DIR="$SYSTEM_LOG_DIR"
        HISTORY_LOG="${LOG_DIR}/history.log"
        echo "Using system log directory: $LOG_DIR"
    else
        # Fall back to user directory
        mkdir -p "$USER_LOG_DIR"
        LOG_DIR="$USER_LOG_DIR"
        HISTORY_LOG="${LOG_DIR}/history.log"
        echo "Using user log directory: $LOG_DIR"
    fi
    
    # Ensure log file exists and is writable
    touch "$HISTORY_LOG" 2>/dev/null || { 
        echo "Error: Cannot create or write to log file. Please check permissions."
        exit 1
    }
}

# Parse options
ROLE=""
FORK=false
THREAD=false
SUBSHELL=false
ANALYSIS_DONE=false
RULES_DONE=false
while getopts "hftsl:ra" opt; do
    case $opt in
        h) show_help ;;
        f) FORK=true ;;
        t) THREAD=true ;;
        s) SUBSHELL=true ;;
        l) 
            LOG_DIR="$OPTARG"
            HISTORY_LOG="${LOG_DIR}/history.log"
            mkdir -p "$LOG_DIR" || { echo "Error: Cannot create custom log directory"; exit 1; }
            ;;
        r) [ "$EUID" -ne 0 ] && handle_error 102 "Option -r requires admin privileges" || echo "Restoring defaults... (not implemented in this version)"; ;;
        a) ANALYSIS_DONE=true ;;
        ?) handle_error 100 "Invalid option" ;;
    esac
done
shift $((OPTIND-1))

# Check mandatory parameter
[ -z "$1" ] && handle_error 101 "Role parameter is mandatory (e.g., web, db, ftp)"
ROLE="$1"

# Validate role
case $ROLE in
    web|db|ftp) ;;
    *) handle_error 103 "Invalid role. Must be one of: web, db, ftp" ;;
esac

# Setup log directory
setup_log_directory

# Check and install tools before proceeding
check_and_install_tools

# Main loop
while true; do
    show_menu
    read choice
    case $choice in
        6)  # Special handling for alerts viewing
            execute_choice "$choice"
            ;;
        *)  # Normal logging for other commands
            execute_choice "$choice" 2>&1 | tee -a "$HISTORY_LOG" > /dev/tty
            ;;
    esac
done