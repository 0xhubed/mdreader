#!/bin/bash

# MDReader Start Script
# Usage: ./scripts/start.sh [quick|full|help]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

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

# Check for existing Flutter installation in nutriLens project
FLUTTER_PATH_NUTRILENS="/home/hubed/projects/nutriLens/flutter/bin"
if [ -d "$FLUTTER_PATH_NUTRILENS" ] && [ -f "$FLUTTER_PATH_NUTRILENS/flutter" ]; then
    export PATH="$PATH:$FLUTTER_PATH_NUTRILENS"
    print_status "Using Flutter from nutriLens project"
fi

# Function to check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        print_error "Please install Flutter: https://docs.flutter.dev/get-started/install"
        exit 1
    fi
    
    print_status "Flutter version:"
    flutter --version
}

# Function to check for connected devices
check_devices() {
    print_status "Checking for connected devices..."
    DEVICES=$(flutter devices --machine 2>/dev/null | jq -r '.[].id' 2>/dev/null || flutter devices | grep -E "^[a-zA-Z0-9]" | wc -l)
    
    if [ "$DEVICES" = "0" ] || [ -z "$DEVICES" ]; then
        print_warning "No devices connected"
        print_warning "Please connect a device or start an emulator"
        flutter devices
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Exiting..."
            exit 1
        fi
    else
        print_success "Connected devices found"
        flutter devices
    fi
}

# Function to clean and get dependencies
full_setup() {
    print_status "Performing full setup..."
    
    print_status "Cleaning previous builds..."
    flutter clean
    
    print_status "Getting dependencies..."
    flutter pub get
    
    print_status "Running code generation (if any)..."
    # flutter packages pub run build_runner build --delete-conflicting-outputs || true
    
    print_success "Full setup completed"
}

# Function to quick setup
quick_setup() {
    print_status "Performing quick setup..."
    
    print_status "Getting dependencies..."
    flutter pub get
    
    print_success "Quick setup completed"
}

# Function to run the app
run_app() {
    local mode="$1"
    
    print_status "Starting MDReader in $mode mode..."
    
    if [ "$mode" = "debug" ]; then
        flutter run --debug
    elif [ "$mode" = "profile" ]; then
        flutter run --profile
    elif [ "$mode" = "release" ]; then
        flutter run --release
    else
        flutter run
    fi
}

# Function to show help
show_help() {
    echo "MDReader Start Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  quick, q      Quick start (pub get + run)"
    echo "  full, f       Full start (clean + pub get + run)"
    echo "  debug, d      Start in debug mode (default)"
    echo "  profile, p    Start in profile mode"
    echo "  release, r    Start in release mode"
    echo "  help, h       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0            # Quick start in debug mode"
    echo "  $0 quick      # Quick start in debug mode"
    echo "  $0 full       # Full rebuild and start"
    echo "  $0 profile    # Quick start in profile mode"
    echo "  $0 release    # Quick start in release mode"
    echo ""
}

# Main script logic
main() {
    local option="${1:-quick}"
    local mode="debug"
    
    echo "🚀 MDReader Development Server"
    echo "================================"
    
    case "$option" in
        "quick"|"q"|"")
            check_flutter
            check_devices
            quick_setup
            run_app "$mode"
            ;;
        "full"|"f")
            check_flutter
            check_devices
            full_setup
            run_app "$mode"
            ;;
        "debug"|"d")
            check_flutter
            check_devices
            quick_setup
            run_app "debug"
            ;;
        "profile"|"p")
            check_flutter
            check_devices
            quick_setup
            run_app "profile"
            ;;
        "release"|"r")
            check_flutter
            check_devices
            quick_setup
            run_app "release"
            ;;
        "help"|"h"|"-h"|"--help")
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $option"
            show_help
            exit 1
            ;;
    esac
}

# Handle script interruption
cleanup() {
    print_warning "Script interrupted"
    exit 1
}

trap cleanup SIGINT SIGTERM

# Run main function
main "$@"