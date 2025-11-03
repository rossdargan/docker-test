#!/bin/bash

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

# Check if Docker is installed
if command -v docker &> /dev/null; then
    print_info "Docker is already installed"
    docker --version
else
    print_info "Docker is not installed. Installing Docker..."
    
    # Update package index
    print_info "Updating package index..."
    apt-get update
    
    # Install required packages
    print_info "Installing prerequisites..."
    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    print_info "Adding Docker GPG key..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    print_info "Setting up Docker repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    apt-get update
    
    # Install Docker Engine
    print_info "Installing Docker Engine..."
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    print_info "Docker installed successfully!"
    docker --version
fi

# Check if Docker Compose is available
if docker compose version &> /dev/null; then
    print_info "Docker Compose is available"
    docker compose version
else
    print_error "Docker Compose plugin is not available"
    exit 1
fi

# URL or path to your docker-compose file
# Modify this to point to your actual docker-compose file
COMPOSE_URL="https://raw.githubusercontent.com/rossdargan/docker-test/refs/heads/main/docker-compose.yml"
COMPOSE_FILE="docker-compose.yml"

# Download docker-compose file
print_info "Downloading docker-compose file from: $COMPOSE_URL"
if curl -fsSL "$COMPOSE_URL" -o "$COMPOSE_FILE"; then
    print_info "Docker-compose file downloaded successfully"
else
    print_error "Failed to download docker-compose file"
    exit 1
fi

# Verify the file was downloaded
if [ ! -f "$COMPOSE_FILE" ]; then
    print_error "Docker-compose file not found"
    exit 1
fi

# Run docker-compose
print_info "Starting Docker Compose..."
docker compose -f "$COMPOSE_FILE" up -d

print_info "Docker Compose is now running!"
print_info "You can check the status with: docker compose ps"
print_info "View logs with: docker compose logs -f"
print_info "Stop services with: docker compose down"
