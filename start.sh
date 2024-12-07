#!/usr/bin/env bash

echo "Worker Initiated"

# Create workspace directory if it doesn't exist
if [ ! -d /workspace ]; then
    ln -s /runpod-volume /workspace
fi

# Create logs directory
if [ ! -d /workspace/logs ]; then
    mkdir -p /workspace/logs
fi

# Copy models to workspace if needed
if [ ! -d /workspace/models ]; then
    cp -r /stable-diffusion-webui-forge/models /workspace/
fi

# Create symlink for models directory
if [ -d /stable-diffusion-webui-forge/models ]; then
    rm -rf /stable-diffusion-webui-forge/models
fi
ln -s /workspace/models /stable-diffusion-webui-forge/models

echo "Starting WebUI API"
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"
export PYTHONUNBUFFERED=true
export HF_HOME="/root"

python3 /stable-diffusion-webui-forge/webui.py \
    --xformers \
    --no-half-vae \
    --skip-python-version-check \
    --skip-torch-cuda-test \
    --skip-install \
    --lowram \
    --opt-sdp-attention \
    --disable-safe-unpickle \
    --port 3000 \
    --api \
    --nowebui \
    --skip-version-check \
    --no-hashing \
    --no-download-sd-model > /workspace/logs/forge.log 2>&1 &

echo "Starting RunPod Handler"
python3 -u /rp_handler.py
