import re, subprocess
files=[f for f in subprocess.run(["git","ls-files","lib"],capture_output=True,text=True).stdout.split() if f.endswith(".dart") and not f.startswith("lib/services/ui_translate/")]
q = r"'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\""
CJKre = re.compile(r'[\u4e00-\u9fff]')
def ok(x): return bool(CJKre.search(x)) and '$' not in x and '\\' not in x
toast=re.compile(r'showToast\(\s*(?:msg:\s*)?(?!uiTx)('+q+')')
n=0
for f in files:
    s=open(f,encoding="utf-8",errors="ignore").read()
    for i,l in enumerate(s.split("\n"),1):
        if l.lstrip().startswith('//'): continue
        m=toast.search(l)
        if m and ok(m.group(1)): print(f"TOAST {f}:{i}: {l.strip()[:80]}"); n+=1
print("plain showToast:",n)
param=re.compile(r'\b(?:tooltip|confirmText|subtitle|helperText)\s*:\s*(?!uiTx)('+q+')')
for f in files:
    s=open(f,encoding="utf-8",errors="ignore").read()
    for i,l in enumerate(s.split("\n"),1):
        if l.lstrip().startswith('//'): continue
        m=param.search(l)
        if m and ok(m.group(1)): print("PARAM",f"{f}:{i}: {l.strip()[:70]}")
