FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required LFS build packages
RUN apt-get update && apt-get install -y \
    bash \
    sudo \
    build-essential \
    bison \
    gawk \
    texinfo \
    gperf \
    flex \
    m4 \
    patch \
    tar \
    xz-utils \
    bzip2 \
    gzip \
    python3 \
    wget \
    git \
    nano \
    diffutils \
    findutils \
    sed \
    grep \
    file \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Disable /etc/bash.bashrc as required by LFS
RUN if [ -e /etc/bash.bashrc ]; then \
        mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE ; \
    fi

# Force /bin/sh → bash
RUN ln -sf /bin/bash /bin/sh

# Create lfs user with sudo rights. Ubuntu 24.04 includes an ubuntu user at
# UID 1000; remove it so host-owned bind mounts resolve to lfs instead.
RUN if id ubuntu >/dev/null 2>&1; then userdel -r ubuntu; fi && \
    groupadd -g 1000 lfs && \
    useradd -m -u 1000 -g 1000 -s /bin/bash lfs && \
    echo "lfs ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup working directory
RUN mkdir -p /mnt/lfs && chown lfs:lfs /mnt/lfs

# Copy LFS bash environment
COPY lfs-bash-config/lfs-bashrc       /home/lfs/.bashrc
COPY lfs-bash-config/lfs-bash_profile /home/lfs/.bash_profile

# Copy all build scripts
COPY lfs-build-scripts/ /home/lfs/lfs-build-scripts/

# Fix ownership and permissions
RUN chown -R lfs:lfs /home/lfs && \
    chmod -R +x /home/lfs/lfs-build-scripts && \
    chmod 644 /home/lfs/.bashrc /home/lfs/.bash_profile

USER lfs
WORKDIR /home/lfs

CMD ["/bin/bash", "--login"]
