FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /

# Upgrade apt packages and install required dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
      python3-dev \
      python3-pip \
      fonts-dejavu-core \
      rsync \
      git \
      jq \
      moreutils \
      aria2 \
      wget \
      curl \
      libglib2.0-0 \
      libsm6 \
      libgl1 \
      libxrender1 \
      libxext6 \
      ffmpeg \
      bc \
      libgoogle-perftools4 \
      libtcmalloc-minimal4 \
      procps && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Install Worker dependencies
RUN pip install requests runpod huggingface_hub

# Install Torch and xformers
RUN pip install --no-cache-dir torch==2.1.2+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
RUN pip install --no-cache-dir xformers==0.0.23.post1 --index-url https://download.pytorch.org/whl/cu118

# Add RunPod Handler and Docker container start script
COPY start.sh rp_handler.py ./
COPY schemas /schemas

RUN git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Start the container
RUN chmod +x /start.sh
ENTRYPOINT /start.sh
