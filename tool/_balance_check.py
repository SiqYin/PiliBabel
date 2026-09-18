import glob
def balance(src):
    i=0;n=len(src);d={'(':0,'{':0,'[':0}
    ins=False;sc='';tri=False;esc=False;line=False;com=False
    BS=chr(92)
    while i<n:
        c=src[i]
        if line:
            if c=='\n':line=False
            i+=1;continue
        if com:
            if src.startswith('*/',i):com=False;i+=2;continue
            i+=1;continue
        if ins:
            if esc:esc=False;i+=1;continue
            if c==BS:esc=True;i+=1;continue
            if tri:
                if src.startswith(sc*3,i):tri=False;i+=3;continue
                i+=1;continue
            if c==sc:ins=False
            i+=1;continue
        if src.startswith('//',i):line=True;i+=2;continue
        if src.startswith('/*',i):com=True;i+=2;continue
        if src.startswith("'''",i) or src.startswith('"""',i):
            tri=True;sc=src[i];ins=True;i+=3;continue
        if c in "'\"":ins=True;sc=c;i+=1;continue
        if c in '([{':d[c]+=1
        elif c==')':d['(']-=1
        elif c=='}':d['{']-=1
        elif c==']':d['[']-=1
        i+=1
    return d
bad=0
for f in glob.glob("lib/pages/setting/models/*.dart"):
    d=balance(open(f,encoding="utf-8").read())
    if any(v!=0 for v in d.values()):
        print("IMBALANCE",f,d);bad+=1
print("string-aware balance:","ALL OK" if bad==0 else f"{bad} files")
