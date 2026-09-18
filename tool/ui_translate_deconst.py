import os, re, sys

DRY = "--apply" not in sys.argv
ROOT = "lib"
EXCLUDE_DIRS = {os.path.join("lib", "grpc")}
head = re.compile(
    r"\bconst\s+(?=[A-Za-z_][A-Za-z0-9_.]*(?:<[^<>]*>)?\s*\(|\[|\{)"
)

def _skip_generics(src, j):
    n = len(src)
    if j < n and src[j] == "<":
        depth = 0
        while j < n:
            c = src[j]
            if c == "<":
                depth += 1
            elif c == ">":
                depth -= 1
                if depth == 0:
                    j += 1
                    break
            j += 1
    return j

def find_const_spans(src):
    spans = []
    i = 0
    n = len(src)
    while True:
        m = head.search(src, i)
        if not m:
            break
        start = m.start()
        j = m.end()
        while j < n and (src[j].isalnum() or src[j] in "_."):
            j += 1
        j = _skip_generics(src, j)
        while j < n and src[j] in " \t\r\n":
            j += 1
        if j < n and src[j] in "([{":
            open_ch = src[j]
            close_ch = {"(": ")", "[": "]", "{": "}"}[open_ch]
            depth = 0
            k = j
            in_str = False
            str_ch = ""
            esc = False
            while k < n:
                c = src[k]
                if in_str:
                    if esc:
                        esc = False
                    elif c == "\\":
                        esc = True
                    elif c == str_ch:
                        in_str = False
                else:
                    if c in "'\"":
                        in_str = True
                        str_ch = c
                    elif c == open_ch:
                        depth += 1
                    elif c == close_ch:
                        depth -= 1
                        if depth == 0:
                            break
                k += 1
            spans.append((start, j, k + 1))
            i = m.end()
        else:
            i = m.end()
    return spans

total_files = 0
total_removed = 0
for dirpath, dirnames, filenames in os.walk(ROOT):
    if any(dirpath == e or dirpath.startswith(e + os.sep) for e in EXCLUDE_DIRS):
        continue
    for fn in filenames:
        if not fn.endswith(".dart"):
            continue
        path = os.path.join(dirpath, fn)
        with open(path, encoding="utf-8") as f:
            src = f.read()
        if "uiTx(" not in src or "const " not in src:
            continue
        removed_here = 0
        for _ in range(12):
            spans = find_const_spans(src)
            to_remove = [s for s in spans if "uiTx(" in src[s[1]:s[2]]]
            if not to_remove:
                break
            for start, _o, _c in sorted(to_remove, reverse=True):
                src = src[:start] + src[start + len("const "):]
                removed_here += 1
        if removed_here:
            total_files += 1
            total_removed += removed_here
            if not DRY:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(src)

print(("DRY " if DRY else "APPLIED ") + f"files={total_files} const_removed={total_removed}")
