#!/bin/bash

# Source colors
source lib/colors.sh

check_python_packages() {
    local required_packages=("psutil")
    local missing_packages=()

    for package in "${required_packages[@]}"; do
        if ! python3 -c "import $package" &> /dev/null; then
            missing_packages+=("$package")
        fi
    done

    if [ ${#missing_packages[@]} -eq 0 ]; then
        echo -e "${GREEN}All required Python packages are installed.${NC}"
        return 0
    fi

    echo -e "${RED}Missing Python packages: ${missing_packages[*]}${NC}"
    echo "Would you like to install them? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        for package in "${missing_packages[@]}"; do
            echo "Installing $package..."
            python3 -m pip install --user "$package"
        done
        echo -e "${GREEN}Python packages installed successfully.${NC}"
    else
        echo -e "${RED}Cannot proceed without required Python packages. Exiting.${NC}"
        exit 1
    fi
}

check_and_install_tools() {
    local required_tools=("python3" "iptables" "nftables" "ollama" "curl" "pip3")
    local missing_tools=()

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -eq 0 ]; then
        echo -e "${GREEN}All required tools are installed.${NC}"
    else
        echo -e "${RED}Missing tools: ${missing_tools[*]}${NC}"
        echo "Would you like to install them? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            for tool in "${missing_tools[@]}"; do
                case "$tool" in
                    "ollama")
                        echo "Installing Ollama..."
                        curl -fsSL https://ollama.com/install.sh | sudo sh
                        sudo ollama pull llama2:7b
                        ;;
                    "pip3")
                        echo "Installing pip3..."
                        sudo apt update && sudo apt install -y python3-pip
                        ;;
                    *)
                        echo "Installing $tool..."
                        sudo apt update && sudo apt install -y "$tool"
                        ;;
                esac
            done
            echo -e "${GREEN}Tools installed successfully.${NC}"
        else
            echo -e "${RED}Cannot proceed without required tools. Exiting.${NC}"
            exit 1
        fi
    fi

    # Check Python packages after ensuring pip3 is installed
    check_python_packages
}

# Note: This script is sourced by main.sh, which will call check_and_install_tools
# Do not run check_and_install_tools here to avoid duplicate execution