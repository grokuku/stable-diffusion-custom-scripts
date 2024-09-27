#!/bin/bash
source /sl_folder.sh

export PATH="/home/abc/miniconda3/bin:$PATH"

#Switch NGINX to PORT 9000
sudo cp /opt/sd-install/parameters/nginx.txt /etc/nginx/sites-enabled/default
sudo nginx -s reload

sudo apt-get update
sudo apt-get -y install openbox libxcb-cursor0 libxkbcommon-x11-0 libxcb-icccm4 libxcb-keysyms1

# Set Variables and parameters

# Name of the custom WebUI (will be used for the program itself and the output directory)
export CustomNAME="GPTSubTrans"

# Name of the base folder for custom WebUIs
export CustomBASE="00-custom"

# Complete Path for the program files
export CustomPATH="/config/$CustomBASE/$CustomNAME"

# Parameters to pass at launch
#export CustomPARAMETERS="--listen 0.0.0.0 --port 9000"

# Folders creation (Program files and output)
mkdir -p ${CustomPATH}

# Creation and Activation on the Conda Virtual Env
if [ ! -d ${CustomPATH}/env ]; then
    conda create -p ${CustomPATH}/env -y
fi
source activate ${CustomPATH}/env
conda install -n base conda-libmamba-solver -y
conda install -c conda-forge git python=3.10 pip --solver=libmamba -y
pip install flask openai google.generativeai anthropic
pip install pyxDG
#conda install -c nvidia cuda-cudart --solver=libmamba -y

# Clone/update program files
if [ ! -d ${CustomPATH}/Fooocus-MRE ]; then
    cd "${CustomPATH}" && git clone https://github.com/machinewrapped/gpt-subtrans.git
fi
cd ${CustomPATH}/gpt-subtrans
git pull -X ours

# installation of requirements
cd ${CustomPATH}/gpt-subtrans
pip install -r requirements.txt

# Launch
python scripts/gui-subtrans.py

sleep infinity
