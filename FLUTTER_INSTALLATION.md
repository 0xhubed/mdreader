# 🚀 Flutter Installation Guide for MDReader

This guide will help you install Flutter on your system to run the MDReader project.

## 📋 System Requirements

### Minimum Requirements
- **Disk Space**: 2.8 GB (does not include disk space for IDE/tools)
- **Tools**: Git, a code editor (VS Code, Android Studio, or IntelliJ)

### Operating System Specific
- **Windows**: Windows 10 or later (64-bit)
- **macOS**: macOS 10.15 (Catalina) or later
- **Linux**: 64-bit, Ubuntu 20.04 or later

## 🖥️ Installation Instructions

### Windows

#### Method 1: Using Chocolatey (Recommended)
```powershell
# Install Chocolatey if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Flutter
choco install flutter
```

#### Method 2: Manual Installation
1. Download Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. Extract to a location like `C:\src\flutter`
3. Add Flutter to PATH:
   ```powershell
   # Add to system PATH
   [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", [System.EnvironmentVariableTarget]::User)
   ```

### macOS

#### Method 1: Using Homebrew (Recommended)
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Flutter
brew install --cask flutter
```

#### Method 2: Manual Installation
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH in ~/.zshrc or ~/.bash_profile
echo 'export PATH="$PATH:~/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Linux (Ubuntu/Debian)

#### Method 1: Using Snap (Recommended)
```bash
# Install Flutter via Snap
sudo snap install flutter --classic

# Add to PATH
echo 'export PATH="$PATH:/snap/bin"' >> ~/.bashrc
source ~/.bashrc
```

#### Method 2: Manual Installation
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Download Flutter
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
echo 'export PATH="$PATH:~/development/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

### WSL (Windows Subsystem for Linux)

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Create development directory
mkdir -p ~/development
cd ~/development

# Download Flutter
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Important: For WSL, you'll need X11 forwarding for GUI
# Install X server on Windows (like VcXsrv or X410)
# Set display variable
echo 'export DISPLAY=:0' >> ~/.bashrc
```

## ✅ Post-Installation Setup

### 1. Verify Installation
```bash
# Check Flutter installation
flutter --version

# Run Flutter doctor to check dependencies
flutter doctor
```

### 2. Install Required Dependencies

#### Android Development (Optional but Recommended)
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Install Android Studio from https://developer.android.com/studio
# Or use command line tools only
```

#### iOS Development (macOS only)
```bash
# Install Xcode from App Store
# Install CocoaPods
sudo gem install cocoapods

# Install iOS tools
xcode-select --install
```

### 3. Configure Your Editor

#### VS Code
```bash
# Install Flutter extension
code --install-extension Dart-Code.flutter
```

#### Android Studio / IntelliJ
- Open IDE → Plugins → Search "Flutter" → Install

## 🚀 Quick Start with MDReader

Once Flutter is installed:

```bash
# Navigate to MDReader project
cd /path/to/mdreader

# Run the setup script
./scripts/start.sh full

# Or manually
flutter pub get
flutter run
```

## 🔧 Troubleshooting

### Common Issues

#### Flutter not found in PATH
```bash
# Linux/macOS
echo $PATH | grep flutter

# If not found, add to PATH again
export PATH="$PATH:$HOME/development/flutter/bin"
```

#### Android SDK not found
```bash
# Set Android SDK path
flutter config --android-sdk /path/to/android/sdk
```

#### Permission denied on Linux/macOS
```bash
# Fix permissions
chmod +x ~/development/flutter/bin/flutter
```

#### WSL specific issues
```bash
# If GUI doesn't work, use web target
flutter run -d web

# Or connect to Windows Android emulator
adb connect localhost:5555
```

### Verify Everything Works
```bash
# Full system check
flutter doctor -v

# Expected output should show:
# ✓ Flutter
# ✓ Android toolchain (if installed)
# ✓ Chrome (for web development)
# ✓ VS Code or Android Studio (if installed)
# ! Xcode (only on macOS)
```

## 📱 Setting Up Devices

### Android Emulator
```bash
# List available emulators
flutter emulators

# Create a new emulator (requires Android Studio)
flutter emulators --create --name my_emulator

# Launch emulator
flutter emulators --launch my_emulator
```

### Physical Device
1. Enable Developer Mode on your device
2. Enable USB Debugging
3. Connect device via USB
4. Verify connection:
   ```bash
   flutter devices
   ```

### Web Development
```bash
# Enable web support
flutter config --enable-web

# Run on Chrome
flutter run -d chrome
```

## 🎯 MDReader Specific Setup

After Flutter installation:

```bash
# Clone MDReader if not already done
git clone <repository-url>
cd mdreader

# Make scripts executable
chmod +x scripts/*.sh

# Run full setup
./scripts/start.sh full
```

## 📚 Additional Resources

- [Official Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)
- [Flutter Doctor Guide](https://docs.flutter.dev/development/tools/flutter-doctor)
- [VS Code Flutter Setup](https://docs.flutter.dev/development/tools/vs-code)
- [Android Studio Setup](https://docs.flutter.dev/development/tools/android-studio)

## 💡 Tips

1. **Use Flutter Version Management (FVM)** for multiple Flutter versions:
   ```bash
   dart pub global activate fvm
   fvm install stable
   fvm use stable
   ```

2. **Enable Flutter Web** for browser testing:
   ```bash
   flutter config --enable-web
   ```

3. **Speed up builds** with gradle daemon:
   ```bash
   cd android
   ./gradlew --daemon
   ```

4. **Use Flutter Inspector** for UI debugging

---

Once Flutter is installed, you can start developing MDReader immediately using the provided scripts! 🚀