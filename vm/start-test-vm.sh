#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${GREEN}=== Starting Test VM ===${NC}"

# Check if test image exists
if [ ! -f "mint-test.qcow2" ]; then
    echo -e "${RED}Error: mint-test.qcow2 not found${NC}"
    echo "Please run ./create-test-vm.sh first"
    exit 1
fi

# Start test VM
qemu-system-x86_64 \
  -enable-kvm \
  -m 8192 \
  -smp 4 \
  -hda mint-test.qcow2 \
  -vga virtio \
  -display gtk \
  -net nic -net user
