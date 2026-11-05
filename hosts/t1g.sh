# Lenovo ThinkPad T1g: Core Ultra 9 285H (Arrow Lake), 64 GB, Intel Arc +
# RTX 5070 (Blackwell). Blackwell needs NVIDIA's open modules from their own
# Debian 13 repo (590+); Debian's 550 driver doesn't support it.
# Verified on the first install (2026-11): backports kernel 7.2 + NVIDIA
# repo driver 620, prime-run, ollama/llama.cpp on the GPU, and sound.
KERNEL=backports
GPU=nvidia-repo
HYBRID_GPU=yes
LOCAL_AI=yes
DOCKER_ON_DEMAND=no
ZRAM=no
EXTRA_PACKAGES=""
# Sound (checked on Arch 7.2.14, where it works): SOF on the Arrow Lake DSP,
# Cirrus CS42L43 codec + two CS35L56 amps on SoundWire (not the XPS's SPI
# amps). The amps load Lenovo tuning (cirrus/cs35l56-b0-dsp1-misc-17aa2349*,
# from mid-2025, newer than trixie's firmware) and the UCM profiles match
# Arch's 1.2.16.1, so both come from backports.
BACKPORTS_PACKAGES="firmware-cirrus alsa-ucm-conf firmware-iwlwifi"
KERNEL_PARAMS=""
# The topology the kernel asks for, sof-arl-cs42l43-l2-cs35l56-l3-2ch.tplg,
# first shipped in SOF 2.13.1; trixie's firmware-sof-signed 2025.01 is 2.12.
# Same sof-bin release as Arch runs here.
SOF_BIN_VERSION=2026.09.2
SOF_BIN_SHA256=5f7bc30b2b5c1e6b0da55a33fc44e2b7f56ae9b06952edcde614f51ef6b943e1
# 3840x2400 on 16" (~283 PPI). X11 assumes 96; 192 (200%) reads well.
SCREEN_DPI=192
# Alacritty doesn't grow enough with Xft.dpi alone; 8 elsewhere.
TERMINAL_FONT_SIZE=14
