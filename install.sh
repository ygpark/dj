#!/bin/bash

# Directory Jump Install Script (Cross-platform)

# Exit immediately if a command exits with a non-zero status
set -e

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print colorized output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Detect the operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Detect the default shell
detect_shell() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "zsh"
    elif [[ "$SHELL" == *"bash"* ]]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# Set up variables based on OS and shell
setup_variables() {
    OS=$(detect_os)
    SHELL_TYPE=$(detect_shell)

    if [[ "$OS" == "linux" && "$SHELL_TYPE" == "unknown" ]]; then
        SHELL_TYPE="bash"  # Default to bash for Linux if shell is unknown
    elif [[ "$OS" == "macos" && "$SHELL_TYPE" == "unknown" ]]; then
        SHELL_TYPE="zsh"   # Default to zsh for macOS if shell is unknown
    fi

    if [[ "$SHELL_TYPE" == "zsh" ]]; then
        RC_FILE="$HOME/.zshrc"
    elif [[ "$SHELL_TYPE" == "bash" ]]; then
        RC_FILE="$HOME/.bashrc"
    else
        print_color "${RED}" "Unsupported shell. Please use bash or zsh."
        exit 1
    fi
}

# Check if the script is run from the cloned directory
if [ ! -f "dj.py" ]; then
    print_color "${RED}" "Error: dj.py not found in the current directory."
    print_color "${RED}" "Please run this script from the directory where you cloned the repository."
    exit 1
fi

# Set up variables
setup_variables

# Create bin directory in home if it doesn't exist
mkdir -p ~/bin

# Copy dj.py to ~/bin/dj and make it executable
cp dj.py ~/bin/dj
chmod +x ~/bin/dj

print_color "${GREEN}" "Copied dj.py to ~/bin/dj and made it executable."

# Check if RC_FILE exists, create if it doesn't
touch "$RC_FILE"

# Check if PATH already includes ~/bin, add if it doesn't
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$RC_FILE"; then
    echo '' >> "$RC_FILE"
    echo '# Add ~/bin to PATH for dj script' >> "$RC_FILE"
    echo 'export PATH="$HOME/bin:$PATH"' >> "$RC_FILE"
    print_color "${GREEN}" "Added ~/bin to PATH in $RC_FILE"
fi

# Remove existing dj function and related comments
sed -i.bak '/# Directory Jump function/,/^}/d' "$RC_FILE"

# Add new dj function
echo '' >> "$RC_FILE"
echo '# Directory Jump function' >> "$RC_FILE"
echo 'dj() {
    if [ "$#" -eq 0 ]; then
        ~/bin/dj
    else
        result=$(~/bin/dj "$@")
        if [[ $result == *"DJCHANGEDIR:"* ]]; then
            dir=$(echo "$result" | grep "DJCHANGEDIR:" | tail -n1 | sed "s/DJCHANGEDIR://")
            echo "$result" | grep -v "DJCHANGEDIR:"
            cd "$dir"
        else
            echo "$result"
        fi
    fi
}' >> "$RC_FILE"

print_color "${GREEN}" "Updated dj function in $RC_FILE"

# Remove empty lines at the end of the file
sed -i.bak -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$RC_FILE"

# Source RC_FILE to apply changes immediately
source "$RC_FILE"

print_color "${GREEN}" "Installation completed successfully!"
print_color "${GREEN}" "Please restart your terminal or run 'source $RC_FILE' to apply the changes."
print_color "${GREEN}" "You can now use the 'dj' command. Type 'dj help' for usage information."