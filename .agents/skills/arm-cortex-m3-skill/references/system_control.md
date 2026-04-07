# System Control

Chapter 4
System Control

This chapter provides a summary of the system control registers whose implementation is specific to the
Cortex-M3 processor.
Registers not described here are described in the ARM®v7-M Architecture Reference Manual.
It contains the following sections:
• 4.1 System control registers on page 4-48.
• 4.2 Auxiliary Control Register, ACTLR on page 4-50.
• 4.3 CPUID Base Register, CPUID on page 4-51.
• 4.4 Auxiliary Fault Status Register, AFSR on page 4-52.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

4-47

4 System Control
4.1 System control registers

4.1

System control registers
List of system control registers whose implementation is specific to the Cortex-M3 processor.
Registers not described in the table are described in the ARMv7-M Architecture Reference Manual.
Table 4-1 System control registers

Address

Name

Type

Reset

Description

0xE000E008 ACTLR

RW

0x00000000

Refer to the Auxiliary Control Register, ACTLR

0xE000E010 STCSR

RW

0x00000000

SysTick Control and Status Register

0xE000E014 STRVR

RW

Unknown

SysTick Reload Value Register

0xE000E018 STCVR

RW clear

Unknown

SysTick Current Value Register

0xE000E01C STCR

RO

Implementation specific SysTick Calibration Value Register

0xE000ED00 CPUID

RO

0x412FC231

0xE000ED04 ICSR

RW or RO 0x00000000

0xE000ED08 VTOR

RW

0x00000000

Vector Table Offset Register

0xE000ED0C AIRCR

RW

0x00000000

Application Interrupt and Reset Control Register. Bits [10:8] are
reset to zero. The ENDIANNESS bit, bit [15], can reset to either
state, depending on the implementation.

0xE000ED10 SCR

RW

0x00000000

System Control Register

0xE000ED14 CCR

RW

0x00000200

Configuration and Control Register.

0xE000ED18 SHPR1

RW

0x00000000

System Handler Priority Register 1

0xE000ED1C SHPR2

RW

0x00000000

System Handler Priority Register 2

0xE000ED20 SHPR3

RW

0x00000000

System Handler Priority Register 3

0xE000ED24 SHCSR

RW

0x00000000

System Handler Control and State Register

0xE000ED28 CFSR

RW

0x00000000

Configurable Fault Status Registers

0xE000ED2C HFSR

RW

0x00000000

HardFault Status Register

0xE000ED30 DFSR

RW

0x00000000

Debug Fault Status Register

0xE000ED34 MMFAR

RW

Unknown

MemManage Fault Address Register. BFAR and MMFAR are the
same physical register. Because of this, the BFARVALID and
MMFARVALID bits are mutually exclusive.

0xE000ED38 BFAR

RW

Unknown

BusFault Address Register. BFAR and MMFAR are the same
physical register. Because of this, the BFARVALID and
MMFARVALID bits are mutually exclusive.

0xE000ED3C AFSR

RW

0x00000000

Refer to the Auxiliary Fault Status Register

0xE000ED40 ID_PFR0

RO

0x00000030

Processor Feature Register 0

0xE000ED44 ID_PFR1

RO

0x00000200

Processor Feature Register 1

0xE000ED48 ID_DFR0

RO

0x00100000

Debug Features Register 0. BFAR and MMFAR are the same
physical register. Because of this, the BFARVALID and
MMFARVALID bits are mutually exclusive.

0xE000ED4C ID_AFR0

RO

0x00000000

Auxiliary Features Register 0

ARM 100165_0201_02_en

Refer to the CPUID Base Register, CPUID
Interrupt Control and State Register

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

4-48

4 System Control
4.1 System control registers

Table 4-1 System control registers (continued)
Address

Name

Reset

Description

0xE000ED50 ID_MMFR0 RO

0x00100030

Memory Model Feature Register 0

0xE000ED54 ID_ MMFR1 RO

0x00000000

Memory Model Feature Register 1

0xE000ED58 ID_MMFR2 RO

0x01000000

Memory Model Feature Register 2

0xE000ED5C ID_MMFR3 RO

0x00000000

Memory Model Feature Register 3

0xE000ED60 ID_ISAR0

RO

0x01100110

Instruction Set Attributes Register 0

0xE000ED64 ID_ISAR1

RO

0x02111000

Instruction Set Attributes Register 1

