#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${GREEN}=== Create Test VM ===${NC}"

# Check if base image exists
if [ ! -f "mint-base.qcow2" ]; then
    echo -e "${RED}Error: mint-base.qcow2 not found${NC}"
    echo "Please run ./setup-base.sh first"
    exit 1
fi

# Check if test image already exists
if [ -f "mint-test.qcow2" ]; then
    echo -e "${YELLOW}Warning: mint-test.qcow2 already exists${NC}"
    read -p "Do you want to recreate it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    rm -f mint-test.qcow2
fi

# Create test image with backing file
echo -e "${GREEN}Creating test image with backing file...${NC}"
qemu-img create -f qcow2 -F qcow2 -b mint-base.qcow2 mint-test.qcow2

echo -e "${GREEN}Test VM created successfully!${NC}"
echo -e "${YELLOW}Start the test VM with:${NC}"
echo "  ./start-test-vm.sh"
