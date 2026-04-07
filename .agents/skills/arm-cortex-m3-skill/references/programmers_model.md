# Programmers Model

Chapter 3
Programmers Model

This chapter describes the processor programmers model.
It contains the following sections:
• 3.1 About the programmers model on page 3-28.
• 3.2 Modes of operation and execution on page 3-29.
• 3.3 Instruction set summary on page 3-30.
• 3.4 Processor memory model on page 3-36.
• 3.5 Write buffer on page 3-39.
• 3.6 Exclusive monitor on page 3-40.
• 3.7 Bit-banding on page 3-41.
• 3.8 Processor core register summary on page 3-43.
• 3.9 Exceptions on page 3-45.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-27

3 Programmers Model
3.1 About the programmers model

3.1

About the programmers model
The Cortex-M3 programmers model is an implementation of the ARMv7-M architecture.
For a complete description of the programmers model, refer to the ARMv7-M Architecture Reference
Manual, which also contains the ARMv7-M Thumb® instructions the model uses. In addition, other
options of the programmers model are described in the System Control, MPU, NVIC, FPU, Debug,
DWT, ITM, and TPIU features topics.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-28

3 Programmers Model
3.2 Modes of operation and execution

3.2

Modes of operation and execution
The Cortex-M3 processor supports Thread and Handler operating modes, and may be run in Thumb or
Debug operating states. In addition, the processor can limit or exclude access to some resources by
executing code in privileged or unprivileged mode.
See the ARM®v7-M Architecture Reference Manual for more information about these modes of operation
and execution.
Operating modes
The conditions which cause the processor to enter Thread or Handler mode are as follows:
• The processor enters Thread mode on Reset, or as a result of an exception return. Privileged and
Unprivileged code can run in Thread mode.
• The processor enters Handler mode as a result of an exception. All code is privileged in Handler
mode.
Operating states
The processor can operate in thumb or debug state:
• Thumb state. This is normal execution running 16-bit and 32-bit halfword aligned Thumb
instructions.
• Debug State. This is the state when the processor is in halting debug.
Privileged access and user access
Handler mode is always privileged. Thread mode can be privileged or unprivileged.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-29

3 Programmers Model
3.3 Instruction set summary

3.3

Instruction set summary
The processor implements the ARMv7-M Thumb instruction set, and is binary compatible with the
instruction sets and features implemented in other Cortex-M profile processors. Instructions can be
paired in a way that achieves optimum reductions in timing.
This section contains the following subsections:
• 3.3.1 Processor instructions on page 3-30.
• 3.3.2 Load/store timings on page 3-34.
• 3.3.3 Binary compatibility with other Cortex® processors on page 3-35.

3.3.1

Processor instructions
The table summarizes the Cortex-M3 processor instruction set. For brevity, not all load and store
addressing modes are shown in the table. The cycle counts provided are based on a system with zero wait
states.
Within the assembler syntax, depending on the operation, the <op2> field can be replaced with one of the
following options:
•
•
•
•

A simple register specifier, for example Rm.
An immediate shifted register, for example Rm, LSL #4.
A register shifted register, for example Rm, LSL Rs.
An immediate value, for example #0xE000E000.

For brevity, not all load and store addressing modes are shown. See the ARMv7-M Architecture Reference
Manual for more information.
The following abbreviations are used in the Cycles column:
P
The number of cycles required for a pipeline refill. This ranges from 1 to 3 depending on the
alignment and width of the target instruction, and whether the processor manages to speculate
the address early.
B
The number of cycles required to perform the barrier operation. For DSB and DMB, the minimum
number of cycles is zero. For ISB, the minimum number of cycles is equivalent to the number
required for a pipeline refill.
N
The number of registers in the register list to be loaded or stored, including PC or LR.
W
The number of cycles spent waiting for an appropriate event.
Table 3-1 Cortex-M3 instruction set summary
Operation

Description

Assembler

Cycles

Move

Register

MOV Rd, <op2>

1

16-bit immediate

MOVW Rd, #<imm>

1

Immediate into top

MOVT Rd, #<imm>

1

To PC

MOV PC, Rm

1+P

Add

ADD Rd, Rn, <op2>

1

Add to PC

ADD PC, PC, Rm

1+P

Add with carry

ADC Rd, Rn, <op2>

