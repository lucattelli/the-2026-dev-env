# Dell Inspiron 15 7580: 8th-gen i7, 16 GB, Intel UHD + NVIDIA MX150 (Pascal,
# confirmed with lspci). Pascal is not supported by NVIDIA's 590+ repo
# drivers, so it stays on Debian's 550 driver and the stable kernel.
KERNEL=stable
GPU=nvidia-debian
HYBRID_GPU=yes
LOCAL_AI=no            # 2 GB of VRAM is too little for useful local models
DOCKER_ON_DEMAND=no
ZRAM=no
EXTRA_PACKAGES=""
KERNEL_PARAMS=""
# Brazilian ABNT2 keyboard (ç key, AltGr); the other machines are US.
KEYBOARD_MODEL=abnt2
KEYBOARD_LAYOUT=br
KEYBOARD_VARIANT=""
# Two SSDs: the system on the M.2 (512 GB), Timeshift snapshots on the SATA
# one (480 GB), formatted ext4 with this label.
TIMESHIFT_LABEL=snapshots
