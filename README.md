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
starship/    prompt config
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

### Shell tools

Also installed by `mise install`:

- **starship**: prompt with git status and the project's tool versions. The
  config in `starship/` uses the plain-text preset, so no Nerd Font is needed.
- **zoxide**: `z <part of a path>` jumps to frequently used directories;
  `zi` picks one with fzf.
- **tealdeer**: `tldr <command>` shows practical examples. Download the
  pages once with `tldr --update`.
- **hyperfine**: `hyperfine 'cmd a' 'cmd b'` benchmarks commands.
- **lazydocker**: terminal dashboard for containers, logs and resources.

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

## Maintenance

- Update the system: `sudo apt update && sudo apt full-upgrade`
- Update Neovim plugins: `:lua vim.pack.update()`
- Update tools within their pinned ranges: `mise upgrade`
- Update uv tools and Rust: `uv self update`, `uv tool upgrade --all`, `rustup update`
- Update the llama.cpp image: `docker pull ghcr.io/ggml-org/llama.cpp:server-cuda`, then recreate the `llama-fim` container
- List system snapshots: `sudo timeshift --list`
- Reload the Neovim config: `<leader>o`
- Reload the tmux config: `prefix R`
