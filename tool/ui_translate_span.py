import os, re, sys

DRY = "--apply" not in sys.argv
ROOT = "lib"
EXCLUDE_DIRS = {os.path.join("lib", "grpc")}
IMPORT_LINE = "import 'package:PiliPlus/services/ui_translate/ui_translate_service.dart';"
HAN = re.compile(r"[一-鿿]")

# TextSpan(text: '中文')  —— 组: 1=整串(单),2=内(单),3=内(双)
pat_span = re.compile(
    r"\bTextSpan\(\s*text:\s*"
    r"('((?:\\.|[^'\\])*)'|\"((?:\\.|[^\"\\])*)\")"
    r"(?=\s*[,)])"
)
# key: '中文'  —— 组: 1=key,2=整串(单),3=内(单),4=内(双)
PARAMS = "message|hint|placeholder|description"
pat_param = re.compile(
    r"\b(" + PARAMS + r"):\s*"
    r"('((?:\\.|[^'\\])*)'|\"((?:\\.|[^\"\\])*)\")"
    r"(?=\s*[,)])"
)

def span_repl(m, c):
    content = m.group(2) if m.group(2) is not None else m.group(3)
    q = "'" if m.group(2) is not None else '"'
    if not HAN.search(content) or "\n" in content:
        return m.group(0)
    c[0] += 1
    return f"TextSpan(text: uiTx({q}{content}{q})"

def param_repl(m, c):
    key = m.group(1)
    content = m.group(3) if m.group(3) is not None else m.group(4)
    q = "'" if m.group(3) is not None else '"'
    if not HAN.search(content) or "\n" in content:
        return m.group(0)
    c[0] += 1
    return f"{key}: uiTx({q}{content}{q})"

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
        if "TextSpan(text:" not in src and not re.search(r"\b(" + PARAMS + r"):", src):
            continue
        c = [0]
        new = pat_span.sub(lambda m: span_repl(m, c), src)
        new = pat_param.sub(lambda m: param_repl(m, c), new)
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
