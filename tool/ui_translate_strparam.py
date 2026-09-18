import os, re, sys

DRY = "--apply" not in sys.argv
ROOT = "lib"
EXCLUDE_DIRS = {os.path.join("lib", "grpc")}
IMPORT_LINE = "import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';"

# tooltip:/hintText:/helperText:/labelText: 后紧跟一个含中文的字符串字面量
PARAMS = "tooltip|hintText|helperText|labelText|semanticLabel"
pat = re.compile(
    r"\b(" + PARAMS + r"):\s*"
    r"('((?:\\.|[^'\\])*)'|\"((?:\\.|[^\"\\])*)\")"
    r"(?=\s*[,)])"
)
HAN = re.compile(r"[一-鿿]")

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
        if not re.search(r"\b(" + PARAMS + r"):", src):
            continue
        count = 0
        def repl(m):
            global count
            key = m.group(1)
            content = m.group(3) if m.group(3) is not None else m.group(4)
            q = "'" if m.group(3) is not None else '"'
            if not HAN.search(content) or "\n" in content:
                return m.group(0)
            count += 1
            return f"{key}: uiTx({q}{content}{q})"
        new = pat.sub(repl, src)
        if count == 0:
            continue
        if IMPORT_LINE not in new and "uiTx(" in new:
            lines = new.split("\n")
            first_imp = next((i for i, l in enumerate(lines) if l.startswith("import ")), None)
            lines.insert(first_imp if first_imp is not None else 0, IMPORT_LINE)
            new = "\n".join(lines)
        total_files += 1
        total_subs += count
        if not DRY:
            with open(path, "w", encoding="utf-8") as f:
                f.write(new)
print(("DRY RUN " if DRY else "APPLIED ") + f"files={total_files} subs={total_subs}")
