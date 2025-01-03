#!/bin/bash
#sleep infinity
source /functions.sh

export PATH="/home/abc/miniconda3/bin:$PATH"

# Set Variables and parameters

# Name of the custom WebUI (will be used for the program itself and the output directory)
export CustomNAME="TRELLIS"

# Name of the base folder for custom WebUIs
export CustomBASE="00-custom"

# Complete Path for the program files
export CustomPATH="/config/$CustomBASE/$CustomNAME"

# Parameters to pass at launch
export CustomPARAMETERS="--listen 0.0.0.0 --port 9000"

# Folders creation (Program files and output)
mkdir -p ${CustomPATH}
mkdir -p $BASE_DIR/outputs/$CustomBASE/$CustomNAME

#Clone Trellis
if [ ! -d ${CustomPATH}/TRELLIS ]; then
cd "${CustomPATH}" && git clone https://github.com/microsoft/TRELLIS --recurse
fi

# check if remote is ahead of local
cd ${CustomPATH}/TRELLIS
check_remote

#clean conda env
clean_env ${CustomPATH}/env

# Creation and Activation on the Conda Virtual Env
if [ ! -d ${CustomPATH}/env ]; then
    conda create -p ${CustomPATH}/env -y
fi
source activate ${CustomPATH}/env
conda install -n base conda-libmamba-solver -y
conda install -c conda-forge git python=3.11 pip --solver=libmamba -y
conda install -c nvidia cuda-cudart --solver=libmamba -y

cd ${CustomPATH}

pip install --upgrade pip

pip3 install torch torchvision torchaudio clang
pip install -U xformers --index-url https://download.pytorch.org/whl/cu124
pip install /wheels/*.whl
pip install plyfile \
			tqdm \
			spconv-cu124 \
			imageio \
			easydict \
			rembg \
			onnxruntime-gpu \
			xatlas \
			pyvista \
			gradio==4.44.1 \
			gradio_litmodel3d==0.0.1 \
			pymeshfix \
			igraph \
			safetensors \
   			sageattention \
			imageio==2.19.5 \
			imageio-ffmpeg==0.4.7
pip install git+https://github.com/EasternJournalist/utils3d.git@9a4eb15e4021b67b12c460c7057d642626897ec8

#run webui
export GRADIO_SERVER_NAME="0.0.0.0"
export GRADIO_SERVER_PORT=9000
cd ${CustomPATH}/TRELLIS
python3 app.py
sleep infinity
