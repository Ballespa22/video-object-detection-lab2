===========================================
VIDEO OBJECT DETECTION – LAB 2 (README)
===========================================

Author: TU NOMBRE  
Course: Deep Learning for Video Signal Processing  
Tested on: Ubuntu 18.04 (class PC), RTX 2080 Ti (CUDA 12.5)

------------------------------------------------------------
1. OVERVIEW
------------------------------------------------------------

This project reproduces the BASE and MEGA approaches from the CVPR-2020 paper:

"Memory Enhanced Global-Local Aggregation for Video Object Detection"

GitHub source used:  
https://github.com/Scalsol/mega.pytorch

The objective of this repository is to:
- Provide a fully working setup of MEGA and BASE.
- Document all problems and fixes encountered.
- Allow anyone to reproduce the demo from scratch.

The demo was successfully executed on the university machine using a Python 3.7 / PyTorch 1.2 environment.

------------------------------------------------------------
2. REQUIREMENTS
------------------------------------------------------------

• Linux environment (Ubuntu recommended)  
• NVIDIA GPU + drivers  
• Conda  
• Python 3.7  
• PyTorch 1.2.0  
• Torchvision 0.4.0  
• CUDA toolkit 10.0  
• Git  

Note:  
Newer PyTorch versions (>=1.3) cause errors with MEGA.  
APEX breaks and requires manual patches.

------------------------------------------------------------
3. INSTALLATION (FULL STEPS)
------------------------------------------------------------

1) Create environment
---------------------
conda create --name MEGA -y python=3.7  
conda activate MEGA  
conda install ipython pip -y  

2) Install dependencies
-----------------------
pip install ninja yacs cython matplotlib tqdm opencv-python scipy  

3) Install PyTorch (IMPORTANT: version 1.2)
-------------------------------------------
conda install pytorch=1.2.0 torchvision=0.4.0 cudatoolkit=10.0 -c pytorch  

4) Install COCO API
-------------------
export INSTALL_DIR=$PWD  
cd $INSTALL_DIR  
git clone https://github.com/cocodataset/cocoapi.git  
cd cocoapi/PythonAPI  
python setup.py build_ext install  
cd $INSTALL_DIR  

5) Install cityscapesScripts
----------------------------
git clone https://github.com/mcordts/cityscapesScripts.git  
cd cityscapesScripts  
python setup.py build_ext install  
cd $INSTALL_DIR  

6) Install APEX (and patch it)
------------------------------
git clone https://github.com/NVIDIA/apex.git  
cd apex  
python setup.py build_ext install  

If you get this error:
TypeError: unsupported operand type(s) for |: 'type' and 'NoneType'

Then edit apex/setup.py  
Change line ~910:
    parallel: int | None = None  
to:
    parallel = None

7) If APEX later fails with:
----------------------------
AttributeError: module 'torch' has no attribute 'library'

Then uninstall:
pip uninstall -y apex

And apply the patches listed in section 4.

8) Install MEGA
---------------
cd $INSTALL_DIR  
git clone https://github.com/Scalsol/mega.pytorch.git  
cd mega.pytorch  
python setup.py build develop  
pip install 'pillow<7.0.0'  

unset INSTALL_DIR  

------------------------------------------------------------
4. REQUIRED CODE FIXES
------------------------------------------------------------

A) mega_core/layers/nms.py
--------------------------
Replace header with:

from mega_core import _C

try:
    from apex import amp
    nms = amp.float_function(_C.nms)
except ImportError:
    nms = _C.nms

B) Remove APEX references in these files:
-----------------------------------------
mega_core/layers/roi_align.py  
mega_core/layers/roi_pool.py  

Delete:
from apex import amp  
Delete all:  
@amp.float_function

C) Fix OpenCV putText crash
---------------------------
If you get:
cv2.error: Can't parse 'org'. Sequence item with index 0 has a wrong type

Modify demo/predictor.py:

Replace:
cv2.putText(image, s, (x, y), ...)

With:
cv2.putText(image, s, (int(x), int(y)), ...)

------------------------------------------------------------
5. MODEL CHECKPOINTS
------------------------------------------------------------

Do NOT upload these to GitHub (too large).

Download from Moodle:
• R_101.pth  
• MEGA_R_101.pth  

Place them in:
mega.pytorch/R_101.pth  
mega.pytorch/MEGA_R_101.pth  

------------------------------------------------------------
6. RUNNING THE DEMO
------------------------------------------------------------

Create output folders:
mkdir -p visualization  
mkdir -p visualization_mega  

Place your image_folder/ inside mega.pytorch/

A) Run BASE:
------------
python demo/demo.py base configs/vid_R_101_C4_1x.yaml R_101.pth \
    --suffix ".JPEG" \
    --visualize-path image_folder \
    --output-folder visualization \
    --output-video

B) Run MEGA:
------------
python demo/demo.py mega configs/MEGA/vid_R_101_C4_MEGA_1x.yaml MEGA_R_101.pth \
    --suffix ".JPEG" \
    --visualize-path image_folder \
    --output-folder visualization_mega \
    --output-video

If GPU fails, run on CPU:
CUDA_VISIBLE_DEVICES="" python demo/demo.py ...

------------------------------------------------------------
7. GITHUB SUBMISSION GUIDE
------------------------------------------------------------

Your repository MUST include:

✓ mega.pytorch/ (without .pth files)  
✓ README (this file)  
✓ List of fixes applied  
✓ Installation steps  
✓ Instructions to download checkpoints manually  
✓ Commands to run BASE and MEGA  

Upload with:
git add .  
git commit -m "Working MEGA + documentation"  
git push  

If large files were accidentally committed:
git rm --cached <filename>  
git commit -m "Remove large files"  
git push  

------------------------------------------------------------
8. SUMMARY OF FIXES
------------------------------------------------------------

• Forced PyTorch 1.2  
• Patched APEX setup.py (parallel=None)  
• Later removed APEX entirely  
• Modified:
    - nms.py  
    - roi_align.py  
    - roi_pool.py  
• Fixed OpenCV putText: int(x), int(y)  
• Successfully ran BASE and MEGA demos

------------------------------------------------------------
END OF FILE
------------------------------------------------------------
