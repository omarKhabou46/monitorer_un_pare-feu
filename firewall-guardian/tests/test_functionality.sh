#!/bin/bash

# Get the absolute path to the project root
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Source colors and utilities
source "$PROJECT_ROOT/scripts/lib/colors.sh"
source "$PROJECT_ROOT/scripts/log_utils.sh"

# Test configuration
TEST_LOG_DIR="/tmp/firewall-guardian-test"
TEST_HISTORY_LOG="${TEST_LOG_DIR}/history.log"
TEST_ROLE="web"

# Setup test environment
setup_test_env() {
    echo -e "${BLUE}Setting up test environment...${NC}"
    mkdir -p "$TEST_LOG_DIR"
    touch "$TEST_HISTORY_LOG"
    export LOG_DIR="$TEST_LOG_DIR"
    export HISTORY_LOG="$TEST_HISTORY_LOG"
    export ROLE="$TEST_ROLE"
    
    # Set up Python path
    export PYTHONPATH="$PROJECT_ROOT:$PYTHONPATH"
    echo -e "${BLUE}Python path set to:${NC}"
    echo "$PYTHONPATH"
}

# Test Python imports
test_python_imports() {
    echo -e "\n${BLUE}Testing Python imports...${NC}"
    
    # Create a temporary Python script to test imports
    local temp_script=$(mktemp)
    cat > "$temp_script" << EOF
#!/usr/bin/env python3
import sys
import os

# Add project root to Python path
project_root = "$PROJECT_ROOT"
if project_root not in sys.path:
    sys.path.insert(0, project_root)

try:
    from lib.logger import Logger
    print("✓ Successfully imported Logger")
except Exception as e:
    print(f"✗ Failed to import Logger: {e}")

try:
    from lib.firewall_utils import apply_rules
    print("✓ Successfully imported apply_rules")
except Exception as e:
    print(f"✗ Failed to import apply_rules: {e}")

try:
    from modules.monitor import FirewallMonitor
    print("✓ Successfully imported FirewallMonitor")
except Exception as e:
    print(f"✗ Failed to import FirewallMonitor: {e}")

try:
    from modules.rules_generator import RulesGenerator
    print("✓ Successfully imported RulesGenerator")
except Exception as e:
    print(f"✗ Failed to import RulesGenerator: {e}")

print("\nPython path:")
for path in sys.path:
    print(f"  {path}")
EOF

    # Make the script executable and run it
    chmod +x "$temp_script"
    python3 "$temp_script"
    rm "$temp_script"
}

# Test alerts viewing
test_alerts_viewing() {
    echo -e "\n${BLUE}Testing alerts viewing...${NC}"
    
    # Generate some test alerts
    echo "$(date '+%Y-%m-%d %H:%M:%S') [TEST] Test alert 1" >> "$TEST_HISTORY_LOG"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [TEST] Test alert 2" >> "$TEST_HISTORY_LOG"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [TEST] Test alert 3" >> "$TEST_HISTORY_LOG"
    
    # Test if alerts file exists and is readable
    if [ -f "$TEST_HISTORY_LOG" ]; then
        echo -e "${GREEN}✓ Alerts log file exists${NC}"
        if [ -r "$TEST_HISTORY_LOG" ]; then
            echo -e "${GREEN}✓ Alerts log file is readable${NC}"
            echo -e "${BLUE}Last 3 alerts:${NC}"
            tail -n 3 "$TEST_HISTORY_LOG"
        else
            echo -e "${RED}✗ Alerts log file is not readable${NC}"
        fi
    else
        echo -e "${RED}✗ Alerts log file does not exist${NC}"
    fi
}

