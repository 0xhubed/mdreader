import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:google_fonts/google_fonts.dart';

class SyntaxHighlighter extends StatelessWidget {
  final String code;
  final String? language;
  final bool isDarkMode;
  final double fontSize;

  const SyntaxHighlighter({
    super.key,
    required this.code,
    this.language,
    required this.isDarkMode,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = isDarkMode ? vs2015Theme : githubTheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme['root']?.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HighlightView(
          code,
          language: language ?? 'text',
          theme: theme,
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: fontSize * 0.9,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class SupportedLanguages {
  static const Map<String, String> languages = {
    'dart': 'dart',
    'javascript': 'javascript',
    'js': 'javascript',
    'typescript': 'typescript',
    'ts': 'typescript',
    'python': 'python',
    'py': 'python',
    'java': 'java',
    'kotlin': 'kotlin',
    'swift': 'swift',
    'cpp': 'cpp',
    'c++': 'cpp',
    'c': 'c',
    'csharp': 'csharp',
    'c#': 'csharp',
    'php': 'php',
    'ruby': 'ruby',
    'go': 'go',
    'rust': 'rust',
    'scala': 'scala',
    'shell': 'shell',
    'bash': 'bash',
    'sh': 'bash',
    'powershell': 'powershell',
    'sql': 'sql',
    'html': 'xml',
    'xml': 'xml',
    'css': 'css',
    'scss': 'scss',
    'sass': 'scss',
    'less': 'less',
    'json': 'json',
    'yaml': 'yaml',
    'yml': 'yaml',
    'dockerfile': 'dockerfile',
    'markdown': 'markdown',
    'md': 'markdown',
    'latex': 'latex',
    'tex': 'latex',
    'r': 'r',
    'matlab': 'matlab',
    'perl': 'perl',
    'lua': 'lua',
    'haskell': 'haskell',
    'elixir': 'elixir',
    'erlang': 'erlang',
    'clojure': 'clojure',
    'vim': 'vim',
    'makefile': 'makefile',
    'cmake': 'cmake',
    'gradle': 'gradle',
    'properties': 'properties',
    'ini': 'ini',
    'toml': 'toml',
    'protobuf': 'protobuf',
    'graphql': 'graphql',
    'nginx': 'nginx',
    'apache': 'apache',
  };

  static String normalizeLanguage(String? lang) {
    if (lang == null || lang.isEmpty) return 'text';
    
    final normalized = lang.toLowerCase().trim();
    return languages[normalized] ?? normalized;
  }
}