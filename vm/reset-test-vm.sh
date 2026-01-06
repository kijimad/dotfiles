#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${GREEN}=== Reset Test VM ===${NC}"

# Check if base image exists
if [ ! -f "mint-base.qcow2" ]; then
    echo -e "${RED}Error: mint-base.qcow2 not found${NC}"
    echo "Cannot reset without base image"
    exit 1
fi

# Confirm reset
if [ -f "mint-test.qcow2" ]; then
    echo -e "${YELLOW}This will delete mint-test.qcow2 and create a fresh copy${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Remove old test image
echo -e "${GREEN}Removing old test image...${NC}"
rm -f mint-test.qcow2

# Create new test image
echo -e "${GREEN}Creating fresh test image...${NC}"
qemu-img create -f qcow2 -F qcow2 -b mint-base.qcow2 mint-test.qcow2

echo -e "${GREEN}Test VM reset complete!${NC}"
echo -e "${YELLOW}Start the test VM with:${NC}"
echo "  ./start-test-vm.sh"
