#!/usr/bin/env python3
# P0-2: wrap DISPLAY-only params' PLAIN CJK literals with uiTx() across lib.
# Guards: skip enum-defining files; skip any literal containing `${` or `\`
# (interpolation / escaped quotes -> avoid truncation); skip comment lines;
# skip already-wrapped; add the ui_translate import when missing.
import re, sys, subprocess
APPLY = "--apply" in sys.argv
files = [f for f in subprocess.run(["git", "ls-files", "lib"],
         capture_output=True, text=True).stdout.split() if f.endswith(".dart")]
DISPLAY = ["title", "content", "buttonText", "okText", "cancelText", "confirmText",
           "helperText", "helper", "promptText", "emptyText", "emptyMessage",
           "hintMessage", "titleText", "submitText", "saveText", "errorText",
           "successText"]
IMPORT = "import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';"
CJK = re.compile(r'[\u4e00-\u9fff]')
rx = re.compile(r'(?P<pre>\b(?:' + "|".join(DISPLAY) + r')\s*:\s*)'
                r'(?!uiTx\()(?P<lit>\'(?:\\.|[^\'\\])*\'|"(?:\\.|[^"\\])*")')
enum_re = re.compile(r'(?m)^\s*(?:sealed |abstract )?enum\s+\w')
# Build a set of Chinese literals that appear in comparison/switch contexts
# anywhere in lib — these are treated as logic keys and NEVER wrapped.
cmp1 = re.compile(r"(?:==|!=|case\s+|\.contains\(|startsWith\(|endsWith\()\s*'([^']*[一-鿿][^']*)'")
cmp1d = re.compile(r'(?:==|!=|case\s+|\.contains\(|startsWith\(|endsWith\()\s*"([^"]*[一-鿿][^"]*)"')
cmp2 = re.compile(r"'([^']*[一-鿿][^']*)'\s*(?:==|!=)")
logic_keys = set()
_all_src = {}
for f in files:
    try:
        _all_src[f] = open(f, encoding="utf-8").read()
    except Exception:
        continue
for s in _all_src.values():
    for rgx in (cmp1, cmp1d, cmp2):
        for m in rgx.finditer(s):
            logic_keys.add(m.group(1))
per = {}
for f in files:
    try:
        s = _all_src[f]
    except Exception:
        continue
    if enum_re.search(s):
        continue
    out = []
    cnt = [0]
    for line in s.split("\n"):
        st = line.lstrip()
        if st.startswith("//") or st.startswith("///") or st.startswith("*"):
            out.append(line); continue
        def repl(m):
            lit = m.group("lit")
            body = lit[1:-1]
            if "${" in lit or "\\" in lit or not CJK.search(body) or body in logic_keys:
                return m.group(0)
            cnt[0] += 1
            return m.group("pre") + "uiTx(" + lit + ")"
        out.append(rx.sub(repl, line))
    cnt = cnt[0]
    if cnt:
        new = "\n".join(out)
        if IMPORT not in new:
            ls = new.split("\n")
            idx = next((i for i, l in enumerate(ls) if l.startswith("import ")), 0)
            ls.insert(idx, IMPORT)
            new = "\n".join(ls)
        per[f] = cnt
        if APPLY:
            open(f, "w", encoding="utf-8").write(new)
for f, c in sorted(per.items(), key=lambda x: -x[1])[:40]:
    print(f"{c:4d}  {f}")
print("MODE", "APPLY" if APPLY else "DRY", "| total", sum(per.values()), "| files", len(per))
