#!/bin/bash

MODULE_NAME="RKKDR"
MODULE_VERSION="1.0.0"
DKMS_SRC_DIR="/usr/src/${MODULE_NAME}-${MODULE_VERSION}"

echo "Installing ${MODULE_NAME} version ${MODULE_VERSION} to DKMS..."

# Copy files to /usr/src
sudo mkdir -p "${DKMS_SRC_DIR}"
sudo cp -r ./* "${DKMS_SRC_DIR}/"

# Add, build, and install via DKMS
sudo dkms add -m "${MODULE_NAME}" -v "${MODULE_VERSION}"
sudo dkms build -m "${MODULE_NAME}" -v "${MODULE_VERSION}"
sudo dkms install -m "${MODULE_NAME}" -v "${MODULE_VERSION}"

echo "DKMS installation complete! The module will now rebuild automatically on kernel updates."
