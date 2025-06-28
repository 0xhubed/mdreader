#!/bin/bash

# Flutter Installation Script for MDReader
# Supports: Ubuntu/Debian, macOS, WSL

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version; then
            echo "wsl"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unsupported"
    fi
}

# Check if Flutter is already installed
check_flutter_installed() {
    if command -v flutter &> /dev/null; then
        print_warning "Flutter is already installed:"
        flutter --version
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_success "Using existing Flutter installation"
            exit 0
        fi
    fi
}

# Install dependencies for Linux/WSL
install_linux_dependencies() {
    print_status "Installing Linux dependencies..."
    
    sudo apt-get update
    sudo apt-get install -y \
        curl \
        git \
        unzip \
        xz-utils \
        zip \
        libglu1-mesa \
        clang \
        cmake \
        ninja-build \
        pkg-config \
        libgtk-3-dev \
        liblzma-dev
    
    print_success "Linux dependencies installed"
}

# Install Flutter on Linux/WSL
install_flutter_linux() {
    local install_dir="$HOME/development"
    
    print_status "Installing Flutter for Linux/WSL..."
    
    # Create development directory
    mkdir -p "$install_dir"
    cd "$install_dir"
    
    # Remove old installation if exists
    if [ -d "flutter" ]; then
        print_warning "Removing old Flutter installation..."
        rm -rf flutter
    fi
    
    # Clone Flutter
    print_status "Cloning Flutter repository..."
    git clone https://github.com/flutter/flutter.git -b stable
    
    # Add to PATH
    local shell_rc="$HOME/.bashrc"
    if [ -f "$HOME/.zshrc" ]; then
        shell_rc="$HOME/.zshrc"
    fi
    
    if ! grep -q "flutter/bin" "$shell_rc"; then
        echo '' >> "$shell_rc"
        echo '# Flutter PATH' >> "$shell_rc"
        echo "export PATH=\"\$PATH:$install_dir/flutter/bin\"" >> "$shell_rc"
        print_success "Flutter added to PATH in $shell_rc"
    fi
    
    # WSL specific setup
    if [ "$1" == "wsl" ]; then
        if ! grep -q "DISPLAY" "$shell_rc"; then
            echo '' >> "$shell_rc"
            echo '# WSL Display for Flutter' >> "$shell_rc"
            echo 'export DISPLAY=:0' >> "$shell_rc"
            print_warning "WSL detected. You'll need an X server (like VcXsrv) on Windows for GUI apps"
        fi
    fi
    
    # Export PATH for current session
    export PATH="$PATH:$install_dir/flutter/bin"
    
    print_success "Flutter installed successfully"
}

# Install Flutter on macOS
install_flutter_macos() {
    print_status "Installing Flutter for macOS..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install Flutter using Homebrew
    print_status "Installing Flutter via Homebrew..."
    brew install --cask flutter
    
    print_success "Flutter installed successfully"
}

# Configure Flutter
configure_flutter() {
    print_status "Configuring Flutter..."
    
    # Run Flutter doctor
    print_status "Running Flutter doctor..."
    flutter doctor
    
    # Enable web support
    print_status "Enabling web support..."
    flutter config --enable-web
    
    # Pre-download development binaries
    print_status "Pre-downloading development binaries..."
    flutter precache
    
    print_success "Flutter configuration complete"
}

# Install VS Code Flutter extension
install_vscode_extension() {
    if command -v code &> /dev/null; then
        print_status "Installing VS Code Flutter extension..."
        code --install-extension Dart-Code.flutter
        print_success "VS Code Flutter extension installed"
    else
        print_warning "VS Code not found. Install the Flutter extension manually if using VS Code"
    fi
}

# Main installation flow
main() {
    echo -e "${PURPLE}🚀 Flutter Installation Script for MDReader${NC}"
    echo "==========================================="
    
    # Check if already installed
    check_flutter_installed
    
    # Detect OS
    local os=$(detect_os)
    print_status "Detected OS: $os"
    
    case "$os" in
        "linux")
            install_linux_dependencies
            install_flutter_linux
            ;;
        "wsl")
            install_linux_dependencies
            install_flutter_linux "wsl"
            ;;
        "macos")
            install_flutter_macos
            ;;
        *)
            print_error "Unsupported operating system: $OSTYPE"
            print_error "Please install Flutter manually: https://docs.flutter.dev/get-started/install"
            exit 1
            ;;
    esac
    
    # Configure Flutter
    configure_flutter
    
    # Install VS Code extension
    install_vscode_extension
    
    # Final instructions
    echo ""
    print_success "Flutter installation complete! 🎉"
    echo ""
    print_status "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.bashrc"
    echo "  2. Verify installation: flutter doctor"
    echo "  3. Start MDReader: ./scripts/start.sh full"
    echo ""
    
    if [ "$os" == "wsl" ]; then
        print_warning "WSL Users: Remember to:"
        echo "  - Install an X server on Windows (VcXsrv or X410)"
        echo "  - Start the X server before running Flutter GUI apps"
        echo "  - Or use 'flutter run -d web' for web development"
    fi
}

# Run main function
main "$@"