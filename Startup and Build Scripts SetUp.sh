#!/bin/bash

# Development Environment Setup Script

set -e

echo "🔧 Setting up Market Data Service Development Environment..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose."
    exit 1
fi

# Create virtual environment
echo "🐍 Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Upgrade pip
echo "📦 Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "📚 Installing requirements..."
pip install -r requirements/dev.txt

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "⚠️  Please update the configuration in .env file, especially the ALPHA_VANTAGE_API_KEY"
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p logs
mkdir -p tests
mkdir -p docs
mkdir -p scripts

# Set up pre-commit hooks
echo "🪝 Setting up pre-commit hooks..."
pre-commit install

# Make scripts executable
chmod +x scripts/*.sh

echo ""
echo "✅ Development environment setup complete!"
echo ""
echo "📍 Next steps:"
echo "   1. Update your .env file with your Alpha Vantage API key"
echo "   2. Start the services: ./scripts/start.sh"
echo "   3. Run tests: pytest"
echo "   4. View API docs: http://localhost:8000/docs"
echo ""
echo "🔥 To activate the virtual environment:"
echo "   source venv/bin/activate"
echo ""
