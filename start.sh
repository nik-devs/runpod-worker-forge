#!/usr/bin/env bash

echo "Worker Initiated"

echo "Symlinking files from Network Volume"
rm -rf /workspace && \
  ln -s /runpod-volume /workspace

mkdir -p /workspace/logs
touch /workspace/logs/webui.log

if [ ! -d "/workspace/stable-diffusion-webui" ]; then
    cp -r /stable-diffusion-webui /workspace/
fi

export LD_PRELOAD="${TCMALLOC}"
export PYTHONUNBUFFERED=true
export HF_HOME="/workspace"
python3 /workspace/stable-diffusion-webui/webui.py \
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
  --no-download-sd-model > /workspace/logs/webui.log 2>&1 &

echo "Starting RunPod Handler"
python3 -u /rp_handler.py
