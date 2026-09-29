# dotfiles

Minimal configs for Neovim, tmux, mise and bash, plus the steps to set up
a development machine from a fresh Debian 13 (trixie) install.

```
nvim/   Neovim 0.12+ config (native vim.pack, LSP via Mason)
tmux/   tmux config, no plugin manager
mise/   global tool versions (Neovim, Node, Go, ...)
bash/   shell snippet sourced from ~/.bashrc
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
git clone git@github.com:<user>/dotfiles.git ~/dotfiles
```

Install mise:

```sh
curl https://mise.run | sh
```

Link the configs. Move any existing ones out of the way first.

```sh
mkdir -p ~/.config
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/tmux ~/.config/tmux
ln -s ~/dotfiles/mise ~/.config/mise
```

Load the bash snippet:

```sh
echo '[ -f ~/dotfiles/bash/bashrc ] && . ~/dotfiles/bash/bashrc' >> ~/.bashrc
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

## 6. Hardware-specific (laptops)

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
- Reload the Neovim config: `<leader>o`
- Reload the tmux config: `prefix R`
