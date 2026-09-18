import re, subprocess, sys
files = subprocess.run(["git","ls-files","lib"],capture_output=True,text=True).stdout.split()
files = [f for f in files if f.endswith(".dart")]
decl = re.compile(r'(?m)^([ \t]*)(static\s+)?const\s+((?:final\s+)?[\w<>,.\s?]+?)\s+(\w+)\s*=\s*')
def extent(s,i):
    depth=0;n=len(s);ins=False;q='';tri=False;esc=False
    while i<n:
        c=s[i]
        if ins:
            if esc: esc=False; i+=1; continue
            if c=='\\': esc=True; i+=1; continue
            if tri:
                if s.startswith(q*3,i): i+=3; ins=False; continue
                i+=1; continue
            if c==q: ins=False
            i+=1; continue
        if s.startswith("'''",i) or s.startswith('"""',i):
            tri=True; q=s[i]; ins=True; i+=3; continue
        if c=="'": ins=True; q=c; i+=1; continue
        if c in '([{': depth+=1
        elif c in ')]}': depth-=1
        elif c==';' and depth<=0: return i
        i+=1
    return n
APPLY = "--apply" in sys.argv
hits=0
for f in files:
    try: src=open(f,encoding="utf-8").read()
    except: continue
    if 'uiTx' not in src: continue
    out=src; changed=0
    for m in decl.finditer(src):
        end=extent(out,m.end()); seg=out[m.end():end]
        if 'uiTx' in seg:
            ln=out[:m.start()].count('\n')+1
            print(f"{'FIX' if APPLY else 'HIT'} {f}:{ln}  ({m.group(4)})")
            new=m.group(1)+(m.group(2) or '')+'final '+m.group(3)+' '+m.group(4)+' ='
            out=out.replace(m.group(0),new,1); changed+=1; hits+=1
    if changed and APPLY:
        open(f,"w",encoding="utf-8").write(out)
print("MODE","APPLY" if APPLY else "DRY","| total",hits)
