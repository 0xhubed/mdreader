# 🚀 MDReader Development Scripts

This directory contains development and build scripts for the MDReader project.

## 📋 Available Scripts

### 🔧 Development Scripts

#### `start.sh` - Development Server
Start the Flutter development server with hot reload.

```bash
# Quick start (recommended for development)
./scripts/start.sh
./scripts/start.sh quick

# Full rebuild start (when dependencies change)
./scripts/start.sh full

# Start in different modes
./scripts/start.sh debug     # Debug mode (default)
./scripts/start.sh profile   # Profile mode (performance testing)
./scripts/start.sh release   # Release mode
```

**Features:**
- ✅ Checks Flutter installation
- ✅ Detects connected devices/emulators
- ✅ Manages dependencies
- ✅ Supports different build modes
- ✅ Colored output for better readability

#### `stop.sh` - Stop Development Server
Stop all Flutter processes and clean up.

```bash
# Graceful stop
./scripts/stop.sh

# Force stop all processes
./scripts/stop.sh force

# Stop and clean build artifacts
./scripts/stop.sh clean

# Stop only Gradle daemons
./scripts/stop.sh gradle

# Show running processes
./scripts/stop.sh status
```

**Features:**
- ✅ Graceful process termination
- ✅ Force kill when needed
- ✅ Gradle daemon management
- ✅ Build artifact cleanup
- ✅ Process status monitoring

#### `dev.sh` - Development Helper
Comprehensive development toolkit with all common tasks.

```bash
# Development server management
./scripts/dev.sh start [quick|full]
./scripts/dev.sh stop [force|clean]
./scripts/dev.sh restart [quick|full]

# Testing
./scripts/dev.sh test [unit|widget|integration|all]
./scripts/dev.sh coverage

# Building
./scripts/dev.sh build [android|ios] [debug|profile|release]

# Code quality
./scripts/dev.sh analyze
./scripts/dev.sh format

# Maintenance
./scripts/dev.sh clean [deep]
./scripts/dev.sh deps
./scripts/dev.sh docs
./scripts/dev.sh info
```

## 🎯 Quick Start Guide

### First Time Setup
```bash
# 1. Make scripts executable (if needed)
chmod +x scripts/*.sh

# 2. Full setup and start
./scripts/start.sh full
```

### Daily Development
```bash
# Start development server
./scripts/start.sh

# When done developing
./scripts/stop.sh
```

### Testing Workflow
```bash
# Run all tests
./scripts/dev.sh test

# Run specific test types
./scripts/dev.sh test unit
./scripts/dev.sh test widget

# Generate coverage report
./scripts/dev.sh coverage
```

### Build Workflow
```bash
# Debug build for testing
./scripts/dev.sh build android debug

# Release build for distribution
./scripts/dev.sh build android release
./scripts/dev.sh build ios release
```

## 🔍 Script Details

### Environment Checks
All scripts perform the following checks:
- ✅ Flutter SDK installation
- ✅ Connected devices/emulators
- ✅ Project dependencies
- ✅ Build environment

### Error Handling
- ✅ Graceful error messages
- ✅ Colored output for visibility
- ✅ Process cleanup on interruption
- ✅ Detailed logging

### Performance Features
- ✅ Quick vs full rebuild options
- ✅ Parallel dependency resolution
- ✅ Efficient process management
- ✅ Build artifact caching

## 🛠️ Customization

### Environment Variables
You can customize script behavior with environment variables:

```bash
# Skip device check
export SKIP_DEVICE_CHECK=true

# Custom Flutter command
export FLUTTER_CMD=fvm flutter

# Enable verbose logging
export VERBOSE=true
```

### Script Modification
The scripts are designed to be easily customizable:

1. **Colors**: Modify color constants at the top of each script
2. **Commands**: Add new commands in the main() function
3. **Checks**: Modify check functions for your environment
4. **Paths**: Update PROJECT_ROOT if needed

## 📱 Platform-Specific Notes

### Android
- Requires Android SDK and tools
- Gradle daemons are managed automatically
- APK builds go to `build/app/outputs/flutter-apk/`

### iOS
- Requires Xcode and iOS development setup
- Code signing handled separately
- Builds go to `build/ios/iphoneos/`

### Linux/macOS/Windows
- Scripts are bash-based (use Git Bash on Windows)
- All paths are handled cross-platform
- Color output works in most terminals

## 🚨 Troubleshooting

### Common Issues

**Flutter not found:**
```bash
# Check Flutter installation
flutter --version

# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

**No devices found:**
```bash
# Check connected devices
flutter devices

# Start an emulator
flutter emulators --launch <emulator_name>
```

**Gradle issues:**
```bash
# Clean Gradle
./scripts/stop.sh gradle
./scripts/dev.sh clean deep
```

**Dependency conflicts:**
```bash
# Full clean and rebuild
./scripts/stop.sh clean
./scripts/start.sh full
```

### Getting Help
```bash
# Show help for any script
./scripts/start.sh help
./scripts/stop.sh help
./scripts/dev.sh help
```

## 📚 Examples

### Complete Development Session
```bash
# Start development
./scripts/start.sh quick

# In another terminal - run tests while developing
./scripts/dev.sh test unit

# Format code before committing
./scripts/dev.sh format

# Analyze code quality
./scripts/dev.sh analyze

# Build release when ready
./scripts/dev.sh build android release

# Stop development server
./scripts/stop.sh
```

### CI/CD Pipeline Usage
```bash
# Clean build for CI
./scripts/dev.sh clean deep
./scripts/start.sh full

# Run full test suite
./scripts/dev.sh test all
./scripts/dev.sh coverage

# Build for multiple platforms
./scripts/dev.sh build android release
./scripts/dev.sh build ios release

# Cleanup
./scripts/stop.sh clean
```

---

These scripts are designed to make MDReader development fast, efficient, and enjoyable! 🎉