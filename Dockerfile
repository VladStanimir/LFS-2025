FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required LFS build packages
RUN apt-get update && apt-get install -y \
    bash \
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

# Create lfs user
RUN useradd -m -s /bin/bash lfs && \
    echo "lfs ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup working directory
RUN mkdir -p /mnt/lfs && chown lfs:lfs /mnt/lfs

USER lfs
WORKDIR /home/lfs

# Environment recommended by LFS
RUN echo 'export LFS=/mnt/lfs' >> ~/.bashrc

CMD ["/bin/bash"]

