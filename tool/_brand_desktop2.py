import io
f=".github/workflows/linux_x64.yml"
s=open(f,encoding="utf-8").read()
pairs=[
 ("opt/PiliBabel/pilinara","opt/PiliBabel/pilibabel"),
 ("SPECS/pilinara.spec","SPECS/pilibabel.spec"),
 ('cat > "$RPM_BUILD_ROOT/SPECS/pilinara','cat > "$RPM_BUILD_ROOT/SPECS/pilibabel'),
 ("PiliNara.AppDir","PiliBabel.AppDir"),
 ("s|Exec=pilinara|Exec=pilinara|g","s|Exec=pilibabel|Exec=pilibabel|g"),
 ("s|Icon=pilinara|Icon=pilinara|g","s|Icon=pilibabel|Icon=pilibabel|g"),
]
n=0
for a,b in pairs:
    c=s.count(a)
    if c: n+=c; s=s.replace(a,b)
open(f,"w",encoding="utf-8").write(s)
print("pass2 repl:",n)
