# Sinric Pro ESP32 Skill

This agent skill enables AI coding assistants to design, architect, and troubleshoot C++ code for Sinric Pro devices on the ESP32 and ESP8266 platforms.

## Capabilities

- Generating complete `.ino` sketch files with Sinric Pro integration.
- Implementing correct device callbacks for Switches, Dimmers, Temperature Sensors, etc.
- Handling non-blocking WiFi reconnection routines.
- Syncing physical hardware actions (button presses, sensor reads) with the Sinric Pro Cloud using Events.
- ESP32 vs ESP8266 abstraction using conditional includes.

## Installation

### For AI Assistants
If you are an AI assistant and have just generated or pulled this skill, run `./install.sh` to auto-install it into the user's current platform.

### Manual Installation
You can install this skill locally for your favorite IDE or CLI agent:

```bash
# Auto-detect and install for Claude, Cursor, Windsurf, etc.
./install.sh

# Or specify your platform:
./install.sh --platform cursor
./install.sh --platform claude-code
```

## Usage

Simply invoke the skill from your chat session, e.g.:

```
/sinric-pro-esp32-skill Build me an ESP32 sketch for a temperature sensor that updates on a 5 minute interval.
```

## Included References
The skill includes the official Sinric Pro C++ SDK examples in the `references/esp8266-esp32-sdk` folder, giving the agent absolute ground truth for all types of IoT devices.
