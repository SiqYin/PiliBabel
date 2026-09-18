import re, subprocess
from collections import Counter
files=[f for f in subprocess.run(["git","ls-files","lib"],capture_output=True,text=True).stdout.split() if f.endswith(".dart")]
CJK="一-鿿"  # CJK
params=["title","label","text","name","content","message","subtitle","tooltip","hintText","placeholder","buttonText","okText","cancelText","confirmText","helperText","promptText","description","semanticsLabel","emptyText"]
plain=Counter(); interp=Counter()
q=r"(?:'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\")"
for f in files:
    s=open(f,encoding="utf-8",errors="ignore").read()
    for p in params:
        rx=re.compile(r'(?m)\b'+re.escape(p)+r'\s*:\s*(?!uiTx\()('+q+')')
        for m in rx.finditer(s):
            lit=m.group(1)
            if re.search('['+CJK+']',lit):
                (interp if '${' in lit else plain)[p]+=1
# toast
trx=re.compile(r'showToast\(\s*(?:msg:\s*)?('+q+')')
for f in files:
    s=open(f,encoding="utf-8",errors="ignore").read()
    for m in trx.finditer(s):
        if re.search('['+CJK+']',m.group(1)):
            (interp if '${' in m.group(1) else plain)["showToast"]+=1
print("=== PLAIN still-unwrapped (param: count) ===")
for p,c in plain.most_common():
    if c: print(f"{c:4d}  {p}")
print("=== INTERPOLATED (P2 template work) ===")
for p,c in interp.most_common():
    if c: print(f"{c:4d}  {p}")
