#!/bin/bash

# Source colors
source lib/colors.sh

show_help() {
    echo -e "${BLUE}Firewall Guardian - v1.0${NC}"
    echo "Usage: $0 [options] <role>"
    echo "A tool to configure, monitor, and analyze firewall settings."
    echo ""
    echo "Options:"
    echo "  -h          Display this help message"
    echo "  -f          Run with fork (sub-processes)"
    echo "  -t          Run with threads (simulated via background jobs)"
    echo "  -s          Run in subshell"
    echo "  -l <dir>    Specify log directory (default: /var/log/firewall-guardian)"
    echo "  -r          Restore default settings (admin only)"
    echo "  -a          Done with AI analysis"
    echo "  -r          Done with rule generation"
    echo "Role: web, db, ftp (mandatory parameter)"
    echo ""
    echo "Example: $0 -f web"
    exit 0
}

handle_error() {
    local code=$1
    local message=$2
    log_message "ERROR" "$message"
    echo -e "${RED}Error $code: $message${NC}"
    show_help
    exit $code
}