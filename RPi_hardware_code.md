**Raspberry Pi Hardware**
- Code `EDCBBA` : `cat /proc/cpuinfo | grep Revision | awk '{print $NF}'`

| Model      | Code - `BB` | No wl | No eth | SoC       | Code - `C` |
|------------|-------------|-------|--------|-----------|------------|
| RPi B      | `00`        | x     |        | BCM2835   | `0`        |
| RPi A      | `00`        | x     | x      | BCM2835   | `0`        |
| RPi A+     | `01` `02`   | x     | x      | BCM2835   | `0`        |
| RPi B+     | `01` `03`   | x     |        | BCM2835   | `0`        |
| RPi Z      | `09`        | x     | x      | BCM2835   | `0`        |
| RPi Zw     | `0c`        |       | x      | BCM2835   | `0`        |
|            |             |       |        |           |            |
| RPi 2B     | `04`        | x     |        | BCM2836   | `1`        |
|            |             |       |        |           |            |
| RPi 2B 1.2 | `04`        | x     |        | BCM2837   | `2`        |
| RPi 3B     | `08`        |       |        | BCM2837   | `2`        |
|            |             |       |        |           |            |
| RPi 3A+    | `0e`        |       | x      | BCM2837B0 | `2`        |
| RPi 3B+    | `0d`        |       |        | BCM2837B0 | `2`        |
|            |             |       |        |           |            |
| RPi 4B     | `11`        |       |        | BCM2711   | `3`        |

- `A` - PCB revision
- `BB` - model : `cat /proc/cpuinfo | grep Revision | tail -c 4 | cut -c 1-2`
- `C` - SoC
- `D` - manufacturer
	- `0` - Sony UK
	- `2` - Embest
	- `3` - Stadium
	- `5` - Sony Japan
- `E` - memory
	- `9` - 512KB
	- `a` - 1GB
	- `b` - 2GB
	- `c` - 4GB
- Model A - no ethernet