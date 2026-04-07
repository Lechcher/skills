# Memory Map and System Control

This document compiles information from Chapters 4 (System Control), 5 (MPU), and sections of Chapter 3 concerning the ARM Cortex-M3 memory model.

## Fixed Memory Map
The processor has a fixed, standardized 4GB memory map to ensure software portability across different Cortex-M3 implementations:
- **0x00000000 - 0x1FFFFFFF**: Code (0.5GB)
- **0x20000000 - 0x3FFFFFFF**: SRAM (0.5GB)
- **0x40000000 - 0x5FFFFFFF**: Peripheral (0.5GB)
- **0x60000000 - 0x9FFFFFFF**: External RAM (1GB)
- **0xA0000000 - 0xDFFFFFFF**: External Device (1GB)
- **0xE0000000 - 0xE00FFFFF**: Private Peripheral Bus (PPB) (1MB) - Includes NVIC, System Timer, SCB, Debug, traces.
- **0xE0100000 - 0xFFFFFFFF**: Vendor-specific / Device (0.5GB - 1MB)

## Bit-Banding
The Cortex-M3 includes bit-band regions in the SRAM and Peripheral map that map a single bit to an entire 32-bit word, allowing atomic bit-level manipulation without LDREX/STREX.
- **SRAM bit-band region**: `0x20000000 - 0x200FFFFF` (1MB). Mapped to alias region: `0x22000000 - 0x23FFFFFF` (32MB).
- **Peripheral bit-band region**: `0x40000000 - 0x400FFFFF` (1MB). Mapped to alias region: `0x42000000 - 0x43FFFFFF` (32MB).

*Bit-band formula*:
`alias_word_address = alias_region_base + (byte_offset * 32) + (bit_number * 4)`

## System Control Space (SCS)
Registers inside the PPB memory region controlling core behavior:
- **CPUID Base Register**: `0xE000ED00`. Contains implementer, variant, and part number details.
- **Interrupt Control and State Register (ICSR)**: `0xE000ED04`. Controls pending NMI/PendSV/SysTick and indicates the active exception.
- **Vector Table Offset Register (VTOR)**: `0xE000ED08`. Offsets the vector table base address from `0x00000000`.
- **Application Interrupt and Reset Control Register (AIRCR)**: Controls endianness and system reset features. Includes PRIGROUP field.
- **System Handler Priority Registers (SHPR1-3)**: Priorities for fault handlers and system exceptions (SysTick, PendSV, SVC).
- **System Handler Control and State Register (SHCSR)**: Enables UsageFault, BusFault, and MemManage faults.

## Memory Protection Unit (MPU)
Optional component providing 8 distinct memory regions.
- Regions can be configured for size (from 32 bytes to 4GB) and access permissions (Privileged/User read-write, read-only, execute-never XN).
- Regions can overlap; the higher numbered region's attributes take precedence.
- Registers include `MPU_TYPE`, `MPU_CTRL`, `MPU_RNR` (Region Number Register), `MPU_RBAR` (Region Base Address Register), and `MPU_RASR` (Region Attribute and Size Register).
