# 📝 MDReader

A privacy-first, offline Markdown reader built with Flutter - born from real-world AI development needs. 

**The Story:** Working extensively with generative AI tools, I constantly create markdown specifications, documentation, and prompts, but Android lacked a quality markdown reader for efficient mobile review. MDReader solves this friction point while serving as the foundation for future mobile control of agentic AI tools.

🌐 **Live Demo:** [mdreader.app](https://mdreader-website-oxuu3itht-0xhubeds-projects-c85e7463.vercel.app)  
📱 **Try It:** [Google Play Internal Test](https://play.google.com/apps/internaltest/4701751354738741902)

## ✨ Features

- **🔒 Privacy by Design**: Zero data collection, no internet access required
- **📱 Beautiful Typography**: Optimized reading experience with excellent fonts
- **🌙 Theme Support**: Light and dark modes with system theme detection
- **📂 File Support**: Open `.md`, `.markdown`, and `.txt` files
- **⚙️ Customizable**: Adjustable font sizes and theme preferences
- **📄 Standards Compliant**: Supports common markdown syntax

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd mdreader
```

2. Quick start with development scripts:
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Full setup and start (recommended for first time)
./scripts/start.sh full

# Or quick start for daily development
./scripts/start.sh
```

3. Manual installation (alternative):
```bash
flutter pub get
flutter run
```

### Building for Release

#### Using Development Scripts (Recommended)
```bash
# Android release build
./scripts/dev.sh build android release

# iOS release build  
./scripts/dev.sh build ios release

# Debug builds for testing
./scripts/dev.sh build android debug
```

#### Manual Building (Alternative)
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🧪 Testing

#### Using Development Scripts (Recommended)
```bash
# Run all tests
./scripts/dev.sh test

# Run specific test types
./scripts/dev.sh test unit
./scripts/dev.sh test widget

# Generate coverage report
./scripts/dev.sh coverage
```

#### Manual Testing (Alternative)
```bash
# All tests
flutter test

# Specific test file
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── document.dart         # Document model
│   └── app_settings.dart     # Settings model
├── services/                 # Business logic
│   ├── file_service.dart     # File operations
│   └── settings_service.dart # Settings persistence
├── providers/                # State management
│   ├── document_provider.dart # Document state
│   └── theme_provider.dart    # Theme state
├── screens/                  # UI screens
│   ├── home_screen.dart      # Home/welcome screen
│   └── reader_screen.dart    # Markdown reader
├── widgets/                  # Reusable widgets
│   └── markdown_viewer.dart  # Markdown renderer
└── utils/                    # Utilities
    ├── constants.dart        # App constants
    └── theme_data.dart       # Theme definitions
```

## 🎨 Design Principles

- **Typography First**: Exceptional readability with proper font hierarchy
- **Minimal Interface**: Focus on content, not chrome
- **Privacy Focused**: No network permissions, local storage only
- **Accessible**: Support for different font sizes and themes

## 📱 Supported Platforms

- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 11.0+

## 🔧 Configuration

### Android

The app requires storage permission to access local files. No internet permission is included by design.

### iOS

Document types are configured to support markdown files. The app can be set as a default reader for `.md` files.

## 🚫 Privacy

MDReader is designed with privacy as the core principle:

- **No Network Access**: App works completely offline
- **No Analytics**: Zero tracking or telemetry
- **Local Storage Only**: Settings stored locally on device
- **File Access**: On-demand only through system file picker

## 📄 Supported Markdown Features

- Headings (H1-H6)
- Paragraphs and line breaks
- **Bold** and *italic* text
- Lists (ordered and unordered)
- `Code blocks` and inline code
- Links (display only - no navigation)
- Images (local files only)

## 🔮 Future Vision

**Immediate Enhancements:** See `FEATURE_ENHANCEMENT_PLAN.md` for planned features including table support, search functionality, recent files, table of contents, and export capabilities.

**Long-term Vision:** This app serves as the foundation for mobile control of agentic AI tools running on workstations, creating a unified development ecosystem that maximizes efficiency across devices. The goal is seamless integration between mobile markdown review and desktop AI tool orchestration.

## 🤝 Contributing

This project follows the implementation plan in `MVP_PLAN.md`. Contributions should maintain the privacy-first philosophy and focus on the reading experience.

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🛠️ Technical Stack & AI Development

**Core Technologies:**
- Built with Flutter 3.x and Dart 3.x
- Uses Provider for state management  
- Google Fonts for typography
- SharedPreferences for settings storage
- File picker for local file access

**AI-Assisted Development:**
- Leveraged Claude AI and GitHub Copilot for rapid Flutter adoption
- Demonstrates cross-platform development from C#/C++ background
- Full-stack implementation from UI/UX to Firebase integration

The app showcases rapid technology adoption using modern AI tools while maintaining privacy-first principles and delivering an excellent markdown reading experience.

## 🚀 Development Scripts

MDReader includes powerful development scripts to streamline your workflow:

### Quick Commands
```bash
# Start development server
./scripts/start.sh              # Quick start
./scripts/start.sh full         # Full rebuild start

# Stop development server  
./scripts/stop.sh               # Graceful stop
./scripts/stop.sh force         # Force stop

# Development helper
./scripts/dev.sh start          # Start server
./scripts/dev.sh test           # Run tests
./scripts/dev.sh build android  # Build for Android
./scripts/dev.sh clean          # Clean project
```

### Complete Development Workflow
```bash
# 1. Start development
./scripts/start.sh full

# 2. Run tests while developing
./scripts/dev.sh test unit

# 3. Check code quality
./scripts/dev.sh analyze
./scripts/dev.sh format

# 4. Build for release
./scripts/dev.sh build android release

# 5. Stop development server
./scripts/stop.sh
```

See `scripts/README.md` for detailed documentation of all available commands and options.