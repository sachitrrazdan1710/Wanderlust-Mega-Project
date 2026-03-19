#!/bin/bash

set -e

echo "🚀 Starting installation..."

# ----------------------------
# 1. Check Docker
# ----------------------------
if ! command -v docker &>/dev/null; then
  echo "❌ Docker not found. Please install Docker Desktop first."
  exit 1
else
  echo "✅ Docker is already installed."
fi

# ----------------------------
# 2. Install KIND
# ----------------------------
if ! command -v kind &>/dev/null; then
  echo "📦 Installing Kind..."

  ARCH=$(uname -m)

  if [ "$ARCH" = "x86_64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-arm64
  else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
  fi

  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind

  echo "✅ Kind installed successfully."
else
  echo "✅ Kind is already installed."
fi

# ----------------------------
# 3. Install kubectl
# ----------------------------
if ! command -v kubectl &>/dev/null; then
  echo "📦 Installing kubectl..."

  ARCH=$(uname -m)
  VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)

  if [ "$ARCH" = "x86_64" ]; then
    curl -Lo ./kubectl "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    curl -Lo ./kubectl "https://dl.k8s.io/release/${VERSION}/bin/linux/arm64/kubectl"
  else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
  fi

  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/kubectl

  echo "✅ kubectl installed successfully."
else
  echo "✅ kubectl is already installed."
fi

# ----------------------------
# 4. Verify Installation
# ----------------------------
echo
echo "🔍 Installed Versions:"
docker --version
kind version
kubectl version --client=true

echo
echo "🎉 Docker, Kind, and kubectl installation complete!"
