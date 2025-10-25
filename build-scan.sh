#!/bin/bash

set -euo pipefail

# Check dependencies
for cmd in podman osv-scanner; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: $cmd is not installed." >&2
    exit 1
  fi
done

# Check if podman machine is running
if ! podman info &> /dev/null; then
  echo "Podman machine is not running. Starting it now..."
  podman machine start
  echo "Podman machine started."
fi

echo "Building container image..."
podman build . -t "localhost/novnc:latest"

echo "Saving container image to novnc.tar..."
podman save --format=docker-archive "localhost/novnc:latest" > novnc.tar

echo "Scanning image with OSV-Scanner..."
osv-scanner scan image --format html --archive novnc.tar > osv-scan.html

echo "Scan complete. Report saved to osv-scan.html"