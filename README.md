# dotfiles

Minimal configs for Neovim, tmux, Alacritty, mise and bash, plus the steps
to set up a development machine from a fresh Debian 13 (trixie) install.

```
nvim/        Neovim 0.12+ config (native vim.pack, LSP via Mason)
tmux/        tmux config, no plugin manager
alacritty/   terminal config
mise/        global tool versions (Neovim, Node, Go, ...)
bash/        shell snippet sourced from ~/.bashrc
```

If you only want the configs on a machine that is already set up, skip to
[Dotfiles](#4-dotfiles).

## 1. Base system

### sudo

If a root password was set during install, your user is not in the `sudo`
group yet:

```sh
su -
usermod -aG sudo <your-user>
```

Log out and back in.

### APT sources

Convert the sources to the deb822 format:

```sh
sudo apt modernize-sources
```

Edit `/etc/apt/sources.list.d/debian.sources`:

- In every block, set `Components: main contrib non-free non-free-firmware`.
- In the `deb.debian.org` block that has `trixie-updates`, add
  `trixie-backports` to the `Suites:` line.
- Keep `trixie-security` only in the `security.debian.org` block.

Then update everything:

```sh
sudo apt update && sudo apt full-upgrade
```

### Firmware and security updates

```sh
sudo apt install fwupd unattended-upgrades
```

### Base packages

```sh
sudo apt install build-essential git curl wget pkg-config libssl-dev \
  ripgrep fd-find fzf bat tmux jq htop xclip unzip
```

## 2. Git and GitHub

```sh
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
```

Create an SSH key and load it into the agent:

```sh
ssh-keygen -t ed25519 -C "you@example.com"
ssh-add ~/.ssh/id_ed25519
```

Copy the public key and add it on GitHub (Settings → SSH and GPG keys):

```sh
xclip -selection clipboard < ~/.ssh/id_ed25519.pub
ssh -T git@github.com
```

Optional: sign commits with the same key. Add it on GitHub a second time,
as a *Signing Key*.

```sh
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

## 3. Language toolchains

Don't use the APT versions of fast-moving runtimes. Each toolchain lives in
the user's home, independent of the system.

- **mise** handles Neovim, Node, Go and the other versions pinned in
  `mise/config.toml` (installed in step 4).
- **uv** handles Python:

  ```sh
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

- **rustup** handles Rust:

  ```sh
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source ~/.cargo/env
  rustup component add rust-analyzer
  ```

## 4. Dotfiles

Clone the repo:

```sh
git clone git@github.com:lucattelli/the-2026-dev-env.git ~/the-2026-dev-env
```

Install mise:

```sh
curl https://mise.run | sh
```

Link the configs. Move any existing ones out of the way first.

```sh
mkdir -p ~/.config
ln -s ~/the-2026-dev-env/nvim ~/.config/nvim
ln -s ~/the-2026-dev-env/tmux ~/.config/tmux
ln -s ~/the-2026-dev-env/mise ~/.config/mise
ln -s ~/the-2026-dev-env/alacritty ~/.config/alacritty
```

Load the bash snippet:

```sh
echo '[ -f ~/the-2026-dev-env/bash/bashrc ] && . ~/the-2026-dev-env/bash/bashrc' >> ~/.bashrc
```

Open a new shell and install the pinned tools:

```sh
mise install
```

Open `nvim` once. It installs the plugins and the language servers
(clangd, lua_ls, gopls). Restart it when done. Mason needs Go to build
gopls, which is why `mise install` comes first.

If tmux is already running, restart the server so every option applies:

```sh
tmux kill-server
```

### Terminal

Install Alacritty and the font used by its config:

```sh
sudo apt install alacritty fonts-jetbrains-mono
```

Make it the default terminal:

```sh
sudo update-alternatives --config x-terminal-emulator
```

On LXQt, also set it in LXQt Configuration Center → Session Settings →
Basic Settings → Terminal emulator, which is what the menu and the keyboard
shortcut use.

The config reloads on save. To always start inside tmux, uncomment the
`[terminal.shell]` block in `alacritty/alacritty.toml`.

## 5. Docker

Install from Docker's official repository, not the `docker.io` package:

```sh
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOT
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: trixie
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOT

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

Log out and back in, then check:

```sh
docker run hello-world
```

Note: membership in the `docker` group is equivalent to root access.

## 6. System snapshots

On ext4, Timeshift works in rsync mode: it copies the system (not `/home`)
and each new snapshot only stores the files that changed.

```sh
sudo apt install timeshift
```

Open Timeshift from the menu and go through the setup wizard:

- **Type:** RSYNC.
- **Location:** a partition on a different disk than the system, if there
  is one. Snapshots on the same disk protect against a bad update, but not
  against a dead drive. Timeshift creates a `timeshift` folder at the root
  of the chosen partition.
- **Schedule:** daily (keep 5) and weekly (keep 2). Leave "boot" off.
- **Users:** keep `/home` excluded. Code lives in git, config in this repo.

Close the wizard before using the command line, since only one instance can
run at a time. Create the first snapshot and check it:

```sh
sudo timeshift --create --comments "new system configured"
sudo timeshift --list
```

Take a manual snapshot before risky changes (drivers, backports packages,
partitioning):

```sh
sudo timeshift --create --comments "before <change>"
```

To roll back, use the GUI or `sudo timeshift --restore`. If the system no
longer boots, start a live USB, install Timeshift there and restore from
the snapshot partition.

## 7. Hardware-specific (laptops)

### NVIDIA GPU

For Turing and newer cards supported by the driver in the Debian repos.
Check Secure Boot first:

```sh
mokutil --sb-state
```

Install the driver:

```sh
sudo apt install linux-headers-amd64 nvidia-driver firmware-misc-nonfree
```

If Secure Boot is enabled, enroll the DKMS key before rebooting, then choose
"Enroll MOK" on the next boot:

```sh
sudo mokutil --import /var/lib/dkms/mok.pub
```

A warning about the `nouveau` module being loaded is expected. Reboot and
check:

```sh
nvidia-smi
```

Very recent GPUs (e.g. RTX 50 series) may need a newer driver from
backports or NVIDIA's own repository.

### GPU in containers

Requires the NVIDIA driver above and Docker from step 5. Add NVIDIA's
repository:

```sh
sudo curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  -o /etc/apt/keyrings/nvidia-container-toolkit.asc

sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.sources <<EOT
Types: deb
URIs: https://nvidia.github.io/libnvidia-container/stable/deb/amd64
Suites: /
Signed-By: /etc/apt/keyrings/nvidia-container-toolkit.asc
EOT
```

Install the toolkit and register it with Docker:

```sh
sudo apt update
sudo apt install nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

Check that a container sees the GPU (the process list is empty inside a
container, which is expected):

```sh
docker run --rm --gpus all debian:trixie nvidia-smi
```

Example: run ollama with GPU acceleration. The `ollama` volume keeps the
downloaded models when the container is removed.

```sh
docker run -d --gpus all --name ollama \
  -v ollama:/root/.ollama -p 11434:11434 ollama/ollama
docker exec -it ollama ollama run qwen2.5-coder:7b
```

### Bluetooth

```sh
sudo apt install rfkill blueman
sudo rfkill unblock bluetooth
```

### Power profiles

```sh
sudo apt install power-profiles-daemon
powerprofilesctl list
```

The bash snippet adds the `perf`, `bal` and `eco` aliases.

## Maintenance

- Update the system: `sudo apt update && sudo apt full-upgrade`
- Update Neovim plugins: `:lua vim.pack.update()`
- Update tools within their pinned ranges: `mise upgrade`
- Update uv and Rust: `uv self update`, `rustup update`
- List system snapshots: `sudo timeshift --list`
- Reload the Neovim config: `<leader>o`
- Reload the tmux config: `prefix R`
