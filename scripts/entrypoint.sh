#!/bin/bash

set -e

# Install ComfyUI
cd /app
if [ ! -f "/app/.download-complete" ] ; then
    chmod +x /scripts/install_comfyui.sh
    bash /scripts/install_comfyui.sh
fi ;

# Download models listed in download.txt
echo "########################################"
echo "[INFO] Downloading models..."
echo "########################################"
aria2c --input-file=/scripts/models.txt \
    --allow-overwrite=false --auto-file-renaming=false --continue=true \
    --max-connection-per-server=5 --conditional-get=true

echo "########################################"
echo "[INFO] Starting ComfyUI..."
echo "########################################"

export PATH="${PATH}:/app/.local/bin"
export PYTHONPYCACHEPREFIX="/app/.cache/pycache"

cd /app

python3 ./ComfyUI/main.py --listen --port 8188 ${CLI_ARGS}