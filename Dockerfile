FROM python:3.11-slim-bookworm

# Install git and aria2c
RUN apt-get update \
    && apt-get install -y git aria2 \
    && rm -rf /var/lib/apt/lists/*

# Install torch, torchvision, and torchaudio
RUN pip install \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121 \
    --extra-index-url https://pypi.org/simple \
    --break-system-packages

# Install dependencies for ComfyUI and ComfyUI-Manager
RUN pip install \
    -r https://raw.githubusercontent.com/comfyanonymous/ComfyUI/master/requirements.txt \
    -r https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main/requirements.txt \
    --break-system-packages \
    && pip cache purge

# Create a low-privilege user
RUN useradd -m -d /app runner \
    && mkdir -p /scripts \
    && chown runner:runner /app /scripts
COPY --chown=runner:runner scripts/. /scripts/

USER runner:runner
VOLUME /app
WORKDIR /app
EXPOSE 8188
ENV CLI_ARGS=""
CMD ["bash","/scripts/entrypoint.sh"]