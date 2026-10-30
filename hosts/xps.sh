# Dell XPS 13 (2026): Core Ultra 7 355 (Panther Lake), Intel Xe3 graphics,
# Wi-Fi 7, no dedicated GPU. Too new for trixie: needs kernel >= 6.17 and
# Mesa >= 25.1.6 for Xe3, plus newer firmware (GPU, Wi-Fi, audio). All of it
# comes from trixie-backports (checked 2026-10: kernel 7.2, Mesa 26.1,
# firmware 20260916).
KERNEL=backports
GPU=none
HYBRID_GPU=no
LOCAL_AI=no
DOCKER_ON_DEMAND=no
ZRAM=no
EXTRA_PACKAGES=""
BACKPORTS_PACKAGES="libgl1-mesa-dri libglx-mesa0 libegl-mesa0 libgbm1 mesa-vulkan-drivers mesa-va-drivers firmware-intel-graphics firmware-iwlwifi firmware-cirrus alsa-ucm-conf"
KERNEL_PARAMS=""
# Brazilian ABNT2 keyboard.
KEYBOARD_MODEL=abnt2
KEYBOARD_LAYOUT=br
KEYBOARD_VARIANT=""
# 2560x1600 on 13.4" (~225 PPI). X11 assumes 96; 120 (125%) reads well.
SCREEN_DPI=120
# Alacritty doesn't grow enough with Xft.dpi alone; 8 elsewhere.
TERMINAL_FONT_SIZE=12
# Sound: Panther Lake's audio DSP needs Sound Open Firmware newer than
# Debian's firmware-sof-signed 2025.01 (no ptl/ files), so it comes from the
# upstream release. The codec is a Cirrus CS42L43 on SoundWire, with Cirrus
# amps (firmware-cirrus above).
SOF_BIN_VERSION=2026.09.2
SOF_BIN_SHA256=5f7bc30b2b5c1e6b0da55a33fc44e2b7f56ae9b06952edcde614f51ef6b943e1
