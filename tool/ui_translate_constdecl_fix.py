#!/usr/bin/env python3
# Fix: str2 codemod wrapped display strings with uiTx() inside const variable/field
# declarations (e.g. `static const List<X> _items = [...]`). Dart forbids method
# calls in const expressions. Convert those specific `const` declarations to `final`.
import re, sys, subprocess

DRY = "--apply" not in sys.argv

files = subprocess.run(
    ["git", "show", "--stat", "--name-only", "--format=", "fdfc3e041"],
    capture_output=True, text=True).stdout.split()
files = [f for f in files if f.endswith(".dart")]

# A const *declaration*: optional 'static', then 'const', then a type expr, then
# identifier, then '='. We must NOT match constructor calls like `const SizedBox(...)`
# (no '=' before) nor `const x = '...'` string (that's fine but uiTx won't appear there
# harmlessly — we only flip when uiTx present).
decl_re = re.compile(r'(?m)^([ \t]*)(static\s+)?const\s+((?:final\s+)?[\w<>,.\s?]+?)\s+(\w+)\s*=\s*')

def find_extent(s, start):
    # from index 'start' (just after '='), scan to the top-level ';' with bracket balance,
    # ignoring string literals & escapes.
    depth = 0
    i = start
    n = len(s)
    in_str = False; quote=''; esc=False; triple=False
    while i < n:
        c = s[i]
        if in_str:
            if esc:
                esc=False; i+=1; continue
            if c == '\\':
                esc=True; i+=1; continue
            if triple:
                if s.startswith(quote*3, i):
                    i+=3; in_str=False; continue
                i+=1; continue
            else:
                if c == quote:
                    in_str=False
                elif c == '\n':  # unterminated single-quote -> bail conservatively
                    pass
                i+=1; continue
        else:
            if s.startswith("'''", i) or s.startswith('"""', i):
                triple=True; quote=s[i]; in_str=True; i+=3; continue
            if c == "'":
                # handle r'..' and escapes minimal
                in_str=True; quote=c; i+=1; continue
            if c in '([{': depth+=1
            elif c in ')]}': depth-=1
            elif c == ';' and depth<=0:
                return i
            elif c == '\n' and depth==0:
                # allow wrapped declarations; keep scanning
                pass
            i+=1
    return n

total=0
for f in files:
    try:
        src=open(f, encoding="utf-8").read()
    except FileNotFoundError:
        continue
    out=src; changed=0
    for m in decl_re.finditer(src):
        # skip if type token is actually a constructor: our regex requires an '=' so ok
        eq = m.end()
        end = find_extent(out, eq)
        seg = out[eq:end]
        if 'uiTx' in seg:
            old_full = m.group(0)
            new_full = f"{m.group(1)}{(m.group(2) or '')}final {m.group(3)} {m.group(4)} ="
            if old_full.replace('=','',1) != new_full.replace('=','',1):
                out = out.replace(old_full, new_full, 1)
                changed+=1
                print(f"{f}: const->final  ({m.group(4)})")
    if changed:
        total+=changed
        if not DRY:
            open(f,"w",encoding="utf-8").write(out)
print("MODE:", "DRY" if DRY else "APPLIED", "| total", total)
