#!/usr/bin/env python3
# P0-6: for reusable widgets that render their OWN String field via a bare
# `Text(field...)` (no receiver dot), wrap it with uiTx — a single choke point
# that translates all callers that pass raw literals. Detection-gated so we only
# touch fields declared as `final String[?] <name>` in the same file and used as
# the first arg of Text(). Preserves trailing `!`; adds import; skips already-wrapped.
import re, sys, subprocess
APPLY = "--apply" in sys.argv
files = [f for f in subprocess.run(["git","ls-files","lib"],capture_output=True,text=True).stdout.split() if f.endswith(".dart")]
IMPORT = "import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';"
FIELDS = {"text","label","title","name","message","body","subtitle"}
SKIPFILE = {"lib/common/widgets/badge.dart",  # already hand-wrapped (PBadge)
            "lib/services/ui_translate/ui_translate_service.dart",
            "lib/services/ui_translate/app_language.dart",
            "lib/common/constants.dart"}
report=[]
for f in files:
    if f in SKIPFILE: continue
    s=open(f,encoding="utf-8",errors="ignore").read()
    declared=set(re.findall(r'\bfinal\s+String\??\s+(\w+)\s*[;=]',s)) & FIELDS
    if not declared: continue
    out=s; n=0
    for fld in declared:
        # Text( <field>!?)  then , or )   ; not already uiTx
        pat=re.compile(r'(?P<t>\bText\(\s*)(?!uiTx\()(?P<e>'+re.escape(fld)+r'\b!?)(?=\s*[),])')
        out,c=pat.subn(lambda m: m.group("t")+"uiTx("+m.group("e")+")", out)
        n+=c
    if n:
        if IMPORT not in out:
            ls=out.split("\n"); idx=next((i for i,l in enumerate(ls) if l.startswith("import ")),0)
            ls.insert(idx,IMPORT); out="\n".join(ls)
        report.append((f,n))
        if APPLY: open(f,"w",encoding="utf-8").write(out)
for f,n in sorted(report,key=lambda x:-x[1]):
    print(f"{n:2d}  {f}")
print("MODE","APPLY" if APPLY else "DRY","| total",sum(n for _,n in report),"| files",len(report))
