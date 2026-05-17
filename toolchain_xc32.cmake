set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Base directories
set(XC32_ROOT "/opt/microchip/xc32")
set(DFP_ROOT "${XC32_ROOT}/packs/SAMRH707_DFP_EXTRACTED")

# Use the inner binary to avoid the wrapper issues we saw
set(CMAKE_C_COMPILER "${XC32_ROOT}/bin/bin/pic32c-gcc")
set(CMAKE_CXX_COMPILER "${XC32_ROOT}/bin/bin/pic32c-g++")

# 1. Base Device Flags
set(DEVICE_FLAGS "-mprocessor=ATSAMRH707F18A -mdfp=${DFP_ROOT}")

# 3. Architecture Overrides
# The log shows it is looking for core_cm7.h, so we use cortex-m7
# We use -mfloat-abi=soft for now to bypass FPU header errors
set(FLAGS "-mprocessor=ATSAMRH707F18A -mdfp=${DFP_ROOT} -mcpu=cortex-m7 -mthumb -mfloat-abi=soft -ffreestanding -D__SAMRH707F18A__")

# 2. Add Missing CMSIS and Standard Library include paths
# These paths are typical for XC32 v5.00 DFP structures
set(INC_FLAGS 
    "-I${XC32_ROOT}/lib/gcc/pic32c/13.2.1/include"
    "-I${XC32_ROOT}/pic32c/include/picolibc"
    "-I${XC32_ROOT}/pic32c/include/CMSIS/Core/Include"
    "-I${DFP_ROOT}/include"
    "-I${DFP_ROOT}/xc32/include"
)

# Combine them all
set(FLAGS "${DEVICE_FLAGS} ${ARCH_FLAGS} ${INCLUDE_FLAGS}")

# Apply to the EXE_LINKER_FLAGS cache
set(CMAKE_EXE_LINKER_FLAGS "${LINKER_FLAGS}" CACHE STRING "Linker flags for ATSAM" FORCE)

set(CMAKE_C_FLAGS "${FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${FLAGS}" CACHE STRING "" FORCE)

# Skip the link test as before
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)