1

Form address

ADR Rd, <label>

1

Add

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-30

3 Programmers Model
3.3 Instruction set summary

Table 3-1 Cortex-M3 instruction set summary (continued)
Operation

Description

Assembler

Cycles

Subtract

Subtract

SUB Rd, Rn, <op2>

1

Subtract with borrow

SBC Rd, Rn, <op2>

1

Reverse

RSB Rd, Rn, <op2>

1

Multiply

MUL Rd, Rn, Rm

1

Multiply accumulate

MLA Rd, Rn, Rm

2

Multiply subtract

MLS Rd, Rn, Rm

2

Long signed

SMULL RdLo, RdHi, Rn, Rm

3 to 5

Long unsigned

UMULL RdLo, RdHi, Rn, Rm

3 to 5

Long signed accumulate

SMLAL RdLo, RdHi, Rn, Rm

4 to 7

Long unsigned accumulate UMLAL RdLo, RdHi, Rn, Rm

4 to 7

Multiply

Divide

Saturate

Compare

Logical

Shift

Rotate

Count

ARM 100165_0201_02_en

Signed

SDIV Rd, Rn, Rm

2 to 12

Unsigned

UDIV Rd, Rn, Rm

2 to 12

Signed

SSAT Rd, #<imm>, <op2>

1

Unsigned

USAT Rd, #<imm>, <op2>

1

Compare

CMP Rn, <op2>

1

Negative

CMN Rn, <op2>

1

AND

AND Rd, Rn, <op2>

1

Exclusive OR

EOR Rd, Rn, <op2>

1

OR

ORR Rd, Rn, <op2>

1

OR NOT

ORN Rd, Rn, <op2>

1

Bit clear

BIC Rd, Rn, <op2>

1

Move NOT

MVN Rd, <op2>

1

AND test

TST Rn, <op2>

1

Exclusive OR test

TEQ Rn, <op1>

Logical shift left

LSL Rd, Rn, #<imm>

1

Logical shift left

LSL Rd, Rn, Rs

1

Logical shift right

LSR Rd, Rn, #<imm>

1

Logical shift right

LSR Rd, Rn, Rs

1

Arithmetic shift right

ASR Rd, Rn, #<imm>

1

Arithmetic shift right

ASR Rd, Rn, Rs

1

Rotate right

ROR Rd, Rn, #<imm>

1

Rotate right

ROR Rd, Rn, Rs

1

With extension

RRX Rd, Rn

1

Leading zeroes

CLZ Rd, Rn

1

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-31

3 Programmers Model
3.3 Instruction set summary

Table 3-1 Cortex-M3 instruction set summary (continued)
Operation

Description

Assembler

Cycles

Load

Word

LDR Rd, [Rn, <op2>]

2

To PC

LDR PC, [Rn, <op2>]

2+P

Halfword

LDRH Rd, [Rn, <op2>]

2

Byte

LDRB Rd, [Rn, <op2>]

2

Signed halfword

LDRSH Rd, [Rn, <op2>]

2

Signed byte

LDRSB Rd, [Rn, <op2>]

2

User word

