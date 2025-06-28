#!/bin/bash

# Setup Flutter PATH for MDReader using existing Flutter installation

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flutter installation path from nutriLens project
FLUTTER_PATH="/home/hubed/projects/nutriLens/flutter/bin"

# Check if Flutter exists at that path
if [ -d "$FLUTTER_PATH" ]; then
    echo -e "${BLUE}[INFO]${NC} Found existing Flutter installation at: $FLUTTER_PATH"
    
    # Export for current session
    export PATH="$PATH:$FLUTTER_PATH"
    
    # Show Flutter version
    flutter --version
    
    echo -e "${GREEN}[SUCCESS]${NC} Flutter is ready to use!"
    echo ""
    echo "To make this permanent, add this line to your ~/.bashrc or ~/.zshrc:"
    echo "export PATH=\"\$PATH:$FLUTTER_PATH\""
    echo ""
    echo "Or run: echo 'export PATH=\"\$PATH:$FLUTTER_PATH\"' >> ~/.bashrc"
else
    echo -e "${RED}[ERROR]${NC} Flutter not found at $FLUTTER_PATH"
    echo "Please check the path or run: ./scripts/install-flutter.sh"
fi