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
# Panel Replay with selective update (the xe driver's default for this
# panel) shows brief horizontal strips with another part of the screen.
# Turning it off falls back to PSR2, which was glitch-free and measured no
# worse at idle (2.67 W vs 3.17 W with Panel Replay, screen static, battery).
# xe.enable_psr2_sel_fetch=0 instead made the mouse stutter badly.
KERNEL_PARAMS="xe.enable_panel_replay=0"
# Brazilian ABNT2 keyboard.
KEYBOARD_MODEL=abnt2
KEYBOARD_LAYOUT=br
KEYBOARD_VARIANT=""
# 2560x1600 on 13.4" (~225 PPI). X11 assumes 96; 144 (150%) reads well.
SCREEN_DPI=144
# Alacritty doesn't grow enough with Xft.dpi alone; 8 elsewhere.
TERMINAL_FONT_SIZE=12
# Sound: Panther Lake's audio DSP needs Sound Open Firmware newer than
# Debian's firmware-sof-signed 2025.01 (no ptl/ files), so it comes from the
# upstream release. The codec is a Cirrus CS42L43 on SoundWire, with Cirrus
# amps (firmware-cirrus above).
SOF_BIN_VERSION=2026.09.2
SOF_BIN_SHA256=5f7bc30b2b5c1e6b0da55a33fc44e2b7f56ae9b06952edcde614f51ef6b943e1
# Speakers: the two CS35L56 amps (on SPI) need Dell's tuning files, and the
# kernel (7.3) can't read the speaker ID from this machine's ACPI, so it
# asks for "spkid0", which doesn't exist; firmware-cirrus ships 10280e54
# tuning for spkid1-3 only. Pointing spkid0 at spkid1 gives "Calibration
# applied" on both amps and working speakers (tested 2026-11). Drop this
# once the kernel reads the real ID (dmesg then names spkid1/2/3 itself).
FIRMWARE_LINKS="
cirrus/cs35l56-b2-dsp1-misc-10280e54-spkid0.wmfw=cirrus/cs35l56-b2-dsp1-misc-10280e54-spkid1.wmfw
cirrus/cs35l56-b2-dsp1-misc-10280e54-spkid0-ampl.bin=cirrus/cs35l56-b2-dsp1-misc-10280e54-spkid1-ampl.bin
cirrus/cs35l56-b2-dsp1-misc-10280e54-spkid0-ampr.bin=cirrus/cs35l56-b2-dsp1-misc-10280e54-spkid1-ampr.bin
"
