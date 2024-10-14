# ComfyUI Flux

ComfyUI Flux is a Docker-based setup for running [ComfyUI](https://github.com/comfyanonymous/ComfyUI) with [FLUX.1](https://www.basedlabs.ai/tools/flux1) models and additional features.

## Features

- Dockerized ComfyUI environment
- Automatic installation of ComfyUI and ComfyUI-Manager
- **Low VRAM Mode**: Download and use FP8 models for reduced VRAM usage
- Pre-configured with FLUX models and VAEs
- Easy model management and updates
- GPU support with CUDA 12.1

## Prerequisites

- Docker and Docker Compose
- NVIDIA GPU with CUDA support (for GPU acceleration)
- (Optional) Huggingface account and token (for downloading FLUX.1[dev] official model)

## Quick Start

1. (Optional) Create a `.env` file in the project root and add your Huggingface token:

   ```bash
   HF_TOKEN=your_huggingface_token
   LOW_VRAM=false  # Set to true to enable low VRAM mode
   ```

2. Download the `docker-compose.yml` file:

   ```bash
   wget https://raw.githubusercontent.com/frefrik/comfyui-flux/main/docker-compose.yml
   ```

   Alternatively, you can create a `docker-compose.yml` file and copy/paste the following contents:

   ```yaml
   services:
     comfyui:
       container_name: comfyui
       image: frefrik/comfyui-flux:latest
       restart: unless-stopped
       ports:
         - "8188:8188"
       volumes:
         - "./data:/app"
       environment:
         - CLI_ARGS=
         - HF_TOKEN=${HF_TOKEN}
         - LOW_VRAM=${LOW_VRAM:-false}
       deploy:
         resources:
           reservations:
             devices:
               - driver: nvidia
                 device_ids: ['0']
                 capabilities: [gpu]
   ```

3. Run the container using Docker Compose:

   ```bash
   docker-compose up -d
   ```

   **Note:** The first time you run the container, it will download all the included models before starting up. This process may take some time depending on your internet connection.

4. Access ComfyUI in your browser at `http://localhost:8188`

## Low VRAM Mode

By setting the `LOW_VRAM` environment variable to `true`, the container will download and use the FP8 models, which are optimized for lower VRAM usage. The FP8 versions have CLIP and VAE merged, so only the checkpoint files are needed.

Enable Low VRAM Mode:

```bash
LOW_VRAM=true
```

## Model Files

Overview of the model files that will be automatically downloaded when using this container. Some model files require an `HF_TOKEN` for download.

### When `LOW_VRAM=false` (default)

| Type | Model File Name | Size | Notes |
|-------------|-------------------------------|---------|-------------------------------------------------|
| UNet | flux1-schnell.safetensors | 23 GiB | |
| UNet | flux1-dev.safetensors | 23 GiB | requires `HF_TOKEN` for download |
| CLIP | clip_l.safetensors | 235 MiB | |
| CLIP | t5xxl_fp16.safetensors | 9.2 GiB | |
| CLIP | t5xxl_fp8_e4m3fn.safetensors | 4.6 GiB | |
| LoRA | flux_realism_lora.safetensors | 22 MiB | |
| VAE | ae.safetensors | 320 MiB | |

### When `LOW_VRAM=true`

| Type | Model File Name | Size | Notes |
|-------------|-------------------------------|---------|-------------------------------------------------|
| Checkpoint | flux1-dev-fp8.safetensors | 17 GiB | |
| Checkpoint | flux1-schnell-fp8.safetensors | 17 GiB | |

## Workflows

Download the images below and drag them into ComfyUI to load the corresponding workflows.

### Official versions

| FLUX.1[schnell] | FLUX.1[dev] |
|-----------------|-------------|
| <div align="center">![Flux Schnell](./images/flux-schnell.png)<br>[Download](https://raw.githubusercontent.com/frefrik/comfyui-flux/refs/heads/main/images/flux-schnell.png)</div> | <div align="center">![Flux Dev](./images/flux-dev.png)<br>[Download](https://raw.githubusercontent.com/frefrik/comfyui-flux/refs/heads/main/images/flux-dev.png)</div> |

### FP8 versions (LOW_VRAM)

| FLUX.1[schnell] FP8 | FLUX.1[dev] FP8 |
|---------------------|-----------------|
| <div align="center">![Flux Schnell FP8](./images/flux-schnell-fp8.png)<br>[Download](https://raw.githubusercontent.com/frefrik/comfyui-flux/main/images/flux-schnell-fp8.png)</div> | <div align="center">![Flux Dev FP8](./images/flux-dev-fp8.png)<br>[Download](https://raw.githubusercontent.com/frefrik/comfyui-flux/main/images/flux-dev-fp8.png)</div> |

## Updating

The ComfyUI and ComfyUI-Manager are automatically updated when the container starts. To update the base image and other dependencies, pull the latest version of the Docker image using:

```bash
docker-compose pull
```

## Additional Notes

- **Switching Between Modes**: If you change the `LOW_VRAM` setting after the initial run, the container will automatically download the required models for the new setting upon restart.
- **Model Downloading**: The scripts are designed to skip downloading models that already exist, so you won't waste bandwidth re-downloading models you already have.
- **Huggingface Token**: The `HF_TOKEN` is only necessary for downloading the `flux1-dev.safetensors` model when `LOW_VRAM=false`.
