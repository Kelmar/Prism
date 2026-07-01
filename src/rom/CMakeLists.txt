cmake_minimum_required(VERSION 3.22.1)

find_program(_CL65 cl65)
find_program(_CA65 cl65)

set(CMAKE_C_COMPILER ${_CL65})
set(CMAKE_C_COMPILER_ID cc65)
set(CMAKE_ASM_COMPILER ${_CA65})
set(CMAKE_ASM_COMPILER_ID ca65)

find_program(_AR ar65)
set(CMAKE_AR "${_AR}" CACHE FILEPATH "Archiver path override (prevents issues with cmake)")

project(rom ASM)

set(sources
    bios/reset.s
    bios/drivers/Prism1/prism1.s
    bios/drivers/Prism1/u26C92.s
    #bios/ksim.s
    bios/io.s
    bios/syscall.s
    bios/vectors.s
    monitor/monitor.s
)

add_executable(rom ${sources})

set_target_properties(rom
    PROPERTIES
        OUTPUT_NAME prism.rom
        COMPILE_FLAGS "-t none -v -g --cpu 65816 --asm-include-dir ${CMAKE_CURRENT_SOURCE_DIR}/../inc"
        LINK_FLAGS "-t none -C ${CMAKE_CURRENT_SOURCE_DIR}/prism.cfg")