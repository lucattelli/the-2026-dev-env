# MacBook Air 11" (2014): Haswell, 4 GB, Intel HD graphics, Broadcom BCM4360
# Wi-Fi (needs broadcom-sta-dkms; the installer has no driver for it, so use
# Ethernet or USB tethering during install). Kept lean: no local AI, Docker
# only on demand, compressed swap in RAM.
KERNEL=stable          # newer kernels tend to break broadcom-sta
GPU=none
HYBRID_GPU=no
LOCAL_AI=no
DOCKER_ON_DEMAND=yes
ZRAM=yes
EXTRA_PACKAGES="broadcom-sta-dkms"
