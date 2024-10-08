# ComfyUI Flux

ComfyUI Flux is a Docker-based setup for running [ComfyUI](https://github.com/comfyanonymous/ComfyUI) with [FLUX.1](https://www.basedlabs.ai/tools/flux1) models and additional features.

## Features

- Dockerized ComfyUI environment
- Automatic installation of ComfyUI and ComfyUI-Manager
- Pre-configured with FLUX models and VAEs
- Easy model management and updates
- GPU support with CUDA 12.1

## Prerequisites

- Docker and Docker Compose
- NVIDIA GPU with CUDA support (for GPU acceleration)
- (Optional) Huggingface account and token (for downloading FLUX.1[dev] models)

## Quick Start

1. (Optional) Create a `.env` file in the project root and add your Huggingface token:
   ```
   HF_TOKEN=your_huggingface_token
   ```

2. Download the `docker-compose.yml` file:
   ```
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
       deploy:
         resources:
           reservations:
             devices:
               - driver: nvidia
                 device_ids: ['0']
                 capabilities: [gpu]
   ```

3. Run the container using Docker Compose:
   ```
   docker-compose up -d
   ```

   Note: The first time you run the container, it will download all the included models before starting up. This process may take some time depending on your internet connection.

4. Access ComfyUI in your browser at `http://localhost:8188`

## Model Files

Overview of the model files that will be automatically downloaded when using this container. Some model files require an `HF_TOKEN` for download.

| Type | Model File Name | Size | Notes |
|-------------|-------------------------------|---------|-------------------------------------------------|
| Checkpoint | flux1-dev-fp8.safetensors | 17 GiB | downloaded if `HF_TOKEN` is provided |
| Checkpoint | flux1-schnell-fp8.safetensors | 17 GiB | |
| CLIP | clip_l.safetensors | 235 MiB | |
| CLIP | t5xxl_fp16.safetensors | 9.2 GiB | |
| CLIP | t5xxl_fp8_e4m3fn.safetensors | 4.6 GiB | |
| LoRA | flux_realism_lora.safetensors | 22 MiB | |
| UNet | flux1-dev.safetensors | 23 GiB | downloaded if `HF_TOKEN` is provided |
| UNet | flux1-schnell.safetensors | 23 GiB | |
| VAE | ae.safetensors | 320 MiB | |
---

## Workflows

Drag the images below into ComfyUI to load the corresponding workflows.

| FLUX.1[schnell] | FLUX.1[dev] |
|-----------------|-------------|
| <div align="center">![Flux Schnell](./images/flux-schnell.png)<br>[Download](https://raw.githubusercontent.com/frefrik/comfyui-flux/refs/heads/main/images/flux-schnell.png)</div> | <div align="center">![Flux Dev](./images/flux-dev.png)<br>[Download](https://raw.githubusercontent.com/frefrik/comfyui-flux/refs/heads/main/images/flux-dev.png)</div> |

## Configuration

- Models are automatically downloaded during container startup. You can modify the `scripts/models.txt` file to add or remove models.
- The `data` directory is mounted as a volume for persistent storage of input files.

## Updating

The ComfyUI and ComfyUI-Manager are automatically updated when the container starts. To update the base image and other dependencies, pull the latest version of the Docker image using:

```
docker-compose pull
```
