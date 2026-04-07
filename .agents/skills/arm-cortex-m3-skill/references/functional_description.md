# Functional Description

Chapter 2
Functional Description

This chapter introduces the processor and its external interfaces.
It contains the following sections:
• 2.1 About the functions on page 2-22.
• 2.2 Processor features list on page 2-23.
• 2.3 Interfaces on page 2-24.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

2-21

2 Functional Description
2.1 About the functions

2.1

About the functions
Block diagram of the processor, showing main functional components and interfaces.
Cortex-M3 processor
Nested
Vectored
Interrupt
Controller
(NVIC)

Interrupts and
power control

†

Wake-up
Interrupt
Controller
(WIC)

† Serial-Wire
or JTAG
Debug Port
(SW-DP or
SWJ-DP)

Serial-Wire or
JTAG Debug
Interface

†

†
Flash Patch
Breakpoint
(FPB)

†

Cortex-M3
processor core

†
Memory
Protection
Unit (MPU)

†

Data
Watchpoint
and Trace
(DWT)

†
AHB
Access Port
(AHB-AP)

ICode
AHB-Lite
instruction
interface

Bus Matrix

DCode
AHB-Lite
data
interface

System
AHB-Lite
system
interface

Embedded
Trace
Macrocell
(ETM)

†
Instrumentation
Trace Macrocell
(ITM)

Trace Port
Interface Unit
(TPIU)

† CoreSight
ROM table

Trace Port
Interface
PPB APB
debug system
interface

† Optional component

Figure 2-1 Cortex-M3 block diagram

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

2-22

2 Functional Description
2.2 Processor features list

2.2

Processor features list
The processor features list includes a low gate count processor core, an optional memory protection unit,
a low-cost debug solution, together with bus interfaces that includes three Advanced High-performance
Bus-Lite (AHB-Lite) interfaces and a Private Peripheral Bus (PPB).
The processor features list comprises:
• A low gate count processor core, with low latency interrupt processing that has:
— A subset of the Thumb instruction set, defined in the ARMv7-M Architecture Reference Manual.
— Banked Stack Pointer (SP).
— Hardware integer divide instructions, SDIV and UDIV.
— Handler and Thread modes.
— Thumb and Debug states.
— Support for interruptible-continued instructions LDM, STM, PUSH, and POP for low interrupt latency.
— Automatic processor state saving and restoration for low latency Interrupt Service Routine (ISR)
entry and exit.
— Support for ARMv6 big-endian byte-invariant or little-endian accesses.
— Support for ARMv6 unaligned accesses.
• Nested Vectored Interrupt Controller (NVIC) closely integrated with the processor core to achieve
low latency interrupt processing. Features include:
— External interrupts, configurable from 1 to 240.
— Bits of priority, configurable from 3 to 8.
— Dynamic reprioritization of interrupts.
— Priority grouping. This enables selection of preempting interrupt levels and non preempting
interrupt levels.
— Support for tail-chaining and late arrival of interrupts. This enables back-to-back interrupt
processing without the overhead of state saving and restoration between interrupts.
— Processor state automatically saved on interrupt entry, and restored on interrupt exit, with no
instruction overhead.
— Optional Wake-up Interrupt Controller (WIC), providing ultra-low power sleep mode support.
• Memory Protection Unit (MPU). An optional MPU for memory protection, including:
— Eight memory regions.
— Sub Region Disable (SRD), enabling efficient use of memory regions.
— The ability to enable a background region that implements the default memory map attributes.
• Bus interfaces:
— Three Advanced High-performance Bus-Lite (AHB-Lite) interfaces: ICode, DCode, and System
bus interfaces.
— Private Peripheral Bus (PPB) based on Advanced Peripheral Bus (APB) interface.
— Bit-band support that includes atomic bit-band write and read operations.
— Memory access alignment.
— Write buffer for buffering of write data.
— Exclusive access transfers for multiprocessor systems.
• Low-cost debug solution that features:
— Debug access to all memory and registers in the system, including access to memory mapped
devices, access to internal core registers when the core is halted, and access to debug control
registers even while SYSRESETn is asserted.
— Serial Wire Debug Port (SW-DP) or Serial Wire JTAG Debug Port (SWJ-DP) debug access.
— Optional Flash Patch and Breakpoint (FPB) unit for implementing breakpoints and code patches.
— Optional Data Watchpoint and Trace (DWT) unit for implementing watchpoints, data tracing, and
system profiling.
— Optional Instrumentation Trace Macrocell (ITM) for support of printf() style debugging.
— Optional Trace Port Interface Unit (TPIU) for bridging to a Trace Port Analyzer (TPA), including
Single Wire Output (SWO) mode.
— Optional Embedded Trace Macrocell (ETM) for instruction trace.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

2-23

2 Functional Description
2.3 Interfaces

2.3

Interfaces
The processor incorporates three external bus interfaces, an ETM interface that allows the connection of
an Embedded Trace Macrocell, an AHB Trace Macrocell interface that enables simple connection of an
ETM to the processor, and an Advanced High-performance Bus Access Port (AHB-AP) interface for
debug accesses.
This section contains the following subsections:
• 2.3.1 Bus interfaces on page 2-24.
• 2.3.2 ETM interface on page 2-25.
• 2.3.3 AHB Trace Macrocell interface on page 2-25.
• 2.3.4 Debug Port AHB-AP interface on page 2-26.

2.3.1

