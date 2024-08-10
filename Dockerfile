FROM python:3.11-slim-bookworm

# Install git and aria2c
RUN apt-get update \
    && apt-get install -y git \
    build-essential \
    gcc \
    g++ \
    aria2 \
    libgl1 \
    libglib2.0-0 \
    fonts-dejavu-core \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install torch, torchvision, torchaudio and xformers
RUN pip install --no-cache-dir --break-system-packages \
    torch \
    torchvision \
    torchaudio \
    xformers \
    --index-url https://download.pytorch.org/whl/cu121

# Install onnxruntime-gpu
RUN pip uninstall --break-system-packages --yes \
    onnxruntime-gpu \
    && pip install --no-cache-dir --break-system-packages \
    onnxruntime-gpu \
    --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/

# Install dependencies for ComfyUI and ComfyUI-Manager
RUN pip install --no-cache-dir --break-system-packages \
    -r https://raw.githubusercontent.com/comfyanonymous/ComfyUI/master/requirements.txt \
    -r https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main/requirements.txt

# Create a low-privilege user
RUN useradd -m -d /app runner \
    && mkdir -p /scripts \
    && chown runner:runner /app /scripts
COPY --chown=runner:runner scripts/. /scripts/

# Add runner to sudoers
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner

USER runner:runner
VOLUME /app
WORKDIR /app
EXPOSE 8188
ENV CLI_ARGS=""
CMD ["bash","/scripts/entrypoint.sh"]