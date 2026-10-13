# dotfiles

Minimal configs for Neovim, tmux, Alacritty, mise, bash and Claude Code,
plus the steps to set up a development machine from a fresh Debian 13
(trixie) install.

```
nvim/        Neovim 0.12+ config (native vim.pack, LSP via Mason)
tmux/        tmux config, no plugin manager
alacritty/   terminal config
mise/        global tool versions (Neovim, Node, Go, CLI tools, Codex)
bash/        shell snippet sourced from ~/.bashrc
claude/      global CLAUDE.md and sandbox image for Claude Code
bin/         helper scripts, added to PATH by the bash snippet
hosts/       per-machine hardware profiles used by devenv-setup
lxqt/        LXQt settings (panel, shortcuts, power), linked as ~/.config/lxqt
starship/    prompt config
```

## Quick start

### 1. Before installing

- Image: Debian 13 netinst (amd64).
- Network: plug in a cable (USB Ethernet or phone USB tethering) if the
  Wi-Fi needs a non-free driver (MacBook Air).
- Check the machine's row in the [table](#machines).

### 2. Installer

Screen by screen:

- **Boot menu:** *Install*. If the machine needs a kernel option (MacBook
  Air: `intel_iommu=off`), press `e`, add it at the end of the `linux`
  line after the `---`, then `Ctrl+X`.
- **Language:** English.
- **Location:** other → South America → Brazil.
- **Locale:** `en_US.UTF-8`.
- **Keyboard:** American English.
- **Network interface:** the cable (Wi-Fi may not be listed).
- **Hostname:** from the [table](#machines) (`l5i`, `insp`, `mba`, `t1g`,
  `xps`).
- **Domain name:** empty.
- **Root password:** set one.
- **Full name / username:** your name / `lucattelli`.
- **Time zone:** São Paulo.
- **Partitioning:** Guided, use entire disk → All files in one partition.
- **Mirror:** Brazil → `deb.debian.org`.
- **Popularity contest:** No.
- **Software selection:**
  - [x] Debian desktop environment
  - [ ] GNOME (selected by default, uncheck it)
  - [x] LXQt
  - [x] SSH server
  - [x] standard system utilities
- **Missing firmware prompt** (e.g. Broadcom Wi-Fi): continue without it.

### 3. First boot: bootstrap and setup

Log in as your user, open a terminal and run:

```sh
wget -qO /tmp/devenv-bootstrap https://raw.githubusercontent.com/lucattelli/the-2026-dev-env/main/bin/devenv-bootstrap && su - -c "sh /tmp/devenv-bootstrap $USER" && sg sudo -c ~/the-2026-dev-env/bin/devenv-setup
```

- Asks for the **root** password, installs `sudo` and `git`, adds you to
  the `sudo` group and clones this repo into `~/the-2026-dev-env`.
- Then starts `devenv-setup` as you, through `sg sudo` so the `sudo` group
  is already active (no logout needed).
- `devenv-setup` asks for **your** password once, then for git name and
  email near the end.
