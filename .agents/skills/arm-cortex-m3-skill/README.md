# arm-cortex-m3-skill

An expert skill derived from the ARM® Cortex®-M3 Processor Technical Reference Manual.

## Features
- Deep technical knowledge of the NVIC, exception model, MPU, and System Control Block.
- Familiarity with the CoreSight debug architecture components (DWT, ITM, ETM, TPIU, FPB).
- Generates C (CMSIS) and Assembly code snippets conforming to ARM unified assembly language.
- Distills architectural intricacies to help write safe and performant embedded code.

## Installation

### Auto-Install
Run the included installation script to copy the skill to your agent's directory:
```bash
./install.sh
```

### Manual Install

**Cursor:**
```bash
cp -R ./arm-cortex-m3-skill .cursor/rules/arm-cortex-m3-skill
```

**Claude Code:**
```bash
cp -R ./arm-cortex-m3-skill ~/.claude/skills/arm-cortex-m3-skill
```

**Universal (.agents):**
```bash
cp -R ./arm-cortex-m3-skill ~/.agents/skills/arm-cortex-m3-skill
```

## Usage

In your agent chat, type `/arm-cortex-m3-skill` followed by your prompt:

```
/arm-cortex-m3-skill Explain how tail-chaining reduces interrupt latency.
/arm-cortex-m3-skill Write code to enable the DWT cycle counter.
/arm-cortex-m3-skill How is priority grouping structured in the AIRCR?
```
