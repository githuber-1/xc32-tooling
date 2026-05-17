# Builds XC32 container in two steps in order to ensure size of the final image is reasonable
# A single stage build captures 8.9GB history
# --- Stage 1: The Builder ---
FROM ubuntu:22.04 AS builder

# Set paths
ENV XC32_DIR=/opt/microchip/xc32
COPY xc32-5.0.0-atsam.tar.gz /tmp/

RUN apt-get update && apt-get install -y unzip

RUN mkdir -p ${XC32_DIR} \
    && tar xzf /tmp/xc32-5.0.0-atsam.tar.gz -C ${XC32_DIR} --wildcards '*/xc32-atsam/*' --strip-components=3 \
    # Remove documentation and examples immediately (saves ~500MB+)
    && rm -rf ${XC32_DIR}/docs ${XC32_DIR}/examples \
    # TRIM THE LIBRARIES: Keep only the Cortex-M7 (v7e-m) libraries
    && cd ${XC32_DIR}/pic32c/lib/thumb \
    && find . -maxdepth 1 -type d ! -name "." ! -name "v7e-m" -exec rm -rf {} + \
    # Extract DFP
    && unzip ${XC32_DIR}/packs/Microchip.SAMRH707_DFP.1.2.156.atpack -d ${XC32_DIR}/packs/SAMRH707_DFP_EXTRACTED \
    && rm ${XC32_DIR}/packs/Microchip.SAMRH707_DFP.1.2.156.atpack

# --- Stage 2: The Final Image ---
FROM ubuntu:22.04
ENV XC32_DIR=/opt/microchip/xc32
ENV PATH="${XC32_DIR}/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    libusb-1.0-0 \
    make \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# This COPY only brings over the trimmed 1-2GB, NOT the 8GB+ history
COPY --from=builder /opt/microchip/xc32 /opt/microchip/xc32

WORKDIR /workspace