LDRT Rd, [Rn, #<imm>]

2

User halfword

LDRHT Rd, [Rn, #<imm>]

2

User byte

LDRBT Rd, [Rn, #<imm>]

2

User signed halfword

LDRSHT Rd, [Rn, #<imm>]

2

User signed byte

LDRSBT Rd, [Rn, #<imm>]

2

PC relative

LDR Rd,[PC, #<imm>]

2

Doubleword

LDRD Rd, Rd, [Rn, #<imm>]

1+N

Multiple

LDM Rn, {<reglist>}

1+N

Multiple including PC

LDM Rn, {<reglist>, PC}

1+N+P

Word

STR Rd, [Rn, <op2>]

2

Halfword

STRH Rd, [Rn, <op2>]

2

Byte

STRB Rd, [Rn, <op2>]

2

Signed halfword

STRSH Rd, [Rn, <op2>]

2

Signed byte

STRSB Rd, [Rn, <op2>]

2

User word

STRT Rd, [Rn, #<imm>]

2

User halfword

STRHT Rd, [Rn, #<imm>]

2

User byte

STRBT Rd, [Rn, #<imm>]

2

User signed halfword

STRSHT Rd, [Rn, #<imm>]

2

User signed byte

STRSBT Rd, [Rn, #<imm>]

2

Doubleword

STRD Rd, Rd, [Rn, #<imm>]

1+N

Multiple

STM Rn, {<reglist>}

1+N

Push

PUSH {<reglist>}

1+N

Push with link register

PUSH {<reglist>, LR}

1+N

Pop

POP {<reglist>}

1+N

Pop and return

POP {<reglist>, PC}

1+N+P

Store

Push

Pop

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-32

3 Programmers Model
3.3 Instruction set summary

Table 3-1 Cortex-M3 instruction set summary (continued)
Operation

Description

Assembler

Cycles

Semaphore

Load exclusive

LDREX Rd, [Rn, #<imm>]

2

Load exclusive half

LDREXH Rd, [Rn]

2

Load exclusive byte

LDREXB Rd, [Rn]

2

Store exclusive

STREX Rd, Rt, [Rn, #<imm>] 2

Store exclusive half

STREXH Rd, Rt, [Rn]

2

Store exclusive byte

STREXB Rd, Rt, [Rn]

2

Clear exclusive monitor

CLREX

1

Conditional

B<cc> <label>

1 or 1 + P

Unconditional

B <label>

1+P

With link

BL <label>

1+P

With exchange

BX Rm

1+P

With link and exchange

BLX Rm

1+P

Branch if zero

CBZ Rn, <label>

1 or 1 + P

Branch if non-zero

CBNZ Rn, <label>

1 or 1 + P

Byte table branch

TBB [Rn, Rm]

2+P

Halfword table branch

TBH [Rn, Rm, LSL#1]

2+P

SVC #<imm>

-

If-then-else

IT... <cond>

1

Disable interrupts

CPSID <flags>

1 or 2

Enable interrupts

CPSIE <flags>

1 or 2

Read special register

MRS Rd, <specreg>

1 or 2

Write special register

MSR <specreg>, Rn

1 or 2

Breakpoint

BKPT #<imm>

-

Signed halfword to word

SXTH Rd, <op2>

1

Signed byte to word

SXTB Rd, <op2>

1

Unsigned halfword

UXTH Rd, <op2>

1

Unsigned byte

UXTB Rd, <op2>

1

Extract unsigned

UBFX Rd, Rn, #<imm>,
#<imm>

1

Extract signed

SBFX Rd, Rn, #<imm>,
#<imm>

1

Clear

BFC Rd, Rn, #<imm>, #<imm> 1

Insert

BFI Rd, Rn, #<imm>, #<imm> 1

Branch

State change Supervisor call

Extend

Bit field

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-33

3 Programmers Model
3.3 Instruction set summary

Table 3-1 Cortex-M3 instruction set summary (continued)
Operation

Description

Assembler

Cycles

Reverse

Bytes in word

REV Rd, Rm

1

Bytes in both halfwords

REV16 Rd, Rm

1

Signed bottom halfword

REVSH Rd, Rm

1

Bits in word

RBIT Rd, Rm

1

Send event

SEV

1

Wait for event

WFE

1+W

Wait for interrupt

WFI

1+W

No operation

NOP

1

Instruction
synchronization

ISB

1+B

Data memory

DMB

1+B

Data synchronization

DSB <flags>

1+B

Hint

Barriers

The following notes apply to the information in the table:
• UMULL, SMULL, UMLAL, and SMLAL instructions use early termination depending on the size of
the source values. These are interruptible, that is abandoned and restarted, with worst case latency of
one cycle.
• Neighboring load and store single instructions can pipeline their address and data phases. This
enables these instructions to complete in a single execution cycle.
• For branch operations, conditional branch completes in a single cycle if the branch is not taken.
• An IT instruction can be folded onto a preceding 16-bit Thumb instruction, enabling execution in
zero cycles.
3.3.2

Load/store timings
Instructions can be optimally paired to achieve more reductions in load and store timings.
The following information may help you to achieve further reductions in timing when pairing
instructions:
• STR Rx,[Ry,#imm] is always one cycle. This is because the address generation is performed in the
initial cycle, and the data store is performed at the same time as the next instruction is executing. If
the store is to the write buffer, and the write buffer is full or not enabled, the next instruction is
delayed until the store can complete. If the store is to the write buffer, for example to the Code
segment, and that transaction stalls, the impact on timing is only felt if another load or store operation
is executed before completion.
• LDR PC,[any] is always a blocking operation. This means at least two cycles for the load, and three
cycles for the pipeline reload. So this operation takes at least five cycles, or more if stalled on the
load or the fetch.
• Any load or store that generates an address dependent on the result of a preceding data processing
operation stalls the pipeline for an additional cycle while the register bank is updated. There is no
forwarding path for this scenario.
• LDR Rx,[PC,#imm] might add a cycle because of contention with the fetch unit.
• TBB and TBH are also blocking operations. These are at least two cycles for the load, one cycle for the
add, and three cycles for the pipeline reload. This means at least six cycles, or more if stalled on the
load or the fetch.
• LDR [any] are pipelined when possible. This means that if the next instruction is an LDR or STR, and
the destination of the first LDR is not used to compute the address for the next instruction, then one
cycle is removed from the cost of the next instruction. So, an LDR might be followed by an STR, so

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-34

3 Programmers Model
3.3 Instruction set summary

•

•
•
•

•

3.3.3

that the STR writes out what the LDR loaded. More multiple LDRs can be pipelined together. Some
optimized examples are:
— LDR R0,[R1]; LDR R1,[R2] - normally three cycles total.
— LDR R0,[R1,R2]; STR R0,[R3,#20] - normally three cycles total.
— LDR R0,[R1,R2]; STR R1,[R3,R2] - normally three cycles total.
— LDR R0,[R1,R5]; LDR R1,[R2]; LDR R2,[R3,#4] - normally four cycles total.
Other instructions cannot be pipelined after STR with register offset. STR can only be pipelined when
it follows an LDR, but nothing can be pipelined after the store. Even a stalled STR normally only takes
two cycles, because of the write buffer.
LDREX and STREX can be pipelined exactly as LDR. Because STREX is treated more like an LDR, it can
be pipelined as explained for LDR. Equally LDREX is treated exactly as an LDR and so can be pipelined.
LDRD and STRD cannot be pipelined with preceding or following instructions. However, the two words
are pipelined together. So, this operation requires three cycles when not stalled.
LDM and STM cannot be pipelined with preceding or following instructions. However, all elements
after the first are pipelined together. So, a three element LDM takes 2+1+1 or 4 cycles when not stalled.
Similarly, an eight element store takes nine cycles when not stalled. When interrupted, LDM and STM
instructions continue from where they left off when returned to. The continue operation adds one or
two cycles to the first element when started.
Unaligned word or halfword loads or stores add penalty cycles. A byte aligned halfword load or store
adds one extra cycle to perform the operation as two bytes. A halfword aligned word load or store
adds one extra cycle to perform the operation as two halfwords. A byte-aligned word load or store
adds two extra cycles to perform the operation as a byte, a halfword, and a byte. These numbers
increase if the memory stalls. A STR or STRH cannot delay the processor because of the write buffer.

Binary compatibility with other Cortex® processors
The processor implements a subset of the instruction set and features provided by the ARMv7-M
architecture profile, and is binary compatible with the instruction sets and features implemented in other
Cortex-M profile processors. You can move software, including system level software, from the
Cortex-M3 processor to other Cortex-M profile processors.
To ensure a smooth transition, ARM recommends that code designed to operate on other Cortex-M
profile processor architectures obeys the following rules and configures the Configuration and Control
Register (CCR) appropriately:
• Use word transfers only to access registers in the NVIC and System Control Space (SCS).
• Treat all unused SCS registers and register fields on the processor as Do-Not-Modify.
• Configure the following fields in the CCR:
— STKALIGN bit to 1.
— UNALIGN_TRP bit to 1.
— Leave all other bits in the CCR register as their original value.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-35

3 Programmers Model
3.4 Processor memory model

3.4

Processor memory model
The processor contains a bus matrix that arbitrates accesses to both the external memory system and to
the internal System Control Space (SCS) and debug components, supports ARMv7 unaligned accesses,
and performs all accesses as single, unaligned accesses.
Priority is always given to the processor to ensure that any debug accesses are as non-intrusive as
possible. For a zero wait state system, all debug accesses to system memory, SCS, and debug resources
are completely non-intrusive.
See the ARMv7-M Architecture Reference Manual for more information about the memory model.
The following figure shows the system address map.
0xE0100000
0xE00FF000
0xE0042000
0xE0041000
0xE0040000

ROM Table
External PPB
ETM
TPIU

0xFFFFFFFF
System
0xE0100000
Private peripheral bus - External
0xE0040000
Private peripheral bus - Internal

0xE0040000
0xE000F000
0xE000E000
0xE0003000
0xE0002000
0xE0001000
0xE0000000

Reserved
SCS
Reserved
FPB
DWT
ITM

0x44000000

0xE0000000

External device 1.0GB

0xA0000000

External RAM
32MB

1.0GB

Bit band alias

0x42000000

0x60000000
31MB

0x40100000
1MB
0x40000000
0x24000000
32MB

Peripheral

0.5GB

Bit band region
0x40000000
SRAM

Bit band alias

0.5GB

0x22000000

0x20000000
31MB

0x20100000
1MB
0x20000000

Code

0.5GB

Bit band region
0x00000000

Figure 3-1 System address map

This section contains the following subsections:
• 3.4.1 Memory regions table on page 3-36.
• 3.4.2 Private Peripheral Bus on page 3-37.
• 3.4.3 Unaligned accesses that cross regions on page 3-37.
3.4.1

Memory regions table
The table shows the processor interfaces that are addressed by the different memory map regions.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-36

3 Programmers Model
3.4 Processor memory model

Table 3-2 Memory regions
Memory Map

Region

Code

Instruction fetches are performed over the ICode bus. Data accesses are performed over the DCode bus.

SRAM

Instruction fetches and data accesses are performed over the system bus.

SRAM bit-band

Alias region. Data accesses are aliases. Instruction accesses are not aliases.

Peripheral

Instruction fetches and data accesses are performed over the system bus.

Peripheral bit-band

Alias region. Data accesses are aliases. Instruction accesses are not aliases.

External RAM

Instruction fetches and data accesses are performed over the system bus.

External Device

Instruction fetches and data accesses are performed over the system bus.

Private Peripheral Bus External and internal Private Peripheral Bus (PPB) interfaces.
This memory region is Execute Never (XN), and so instruction fetches are prohibited. An MPU, if present,
cannot change this.
System

3.4.2

System segment for vendor system peripherals. This memory region is XN, and so instruction fetches are
prohibited. An MPU, if present, cannot change this.

Private Peripheral Bus
The Private Peripheral Bus (PPB) memory region provides access to internal and external processor
resources.
The internal PPB provides access to:
•
•
•
•

The Instrumentation Trace Macrocell (ITM).
The Data Watchpoint and Trace (DWT).
The Flashpatch and Breakpoint (FPB).
The System Control Space (SCS), including the Memory Protection Unit (MPU) and the Nested
Vectored Interrupt Controller (NVIC).

The external PPB (EPPB) provides access to:
• The Embedded Trace Macrocell (ETM).
• The ROM table.
• Implementation-specific areas of the PPB memory map.
• CoreSight Micro Trace Buffer (MTB), if included.
• Cross Trigger Interface (CTI), if included.
3.4.3

Unaligned accesses that cross regions
The Cortex-M3 processor supports ARMv7 unaligned accesses, and performs all accesses as single,
unaligned accesses. They are converted into two or more aligned accesses by the DCode and System bus
interfaces.
Note
All Cortex-M3 external accesses are aligned.
Unaligned support is only available for load/store singles (LDR, LDRH, STR, STRH). Load/store double
already supports word aligned accesses, but does not permit other unaligned accesses, and generates a
fault if this is attempted.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-37

3 Programmers Model
3.4 Processor memory model

Unaligned accesses that cross memory map boundaries are architecturally UNPREDICTABLE. The processor
behavior is boundary dependent, as follows:
• DCode accesses wrap within the region. For example, an unaligned halfword access to the last byte
of Code space (0x1FFFFFFF) is converted by the DCode interface into a byte access to 0x1FFFFFFF
followed by a byte access to 0x00000000.
• System accesses that cross into PPB space do not wrap within System space. For example, an
unaligned halfword access to the last byte of System space (0xDFFFFFFF) is converted by the System
interface into a byte access to 0xDFFFFFFF followed by a byte access to 0xE0000000. 0xE0000000 is
not a valid address on the System bus.
• System accesses that cross into Code space do not wrap within System space. For example, an
unaligned halfword access to the last byte of System space (0xFFFFFFFF) is converted by the System
interface into a byte access to 0xFFFFFFFF followed by a byte access to 0x00000000. 0x00000000 is
not a valid address on the System bus.
• Unaligned accesses are not supported to PPB space, and so there are no boundary crossing cases for
PPB accesses.
Unaligned accesses that cross into the bit-band alias regions are also architecturally UNPREDICTABLE. The
processor performs the access to the bit-band alias address, but this does not result in a bit-band
operation. For example, an unaligned halfword access to 0x21FFFFFF is performed as a byte access to
0x21FFFFFF followed by a byte access to 0x22000000 (the first byte of the bit-band alias).
Unaligned loads that match against a literal comparator in the FPB are not remapped. FPB only remaps
aligned addresses.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-38

3 Programmers Model
3.5 Write buffer

3.5

Write buffer
To prevent bus wait cycles from stalling the processor during data stores, buffered stores to the DCode
and System buses go through a one-entry write buffer. If the write buffer is full, subsequent accesses to
the bus stall until the write buffer has drained.
The write buffer is only used if the bus waits the data phase of the buffered store, otherwise the
transaction completes on the bus.
DMB and DSB instructions wait for the write buffer to drain before completing. If an interrupt comes in
while DMB or DSB is waiting for the write buffer to drain, the processor returns to the instruction following
the DMB or DSB after the interrupt completes. This is because interrupt processing acts as a memory barrier
operation.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-39

3 Programmers Model
3.6 Exclusive monitor

3.6

Exclusive monitor
The Cortex-M3 processor implements a local exclusive monitor. The local monitor within the processor
has been constructed so that it does not hold any physical address, but instead treats any access as
matching the address of the previous LDREX. This means that the implemented exclusives reservation
granule is the entire memory address range.
The Cortex-M3 processor does not support exclusive accesses to bit-band regions.
For more information about semaphores and the local exclusive monitor, see the ARMv7-M Architecture
Reference Manual.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-40

3 Programmers Model
3.7 Bit-banding

3.7

Bit-banding
Bit-banding is an optional feature of the Cortex-M3 processor. Bit-banding maps a complete word of
memory onto a single bit in the bit-band region. For example, writing to one of the alias words sets or
clears the corresponding bit in the bit-band region.
This section contains the following subsections:
• 3.7.1 About bit-banding on page 3-41.
• 3.7.2 Directly accessing an alias region on page 3-42.
• 3.7.3 Directly accessing a bit-band region on page 3-42.

3.7.1

About bit-banding
Bit-banding enables every individual bit in the bit-banding region to be directly accessible from a wordaligned address using a single LDR instruction. It also enables individual bits to be toggled without
performing a read-modify-write sequence of instructions.
The processor memory map includes two bit-band regions. These occupy the lowest 1MB of the SRAM
and Peripheral memory regions respectively. These bit-band regions map each word in an alias region of
memory to a bit in a bit-band region of memory.
The System bus interface contains logic that controls bit-band accesses as follows:
•
•
•
•

It remaps bit-band alias addresses to the bit-band region.
For reads, it extracts the requested bit from the read byte, and returns this in the Least Significant Bit
(LSB) of the read data returned to the core.
For writes, it converts the write to an atomic read-modify-write operation.
The processor does not stall during bit-band operations unless it attempts to access the System bus
while the bit-band operation is being carried out.

The memory map has two 32MB alias regions that map to two 1MB bit-band regions:
•
•

Accesses to the 32MB SRAM alias region map to the 1MB SRAM bit-band region.
Accesses to the 32MB peripheral alias region map to the 1MB peripheral bit-band region.

A mapping formula shows how to reference each word in the alias region to a corresponding bit, or target
bit, in the bit-band region. The mapping formula is:
bit_word_offset = (byte_offset × 32) + (bit_number × 4)
bit_word_addr = bit_band_base + bit_word_offset

where:
•
•
•
•
•

bit_word_offset is the position of the target bit in the bit-band memory region.
bit_word_addr is the address of the word in the alias memory region that maps to the targeted bit.
bit_band_base is the starting address of the alias region.
byte_offset is the number of the byte in the bit-band region that contains the targeted bit.
bit_number is the bit position, 0 to 7, of the targeted bit.

The following figure shows examples of bit-band mapping between the SRAM bit-band alias region and
the SRAM bit-band region:
• The alias word at 0x23FFFFE0 maps to bit [0] of the bit-band byte at 0x200FFFFF: 0x23FFFFE0 =
0x22000000 + (0xFFFFF*32) + 0*4.
• The alias word at 0x23FFFFFC maps to bit [7] of the bit-band byte at 0x200FFFFF: 0x23FFFFFC =
0x22000000 + (0xFFFFF*32) + 7*4.
• The alias word at 0x22000000 maps to bit [0] of the bit-band byte at 0x20000000: 0x22000000 =
0x22000000 + (0*32) + 0*4.
• The alias word at 0x2200001C maps to bit [7] of the bit-band byte at 0x20000000: 0x2200001C =
0x22000000 + (0*32) + 7*4.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-41

3 Programmers Model
3.7 Bit-banding
32MB alias region
0x23FFFFFC

0x23FFFFF8

0x23FFFFF4

0x23FFFFF0

0x23FFFFEC

0x23FFFFE8

0x23FFFFE4

0x23FFFFE0

0x2200001C

0x22000018

0x22000014

0x22000010

0x2200000C

0x22000008

0x22000004

0x22000000

3

7

3

1MB SRAM bit-band region
7

6

5

4

3

2

1

0

7

6

0x200FFFFF

7

6

5

4

3

2

5

4

3

2

1

0

7

6

0x200FFFFE

1

0

7

6

0x20000003

5

4

3

2

0x20000002

5

4

2

1

0

6

0x200FFFFD

1

0

7

6

5

4

3

2

0x20000001

5

4

2

1

0

1

0

0x200FFFFC

1

0

7

6

5

4

3

2

0x20000000

Figure 3-2 Bit-band mapping

3.7.2

Directly accessing an alias region
Writing to a word in the alias region has the same effect as a read-modify-write operation on the targeted
bit in the bit-band region.
Bit [0] of the value written to a word in the alias region determines the value written to the targeted bit in
the bit-band region. Writing a value with bit [0] set writes a 1 to the bit-band bit, and writing a value with
bit [0] cleared writes a 0 to the bit-band bit.
Bits [31:1] of the alias word have no effect on the bit-band bit. Writing 0x01 has the same effect as
writing 0xFF. Writing 0x00 has the same effect as writing 0x0E.
Reading a word in the alias region returns either 0x01 or 0x00. A value of 0x01 indicates that the
targeted bit in the bit-band region is set. A value of 0x00 indicates that the targeted bit is clear. Bits
[31:1] are zero.

3.7.3

Directly accessing a bit-band region
You can directly access the bit-band region with normal reads and writes to that region.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-42

3 Programmers Model
3.8 Processor core register summary

3.8

Processor core register summary
The processor has 32-registers that includes 13 general-purpose registers and several special-purpose
registers.
The processor has the following 32-bit registers:
• 13 general-purpose registers, R0-R12.
• Stack Pointer (SP), R13 alias of banked registers, SP_process and SP_main.
• Link Register (LR), R14.
• Program Counter (PC), R15.
• Special-purpose Program Status Registers, (xPSR).
The following figure shows the processor register set.

low registers

high registers

Program Status Register

R0
R1
R2
R3
R4
R5
R6
R7
R8
R9
R10
R11
R12
R13 (SP)
R14 (LR)
R15 (PC)
xPSR

SP_process

SP_main

Figure 3-3 Processor register set

The general-purpose registers R0-R12 have no special architecturally-defined uses. Most instructions
that can specify a general-purpose register can specify R0-R12.
Low registers
Registers R0-R7 are accessible by all instructions that specify a general-purpose register.
High registers
Registers R8-R12 are accessible by all 32-bit instructions that specify a general-purpose register.
Registers R8-R12 are not accessible by any 16-bit instructions.
Registers R13, R14, and R15 have the following special functions:
Stack pointer
Register R13 is used as the Stack Pointer (SP). Because the SP ignores writes to bits [1:0], it is
autoaligned to a word, four-byte boundary.
Handler mode always uses SP_main, but you can configure Thread mode to use either SP_main
or SP_process.
Link register
Register R14 is the subroutine Link Register (LR).
The LR receives the return address from PC when a Branch and Link (BL) or Branch and Link
with Exchange (BLX) instruction is executed.
The LR is also used for exception return.
At all other times, you can treat R14 as a general-purpose register.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-43

3 Programmers Model
3.8 Processor core register summary

Program counter
Register R15 is the Program Counter (PC).
Bit [0] is always 0, so instructions are always aligned to word or halfword boundaries.
See the ARMv7-M Architecture Reference Manual for more information.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-44

3 Programmers Model
3.9 Exceptions

3.9

Exceptions
Exceptions are handled and prioritized by the processor and the NVIC. In addition to architecturally
defined behavior, the processor implements advanced exception and interrupt handling that reduces
interrupt latency and includes implementation defined behavior.
This section contains the following subsections:
• 3.9.1 Exception handling and prioritization on page 3-45.
• 3.9.2 Interrupt latency on page 3-45.
• 3.9.3 Base register update in LDM and STM operations on page 3-46.

3.9.1

Exception handling and prioritization
The processor and the Nested Vectored Interrupt Controller (NVIC) prioritize and handle all exceptions.
When handling exceptions:
•
•
•

All exceptions are handled in Handler mode.
Processor state is automatically stored to the stack on an exception, and automatically restored from
the stack at the end of the Interrupt Service Routine (ISR).
The vector is fetched in parallel to the state saving, enabling efficient interrupt entry.

The processor supports tail-chaining that enables back-to-back interrupts without the overhead of state
saving and restoration.
You configure the number of interrupts, and bits of interrupt priority, during implementation. Software
can choose only to enable a subset of the configured number of interrupts, and can choose how many bits
of the configured priorities to use.
Note
Vector table entries are compatible with interworking between ARM and Thumb instructions. This
causes bit[0] of the vector value to load into the Execution Program Status Register (EPSR) T-bit on
exception entry. All populated vectors in the vector table entries must have bit[0] set. Creating a table
entry with bit[0] clear generates an INVSTATE fault on the first instruction of the handler corresponding
to this vector.

3.9.2

Interrupt latency
The processor implements advanced exception and interrupt handling that reduces interrupt latency, and
includes implementation defined behavior in addition to the architecturally defined behavior.
To reduce interrupt latency, the processor implements both interrupt late-arrival and interrupt tailchaining mechanisms, as defined by the ARMv7-M architecture:
•
•
•

There is a maximum of a twelve cycle latency from asserting the interrupt to execution of the first
instruction of the ISR when the memory being accessed has no wait states being applied. The first
instruction to be executed is fetched in parallel to the stack push.
Returns from interrupts similarly take twelve cycles where the instruction being returned to is fetched
in parallel to the stack pop.
Tail chaining requires six cycles when using zero wait state memory. No stack pushes or pops are
performed and only the instruction for the next ISR is fetched.

The processor exception model has the following implementation-defined behavior in addition to the
architecturally defined behavior:
• Exceptions on stacking from HardFault to NMI lockup at NMI priority.
• Exceptions on unstacking from NMI to HardFault lockup at HardFault priority.
To minimize interrupt latency, the processor abandons any divide instruction to take any pending
interrupt. On return from the interrupt handler, the processor restarts the divide instruction from the
beginning. The processor implements the Interruptible-continuable Instruction field. Load multiple (LDM)
ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-45

3 Programmers Model
3.9 Exceptions

operations and store multiple (STM) operations are interruptible. The EPSR holds the information
required to continue the load or store multiple from the point where the interrupt occurred.
This means that software must not use load-multiple or store-multiple instructions to access a device or
access a memory region that is read-sensitive or sensitive to repeated writes. The software must not use
these instructions in any case where repeated reads or writes might cause inconsistent results or
unwanted side-effects.
For more information, see the ARMv7-M Architecture Reference Manual.
3.9.3

Base register update in LDM and STM operations
When the instruction specifies base register write-back, the base register changes to the updated address
(an abort restores the original base value). When the base register is in the register list of an LDM, and is
not the last register in the list, the base register changes to the loaded value.
An LDM or STM is restarted rather than continued if:
• The instruction faults.
• The instruction is inside an IT.
If an LDM has completed a base load, it is continued from before the base load.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

3-46