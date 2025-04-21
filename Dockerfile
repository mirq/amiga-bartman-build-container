FROM alpine:3.21

# Define build arguments for customization
ARG USERNAME=amiga
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install necessary packages for development and building code
RUN apk add --no-cache \
    curl \
    unzip \
    wget \
    git \
    build-base \
    cmake \
    make \
    g++ \
    gcc \
    python3 \
    py3-pip \
    nodejs \
    npm \
    xz

# Install lha tool for creating LHA archives (common for Amiga)
RUN wget https://github.com/fragglet/lhasa/releases/download/v0.4.0/lhasa-0.4.0.tar.gz && \
    tar -xzf lhasa-0.4.0.tar.gz && \
    cd lhasa-0.4.0 && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf lhasa-0.4.0 lhasa-0.4.0.tar.gz
    
# Create a non-root user with specified UID/GID
RUN addgroup -g $USER_GID $USERNAME && \
    adduser -D -s /bin/sh -G $USERNAME -u $USER_UID $USERNAME

# Set the working directory
WORKDIR /home/$USERNAME


RUN cp /usr/share/cmake/Modules/Platform/Generic.cmake /usr/share/cmake/Modules/Platform/amiga-elf.cmake

# Switch to the non-root user
USER $USERNAME

# Create the VSCode extensions directory
RUN mkdir -p /home/$USERNAME/.vscode/extensions

# Download and extract the Amiga Debug extension
RUN wget https://github.com/BartmanAbyss/vscode-amiga-debug/releases/download/1.7.9/amiga-debug-1.7.9.vsix \
    && mkdir -p /home/$USERNAME/.vscode/extensions/bartmanabyss.amiga-debug-1.7.9 \
    && unzip amiga-debug-1.7.9.vsix -d bartman-extension \
    && cp -a bartman-extension/extension/. /home/$USERNAME/.vscode/extensions/bartmanabyss.amiga-debug-1.7.9 \
    && rm -rf bartman-extension \
    && rm amiga-debug-1.7.9.vsix

RUN chmod -R 755 /home/$USERNAME/.vscode/extensions/bartmanabyss.amiga-debug-1.7.9/bin/linux


# Set environment variables
ENV PATH="/home/$USERNAME/.local/bin:${PATH}"
ENV VSCODE_AMIGA_EXTENSION_PATH=/home/$USERNAME/.vscode/extensions/bartmanabyss.amiga-debug-1.7.9

# Create projects directory
RUN mkdir -p /home/$USERNAME/projects

# Set the working directory to a commonly used location for code
WORKDIR /home/$USERNAME/projects

# Set the default command
CMD ["/bin/sh"]