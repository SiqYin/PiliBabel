### PiliBabel v3.9.1

**The default font is 霞鹜文楷 again.**

3.8.12 handed the default over to the platform font to match the official app; that turned out to be the wrong call for this fork — the bundled LXGW WenKai is what people install PiliBabel for. 3.9.1 restores it as the default: a fresh install, and anyone who never touched 字体设置, gets 霞鹜文楷.

Nothing else changed in font handling. 系统默认 is still there as an explicit choice, and an explicitly chosen font is still respected — only the *unset* case flips back.

This release also carries the 3.9.0 changelog in English (see v3.9.0) and the same build fixes.
