# ARM Cortex-M3 TRM Core Summary

This document distills Chapter 1 (Introduction), Chapter 2 (Functional Description), and Chapter 3 (Programmers Model) of the ARM Cortex-M3 Technical Reference Manual.

## Processor Features List
The Cortex-M3 is a 32-bit high-performance processor designed for microcontroller applications. Key features:
- **ARMv7-M Architecture**: Extensively implements the Thumb-2 instruction set, providing a blend of 16-bit and 32-bit instructions without mode switching.
- **Harvard Architecture**: Separate instruction and data buses linked to a unified memory space.
- **Nested Vectored Interrupt Controller (NVIC)**: Highly deterministic, low-latency interrupt processing integrated closely with the core.
- **3-stage Pipeline**: Fetch, Decode, Execute with branch speculation.
- **Hardware Divide and Single-Cycle Multiply**: Fast execution for arithmetic operations.
- **Debug and Trace**: Extensive features (DWT, ITM, ETM, TPIU, FPB) without interrupting normal execution.

## Programmers Model
The Cortex-M3 has two modes and two privilege levels:

### Modes
1. **Thread Mode**: Used to execute application software. The processor enters Thread mode when it comes out of reset.
2. **Handler Mode**: Used to handle exceptions. The processor returns to Thread mode when it has finished processing all exceptions.

### Privilege Levels
- **Unprivileged**: Has limited access to system resources. Cannot execute MSR/MRS to core control registers (except APSR). Cannot access the System Timer, NVIC, or system control block.
- **Privileged**: Has full access to all resources. Handler mode is always privileged. Thread mode can be privileged or unprivileged (controlled via the `CONTROL` register).

### Core Registers
- **R0-R12**: General-purpose registers. R0-R7 are low registers (accessible by all Thumb instructions), R8-R12 are high registers.
- **R13 (SP)**: Stack Pointer. The M3 implements two stack pointers: Main Stack Pointer (MSP) and Process Stack Pointer (PSP). Only one is visible as R13 at a time.
- **R14 (LR)**: Link Register. Holds the return address for subroutines or an `EXC_RETURN` value during exception processing.
- **R15 (PC)**: Program Counter.
- **PSR**: Program Status Register (combines APSR, IPSR, EPSR).
- **PRIMASK**: 1-bit register used to disable all exceptions with configurable priority.
- **FAULTMASK**: 1-bit register used to disable all exceptions except NMI.
- **BASEPRI**: Defines the minimum priority for exception processing.
- **CONTROL**: Defines the privilege level in Thread mode and which stack pointer to use (MSP or PSP).

## Instruction Set Summary
- Support for Thumb and Thumb-2 instructions.
- No support for ARM (32-bit only encoded) instructions.
- Provides specialized instructions for bit manipulation (BFC, BFI, SBFX, UBFX).
- Table branch instructions (TBB, TBH) for efficient switch statement implementation.
- Exclusive access instructions (LDREX, STREX) for synchronization primitives.
