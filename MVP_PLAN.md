# 📝 MDReader MVP Plan

## 🎯 MVP Scope
A minimal viable product focused on core functionality: opening and beautifully displaying local Markdown files with exceptional typography and privacy.

## 🚀 MVP Goals
- **Primary**: Read local `.md` files with excellent typography
- **Secondary**: Basic theming (light/dark)
- **Constraint**: Zero network access, zero data collection

## 🏗️ MVP Architecture

### Core Components (MVP Only)
- **File Picker**: Select and open local `.md` files
- **Markdown Renderer**: Display markdown with beautiful typography
- **Theme Manager**: Light/dark theme switching
- **Settings**: Basic preferences (theme, font size)

### MVP Tech Stack
```yaml
dependencies:
  flutter_markdown: ^0.6.18
  file_picker: ^6.1.1
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  google_fonts: ^6.1.0
```

## 📱 MVP UI Design

### Simplified Layout
```
┌─────────────────────────────┐
│ MDReader            [🌙]    │ ← Simple Header
├─────────────────────────────┤
│                             │
│     Markdown Content        │ ← Main Focus
│     (Beautiful Typography)  │
│                             │
│                             │
├─────────────────────────────┤
│ [📂 Open File]              │ ← Bottom Action
└─────────────────────────────┘
```

### MVP Color Scheme
```dart
// Light Theme
primary: #2563eb
background: #ffffff
text: #1e293b
surface: #f8fafc

// Dark Theme  
primary: #60a5fa
background: #0f172a
text: #f1f5f9
surface: #1e293b
```

## 🗂️ MVP Project Structure

```
lib/
├── main.dart
├── models/
│   ├── document.dart
│   └── app_settings.dart
├── services/
│   ├── file_service.dart
│   └── settings_service.dart
├── providers/
│   ├── document_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── home_screen.dart
│   └── reader_screen.dart
├── widgets/
│   ├── markdown_viewer.dart
│   └── theme_toggle.dart
└── utils/
    ├── constants.dart
    └── theme_data.dart
```

## 🔧 MVP Features

### 1. Essential File Handling
```dart
✅ Open .md files via file picker
✅ Display file content
✅ Basic error handling
❌ Recent files (enhancement)
❌ File validation (enhancement)
```

### 2. Core Markdown Support
```dart
✅ Headings (H1-H6)
✅ Paragraphs and line breaks
✅ Bold and italic text
✅ Lists (ordered/unordered)
✅ Code blocks and inline code
✅ Links
✅ Images (local only)
❌ Tables (enhancement)
❌ Task lists (enhancement)
❌ Syntax highlighting (enhancement)
```

### 3. Basic Theming
```dart
✅ Light theme
✅ Dark theme
✅ Theme persistence
✅ Basic typography scaling
❌ Custom themes (enhancement)
❌ Reading mode (enhancement)
```

### 4. Essential Settings
```dart
✅ Theme selection
✅ Font size (3 options: small, medium, large)
❌ Font family selection (enhancement)
❌ Advanced typography (enhancement)
```

## 📋 MVP Development Timeline (4 Weeks)

### Week 1: Foundation
- [ ] Flutter project setup
- [ ] Basic file picker integration
- [ ] Simple markdown rendering
- [ ] Basic navigation between home and reader

### Week 2: Core Functionality
- [ ] Enhanced markdown support (headings, lists, code)
- [ ] Basic light/dark theme implementation
- [ ] Settings screen with theme toggle
- [ ] Font size controls

### Week 3: Polish & Typography
- [ ] Typography optimization
- [ ] Responsive layout
- [ ] Error handling for file operations
- [ ] Settings persistence

### Week 4: Testing & Finalization
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] Bug fixes
- [ ] MVP release preparation

## 🎨 MVP Design Specifications

### Typography (Simplified)
- **Font Family**: System default (San Francisco/Roboto)
- **Font Sizes**: 
  - Small: 14px
  - Medium: 16px (default)
  - Large: 18px
- **Line Height**: 1.6
- **Heading Scale**: 2.0, 1.5, 1.25, 1.125, 1.0, 0.875

### Spacing (Minimal)
- **Content Padding**: 16px
- **Element Spacing**: 16px
- **Section Breaks**: 24px

## 🔒 MVP Privacy Implementation

### Core Privacy Features
- **No Network Permission**: Completely offline
- **Local Storage Only**: SharedPreferences for settings
- **No Analytics**: Zero tracking
- **File Access**: On-demand only

### Security (Basic)
- **File Type Validation**: .md, .markdown, .txt only
- **Memory Management**: Basic large file handling
- **Error Boundaries**: Graceful failures

## 📱 MVP Platform Support

### Android (Primary)
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 33 (Android 13)
- **Permissions**: Storage access only

### iOS (Secondary)
- **Min Version**: iOS 11
- **Document Picker**: Native integration

## 🧪 MVP Testing Strategy

### Essential Tests
- [ ] File picker functionality
- [ ] Markdown rendering accuracy
- [ ] Theme switching
- [ ] Settings persistence
- [ ] Basic error scenarios

### Testing Tools
```yaml
dev_dependencies:
  flutter_test: any
  integration_test: any
```

## 📊 MVP Success Criteria

### Functionality
- [ ] Can open and display any standard markdown file
- [ ] Smooth theme switching
- [ ] Settings persist between sessions
- [ ] No crashes with reasonable file sizes (<5MB)

### Performance
- [ ] App launch < 3 seconds
- [ ] File opening < 2 seconds for typical files
- [ ] Smooth scrolling on target devices

### User Experience
- [ ] Intuitive file opening flow
- [ ] Readable typography in both themes
- [ ] Responsive to different screen sizes

## 🚫 MVP Exclusions

### Features NOT in MVP
- Table of contents / navigation
- Search functionality
- Recent files list
- Export capabilities
- Custom themes beyond light/dark
- Advanced typography controls
- Table rendering
- Math/LaTeX support
- Multiple file tabs
- Bookmarks or reading position
- Advanced markdown extensions

### Technical Debt Acceptable in MVP
- Basic error messages (not user-friendly)
- Limited file size handling
- Basic theme implementation
- Minimal settings screen
- No performance optimization for very large files

## 🔄 MVP to Enhancement Transition

### Data Collection for Future Features
- Track which markdown features are most used
- Monitor performance with different file sizes
- Note user feedback on typography and themes

### Architecture Decisions for Extensibility
- Provider pattern for easy feature addition
- Modular service architecture
- Clean separation of UI and business logic

---

## 📝 MVP Development Notes

**Focus**: Get the core experience right - beautiful markdown reading with privacy
**Quality over Features**: Better to have fewer features that work perfectly
**User Feedback**: Early user testing to validate core assumptions
**Performance**: Ensure smooth experience on mid-range devices

The MVP should feel complete and polished within its limited scope, providing a solid foundation for future enhancements.