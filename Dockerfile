FROM ubuntu:jammy

# Build type argument: release or debug (default: release)
ARG BUILD_TYPE=release

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

# Download and setup Nordic SDK
RUN library_sdk_path="libraries/SDK" && \
    nordic_sdk_version="17.1.0_ddde560" && \
    nordic_sdk_path="nRF5_SDK_${nordic_sdk_version}" && \
    nordic_sdk_zip="nRF5_SDK_${nordic_sdk_version}.zip" && \
    nordic_sdk_url="https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/sdks/nrf5/binaries/nrf5_sdk_${nordic_sdk_version}.zip" && \
    mkdir -p ${library_sdk_path} && cd ${library_sdk_path} && \
    wget -q -O ${nordic_sdk_zip} ${nordic_sdk_url} && \
    unzip -q ${nordic_sdk_zip} && \
    rm ${nordic_sdk_zip}

# Copy the project files into the container
WORKDIR /code
COPY . .

# Build the project with the specified build type
WORKDIR /code/build
RUN make ${BUILD_TYPE}
