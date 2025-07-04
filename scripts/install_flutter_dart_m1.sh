#!/bin/bash

# Flutter and Dart Installation Script for Mac M1
# Optimized for Apple Silicon (M1/M2) processors

set -e

echo "🚀 Starting Flutter and Dart installation for Mac M1..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if running on Apple Silicon
if [[ $(uname -m) != "arm64" ]]; then
    print_error "This script is optimized for Apple Silicon (M1/M2). Your system is $(uname -m)"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    print_status "Homebrew installed successfully"
else
    print_status "Homebrew is already installed"
fi

# Update Homebrew
print_info "Updating Homebrew..."
brew update

# Install Git if not present
if ! command -v git &> /dev/null; then
    print_info "Installing Git..."
    brew install git
    print_status "Git installed successfully"
else
    print_status "Git is already installed"
fi

# Install Flutter using Homebrew
print_info "Installing Flutter..."
brew install --cask flutter

# Set Flutter path
FLUTTER_PATH="/opt/homebrew/Caskroom/flutter/stable/flutter"
if [[ ! -d "$FLUTTER_PATH" ]]; then
    # Find the actual Flutter installation path
    FLUTTER_PATH=$(find /opt/homebrew/Caskroom/flutter -name "flutter" -type d | head -1)
fi

# Add Flutter to PATH
echo "# Flutter" >> ~/.zshrc
echo "export PATH=\"$FLUTTER_PATH/bin:\$PATH\"" >> ~/.zshrc

# Also add to current session
export PATH="$FLUTTER_PATH/bin:$PATH"

print_status "Flutter installed successfully"

# Install Dart (usually comes with Flutter, but let's ensure it's available)
print_info "Installing Dart SDK..."
brew tap dart-lang/dart
brew install dart

print_status "Dart SDK installed successfully"

# Install additional dependencies for iOS development
print_info "Installing iOS development dependencies..."
brew install --cask xcode
brew install cocoapods

print_status "iOS development dependencies installed"

# Install Android development dependencies
print_info "Installing Android development dependencies..."
brew install --cask android-studio
brew install --cask android-platform-tools

print_status "Android development dependencies installed"

# Configure Flutter for optimal performance on M1
print_info "Configuring Flutter for Apple Silicon..."

# Enable desktop support
flutter config --enable-macos-desktop
flutter config --enable-web

# Configure analytics (optional)
flutter config --no-analytics

print_status "Flutter configured for Apple Silicon"

# Run Flutter doctor to check installation
print_info "Running Flutter doctor to verify installation..."
flutter doctor

# Create a simple test to verify everything works
print_info "Creating a test Flutter app to verify installation..."
cd /tmp
flutter create flutter_test_app --platforms=ios,android,macos,web
cd flutter_test_app

print_info "Testing Flutter build for macOS..."
flutter build macos --release

print_status "Flutter installation completed successfully!"

echo ""
echo "🎉 Installation Summary:"
echo "   • Flutter: $(flutter --version | head -1)"
echo "   • Dart: $(dart --version)"
echo "   • Location: $FLUTTER_PATH"
echo ""
echo "📋 Next Steps:"
echo "   1. Restart your terminal or run: source ~/.zshrc"
echo "   2. Run 'flutter doctor' to verify installation"
echo "   3. Set up your IDE with Flutter plugins"
echo "   4. For iOS development: Install Xcode from App Store"
echo "   5. For Android development: Configure Android Studio"
echo ""
echo "💡 Useful Commands:"
echo "   • flutter doctor -v    : Detailed system check"
echo "   • flutter create app   : Create new Flutter app"
echo "   • flutter run          : Run app on connected device"
echo "   • flutter build ios    : Build for iOS"
echo "   • flutter build android: Build for Android"
echo ""

# Clean up test app
rm -rf /tmp/flutter_test_app

print_status "Setup complete! Happy coding! 🚀"