0xE000ED68 ID_ISAR2

RO

0x21112231

Instruction Set Attributes Register 2

0xE000ED6C ID_ISAR3

RO

0x01111110

Instruction Set Attributes Register 3

0xE000ED70 ID_ISAR4

RO

0x01310132

Instruction Set Attributes Register 4

0xE000ED88 CPACR

RW

0x00000000

Coprocessor Access Control Register

0xE000EF00 STIR

WO

0x00000000

Software Triggered Interrupt Register

ARM 100165_0201_02_en

Type

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

4-49

4 System Control
4.2 Auxiliary Control Register, ACTLR

4.2

Auxiliary Control Register, ACTLR
Characteristics and bit assignments of the ACTLR register.
Purpose
Disables certain aspects of functionality within the processor.
Usage Constraints
There are no usage constraints.
Configurations
This register is available in all processor configurations.
Attributes
See the System control registers table.
The following figure shows the ACTLR bit assignments.
31

10 9 8 7
Reserved

3 2 1 0
Reserved

DISOOFP
DISFPCA

DISFOLD
DISDEFWBUF
DISMCYCINT

Figure 4-1 ACTLR bit assignments

The following table shows the ACTLR bit assignments.
Table 4-2 ACTLR bit assignments
Bits

Name

Function

[31:10] -

Reserved.

[9]

DISOOFP

Disables floating point instructions completing out of order with respect to integer instructions.

[8]

DISFPCA

SBZP.

[7:3]

-

Reserved

[2]

DISFOLD

Disables folding of IT instructions.

[1]

DISDEFWBUF Disables write buffer use during default memory map accesses. This causes all bus faults to be precise, but
decreases the performance of the processor because stores to memory must complete before the next
instruction can be executed.

[0]

DISMCYCINT Disables interruption of multi-cycle instructions. This increases the interrupt latency of the processor
because load/store and multiply/divide operations complete before interrupt stacking occurs.

Related references
4.1 System control registers on page 4-48.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

4-50

4 System Control
4.3 CPUID Base Register, CPUID

4.3

CPUID Base Register, CPUID
Characteristics and bit assignments of the CPUID register.
Purpose
Specifies:
• The ID number of the processor core.
• The version number of the processor core.
• The implementation details of the processor core.
Usage Constraints
There are no usage constraints.
Configurations
This register is available in all processor configurations.
Attributes
Described in the System control registers table.
The following figure shows the CPUID bit assignments.
31

24 23
IMPLEMENTER

20 19

VARIANT

16 15

4 3

(Constant)

PARTNO

0

REVISION

Figure 4-2 CPUID bit assignments

The following table shows the CPUID bit assignments.
Table 4-3 CPUID bit assignments
Bits

NAME

Function

[31:24] IMPLEMENTER Indicates implementer: 0x41 = ARM
[23:20] VARIANT

Indicates processor revision: 0x0 = Revision 0

[19:16] (Constant)

Reads as 0xF

[15:4]

PARTNO

Indicates part number: 0xC24 = Cortex-M3

[3:0]

REVISION

Indicates patch release: 0x1= Patch 1.

Related references
4.1 System control registers on page 4-48.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

4-51

4 System Control
4.4 Auxiliary Fault Status Register, AFSR

4.4

Auxiliary Fault Status Register, AFSR
Characteristics and bit assignments of the AFSR register.
Purpose
Specifies additional system fault information to software.
Usage Constraints
The AFSR flags map directly onto the AUXFAULT inputs of the processor, and a single-cycle
high level on an external pin causes the corresponding AFSR bit to become latched as one. The
bit can only be cleared by writing a one to the corresponding AFSR bit.
When an AFSR bit is written or latched as one, an exception does not occur. To make use of
AUXFAULT input signals, software must poll the AFSR.
Configurations
This register is available in all processor configurations.
Attributes
See the System control registers table.
The following figure shows the AFSR bit assignments.
31

0
AUXFAULT

Figure 4-3 AFSR bit assignments

The following table shows the AFSR bit assignments.
Table 4-4 AFSR bit assignments
Bits

Name

Function

[31:0] AUXFAULT Latched version of the AUXFAULT inputs.

Related references
4.1 System control registers on page 4-48.

ARM 100165_0201_02_en

Copyright © 2005-2008, 2010, 2015, 2016 ARM Limited or its
affiliates. All rights reserved.
Non-Confidential

4-52