#!/bin/bash

echo "########################################"
echo "[INFO] Downloading ComfyUI & Manager..."
echo "########################################"

set -euxo pipefail

# ComfyUI
cd /app
git clone --recurse-submodules \
    https://github.com/comfyanonymous/ComfyUI.git \
    || (cd /app/ComfyUI && git pull)

# ComfyUI Manager
cd /app/ComfyUI/custom_nodes
git clone --recurse-submodules \
    https://github.com/ltdrdata/ComfyUI-Manager.git \
    || (cd /app/ComfyUI/custom_nodes/ComfyUI-Manager && git pull)

# Copy workflows
WORKFLOWS_DIR="/app/ComfyUI/user/default/workflows"
mkdir -p "$WORKFLOWS_DIR"

if [ -d "/workflows" ]; then
    cp -R /workflows/* "$WORKFLOWS_DIR/"
    echo "[INFO] Workflows copied successfully."
else
    echo "[WARNING] /workflows directory not found. Skipping workflow copy."
fi

# Finish
touch /app/.download-complete