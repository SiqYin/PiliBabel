import re, subprocess
files=[f for f in subprocess.run(["git","ls-files","lib"],capture_output=True,text=True).stdout.split() if f.endswith(".dart")]
CJK="\u4e00-\u9fff"
q=r"(?:'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\")"
enum_re=re.compile(r'(?m)^\s*(?:sealed |abstract )?enum\s+\w')
SKIPFILE={"lib/models/common/theme/theme_color_type.dart","lib/models_new/space_setting/privacy.dart","lib/services/ai_chat/ai_chat_service.dart","lib/models/common/msg/msg_type.dart"}
out=[]
for f in files:
    if f in SKIPFILE: continue
    s=open(f,encoding="utf-8",errors="ignore").read()
    if enum_re.search(s): continue
    for p in ["label","text","title","content","helperText"]:
        for m in re.finditer(r'(?m)\b'+re.escape(p)+r'\s*:\s*(?!uiTx\()('+q+')',s):
            lit=m.group(1)
            if re.search('['+CJK+']',lit) and "${" not in lit and "\\" not in lit:
                ln=s[:m.start()].count("\n")+1
                out.append(f"{f}:{ln}  {p}: {lit}")
seen=set(); lines=[]
for l in out:
    if l not in seen: seen.add(l); lines.append(l)
print(f"{len(lines)} sites\n")
print("\n".join(lines[:80]))
