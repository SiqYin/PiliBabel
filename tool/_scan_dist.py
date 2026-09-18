import re, subprocess
from collections import Counter
files=[f for f in subprocess.run(["git","ls-files","lib"],capture_output=True,text=True).stdout.split() if f.endswith(".dart")]
CJK="一-鿿"
q=r"(?:'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\")"
enum_re=re.compile(r'(?m)^\s*(?:sealed |abstract )?enum\s+\w')
for p in ["label","text","name"]:
    per=Counter(); enumset=set()
    for f in files:
        s=open(f,encoding="utf-8",errors="ignore").read()
        isenum=bool(enum_re.search(s))
        for m in re.finditer(r'(?m)\b'+re.escape(p)+r'\s*:\s*(?!uiTx\()('+q+')',s):
            lit=m.group(1)
            if re.search('['+CJK+']',lit) and '${' not in lit:
                per[f]+=1
                if isenum: enumset.add(f)
    print(f"\n== {p}: total {sum(per.values())} (in enum files {sum(per[f] for f in enumset)}) ==")
    for f,c in per.most_common(10):
        print(f"   {c:3d} {f}{' [enum]' if f in enumset else ''}")
