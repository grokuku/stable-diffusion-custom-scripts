#!/bin/bash
source /sl_folder.sh

export PATH="/home/abc/miniconda3/bin:$PATH"

# Set Variables and parameters

# Name of the custom WebUI (will be used for the program itself and the output directory)
export CustomNAME="sd-webui-forge"

# Name of the base folder for custom WebUIs
export CustomBASE="00-custom"

# Complete Path for the program files
export CustomPATH="/config/$CustomBASE/$CustomNAME"

# Parameters to pass at launch
export CustomPARAMETERS="--listen --port 9000 --enable-insecure-extension-access --xformers --api --medvram"

# Folders creation (Program files and output)
mkdir -p ${CustomPATH}
mkdir -p $BASE_DIR/outputs/$CustomBASE/$CustomNAME

# Creation and Activation on the Conda Virtual Env
if [ ! -d ${CustomPATH}/env ]; then
    conda create -p ${CustomPATH}/env -y
fi
source activate ${CustomPATH}/env
conda install -n base conda-libmamba-solver -y
conda install -c conda-forge git python=3.11 pip gcc gxx libcurand --solver=libmamba -y

# Clone/update program files
if [ ! -d ${CustomPATH}/$CustomNAME ]; then
    cd "${CustomPATH}" && git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git
fi

cd ${CustomPATH}/$CustomNAME
if [ -d "${CustomPATH}/$CustomNAME/webui/venv" ]; then
    # check if remote is ahead of local
    # https://stackoverflow.com/a/25109122/1469797
    if [ "$CLEAN_ENV" != "true" ] && [ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
    sed 's/\// /g') | cut -f1) ]; then
         echo "Local branch up-to-date, keeping existing venv"
      else
        if [ "$CLEAN_ENV" = "true" ]; then
          echo "Forced wiping venv for clean packages install"
        else
          echo "Remote branch is ahead. Wiping venv for clean packages install"
        fi
        rm -rf ${CustomPATH}/$CustomNAME/webui/venv
        git pull -X ours
    fi
fi

# Merge Models, vae, lora, and hypernetworks, and outputs
# Ignore move errors if they occur
sl_folder ${CustomPATH}/$CustomNAME/webui/models Stable-diffusion ${BASE_DIR}/models stable-diffusion
sl_folder ${CustomPATH}/$CustomNAME/webui/models hypernetworks ${BASE_DIR}/models hypernetwork
sl_folder ${CustomPATH}/$CustomNAME/webui/models Lora ${BASE_DIR}/models lora
sl_folder ${CustomPATH}/$CustomNAME/webui/models VAE ${BASE_DIR}/models vae
sl_folder ${CustomPATH}/$CustomNAME/webui embeddings ${BASE_DIR}/models embeddings
sl_folder ${CustomPATH}/$CustomNAME/webui/models ESRGAN ${BASE_DIR}/models upscale
sl_folder ${CustomPATH}/$CustomNAME/webui/models BLIP ${BASE_DIR}/models blip
sl_folder ${CustomPATH}/$CustomNAME/webui/models Codeformer ${BASE_DIR}/models codeformer
sl_folder ${CustomPATH}/$CustomNAME/webui/models GFPGAN ${BASE_DIR}/models gfpgan
sl_folder ${CustomPATH}/$CustomNAME/webui/models LDSR ${BASE_DIR}/models ldsr

sl_folder ${CustomPATH}/$CustomNAME/webui outputs ${BASE_DIR}/outputs/$CustomBASE $CustomNAME

cd ${CustomPATH}/$CustomNAME/webui
source venv/bin/activate
export PATH="${CustomPATH}/$CustomNAME/webui/venv/lib/python3.11/site-packages/onnxruntime/capi:$PATH"
pip install --upgrade pip

# Launch SD-WEBUI-FORGE
bash webui.sh ${CustomPARAMETERS}
