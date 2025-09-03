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

# Install dependencies for ComfyUI and Manager
for req_file in "/app/ComfyUI/requirements.txt" "/app/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt"; do
    if [ -f "$req_file" ]; then
        echo "[INFO] Installing requirements from $req_file"
        uv pip install -r "$req_file" --retries 3 || echo "Warning: Some dependencies from $req_file may have failed to install"
    fi
done

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