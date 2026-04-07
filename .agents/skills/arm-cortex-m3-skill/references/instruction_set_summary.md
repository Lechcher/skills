# Instruction Set Summary

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
