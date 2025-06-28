#!/bin/bash

# MDReader Development Helper Script
# Usage: ./scripts/dev.sh [command] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

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

print_command() {
    echo -e "${PURPLE}[CMD]${NC} $1"
}

# Function to run tests
run_tests() {
    local test_type="${1:-all}"
    
    cd "$PROJECT_ROOT"
    
    print_status "Running tests: $test_type"
    
    case "$test_type" in
        "unit"|"u")
            print_command "flutter test test/ --coverage"
            flutter test test/ --coverage
            ;;
        "widget"|"w")
            print_command "flutter test test/widget_test.dart"
            flutter test test/widget_test.dart
            ;;
        "integration"|"i")
            print_command "flutter test integration_test/"
            flutter test integration_test/ || print_warning "No integration tests found"
            ;;
        "all"|"a"|"")
            print_command "flutter test --coverage"
            flutter test --coverage
            ;;
        *)
            print_error "Unknown test type: $test_type"
            print_status "Available types: unit, widget, integration, all"
            exit 1
            ;;
    esac
    
    print_success "Tests completed"
}

# Function to build the app
build_app() {
    local platform="${1:-android}"
    local mode="${2:-debug}"
    
    cd "$PROJECT_ROOT"
    
    print_status "Building for $platform in $mode mode"
    
    case "$platform" in
        "android"|"a")
            case "$mode" in
                "debug"|"d")
                    print_command "flutter build apk --debug"
                    flutter build apk --debug
                    ;;
                "profile"|"p")
                    print_command "flutter build apk --profile"
                    flutter build apk --profile
                    ;;
                "release"|"r")
                    print_command "flutter build apk --release"
                    flutter build apk --release
                    ;;
                *)
                    print_error "Unknown mode: $mode"
                    exit 1
                    ;;
            esac
            ;;
        "ios"|"i")
            case "$mode" in
                "debug"|"d")
                    print_command "flutter build ios --debug --no-codesign"
                    flutter build ios --debug --no-codesign
                    ;;
                "profile"|"p")
                    print_command "flutter build ios --profile --no-codesign"
                    flutter build ios --profile --no-codesign
                    ;;
                "release"|"r")
                    print_command "flutter build ios --release --no-codesign"
                    flutter build ios --release --no-codesign
                    ;;
                *)
                    print_error "Unknown mode: $mode"
                    exit 1
                    ;;
            esac
            ;;
        *)
            print_error "Unknown platform: $platform"
            print_status "Available platforms: android, ios"
            exit 1
            ;;
    esac
    
    print_success "Build completed"
}

# Function to analyze code
analyze_code() {
    cd "$PROJECT_ROOT"
    
    print_status "Running code analysis..."
    
    print_command "flutter analyze"
    flutter analyze
    
    print_success "Code analysis completed"
}

# Function to format code
format_code() {
    cd "$PROJECT_ROOT"
    
    print_status "Formatting code..."
    
    print_command "dart format lib/ test/ --set-exit-if-changed"
    dart format lib/ test/ --set-exit-if-changed || {
        print_warning "Code formatting applied"
        dart format lib/ test/
    }
    
    print_success "Code formatting completed"
}

# Function to check dependencies
check_deps() {
    cd "$PROJECT_ROOT"
    
    print_status "Checking dependencies..."
    
    print_command "flutter pub deps"
    flutter pub deps
    
    print_status "Checking for outdated packages..."
    print_command "flutter pub outdated"
    flutter pub outdated || true
    
    print_success "Dependency check completed"
}

# Function to generate documentation
generate_docs() {
    cd "$PROJECT_ROOT"
    
    print_status "Generating documentation..."
    
    if ! command -v dart &> /dev/null; then
        print_error "Dart SDK not found"
        exit 1
    fi
    
    print_command "dart doc"
    dart doc || {
        print_warning "dart doc not available, using flutter"
        print_command "flutter packages pub run dartdoc"
        flutter packages pub run dartdoc
    }
    
    print_success "Documentation generated in doc/api/"
}

