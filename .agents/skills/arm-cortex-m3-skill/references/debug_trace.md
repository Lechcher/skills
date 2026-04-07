# Debug and Trace Architecture

This document summarizes Chapters 7, 8, 9, 10, and 11 of the Cortex-M3 TRM regarding the debug and trace configuration.

## Debug Configuration
The Cortex-M3 uses the ARM CoreSight debug architecture. Features are optional based on the silicon vendor's implementation but generally include:
- Halting debug (allowing the processor to be halted and state examined).
- Monitor debug (a DebugMonitor exception `DebugMon` occurring, enabling self-hosted debug).
- Serial Wire Debug (SWD) and JTAG connections.

## Data Watchpoint and Trace Unit (DWT)
The DWT contains up to four comparators. It provides:
- Watchpoints (hardware breakpoints) for data memory addresses.
- Data tracing.
- Cycle counting (optional CYCCNT register, operating at core clock speed).
- Sleep and interrupt profiling.

## Instrumentation Trace Macrocell (ITM)
The ITM provides software-driven trace. It allows printf-style debugging via trace ports without halting the system.
- 32 stimulus ports are provided for software to write to.
- Generates packets timestamped by the DWT.
- Outputs via the SWO (Serial Wire Output) or TPIU.

## FPB (Flash Patch and Breakpoint Unit)
The FPB implements hardware breakpoints.
- Can remap instructions from Code space to SRAM space.
- Provides up to 6 instruction breakpoints and 2 literal breakpoints.

## Embedded Trace Macrocell (ETM) (Optional)
When implemented, the ETM provides full instruction trace.
- Traces program flow out in real-time.
- Captures context IDs and instruction addresses.
- Very high bandwidth trace requires the TPIU and an external trace capture device (e.g., DSTREAM).

## TPIU (Trace Port Interface Unit)
Formats output from the ITM and ETM into trace streams for capture by an external Trace Port Analyzer (TPA) or logic analyzer.
