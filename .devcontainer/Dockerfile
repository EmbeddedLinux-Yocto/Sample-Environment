# =============================================================================
# Yocto Project Build Environment
# Course: Embedded Linux using Yocto (Udemy)
# Target Board: NVIDIA Jetson Nano Orin
# Base: Ubuntu 22.04 LTS (Jammy) — supported by Yocto Kirkstone / Mickledore
# =============================================================================

FROM ubuntu:22.04

LABEL maintainer="Yocto Dev"
LABEL description="Yocto Project build environment for Jetson Nano Orin (meta-tegra)"
LABEL yocto_release="Kirkstone / Mickledore"

# ---------------------------------------------------------------------------
# Prevent interactive prompts during package installation
# ---------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ---------------------------------------------------------------------------
# System update & core toolchain packages
# (Yocto Project Quick Build — official host requirements for Ubuntu/Debian)
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # ---- Build essentials ----
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    ninja-build \
    # ---- Yocto mandatory dependencies ----
    chrpath \
    gawk \
    git \
    wget \
    curl \
    diffstat \
    unzip \
    texinfo \
    socat \
    cpio \
    file \
    # ---- Python 3 (Yocto requires Python 3.8+) ----
    python3 \
    python3-pip \
    python3-dev \
    python3-pexpect \
    python3-git \
    python3-jinja2 \
    python3-subunit \
    python3-distutils \
    # ---- Compression / archive tools ----
    xz-utils \
    zstd \
    liblz4-tool \
    lz4 \
    bzip2 \
    tar \
    # ---- Network / misc utilities ----
    iputils-ping \
    debianutils \
    iproute2 \
    net-tools \
    rsync \
    patch \
    # ---- Terminal & text tools ----
    xterm \
    less \
    vim \
    nano \
    bash-completion \
    # ---- OpenEmbedded/Yocto UI dependencies ----
    libsdl1.2-dev \
    libssl-dev \
    libegl1-mesa \
    mesa-common-dev \
    # ---- Cross-compilation & linking tools ----
    binutils \
    bison \
    flex \
    libncurses5-dev \
    libncursesw5-dev \
    # ---- Locale & timezone ----
    locales \
    tzdata \
    # ---- Repo tool dependencies ----
    ca-certificates \
    gnupg \
    lsb-release \
    # ---- For meta-tegra / Jetson BSP ----
    zlib1g-dev \
    libtool \
    autoconf \
    automake \
    pkg-config \
    libglib2.0-dev \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Generate locale (Yocto requires en_US.UTF-8)
# ---------------------------------------------------------------------------
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ---------------------------------------------------------------------------
# Install repo tool (needed for some Yocto BSP manifests incl. Tegra)
# ---------------------------------------------------------------------------
RUN curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo \
    -o /usr/local/bin/repo \
 && chmod a+rx /usr/local/bin/repo

# ---------------------------------------------------------------------------
# Upgrade pip and install useful Python packages for Yocto/BitBake
# ---------------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir --upgrade pip \
 && python3 -m pip install --no-cache-dir \
    kas \
    pyyaml \
    jsonschema \
    websockets \
    paramiko

# ---------------------------------------------------------------------------
# Create a non-root user 'yocto' (BitBake refuses to run as root)
# ---------------------------------------------------------------------------
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid ${USER_GID} yocto \
 && useradd  --uid ${USER_UID} \
             --gid ${USER_GID} \
             --no-log-init \
             --create-home \
             --shell /bin/bash \
             yocto \
 && echo "yocto ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ---------------------------------------------------------------------------
# git global configuration (BitBake / kas require a usable git identity)
# ---------------------------------------------------------------------------
RUN git config --system user.email "yocto@build.local" \
 && git config --system user.name  "Yocto Build" \
 && git config --system safe.directory '*'

# ---------------------------------------------------------------------------
# Persistent workspace directories
#   /home/yocto/yocto-workspace  →  your Yocto build tree
#   /home/yocto/downloads        →  DL_DIR  (shared download cache)
#   /home/yocto/sstate-cache     →  SSTATE_DIR (shared sstate cache)
# ---------------------------------------------------------------------------
RUN mkdir -p /home/yocto/yocto-workspace \
             /home/yocto/downloads \
             /home/yocto/sstate-cache \
 && chown -R yocto:yocto /home/yocto

# ---------------------------------------------------------------------------
# Copy entrypoint script (clone Poky on first run)
# ---------------------------------------------------------------------------
COPY .devcontainer/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ---------------------------------------------------------------------------
# Switch to non-root user
# ---------------------------------------------------------------------------
USER yocto
WORKDIR /home/yocto/yocto-workspace

# ---------------------------------------------------------------------------
# Convenience aliases for the yocto user
# ---------------------------------------------------------------------------
RUN echo '' >> ~/.bashrc \
 && echo '# --- Yocto helpers ---' >> ~/.bashrc \
 && echo 'alias ll="ls -lah --color=auto"' >> ~/.bashrc \
 && echo 'alias bitbake-init="source poky/oe-init-build-env build"' >> ~/.bashrc \
 && echo 'export DL_DIR=/home/yocto/downloads' >> ~/.bashrc \
 && echo 'export SSTATE_DIR=/home/yocto/sstate-cache' >> ~/.bashrc

# ---------------------------------------------------------------------------
# Default shell so oe-init-build-env works correctly
# ---------------------------------------------------------------------------
SHELL ["/bin/bash", "-c"]

# Clone Poky on first start, then exec the given command (default: bash)
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
