# Lenovo ThinkPad T1g: Core Ultra 9 285H (Arrow Lake), 64 GB, Intel Arc +
# RTX 5070 (Blackwell). Blackwell needs NVIDIA's open modules from their own
# Debian 13 repo (590+); Debian's 550 driver doesn't support it.
# Untested combination: backports kernel + NVIDIA repo driver. Verify after
# the first install.
KERNEL=backports
GPU=nvidia-repo
HYBRID_GPU=yes
LOCAL_AI=yes
DOCKER_ON_DEMAND=no
ZRAM=no
EXTRA_PACKAGES=""
