#!/bin/bash

set -e

# Ensure correct permissions for /app directory
if [ ! -w "/app" ]; then
    echo "Warning: Cannot write to /app. Attempting to fix permissions..."
    sudo chown -R $(id -u):$(id -g) /app
fi

# Install or update ComfyUI
cd /app
if [ ! -d "/app/ComfyUI" ]; then
    echo "ComfyUI not found. Installing..."
    chmod +x /scripts/install_comfyui.sh
    bash /scripts/install_comfyui.sh
else
    echo "Updating ComfyUI..."
    cd /app/ComfyUI
    git fetch origin master
    git reset --hard origin/master
    uv pip install -r requirements.txt
    echo "Updating ComfyUI-Manager..."
    cd /app/ComfyUI/custom_nodes/ComfyUI-Manager
    git fetch origin main
    git reset --hard origin/main
    uv pip install -r requirements.txt
    cd /app
fi

# Determine model list file based on LOW_VRAM
if [ "$LOW_VRAM" == "true" ]; then
    echo "[INFO] LOW_VRAM is set to true. Downloading FP8 models..."
    MODEL_LIST_FILE="/scripts/models_fp8.txt"
else
    echo "[INFO] LOW_VRAM is not set or false. Downloading non-FP8 models..."
    MODEL_LIST_FILE="/scripts/models.txt"
fi

# Create temporary file for model list
TEMP_MODEL_LIST=$(mktemp)

# Filter models based on MODELS_DOWNLOAD if set
if [ -n "${MODELS_DOWNLOAD}" ]; then
    echo "[INFO] Filtering models based on MODELS_DOWNLOAD=${MODELS_DOWNLOAD}"

    # Convert to lowercase for case-insensitive matching
    MODELS_DOWNLOAD_LC=$(echo "$MODELS_DOWNLOAD" | tr '[:upper:]' '[:lower:]')

    if [ "$LOW_VRAM" == "true" ]; then
        # For FP8 models, only copy the specified model sections
        if [[ "$MODELS_DOWNLOAD_LC" == *"schnell"* ]]; then
            sed -n '/# FLUX.1\[schnell\] FP8/,/^$/p' "$MODEL_LIST_FILE" >> "$TEMP_MODEL_LIST"
        fi
        if [[ "$MODELS_DOWNLOAD_LC" == *"dev"* ]]; then
            sed -n '/# FLUX.1\[dev\] FP8/,/^$/p' "$MODEL_LIST_FILE" >> "$TEMP_MODEL_LIST"
        fi
    else
        # For full models, copy dependencies first
        sed -n '/# Flux Text Encoders/,/# VAE/p' "$MODEL_LIST_FILE" >> "$TEMP_MODEL_LIST"
        sed -n '/# Loras/,/^$/p' "$MODEL_LIST_FILE" >> "$TEMP_MODEL_LIST"

        # Then add requested models and their VAE
        if [[ "$MODELS_DOWNLOAD_LC" == *"schnell"* ]]; then
            sed -n '/# FLUX.1\[schnell\] UNet/,/^$/p' "$MODEL_LIST_FILE" >> "$TEMP_MODEL_LIST"
            sed -n '/# VAE/,/# Loras/p' "$MODEL_LIST_FILE" >> "$TEMP_MODEL_LIST"
        fi
        if [[ "$MODELS_DOWNLOAD_LC" == *"dev"* ]]; then
            sed -n '/# FLUX.1\[dev\] UNet/,/^$/p' "$MODEL_LIST_FILE" >> "$TEMP_MODEL_LIST"
            sed -n '/# VAE/,/# Loras/p' "$MODEL_LIST_FILE" >> "$TEMP_MODEL_LIST"
        fi
    fi

    # If the temp file is empty (invalid MODELS_DOWNLOAD value), use the full list
    if [ ! -s "$TEMP_MODEL_LIST" ]; then
        echo "[WARN] No models matched MODELS_DOWNLOAD value. Using complete model list."
        cp "$MODEL_LIST_FILE" "$TEMP_MODEL_LIST"
    fi
else
    # If MODELS_DOWNLOAD not set, use the complete list
    cp "$MODEL_LIST_FILE" "$TEMP_MODEL_LIST"
fi

# Download models
echo "########################################"
echo "[INFO] Downloading models..."
echo "########################################"

if [ -z "${HF_TOKEN}" ]; then
    echo "[WARN] HF_TOKEN not provided. Skipping models that require authentication..."
    sed '/# Requires HF_TOKEN/,/^$/d' "$TEMP_MODEL_LIST" > /scripts/models_filtered.txt
    DOWNLOAD_LIST_FILE="/scripts/models_filtered.txt"
else
    DOWNLOAD_LIST_FILE="$TEMP_MODEL_LIST"
fi

aria2c --input-file="$DOWNLOAD_LIST_FILE" \
    --allow-overwrite=false --auto-file-renaming=false --continue=true \
    --max-connection-per-server=5 --conditional-get=true \
    ${HF_TOKEN:+--header="Authorization: Bearer ${HF_TOKEN}"}

# Cleanup
rm -f "$TEMP_MODEL_LIST"

echo "########################################"
echo "[INFO] Starting ComfyUI..."
echo "########################################"

export PATH="${PATH}:/app/.local/bin"
export PYTHONPYCACHEPREFIX="/app/.cache/pycache"

cd /app

python3 ./ComfyUI/main.py --listen --port 8188 ${CLI_ARGS}
