# Yocto Build Environment — Jetson Nano Orin

Dockerized build environment for the **Embedded Linux using Yocto** Udemy course,
targeting the **NVIDIA Jetson Nano Orin** board (via `meta-tegra`).

---

## What the Docker Environment Does

When you start the container for the first time, the entrypoint script automatically:

1. **Clones Poky** (the Yocto Project reference distribution) into `yocto-workspace/poky/` inside the container. Poky provides BitBake (the build engine), OpenEmbedded-Core metadata, and all the base tooling needed to build a Linux image.
2. **Creates a non-root user** (`yocto`) so that BitBake — which refuses to run as root — works out of the box.
3. **Mounts persistent storage** so that your source layers, build output, download cache, and sstate cache all survive container restarts.

> **Note:** `yocto-workspace/` and `_build/` are git-ignored. They are managed by Docker and BitBake respectively, not by this repository.

---

## Prerequisites

- [Docker](https://docs.docker.com/engine/install/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)

---

## Getting Started

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd Sample_Environment
```

### 2. Make the helper script executable (only needed once after clone)

```bash
chmod +x .devcontainer/run_yocto_env.sh
```

### 3. Build the image and enter the environment

```bash
./.devcontainer/run_yocto_env.sh
```

This will:
- Build the Docker image (first run takes a few minutes)
- Start an interactive shell inside the container as the `yocto` user
- Automatically clone Poky into `yocto-workspace/` if it is not already there
- Mount `./yocto-workspace` and the BitBake caches so your work persists on disk

---

## Directory Layout

```
Sample_Environment/
├── .devcontainer/
│   ├── Dockerfile            # Build environment definition
│   ├── docker-compose.yml    # Container configuration & volume mounts
│   ├── devcontainer.json     # VS Code Dev Container config
│   ├── entrypoint.sh         # Clones Poky on first start, sets up the user
│   ├── run_yocto_env.sh      # Helper script to start the container (CLI)
│   └── yocto-workspace/      # Yocto source tree (git-ignored, lives on host)
├── _build/                   # BitBake build output (git-ignored)
├── .gitignore
└── README.md
```

| Docker Volume        | Purpose                              | Persists?       |
|----------------------|--------------------------------------|-----------------|
| `./yocto-workspace`  | Source layers (Poky, meta-layers)    | Yes (host disk) |
| `./_build`           | BitBake build output                 | Yes (host disk) |
| `yocto_dl_cache`     | BitBake download cache (`DL_DIR`)    | Yes (Docker volume) |
| `yocto_sstate_cache` | BitBake sstate cache (`SSTATE_DIR`)  | Yes (Docker volume) |

---

## Building a Minimal Linux Image

All of the following commands are run **inside the container**.

### Step 1 — Initialize the BitBake build environment

```bash
source poky/oe-init-build-env ../_build
```

This script is provided by Poky and does two things:
- Sets up all the shell environment variables that BitBake needs (e.g. `BUILDDIR`, `PATH`).
- Creates the build directory (`../_build` relative to `yocto-workspace/`) if it does not already exist, and populates it with default configuration files (`local.conf`, `bblayers.conf`).

After running this command your working directory will automatically change to `_build/`. All subsequent `bitbake` commands must be run from inside this directory.

### Step 2 — Build the minimal image

```bash
bitbake core-image-minimal
```

`core-image-minimal` is the smallest bootable Yocto image — a Linux kernel plus a bare-bones root filesystem with BusyBox. BitBake will fetch sources, compile the cross-toolchain, build every package, and assemble the final image.

> **Be patient — this takes time.**
> On a modern machine with a fast internet connection the first build typically takes **30 minutes to 2 hours**. On slower hardware or with a slow connection it can take considerably longer. Subsequent builds are much faster thanks to the sstate cache.

### Step 3 — Run the image in QEMU

Once the build finishes, you can boot the image immediately in QEMU without any physical hardware. The QEMU helper scripts are located inside Poky:

```bash
cd /home/yocto/project/yocto-workspace/poky/scripts
runqemu core-image-minimal slirp nographic
```

- **`slirp`** — uses QEMU's built-in user-mode networking instead of a TUN/TAP device, which is required when running inside a container that does not have `/dev/net/tun`.
- **`nographic`** — disables the SDL graphical window and redirects the serial console to your terminal, which is required when there is no display server available.

To exit QEMU, press `Ctrl-A` then `X`.

---

## Notes

- BitBake **refuses to run as root** — the container uses a non-root `yocto` user automatically.
- The helper script detects your host `UID`/`GID` at runtime, so files written inside the container are owned by **you** on the host — no `sudo` needed.
- Download and sstate caches are shared across container runs, which significantly speeds up subsequent builds.
