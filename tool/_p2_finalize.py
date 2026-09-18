import re, subprocess
files=[f for f in subprocess.run(["git","diff","--name-only","HEAD"],capture_output=True,text=True).stdout.split() if f.endswith(".dart")]
IMPORT="import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';"
added=[]
for f in files:
    try: s=open(f,encoding="utf-8").read()
    except: continue
    if re.search(r'\buiTx[PC]?\(', s) and IMPORT not in s:
        ls=s.split("\n"); idx=next((i for i,l in enumerate(ls) if l.startswith("import ")),0)
        ls.insert(idx,IMPORT); open(f,"w",encoding="utf-8").write("\n".join(ls)); added.append(f)
print("import added:",added)
# paren balance per changed file
for f in files:
    s=open(f,encoding="utf-8",errors="ignore").read()
    p=s.count('(')-s.count(')'); b=s.count('{')-s.count('}'); k=s.count('[')-s.count(']')
    if p or b or k: print("RAW-IMBALANCE",f,p,b,k)
print("changed files:",len(files))
