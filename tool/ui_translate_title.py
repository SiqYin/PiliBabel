#!/usr/bin/env python3
# P0 (batch 1): wrap display `title:`/`label:`/`text:` CJK literals with uiTx()
# ONLY in lib/pages/setting/models/*.dart (getter-built model lists; forceAppUpdate
# rebuilds them; no in-file logic-key comparisons). Skips comment lines & already-wrapped.
import re, sys, glob, os
APPLY = "--apply" in sys.argv
FILES = sorted(glob.glob("lib/pages/setting/models/*.dart"))
rx = re.compile(r'(\b(?:title|label|text)\s*:\s*)(?!uiTx\()(\'(?:\\.|[^\'\\])*\'|"(?:\\.|[^"\\])*")')
CJK = re.compile(r'[一-鿿]')
IMPORT = "import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';"

def process(f):
    src = open(f, encoding="utf-8").read()
    state = {"n": 0}
    def repl(m):
        pre, lit = m.group(1), m.group(2)
        if not CJK.search(lit):
            return m.group(0)
        state["n"] += 1
        return f"{pre}uiTx({lit})"
    out = []
    for line in src.split("\n"):
        s = line.lstrip()
        if s.startswith("//") or s.startswith("///") or s.startswith("*"):
            out.append(line)
        else:
            out.append(rx.sub(repl, line))
    new = "\n".join(out)
    if state["n"] and IMPORT not in new:
        lines = new.split("\n")
        idx = next((i for i,l in enumerate(lines) if l.startswith("import ")), 0)
        lines.insert(idx, IMPORT)
        new = "\n".join(lines)
    if state["n"] and APPLY:
        open(f, "w", encoding="utf-8").write(new)
    return state["n"]

total = 0
for f in FILES:
    n = process(f)
    if n:
        total += n
        print(f"{f}: +{n}")
print("MODE", "APPLY" if APPLY else "DRY", "| total", total)