# Function to clean project
clean_project() {
    local deep="${1:-false}"
    
    cd "$PROJECT_ROOT"
    
    print_status "Cleaning project..."
    
    print_command "flutter clean"
    flutter clean
    
    if [ "$deep" = "deep" ] || [ "$deep" = "true" ]; then
        print_status "Deep cleaning..."
        
        # Remove pub cache for this project
        rm -rf .dart_tool
        rm -rf .packages
        rm -rf pubspec.lock
        
        # Remove platform specific build files
        rm -rf ios/Pods
        rm -rf ios/.symlinks
        rm -rf ios/Flutter/Flutter.framework
        rm -rf ios/Flutter/Flutter.podspec
        
        rm -rf android/.gradle
        rm -rf android/app/build
        
        print_success "Deep clean completed"
    else
        print_success "Clean completed"
    fi
}

# Function to show project info
show_info() {
    cd "$PROJECT_ROOT"
    
    echo -e "${CYAN}📱 MDReader Project Information${NC}"
    echo "=================================="
    
    print_status "Project structure:"
    tree -L 2 -I 'build|.dart_tool|.git|node_modules' || {
        find . -maxdepth 2 -type d | grep -E '^./[^.]' | sort
    }
    
    echo ""
    print_status "Flutter information:"
    flutter --version
    
    echo ""
    print_status "Connected devices:"
    flutter devices
    
    echo ""
    print_status "Project dependencies:"
    grep -A 20 "dependencies:" pubspec.yaml
}

# Function to show help
show_help() {
    echo -e "${CYAN}🛠️  MDReader Development Helper${NC}"
    echo "================================="
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo -e "${YELLOW}Available Commands:${NC}"
    echo ""
    echo -e "${GREEN}Development:${NC}"
    echo "  start [quick|full]    Start the development server"
    echo "  stop [force|clean]    Stop the development server"
    echo "  restart [quick|full]  Restart the development server"
    echo ""
    echo -e "${GREEN}Testing:${NC}"
    echo "  test [unit|widget|integration|all]  Run tests"
    echo "  coverage                             Generate test coverage"
    echo ""
    echo -e "${GREEN}Building:${NC}"
    echo "  build [android|ios] [debug|profile|release]  Build the app"
    echo "  analyze                              Run code analysis"
    echo "  format                               Format code"
    echo ""
    echo -e "${GREEN}Maintenance:${NC}"
    echo "  clean [deep]          Clean build artifacts"
    echo "  deps                  Check dependencies"
    echo "  docs                  Generate documentation"
    echo "  info                  Show project information"
    echo ""
    echo -e "${GREEN}Utilities:${NC}"
    echo "  help, h               Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 start quick        # Quick start"
    echo "  $0 test unit          # Run unit tests"
    echo "  $0 build android release  # Build release APK"
    echo "  $0 clean deep         # Deep clean project"
    echo ""
}

# Function to restart development server
restart_dev() {
    local mode="${1:-quick}"
    
    print_status "Restarting development server..."
    
    # Stop first
    "$SCRIPTS_DIR/stop.sh" graceful
    
    # Wait a moment
    sleep 2
    
    # Start again
    "$SCRIPTS_DIR/start.sh" "$mode"
}

# Function to generate coverage report
generate_coverage() {
    cd "$PROJECT_ROOT"
    
    print_status "Generating test coverage..."
    
    print_command "flutter test --coverage"
    flutter test --coverage
    
    if command -v genhtml &> /dev/null; then
        print_status "Generating HTML coverage report..."
        genhtml coverage/lcov.info -o coverage/html
        print_success "Coverage report generated in coverage/html/"
    else
        print_warning "genhtml not found. Install lcov for HTML reports."
        print_success "Raw coverage data in coverage/lcov.info"
    fi
}

# Main script logic
main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        "start"|"s")
            "$SCRIPTS_DIR/start.sh" "$@"
            ;;
        "stop")
            "$SCRIPTS_DIR/stop.sh" "$@"
            ;;
        "restart"|"r")
            restart_dev "$@"
            ;;
        "test"|"t")
            run_tests "$@"
            ;;
        "coverage"|"cov")
            generate_coverage
            ;;
        "build"|"b")
            build_app "$@"
            ;;
        "analyze"|"a")
            analyze_code
            ;;
        "format"|"fmt")
            format_code
            ;;
        "clean"|"c")
            clean_project "$@"
            ;;
        "deps"|"d")
            check_deps
            ;;
        "docs")
            generate_docs
            ;;
        "info"|"i")
            show_info
            ;;
        "help"|"h"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
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