- Ends with a numbered checklist. Follow it in order:
  - Reboot (loads Wi-Fi/NVIDIA drivers, kernel options, groups, locale,
    keyboard).
  - Connect to Wi-Fi, if the cable was only for the install.
  - `bw login`, then `devenv-keys` (restores this machine's SSH keys).
  - Switch the repo remote to SSH.
  - Log in: `gh auth login`, `claude`, `codex`.
  - Timeshift setup wizard.
  - Open `nvim` once.

Without the bootstrap script, the same by hand:

```sh
su - -c "apt install -y sudo git && usermod -aG sudo $USER"
git clone https://github.com/lucattelli/the-2026-dev-env ~/the-2026-dev-env
sg sudo -c ~/the-2026-dev-env/bin/devenv-setup   # or reboot first, then run it directly
```

`devenv-setup` is safe to re-run. It changes only what differs from the
expected state, and moves existing configs aside (`*.bak-<date>`) instead of
deleting them. The sections after the machine table document what it does,
step by step.

## Locale and keyboard

Set by `devenv-setup` on every machine:

- Messages in English (`en_US.UTF-8`).
- Formats from `pt_BR`: numbers (1.234,56), dates (12/10/2026), currency
  (R$), A4 paper, metric units.
- Keyboard `us`, variant `intl` (dead keys): `'` + `a` = `á`, `'` + `c` =
  `ç`, `~` + `a` = `ã`, `'` + space = `'`. Same for `"`, `` ` ``, `~`, `^`.
- A profile can override the keyboard with `KEYBOARD_LAYOUT` and
  `KEYBOARD_VARIANT`.

## Machines

Hardware choices live in `hosts/<hostname>.sh`. Everything else is the same
on every machine.

| Hostname | Machine | Kernel | GPU driver | Notes |
| --- | --- | --- | --- | --- |
| `l5i` | Lenovo Legion 5 (RTX 2060) | stable | Debian 550 | discrete mode, local AI |
| `insp` | Dell Inspiron 7580 (MX150) | stable | Debian 550 | hybrid, `prime-run` |
| `mba` | MacBook Air 11" 2014 (4 GB) | stable | none | Broadcom Wi-Fi, zram, Docker on demand, `intel_iommu=off` |
| `t1g` | ThinkPad T1g (RTX 5070) | backports | NVIDIA repo (590+) | hybrid, local AI; untested |
| `xps` | Dell XPS 13 2026 (Ultra 7 355) | backports | none | review after arrival |

Why two kernel tracks: older machines are fully supported by Debian's 6.12
kernel and gain nothing from a newer one (on the MacBook, newer kernels tend
to break the Broadcom driver). The T1g and the XPS are too new for it. And
no single NVIDIA driver covers every GPU: Debian's 550 doesn't support
Blackwell (RTX 50), and NVIDIA's 590+ repo doesn't support Pascal (MX150).

The MacBook Air's SSD only shows up with `intel_iommu=off`. At the
installer's boot menu, press `e` and add it at the end of the `linux` line,
after the `---`, so the installer also keeps it for the installed system.
`devenv-setup` then pins it in `/etc/default/grub.d/devenv.cfg` through the
profile's `KERNEL_PARAMS`.

On a hybrid machine the Intel GPU drives the desktop; run a program on the
NVIDIA GPU with `prime-run <command>`.

### LXQt settings

`~/.config/lxqt` is a link to `lxqt/` in this repo, so shortcuts, panel and
power settings follow you between machines. Monitor layouts are per machine
and ignored by git. To start versioning them from an existing machine:

```sh
mv ~/.config/lxqt ~/the-2026-dev-env/lxqt
ln -s ~/the-2026-dev-env/lxqt ~/.config/lxqt
git -C ~/the-2026-dev-env status   # review what to commit
```

If you only want the configs on a machine that is already set up, skip to
[Dotfiles](#4-dotfiles).

## 1. Base system

### sudo

Debian is installed with a root password, so the installer leaves out the
`sudo` package and your user is not in the `sudo` group. As root, add both
(plus `git`, needed to clone this repo):

```sh
su - -c "apt install -y sudo git && usermod -aG sudo <your-user>"
```

Log out and back in. `devenv-setup` checks for both and stops with this
command if either is missing.

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

### SSH keys

Each machine has its own SSH key, kept in Bitwarden and registered on GitHub
once. Keys live in a Bitwarden folder named `ssh`, as secure notes:

- Item name: `<hostname>-<purpose>` for one machine (`l5i-github`), or
  `all-<purpose>` for every machine (`all-tilde`).
- One hidden field per file in `~/.ssh`: the field name is the file name
  (`id_ed25519`, `id_ed25519.pub`), the value is the file content. Field
  names must be unique across a machine's items.

On a reinstalled machine, restore its keys (needs `bw`, installed by mise in
step 4, and `jq`). Existing files are never overwritten:

```sh
devenv-keys
ssh -T git@github.com
```

For a new machine, create the key, store it in Bitwarden and add the public
key on GitHub (Settings → SSH and GPG keys) twice: as an *Authentication
Key* and as a *Signing Key*.

```sh
ssh-keygen -t ed25519 -C "you@$(hostname)"
```

Multi-line values pasted into Bitwarden's field UI can lose their line
breaks. Check the private key round-trips, and write it with the CLI if not:

```sh
export BW_SESSION=$(bw unlock --raw)
item="$(hostname)-github"
bw get item "$item" | jq -r '.fields[] | select(.name == "id_ed25519") | .value' \
  | diff - ~/.ssh/id_ed25519 && echo ok

# only if the check fails:
id=$(bw get item "$item" | jq -r .id)
bw get item "$id" \
  | jq --arg v "$(cat ~/.ssh/id_ed25519)" '(.fields[] | select(.name == "id_ed25519") | .value) = $v' \
  | bw encode | bw edit item "$id" >/dev/null
```

Sign commits with the key:

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

The snippet sets `EDITOR` to Neovim, keeps 100k lines of history, puts the
repo's `bin/` (and opencode, if installed) on `PATH`, activates mise, starts
the starship prompt and zoxide, aliases `fd` and `bat`
to their Debian names (`fdfind`, `batcat`) and adds the power profile
aliases from step 7. It also loads the fzf key bindings, using `fd` as the
file source so they respect `.gitignore`:

- `Ctrl+R`: fuzzy search through shell history
- `Ctrl+T`: insert a file path into the current command
- `Alt+C`: `cd` into a directory

Typing `fzf` on its own just opens the finder; the key bindings are what the
snippet adds. Every part is guarded, so the same file works on machines
where a tool is missing.

Open a new shell and install the pinned tools:

```sh
mise install
```

This also installs `gh`, `delta` and `lazygit`. Log in to the GitHub CLI
(GitHub.com, SSH, skip the key upload since it is already registered, log in
with a browser):

```sh
gh auth login
```

Use delta as git's pager:

```sh
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3
```

`lazygit` needs no setup. It is the review step for agent work: stage hunk by
hunk (`enter`), commit (`c`, signed like any other commit), push (`P`).

Open `nvim` once. It installs the plugins and the language servers
(clangd, lua_ls, gopls). Restart it when done. Mason needs Go to build
gopls, which is why `mise install` comes first.

If tmux is already running, restart the server so every option applies:

```sh
tmux kill-server
```

### Shell tools

Also installed by `mise install`:

- **starship**: one-line prompt with directory, git branch and status, the
  project's language versions and the duration of slow commands. The config
  in `starship/` uses plain-text symbols, so no Nerd Font is needed.
- **zoxide**: `z <part of a path>` jumps to frequently used directories;
  `zi` picks one with fzf.
- **tealdeer**: `tldr <command>` shows practical examples. Download the
  pages once with `tldr --update`.
- **hyperfine**: `hyperfine 'cmd a' 'cmd b'` benchmarks commands.
- **lazydocker**: terminal dashboard for containers, logs and resources.
- **dust**: disk usage as a tree sorted by size, e.g. `dust -d 2 ~` or
  `sudo dust /var/lib/docker` to see what models and images take up.
- **glow**: renders Markdown in the terminal; `glow -p README.md` pages
  long files.

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

### Claude Code

Install with the native installer (no root, updates itself in the
background) and log in on first run. The free Claude.ai plan does not
include Claude Code.

```sh
curl -fsSL https://claude.ai/install.sh | bash
claude
```

Link the global `CLAUDE.md`, which tells Claude Code how this machine works
(mise, uv, Debian package names). Link the file, not the folder:
`~/.claude` also holds credentials and history that must stay out of git.

```sh
mkdir -p ~/.claude
ln -s ~/the-2026-dev-env/claude/CLAUDE.md ~/.claude/CLAUDE.md
```

Check with `/memory` inside a session. Claude Code runs commands in a
non-interactive shell that doesn't load `~/.bashrc`, so the bash snippet's
aliases are not available there; `CLAUDE.md` covers that.

Workflow: run `claude` in a tmux pane next to Neovim (`prefix |` opens it in
the same directory). Edits show up in Neovim through `autoread` and tmux's
`focus-events`.

### Claude Code sandbox

`claude-sandbox` runs Claude Code without permission prompts inside a
container that only sees the current directory. Requires Docker (step 5).

```sh
cd ~/code/my-project
claude-sandbox            # extra args go to claude, e.g. --resume
```

- Mounted: the current directory at `/workspace` and `CLAUDE.md`
  (read-only). Not mounted: SSH keys, `~/.gitconfig`, the Docker socket,
  the rest of `$HOME`.
- Files are created with your UID/GID, so they belong to your user.
- mise and uv are in the image; projects with a `mise.toml` get the same
  tool versions with `mise install`.
- Login lives in the `claude-sandbox-config` volume, separate from
  `~/.claude`. On first run, open the printed URL on the host and paste the
  code back.
- The agent can't push and its commits would be unsigned. Review with
  `git diff` and commit from the host.
- Network access is unrestricted. Add an egress firewall before running it
  on sensitive code.

The image is built on first use and cached. To update Claude Code inside it:

```sh
docker build --no-cache -t claude-sandbox ~/the-2026-dev-env/claude/sandbox
```

### Other coding agents

Optional, for comparing models from other providers in the same workflow.

**Codex CLI** (OpenAI) is pinned in `mise/config.toml`, so `mise install`
already installed it. Run `codex` and choose *Sign in with ChatGPT*; usage
comes from the ChatGPT plan (rolling 5-hour limits) or from an API key.
Codex reads `AGENTS.md`, so reuse the same instructions as Claude Code:

```sh
mkdir -p ~/.codex
ln -s ~/the-2026-dev-env/claude/CLAUDE.md ~/.codex/AGENTS.md
```

**opencode** works with many providers, including OpenCode Zen, its own
gateway with some free models:

```sh
curl -fsSL https://opencode.ai/install | bash
opencode
```

Inside it, run `/connect` → OpenCode Zen, then `/models` to pick a model.
Notes on Zen:

- Free models rotate and are usually limited-time.
- Some free models may use your prompts and code for training (e.g. Big
  Pickle). Check the privacy section of the Zen docs and prefer zero-retention
  ones. Never use free models on work or confidential code.
- With billing details on file, Zen auto-reloads credit when the balance gets
  low. Disable auto-reload or set a monthly limit.

Credentials for both live outside the repo (`~/.codex/`,
`~/.local/share/opencode/`).

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

To start ollama with the system: `docker update --restart unless-stopped ollama`.

To ask the local model from the shell, install `llm` with the ollama plugin
(`llm install` doesn't work inside uv environments, hence `--with`):

```sh
uv tool install llm --with llm-ollama
llm models default qwen2.5-coder:7b
llm "how do I list open ports on linux?"
cat error.log | llm "explain this error"
```

The plugin asks ollama for its models at runtime, so ollama must be running;
otherwise `llm` reports an unknown model.

### Local code completion (llama.vim)

The Neovim config includes llama.vim, which shows inline completions from a
local model served by llama.cpp. It is off when Neovim starts; run
`:LlamaEnable` to turn it on. Machines without the server are unaffected.

Run the server in a container:

```sh
docker run -d --gpus all --name llama-fim --restart unless-stopped \
  -p 127.0.0.1:8012:8012 -v llama-cache:/root/.cache \
  ghcr.io/ggml-org/llama.cpp:server-cuda \
  --fim-qwen-1.5b-default --host 0.0.0.0
```

The preset downloads Qwen 2.5 Coder 1.5B, listens on port 8012 (the plugin's
default endpoint) and loads the whole model on the GPU. The port is bound to
localhost only, and the volume keeps the downloaded model.

Once enabled, `Tab` accepts a suggestion and `Ctrl+F` toggles it manually;
see `:help llama`.

VRAM: on a 6 GB card the completion model (~2 GB) and a 7B ollama model
(~5 GB) don't fit together. ollama frees its VRAM after a few idle minutes;
stop the completion server (`docker stop llama-fim`) before heavy ollama use.

### Keyboard (Vial)

Vial configures keyboards running Vial firmware (e.g. a Corne). Allow your
user to access them; the rule only matches Vial devices:

```sh
export USER_GID=$(id -g)
sudo --preserve-env=USER_GID sh -c 'echo "KERNEL==\"hidraw*\", SUBSYSTEM==\"hidraw\", ATTRS{serial}==\"*vial:f64c2b3c*\", MODE=\"0660\", GROUP=\"$USER_GID\", TAG+=\"uaccess\", TAG+=\"udev-acl\"" > /etc/udev/rules.d/99-vial.rules && udevadm control --reload && udevadm trigger'
```

Reconnect the keyboard. The AppImage needs FUSE 2. Download it from
get.vial.today and put it on `PATH`:

```sh
sudo apt install libfuse2t64
mv ~/Downloads/Vial-*.AppImage ~/.local/bin/vial
chmod +x ~/.local/bin/vial
```

The web version (vial.rocks) needs the same udev rule and a Chromium-based
browser (WebHID), such as the Chromium from step 8; Firefox doesn't
support it.

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

### Hibernation

Hibernation writes RAM to swap and powers off completely: no battery drain,
but a slower resume than sleep. Take a Timeshift snapshot first. The worst
case is losing the open session, not the system.

Requirements:

- A swap partition at least as large as RAM (`free -h`, `lsblk -f`).
- Secure Boot disabled. With Secure Boot on, kernel lockdown blocks
  hibernation.

Check that the initramfs knows where to resume from. The UUID must match the
swap partition in `lsblk -f`:

```sh
cat /etc/initramfs-tools/conf.d/resume
```

If the file is missing, create it with `RESUME=UUID=<swap-uuid>`.

With the NVIDIA driver, video memory must be saved too, or the screen comes
back black. Debian 13 mounts `/tmp` in RAM, so point the driver to a
directory on disk:

```sh
echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp" \
  | sudo tee /etc/modprobe.d/nvidia-power.conf
sudo update-initramfs -u
```

The `nvidia-hibernate` and `nvidia-resume` services ship with the driver and
must be enabled (`systemctl list-unit-files | grep nvidia`).

Reboot and check that the options are active (`1` and `"/var/tmp"`):

```sh
grep -E "PreserveVideoMemory|TemporaryFilePath" /proc/driver/nvidia/params
```

Save your work and test:

```sh
systemctl hibernate
```

If the session doesn't come back, reboot and look at the previous attempt:

```sh
journalctl -b -1 | grep -iE "PM:|hibernat|nvidia" | tail -40
```

### Lid and sleep

Closing the lid suspends; hibernation is used on demand, with
`systemctl hibernate` or from the LXQt leave menu. Suspend wakes up as soon
as the lid opens, while hibernation needs the power button (unless the BIOS
has a "Flip to Start" option). The NVIDIA video memory option above also
makes suspend more reliable.

The lid is handled by LXQt: LXQt Configuration Center → Power Management →
Lid, with the lid watcher enabled and the action set to *Suspend*. Check
that LXQt holds the lid lock:

```sh
systemd-inhibit --list | grep -i lid
```

To let systemd-logind handle the lid instead (e.g. to hibernate on close),
disable the LXQt lid watcher and add a drop-in in
`/etc/systemd/logind.conf.d/`. Reload it with
`sudo systemctl kill -s HUP systemd-logind`, never with a restart, which
ends the graphical session.

## 8. Everyday apps

LibreOffice, Thunderbird (ESR) and Chromium come from the Debian repos and
get security updates with the system. The `l10n` packages are the Portuguese
interfaces; `hunspell-pt-br` is the spell checker. Chromium is also the
browser for WebHID tools such as vial.rocks.

```sh
sudo apt install libreoffice libreoffice-l10n-pt-br hunspell-pt-br \
  thunderbird thunderbird-l10n-pt-br chromium chromium-l10n
```

Bitwarden isn't in the Debian repos; install it from Flathub. Set up
Flatpak once, then log out and back in so its apps show up in the menu:

```sh
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.bitwarden.desktop
```

Also install the Bitwarden browser extension for filling in passwords.
Optionally, the CLI (`bw`) reads secrets from the shell, e.g.
`export API_KEY=$(bw get password my-api)`:

```sh
mise use -g npm:@bitwarden/cli
```

## Maintenance

### Weekly: `devenv-update`

`bin/devenv-update` updates everything that can be updated from the shell,
in order, and stops at the first error:

1. Timeshift snapshot
2. APT (Debian plus the Docker and NVIDIA repos)
3. Flatpak
4. mise itself and its tools, within their pinned ranges
5. uv itself and uv tools (`llm`)
6. Rust (`rustup update`)
7. tldr pages

It asks for the sudo password once, keeps the APT and Flatpak
confirmations so you can review what changes, and skips tools that aren't
installed, so it also runs on other machines.

Manual snapshots are not pruned by Timeshift's schedule. Every few weeks,
list them with `sudo timeshift --list` and remove old ones with
`sudo timeshift --delete`.

### Occasionally, by hand

- Neovim plugins: `:lua vim.pack.update()`
- Language servers: `:Mason`, then `U`
- Container images: `docker pull ollama/ollama` and
  `docker pull ghcr.io/ggml-org/llama.cpp:server-cuda`, then recreate the
  `ollama` and `llama-fim` containers with their `docker run` commands
  (models live in volumes and are kept)
- Claude sandbox image:
  `docker build --no-cache -t claude-sandbox ~/the-2026-dev-env/claude/sandbox`
- Firmware: `fwupdmgr refresh && fwupdmgr update`
- Vial: download the new AppImage when there is a release

Claude Code updates itself in the background; opencode has its own update
command (`opencode --help`).

### Reloading configs

- Neovim: `<leader>o`
- tmux: `prefix R`
