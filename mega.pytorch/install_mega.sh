#!/bin/bash
set -e  # stop on error

echo "=== Creating Conda environment ==="
conda create --name MEGA -y python=3.7
source activate MEGA

echo "=== Installing dependencies ==="
conda install -y ipython pip
pip install ninja yacs cython matplotlib tqdm opencv-python scipy
conda install -y pytorch=1.2.0 torchvision=0.4.0 cudatoolkit=10.0 -c pytorch

export INSTALL_DIR=$PWD
echo "INSTALL_DIR set to $INSTALL_DIR"

echo "=== COCO API ==="
cd $INSTALL_DIR
git clone https://github.com/cocodataset/cocoapi.git
cd cocoapi/PythonAPI
python setup.py build_ext install

echo "=== Cityscapes Scripts ==="
cd $INSTALL_DIR
git clone https://github.com/mcordts/cityscapesScripts.git
cd cityscapesScripts
python setup.py build_ext install

echo "=== Installing Apex ==="
cd $INSTALL_DIR
git clone https://github.com/NVIDIA/apex.git
cd apex

# Fix APEX line 910 (parallel: int | None → parallel=None)
sed -i 's/parallel: int | None = None/parallel = None/' setup.py

python setup.py build_ext install || true  # allow failure

echo "=== Removing APEX (required fix) ==="
pip uninstall -y apex || true

echo "=== Installing MEGA ==="
cd $INSTALL_DIR
git clone https://github.com/Scalsol/mega.pytorch.git
cd mega.pytorch
python setup.py build develop

echo "=== Installing correct Pillow version ==="
pip install "pillow<7.0.0"

echo "=== Removing APEX usage from MEGA source ==="

# 1. Remove apex import from nms.py
sed -i 's/from apex import amp//g' mega_core/layers/nms.py
sed -i 's/nms = amp.float_function(_C.nms)/nms = _C.nms/' mega_core/layers/nms.py

# 2. Remove apex decorators and import from roi_align.py
sed -i 's/from apex import amp//g' mega_core/layers/roi_align.py
sed -i 's/@amp.float_function//g' mega_core/layers/roi_align.py

# 3. Remove apex decorators and import from roi_pool.py
sed -i 's/from apex import amp//g' mega_core/layers/roi_pool.py
sed -i 's/@amp.float_function//g' mega_core/layers/roi_pool.py

echo "=== Fixing OpenCV putText crash (convert coords to int) ==="
sed -i 's/(x, y)/(int(x), int(y))/' demo/predictor.py

echo "=== Installation complete ==="
echo "You can now run BASE or MEGA demos:"
echo ""
echo "BASE:"
echo "python demo/demo.py base configs/vid_R_101_C4_1x.yaml R_101.pth --suffix \".JPEG\" --visualize-path image_folder --output-folder visualization --output-video"
echo ""
echo "MEGA:"
echo "python demo/demo.py mega configs/MEGA/vid_R_101_C4_MEGA_1x.yaml MEGA_R_101.pth --suffix \".JPEG\" --visualize-path image_folder --output-folder visualization_mega --output-video"
echo ""
