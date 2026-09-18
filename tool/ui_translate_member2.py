#!/usr/bin/env python3
# P0-4 (member2): wrap member-access display args in Text(), MULTILINE-tolerant.
# Catches `Text(\n   item.label,\n` that the line-based pass missed. Skips already
# wrapped (uiTx guard), and requires the member be the whole first arg (then , or ) ).
import re, sys, subprocess
APPLY = "--apply" in sys.argv
files = [f for f in subprocess.run(["git","ls-files","lib"],capture_output=True,text=True).stdout.split() if f.endswith(".dart")]
IMPORT = "import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';"
MEM = "label|title|name|message|displayName|text|subtitle|body|description"
rx = re.compile(r'(?P<t>\bText\(\s*)(?!uiTx\()(?P<e>[A-Za-z_]\w*(?:\.\w+)*\.(?:' + MEM + r')\b!?)(?=\s*[),])')
SKIP = {"lib/services/ui_translate/ui_translate_service.dart"}
per={}; newsrc={}
for f in files:
    if f in SKIP: continue
    try: s=open(f,encoding="utf-8").read()
    except Exception: continue
    matches=[m for m in rx.finditer(s)]
    if not matches: continue
    new, last = [], 0; cnt=0
    for m in matches:
        new.append(s[last:m.start("e")])
        new.append("uiTx("+m.group("e")+")")
        last=m.end("e"); cnt+=1
    new.append(s[last:])
    new="".join(new)
    if IMPORT not in new:
        ls=new.split("\n"); idx=next((i for i,l in enumerate(ls) if l.startswith("import ")),0)
        ls.insert(idx,IMPORT); new="\n".join(ls)
    per[f]=cnt; newsrc[f]=new
for f,c in sorted(per.items(), key=lambda x:-x[1])[:30]:
    print(f"{c:3d}  {f}")
print("MODE", "APPLY" if APPLY else "DRY", "| total", sum(per.values()), "| files", len(per))
if APPLY:
    for f in newsrc: open(f,"w",encoding="utf-8").write(newsrc[f])
