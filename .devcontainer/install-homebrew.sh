#!/bin/bash

# Script to install Homebrew on Linux
# This script installs Homebrew (formerly Linuxbrew) on Linux systems

set -e

echo "🍺 Installing Homebrew on Linux..."

# Check if Homebrew is already installed
if command -v brew &> /dev/null; then
    echo "✓ Homebrew is already installed"
    exit 0
fi

# Update package manager
echo "📦 Updating package manager..."
if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y build-essential curl file git procps
elif command -v yum &> /dev/null; then
    yum groupinstall -y "Development Tools"
    yum install -y curl file git procps-ng
elif command -v dnf &> /dev/null; then
    dnf groupinstall -y "Development Tools"
    dnf install -y curl file git procps-ng
elif command -v pacman &> /dev/null; then
    pacman -Sy --noconfirm base-devel curl file git procps-ng
else
    echo "❌ Unsupported package manager. Please install dependencies manually."
    exit 1
fi

# Install Homebrew
echo "🔧 Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Setup Homebrew in PATH
echo "🔗 Setting up Homebrew in PATH..."
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
fi

echo "✓ Homebrew installation completed!"
echo "💡 Run 'eval \$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' to use Homebrew in the current shell"
