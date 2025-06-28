#!/bin/bash

# MDReader Stop Script
# Usage: ./scripts/stop.sh [force]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Function to find Flutter processes
find_flutter_processes() {
    print_status "Looking for Flutter processes..."
    
    # Find flutter run processes
    FLUTTER_PIDS=$(pgrep -f "flutter.*run" 2>/dev/null || true)
    
    # Find dart processes related to MDReader
    DART_PIDS=$(pgrep -f "dart.*mdreader" 2>/dev/null || true)
    
    # Find gradle daemon processes (Android builds)
    GRADLE_PIDS=$(pgrep -f "gradle.*daemon" 2>/dev/null || true)
    
    ALL_PIDS="$FLUTTER_PIDS $DART_PIDS"
    
    if [ -n "$ALL_PIDS" ]; then
        echo "Found processes: $ALL_PIDS"
        return 0
    else
        return 1
    fi
}

# Function to stop Flutter processes gracefully
stop_gracefully() {
    print_status "Attempting graceful shutdown..."
    
    if find_flutter_processes; then
        for pid in $ALL_PIDS; do
            if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
                print_status "Sending SIGTERM to process $pid"
                kill -TERM "$pid" 2>/dev/null || true
            fi
        done
        
        # Wait a bit for graceful shutdown
        sleep 3
        
        # Check if processes are still running
        local remaining=0
        for pid in $ALL_PIDS; do
            if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
                remaining=$((remaining + 1))
            fi
        done
        
        if [ $remaining -eq 0 ]; then
            print_success "All Flutter processes stopped gracefully"
            return 0
        else
            print_warning "$remaining processes still running"
            return 1
        fi
    else
        print_success "No Flutter processes found"
        return 0
    fi
}

# Function to force stop processes
stop_forcefully() {
    print_warning "Force stopping Flutter processes..."
    
    if find_flutter_processes; then
        for pid in $ALL_PIDS; do
            if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
                print_status "Force killing process $pid"
                kill -KILL "$pid" 2>/dev/null || true
            fi
        done
        
        sleep 1
        
        # Check if any processes are still running
        local remaining=0
        for pid in $ALL_PIDS; do
            if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
                remaining=$((remaining + 1))
            fi
        done
        
        if [ $remaining -eq 0 ]; then
            print_success "All processes force stopped"
        else
            print_error "$remaining processes could not be stopped"
        fi
    fi
}

# Function to stop Gradle daemons
stop_gradle_daemons() {
    print_status "Stopping Gradle daemons..."
    
    if command -v gradle &> /dev/null; then
        gradle --stop &> /dev/null || true
        print_success "Gradle daemons stopped"
    else
        if [ -n "$GRADLE_PIDS" ]; then
            for pid in $GRADLE_PIDS; do
                if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
                    print_status "Stopping Gradle daemon process $pid"
                    kill -TERM "$pid" 2>/dev/null || true
                fi
            done
        fi
    fi
}

# Function to clean up build artifacts
cleanup_build_artifacts() {
    local project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    
    print_status "Cleaning up build artifacts..."
    
    cd "$project_root"
    
    # Remove build directories
    if [ -d "build" ]; then
        rm -rf build
        print_status "Removed build directory"
    fi
    
    # Remove iOS build
    if [ -d "ios/build" ]; then
        rm -rf ios/build
        print_status "Removed iOS build directory"
    fi
    
    # Remove Android build
    if [ -d "android/build" ]; then
        rm -rf android/build
        print_status "Removed Android build directory"
    fi
    
    # Remove .dart_tool
    if [ -d ".dart_tool" ]; then
        rm -rf .dart_tool
        print_status "Removed .dart_tool directory"
    fi
    
    print_success "Build artifacts cleaned up"
}

# Function to show running processes
show_processes() {
    print_status "Current Flutter/Dart processes:"
    
    echo "Flutter processes:"
    pgrep -f "flutter" -l 2>/dev/null || echo "  None found"
    
    echo ""
    echo "Dart processes:"
    pgrep -f "dart" -l 2>/dev/null || echo "  None found"
    
    echo ""
    echo "Gradle processes:"
    pgrep -f "gradle" -l 2>/dev/null || echo "  None found"
}

# Function to show help
show_help() {
    echo "MDReader Stop Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  (no option)   Graceful stop of Flutter processes"
    echo "  force, f      Force stop all Flutter/Dart processes"
    echo "  clean, c      Stop processes and clean build artifacts"
    echo "  gradle, g     Stop Gradle daemons only"
    echo "  status, s     Show running processes"
    echo "  help, h       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0            # Graceful stop"
    echo "  $0 force      # Force stop all processes"
    echo "  $0 clean      # Stop and clean build artifacts"
    echo "  $0 status     # Show running processes"
    echo ""
}

# Main script logic
main() {
    local option="${1:-graceful}"
    
    echo "🛑 MDReader Stop Script"
    echo "======================="
    
    case "$option" in
        ""|"graceful"|"g")
            if ! stop_gracefully; then
                print_warning "Graceful stop failed, trying force stop..."
                stop_forcefully
            fi
            ;;
        "force"|"f")
            stop_forcefully
            ;;
        "clean"|"c")
            if ! stop_gracefully; then
                stop_forcefully
            fi
            stop_gradle_daemons
            cleanup_build_artifacts
            ;;
        "gradle")
            stop_gradle_daemons
            ;;
        "status"|"s")
            show_processes
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
    
    print_success "Stop script completed"
}

# Handle script interruption
cleanup() {
    print_warning "Script interrupted"
    exit 1
}

trap cleanup SIGINT SIGTERM

# Run main function
main "$@"