Bus interfaces
The Cortex-M3 processor contains three external Advanced High-performance Bus (AHB)-Lite bus
interfaces and one Advanced Peripheral Bus (APB) interface.
The processor matches the AMBA 3 specification except for maintaining control information during
waited transfers. The AMBA 3 AHB-Lite Protocol states that when the slave is requesting wait states the
master must not change the transfer type, except for the following cases:
• On an IDLE transfer, the master can change the transfer type from IDLE to NONSEQ.
• On a BUSY transfer with a fixed length burst, the master can change the transfer type from BUSY to
SEQ.
• On a BUSY transfer with an undefined length burst, the master can change the transfer type from
BUSY to any other transfer type.
The processor does not match this definition because it might change the access type from SEQ or
NONSEQ to IDLE during a waited transfer. The processor might also change the address or other control
information and therefore request an access to a new location. The original address that was retracted
might not be requested again. This cancels the outstanding transfer that has not occurred because the
previous access is wait-stated and awaiting completion. This is done so that the processor can have a
lower interrupt latency and higher performance in wait-stated systems by retracting accesses that are no
longer required.
To achieve complete compliance with the AMBA 3 specification you can implement the design with the
AHB_CONST_CTRL parameter set to 1. This ensures that when transfers are issued during a wait-stated
response they are never retracted or modified and the original transfer is honored. The consequence of
setting this parameter is that the performance of the core might decrease for wait-stated systems as a
result of the interrupt and branch latency increasing.
ICode memory interface
Instruction fetches from Code memory space 0x00000000 to 0x1FFFFFFF are performed over the 32-bit
AHB-Lite bus.
The Debugger cannot access this interface. All fetches are word-wide. The number of instructions
fetched per word depends on the code running and the alignment of the code in memory.
DCode memory interface
Data and debug accesses to Code memory space 0x00000000 to 0x1FFFFFFF are performed over the 32bit AHB-Lite bus.
Core data accesses have a higher priority than debug accesses on this bus. This means that debug
accesses are waited until core accesses have completed when there are simultaneous core and debug
access to this bus.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

2-24

2 Functional Description
2.3 Interfaces

Control logic in this interface converts unaligned data and debug accesses into two or three aligned
accesses, depending on the size and alignment of the unaligned access. This stalls any subsequent data or
debug access until the unaligned access has completed.
Note
ARM strongly recommends that any external arbitration between the ICode and DCode AHB bus
interfaces ensures that DCode has a higher priority than ICode.

System interface
Instruction fetches and data and debug accesses to address ranges 0x20000000 to 0xDFFFFFFF and
0xE0100000 to 0xFFFFFFFF are performed over the 32-bit AHB-Lite bus.
For simultaneous accesses to the 32-bit AHB-Lite bus, the arbitration order in decreasing priority is:
• Data accesses.
• Instruction and vector fetches.
• Debug.
The system bus interface contains control logic to handle unaligned accesses, FPB remapped accesses,
bit-band accesses, and pipelined instruction fetches.
Private Peripheral Bus (PPB)
Data and debug accesses to external PPB space 0xE0040000 to 0xE00FFFFF are performed over the 32bit Advanced Peripheral Bus (APB) bus.
The Trace Port Interface Unit (TPIU) and vendor specific peripherals are on the 32-bit Advanced
Peripheral Bus (APB) bus.
Core data accesses have higher priority than debug accesses, so debug accesses are waited until core
accesses have completed when there are simultaneous core and debug accesses to this bus. Only the
address bits necessary to decode the External PPB space are supported on this interface.
The External PPB (EPPB) space, 0xE0040000 up to 0xE0100000, is intended for CoreSight-compatible
debug and trace components, and has a number of irregular limitations which make it less useful for
regular system peripherals. ARM recommends that system peripherals are placed in suitable Device type
areas of the System bus address space, with use of an AHB2APB protocol converter for APB-based
devices.
Limitations of the EPPB space are:
• It is accessible in privileged mode only.
• It is accessed in little-endian fashion irrespective of the data endianness setting of the processor.
• Accesses behave as Strongly Ordered.
• No bit-band function is available.
• Unaligned accesses have Unpredictable results.
• Only 32-bit data accesses are supported.
• It is accessible from the Debug Port and the local processor, but not from any other processor in the
system.
2.3.2

ETM interface
The ETM interface enables simple connection of an ETM to the processor. It provides a channel for
instruction trace to the ETM.
See the ARM Embedded Trace Macrocell Architecture Specification.

2.3.3

AHB Trace Macrocell interface
The AHB Trace Macrocell (HTM) interface enables a simple connection of the AHB trace macrocell to
the processor, and provides a channel for the data trace to the HTM.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

2-25

2 Functional Description
2.3 Interfaces

Your implementation must include this interface to use the HTM interface. You must set TRCENA to 1
in the Debug Exception and Monitor Control Register (DEMCR) before you enable the HTM port to
supply trace data. See the ARM®v7-M Architecture Reference Manual.
2.3.4

Debug Port AHB-AP interface
The processor contains an Advanced High-performance Bus Access Port (AHB-AP) interface for debug
accesses. An external Debug Port (DP) component accesses this interface.
The Cortex-M3 system supports three possible DP implementations:
•
•
•

The Serial Wire JTAG Debug Port (SWJ-DP). The SWJ-DP is a standard CoreSight debug port that
combines JTAG-DP and Serial Wire Debug Port (SW-DP).
The SW-DP. This provides a two-pin interface to the AHB-AP port.
No DP present. If no debug functionality is present within the processor, a DP is not required.

The two DP implementations provide different mechanisms for debug access to the processor. Your
implementation must contain only one of these components.
Note
Your implementation might contain an alternative implementer-specific DP instead of SW-DP or SWJDP. See your implementer for details.
For more detailed information on the DP components, see the CoreSight™ Components Technical
Reference manual.
The DP and AP together are referred to as the Debug Access Port (DAP).
For more detailed information on the debug interface, see the ARM® Debug Interface v5 Architecture
Specification.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

2-26