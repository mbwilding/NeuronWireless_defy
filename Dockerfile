FROM ubuntu:jammy

# Build type argument: release or debug (default: release)
ARG BUILD_TYPE=release

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LIBRARY_SDK_PATH="libraries/SDK" \
    NORDIC_SDK_PATH="nRF5_SDK_17.1.0_ddde560" \
    NORDIC_SDK_ZIP="nRF5_SDK_17.1.0_ddde560.zip" \
    NORDIC_SDK_URL="https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/sdks/nrf5/binaries/nrf5_sdk_17.1.0_ddde560.zip"

# Download and setup Nordic SDK
RUN mkdir -p ${LIBRARY_SDK_PATH} && cd ${LIBRARY_SDK_PATH} && \
    wget -O ${NORDIC_SDK_ZIP} ${NORDIC_SDK_URL} && \
    unzip ${NORDIC_SDK_ZIP} && \
    rm ${NORDIC_SDK_ZIP}

# Install prerequisites
RUN apt-get update -y && apt-get install -y \
    build-essential \
    wget \
    make \
    gcc-arm-none-eabi \
    software-properties-common \
    python3.11 \
    python3-pip \
    unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set to use python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --set python3 /usr/bin/python3.11

# Install intelhex
RUN pip3 install intelhex

# Copy the project files into the container
COPY . .
WORKDIR /build

# Build the project with the specified build type
RUN make ${BUILD_TYPE}
