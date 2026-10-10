#!/usr/bin/env python3
"""把 docs/readme/<code>.md 拼成根目录的 README.md。

为什么要有这个脚本：README 要出十几种语言。全部内联进一个 200+ KB 的
`README.md` 手工维护，很容易改坏；拆成每语言一个源文件后，加语言 =
加一个文件 + 在 LANGUAGES 里加一行，其余全自动。

**语言切换用页内锚点，不用 `<details>`。** 折叠块能让页面短很多，但
「点锚点跳到折叠块里会不会自动展开」在 GitHub 上并没有保证，赌不起；
全部展开则一定跳到可见内容。代价是 README 变长 —— 但切换条在顶部、
每节末尾也有「返回语言列表」，实际不影响使用。

**允许增量**：只生成源文件已存在的语言，其余跳过并告警（切换条也只列已生成的），
所以翻译可以一批一批加，期间不会出现死链。

用法：
    python tool/build_readme.py            # 生成 README.md 与各语言跳转占位
    python tool/build_readme.py --check    # 只看哪些语言还没翻译
"""

import argparse
import io
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_DIR = os.path.join(ROOT, "docs", "readme")

# (文件名 code, 标题文本)
#
# 标题文本决定 GitHub 自动生成的锚点（`## 中文` → `#中文`），所以它同时也是
# 切换条的 href 目标，两者必须严格一致 —— 改名等于改所有链接。
#
# 命名沿用 README 既有惯例：**用该语言的通称、且不带字形前缀**
# （繁體中文 → 「中文」，繁體粵語 → 「粵語」）。
#
# 截图归属（assets/screenshots/）：只有 en / zh / ja 有自己的一套
# readme_<code>_*.jpg。**粵語复用中文那套**（同属中文家族、界面截图最接近），
# 其余新语言一律复用英文那套 —— 新增语言时照此办理，别默认抄英文的。
LANGUAGES = [
    ("en", "English"),
    ("zh", "中文"),
    ("yue", "粵語"),
    ("ja", "日本語"),
    ("fr", "Français"),
    ("de", "Deutsch"),
    ("es", "Español"),
    ("ko", "한국어"),
    ("ar", "العربية"),
    ("vi", "Tiếng Việt"),
    ("ms", "Bahasa Melayu"),
    ("id", "Bahasa Indonesia"),
]

# 第一个存在源文件的语言视为「主语言」（打开 README 先看到它）。
ANCHOR_TOP = "readme-languages"
ANCHOR_PREFIX = "readme-"


def source_path(code):
    return os.path.join(SRC_DIR, "%s.md" % code)


def read_source(code):
    path = source_path(code)
    if not os.path.isfile(path):
        return None
    with io.open(path, encoding="utf-8") as f:
        text = f.read().strip("\n")
    return text or None


def available():
    return [(c, n) for c, n in LANGUAGES if read_source(c) is not None]


def switcher(langs, active=None):
    """切换条：当前语言用 <b>，其余是指向各自标题锚点的页内链接。"""
    parts = []
    for code, name in langs:
        if code == active:
            parts.append("<b>%s</b>" % name)
        else:
            parts.append('<a href="#%s%s">%s</a>' % (ANCHOR_PREFIX, code, name))
    return " · ".join(parts)


def build():
    langs = available()
    if not langs:
        sys.stderr.write("docs/readme/ 下没有任何源文件\n")
        return None
    todo = [n for c, n in LANGUAGES if read_source(c) is None]
    if todo:
        sys.stderr.write("尚未翻译（已跳过）：%s\n" % ", ".join(todo))

    bar = switcher(langs)
    out = [
        '<div align="center">',
        "    <p><b>PiliBabel</b></p>",
        "    <p>%s</p>" % bar,
        "    <p><sub>Pick your language above — the links jump within this "
        "page, no need to open another file.</sub></p>",
        "</div>",
        "",
        '<a id="%s"></a>' % ANCHOR_TOP,
        "",
    ]

    for code, name in langs:
        out += [
            "---",
            "",
            # 显式 ASCII 锚点：**不要**依赖 GitHub 从标题自动生成的 slug
            # （它会小写、会吃掉标点，Français / Español / Tiếng Việt 这类
            # 带变音符号的标题极易对不上，点了就是不跳）。code 是我们自己的，
            # 稳定且永远 ASCII。
            '<a id="%s%s"></a>' % (ANCHOR_PREFIX, code),
            "",
            "## %s" % name,
            "",
            read_source(code),
            "",
            '<sub><a href="#%s">↑ %s</a></sub>' % (ANCHOR_TOP, bar),
            "",
        ]

    text = "\n".join(out).rstrip("\n") + "\n"
    with io.open(os.path.join(ROOT, "README.md"), "w",
                 encoding="utf-8", newline="\n") as f:
        f.write(text)
    return text


def build_stubs(langs):
    """旧文件名保留成跳转占位，避免外部链接 404。"""
    for code, name in langs:
        if code == langs[0][0]:
            continue
        with io.open(os.path.join(ROOT, "README.%s.md" % code), "w",
                     encoding="utf-8", newline="\n") as f:
            f.write(
                "# %s\n\n"
                "This translation now lives inside the main README, so that the "
                "language switcher can change language without leaving the "
                "page.\n\n"
                "→ **[PiliBabel — %s](README.md#%s%s)**\n" % (name, name, ANCHOR_PREFIX, code)
            )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true",
                    help="只报告哪些语言还没翻译，不写盘")
    args = ap.parse_args()

    if args.check:
        todo = [n for c, n in LANGUAGES if read_source(c) is None]
        done = len(LANGUAGES) - len(todo)
        print("已就绪 %d / %d" % (done, len(LANGUAGES)))
        if todo:
            print("待翻译：%s" % ", ".join(todo))
        return 0

    text = build()
    if text is None:
        return 1
    build_stubs(available())
    print("README.md 已生成：%d 字节 / %d 行 / %d 种语言"
          % (len(text.encode("utf-8")), text.count("\n"), len(available())))
    return 0


if __name__ == "__main__":
    sys.exit(main())
