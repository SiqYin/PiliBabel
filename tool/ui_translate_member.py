#!/usr/bin/env python3
# P0-3: wrap member-access display args `Text(x.label/.title/.name/.message/...)`
# with uiTx(). Safe because such Text() args are already Strings in compiling code.
# Skips already-wrapped, comments, the service file, and files defining enums are
# untouched only if they'd break const — but wrapping a *reference* (not a literal)
# never breaks const, so enum files are allowed here. Adds import when missing.
import re, sys, subprocess
APPLY = "--apply" in sys.argv
files = [f for f in subprocess.run(["git","ls-files","lib"],capture_output=True,text=True).stdout.split()
         if f.endswith(".dart")]
IMPORT = "import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';"
MEMBERS = "label|title|name|message|displayName|subtitle|text"
rx = re.compile(r'(?P<t>\bText\(\s*)(?!uiTx\()(?P<e>[A-Za-z_]\w*(?:\.\w+)*\.(?:' + MEMBERS + r')\b!?)(?![\w.])')
SKIP = {"lib/services/ui_translate/ui_translate_service.dart"}
per = {}
newsrc = {}
for f in files:
    if f in SKIP: continue
    try: s = open(f, encoding="utf-8").read()
    except Exception: continue
    out=[]; cnt=[0]
    for line in s.split("\n"):
        st=line.lstrip()
        if st.startswith("//") or st.startswith("///") or st.startswith("*"):
            out.append(line); continue
        def repl(m):
            cnt[0]+=1
            return m.group("t") + "uiTx(" + m.group("e") + ")"
        out.append(rx.sub(repl, line))
    if cnt[0]:
        new="\n".join(out)
        if IMPORT not in new:
            ls=new.split("\n"); idx=next((i for i,l in enumerate(ls) if l.startswith("import ")),0)
            ls.insert(idx, IMPORT); new="\n".join(ls)
        per[f]=cnt[0]; newsrc[f]=new
for f,c in sorted(per.items(), key=lambda x:-x[1])[:40]:
    print(f"{c:4d}  {f}")
print("MODE", "APPLY" if APPLY else "DRY", "| total", sum(per.values()), "| files", len(per))
if APPLY:
    for f,c in newsrc.items(): open(f,"w",encoding="utf-8").write(c)
