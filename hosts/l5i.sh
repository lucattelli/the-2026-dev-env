# Lenovo Legion 5 15IMH05H: i7-10750H, 64 GB, RTX 2060 (Turing).
# BIOS in Discrete Graphics mode, so the NVIDIA GPU drives every display.
KERNEL=stable          # stable | backports
GPU=nvidia-debian      # none | nvidia-debian | nvidia-repo
HYBRID_GPU=no          # yes: Intel + NVIDIA, use prime-run for the NVIDIA GPU
LOCAL_AI=yes           # ollama + llama.cpp containers on the GPU
DOCKER_ON_DEMAND=no    # yes: Docker starts on first use instead of at boot
ZRAM=no                # yes: compressed swap in RAM, for low-memory machines
EXTRA_PACKAGES=""
KERNEL_PARAMS=""        # extra kernel command line options, kept in GRUB
