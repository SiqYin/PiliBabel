import os, re, sys

DRY = "--apply" not in sys.argv
ROOT = "lib"
EXCLUDE_DIRS = {os.path.join("lib", "grpc")}
IMPORT_LINE = "import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';"

# Text(  <expr>.label  )  或  ,
pat = re.compile(r"\bText\(\s*([A-Za-z_][\w.]*\.label)\s*(?=[,)])")

total_files = 0
total_subs = 0
for dirpath, dirnames, filenames in os.walk(ROOT):
    if any(dirpath == e or dirpath.startswith(e + os.sep) for e in EXCLUDE_DIRS):
        continue
    for fn in filenames:
        if not fn.endswith(".dart"):
            continue
        path = os.path.join(dirpath, fn)
        with open(path, encoding="utf-8") as f:
            src = f.read()
        if ".label" not in src or "Text(" not in src:
            continue
        c = [0]
        def repl(m):
            c[0] += 1
            return f"Text(uiTx({m.group(1)})"
        new = pat.sub(repl, src)
        if c[0] == 0:
            continue
        if IMPORT_LINE not in new and "uiTx(" in new:
            lines = new.split("\n")
            first_imp = next((i for i, l in enumerate(lines) if l.startswith("import ")), None)
            lines.insert(first_imp if first_imp is not None else 0, IMPORT_LINE)
            new = "\n".join(lines)
        total_files += 1
        total_subs += c[0]
        if not DRY:
            with open(path, "w", encoding="utf-8") as f:
                f.write(new)
print(("DRY RUN " if DRY else "APPLIED ") + f"files={total_files} subs={total_subs}")
