#!/bin/bash

set -e

# Install ComfyUI
cd /app
if [ ! -f "/app/.download-complete" ] ; then
    chmod +x /scripts/install_comfyui.sh
    bash /scripts/install_comfyui.sh
else
    echo "Updating ComfyUI..."
    cd /app/ComfyUI
    git pull
    echo "Updating ComfyUI-Manager..."
    cd /app/ComfyUI/custom_nodes/ComfyUI-Manager
    git pull
    cd /app
fi ;

# Download models listed in download.txt
echo "########################################"
echo "[INFO] Downloading models..."
echo "########################################"
aria2c --input-file=/scripts/models.txt \
    --allow-overwrite=false --auto-file-renaming=false --continue=true \
    --max-connection-per-server=5 --conditional-get=true \
    --header="Authorization: Bearer ${HF_TOKEN}"

echo "########################################"
echo "[INFO] Starting ComfyUI..."
echo "########################################"

export PATH="${PATH}:/app/.local/bin"
export PYTHONPYCACHEPREFIX="/app/.cache/pycache"

cd /app

python3 ./ComfyUI/main.py --listen --port 8188 ${CLI_ARGS}