# Test monitoring functionality
test_monitoring() {
    echo -e "\n${BLUE}Testing monitoring functionality...${NC}"
    
    # Check if monitor.py exists and is executable
    MONITOR_PATH="$PROJECT_ROOT/modules/monitor.py"
    if [ -f "$MONITOR_PATH" ]; then
        echo -e "${GREEN}✓ Monitor module exists${NC}"
        if [ -x "$MONITOR_PATH" ]; then
            echo -e "${GREEN}✓ Monitor module is executable${NC}"
        else
            echo -e "${YELLOW}! Monitor module is not executable${NC}"
            chmod +x "$MONITOR_PATH"
            echo -e "${GREEN}✓ Made monitor module executable${NC}"
        fi
    else
        echo -e "${RED}✗ Monitor module not found${NC}"
    fi
    
    # Test Python environment
    echo -e "\n${BLUE}Testing Python environment...${NC}"
    if python3 -c "import psutil" 2>/dev/null; then
        echo -e "${GREEN}✓ psutil module is installed${NC}"
    else
        echo -e "${RED}✗ psutil module is not installed${NC}"
    fi
    
    # Test monitor module import
    if python3 -c "from modules.monitor import FirewallMonitor" 2>/dev/null; then
        echo -e "${GREEN}✓ Monitor module can be imported${NC}"
    else
        echo -e "${RED}✗ Monitor module cannot be imported${NC}"
        echo -e "${YELLOW}Checking monitor.py content...${NC}"
        head -n 5 "$MONITOR_PATH"
    fi
}

# Test rule generation
test_rule_generation() {
    echo -e "\n${BLUE}Testing rule generation...${NC}"
    
    # Check if rules_generator.py exists
    RULES_PATH="$PROJECT_ROOT/modules/rules_generator.py"
    if [ -f "$RULES_PATH" ]; then
        echo -e "${GREEN}✓ Rules generator module exists${NC}"
        
        # Test Python imports with proper path
        if PYTHONPATH="$PROJECT_ROOT" python3 -c "from modules.rules_generator import RulesGenerator" 2>/dev/null; then
            echo -e "${GREEN}✓ Rules generator module can be imported${NC}"
        else
            echo -e "${RED}✗ Rules generator module cannot be imported${NC}"
            echo -e "${YELLOW}Checking rules_generator.py content...${NC}"
            head -n 5 "$RULES_PATH"
            echo -e "\n${YELLOW}Checking Python path...${NC}"
            PYTHONPATH="$PROJECT_ROOT" python3 -c "import sys; print('\n'.join(sys.path))"
        fi
    else
        echo -e "${RED}✗ Rules generator module not found${NC}"
    fi
}

# Test backup functionality
test_backup() {
    echo -e "\n${BLUE}Testing backup functionality...${NC}"
    
    # Check backup directory
    BACKUP_DIR="$(dirname "$0")/../backups"
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${GREEN}✓ Backup directory exists${NC}"
        if [ -w "$BACKUP_DIR" ]; then
            echo -e "${GREEN}✓ Backup directory is writable${NC}"
        else
            echo -e "${RED}✗ Backup directory is not writable${NC}"
        fi
    else
        echo -e "${RED}✗ Backup directory not found${NC}"
    fi
}

# Main test execution
main() {
    echo -e "${BLUE}Starting Firewall Guardian functionality tests...${NC}"
    echo -e "${BLUE}Project root: $PROJECT_ROOT${NC}"
    
    # Setup test environment
    setup_test_env
    
    # Run tests
    test_alerts_viewing
    test_python_imports
    test_monitoring
    test_rule_generation
    test_backup
    
    echo -e "\n${BLUE}Test summary:${NC}"
    echo -e "Test logs are available at: ${YELLOW}$TEST_HISTORY_LOG${NC}"
    echo -e "To view the test logs, run: ${GREEN}less $TEST_HISTORY_LOG${NC}"
}

# Run tests
main

# Cleanup
cleanup() {
    echo -e "\n${BLUE}Cleaning up test environment...${NC}"
    rm -rf "$TEST_LOG_DIR"
}

# Register cleanup function
trap cleanup EXIT 