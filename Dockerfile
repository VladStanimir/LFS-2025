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

# Force /bin/sh → bash
RUN ln -sf /bin/bash /bin/sh

# Create lfs user with sudo rights
RUN useradd -m -s /bin/bash lfs && \
    echo "lfs ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup working directory
RUN mkdir -p /mnt/lfs && chown lfs:lfs /mnt/lfs

# Copy helper scripts into container home
COPY scripts/version-check.sh /home/lfs/
COPY scripts/prepare-chapter4.sh /home/lfs/

# Copy LFS shell environment files
COPY scripts/lfs-bashrc /home/lfs/.bashrc
COPY scripts/lfs-bash_profile /home/lfs/.bash_profile

# Fix ownership and permissions
RUN chown lfs:lfs \
        /home/lfs/.bashrc \
        /home/lfs/.bash_profile \
        /home/lfs/version-check.sh \
        /home/lfs/prepare-chapter4.sh \

# Fix permissions
RUN chmod +x \
        /home/lfs/version-check.sh \
        /home/lfs/prepare-chapter4.sh \

USER lfs
WORKDIR /home/lfs

CMD ["/bin/bash", "--login"]

