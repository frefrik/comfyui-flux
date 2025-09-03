FROM python:3.12-slim-trixie

# Build arguments
ARG CUDA_VERSION=cu128

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    CLI_ARGS=""

# Copy UV binaries
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        build-essential \
        gcc \
        g++ \
        aria2 \
        libgl1 \
        libglib2.0-0 \
        fonts-dejavu-core \
        sudo \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Create application directories and user
RUN useradd -m -d /app -s /bin/bash runner && \
    mkdir -p /app /scripts /workflows /opt/venv && \
    chown -R runner:runner /app /scripts /workflows /opt/venv && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/runner && \
    chmod 0440 /etc/sudoers.d/runner

# Set working directory
WORKDIR /app

# Switch to non-root user
USER runner

# Create virtual environment
RUN uv venv /opt/venv

# Install torch, torchvision, torchaudio and xformers
RUN uv pip install --no-cache \
    torch \
    torchvision \
    torchaudio \
    xformers \
    --index-url https://download.pytorch.org/whl/${CUDA_VERSION}

# Install onnxruntime-gpu
RUN uv pip install --no-cache \
    onnxruntime-gpu \
    --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/

# Copy application files
COPY --chown=runner:runner scripts/. /scripts/
COPY --chown=runner:runner workflows/. /workflows/

VOLUME ["/app"]
EXPOSE 8188
CMD ["bash","/scripts/entrypoint.sh"]