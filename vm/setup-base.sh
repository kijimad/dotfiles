#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${GREEN}=== Linux Mint Base Image Setup ===${NC}"

# Check for ISO file
ISO_FILE=$(ls linuxmint-*.iso 2>/dev/null | head -n 1)
if [ -z "$ISO_FILE" ]; then
    echo -e "${RED}Error: No Linux Mint ISO file found in $SCRIPT_DIR${NC}"
    echo "Please download Linux Mint ISO and place it in this directory:"
    echo "  cd $SCRIPT_DIR"
    echo "  wget https://mirrors.kernel.org/linuxmint/stable/21.3/linuxmint-21.3-cinnamon-64bit.iso"
    exit 1
fi

echo -e "${YELLOW}Found ISO: $ISO_FILE${NC}"

# Check if base image already exists
if [ -f "mint-base.qcow2" ]; then
    echo -e "${YELLOW}Warning: mint-base.qcow2 already exists${NC}"
    read -p "Do you want to recreate it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    rm -f mint-base.qcow2
fi

# Create base image
echo -e "${GREEN}Creating base image (30GB)...${NC}"
qemu-img create -f qcow2 mint-base.qcow2 30G

# Start installation VM
echo -e "${GREEN}Starting installation VM...${NC}"
echo -e "${YELLOW}Install Linux Mint and shutdown the VM when complete.${NC}"
echo ""

qemu-system-x86_64 \
  -enable-kvm \
  -m 8192 \
  -smp 4 \
  -cdrom "$ISO_FILE" \
  -hda mint-base.qcow2 \
  -boot d

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Make the base image read-only:"
echo "   chmod 444 mint-base.qcow2"
echo "2. Create a test VM:"
echo "   ./create-test-vm.sh"
