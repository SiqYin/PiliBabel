#!/usr/bin/env python3
"""维护 README 多语言版本的语言切换条。

布局（与 0.3.10 及以前一致，也是 dify 等项目的通行做法）：

    根目录  README.md          英文（主语言）
            README.<code>.md   其余每种语言一个文件

在 GitHub 上点切换条就是跳到对应文件的页面 —— 不做页内锚点、不做折叠。
**页内锚点 + `<details>` 折叠两条路都试过，最终放弃**：要么整页 300 KB 太长，
要么折叠后还得再点一次才展开，都不如「一种语言一个页面」直接。过程见 git 历史里的
`docs(readme): switch languages in-page` 与 `docs(readme): collapse ...`。

这个脚本**只负责切换条**：把 `<!-- lang-switch:start -->` 与
`<!-- lang-switch:end -->` 之间整段重写，其余内容（也就是正文）一个字都不碰。
所以各语言文件本身就是**唯一事实来源**，不存在「源文件 + 生成物」两份重复内容；
加一种语言 = 加一个 `README.<code>.md` + 在 LANGUAGES 里加一行。

用法：
    python tool/build_readme.py            # 刷新所有语言的切换条
    python tool/build_readme.py --check    # 只报告缺哪些语言文件
"""

import argparse
import io
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# (文件名后缀代码, 切换条显示名)
#
# 命名沿用 README 既有惯例：**用该语言的通称、且不带字形前缀**
# （繁體中文 → 「中文」，繁體粵語 → 「粵語」）。
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

START = "<!-- lang-switch:start -->"
END = "<!-- lang-switch:end -->"

PRIMARY = LANGUAGES[0][0]


def file_of(code):
    """语言 code -> 仓库根目录下的文件名。"""
    return "README.md" if code == PRIMARY else "README.%s.md" % code


def path_of(code):
    return os.path.join(ROOT, file_of(code))


def switcher_block(active):
    """切换条本体。当前语言加粗，其余指向各自语言的文件。"""
    parts = []
    for code, name in LANGUAGES:
        if code == active:
            parts.append("<b>%s</b>" % name)
        else:
            parts.append('<a href="%s">%s</a>' % (file_of(code), name))
    return "\n".join([
        START,
        '<div align="center">',
        "    <p>%s</p>" % " · ".join(parts),
        "</div>",
        END,
    ])


def refresh(code):
    """把某个语言文件里的切换条重写成当前状态。返回是否改动过。"""
    path = path_of(code)
    if not os.path.isfile(path):
        return False
    with io.open(path, encoding="utf-8") as f:
        text = f.read()

    block = switcher_block(code)
    i, j = text.find(START), text.find(END)
    if i >= 0 and j > i:
        new = text[:i] + block + text[j + len(END):]
    else:
        # 首次接管：插在第一个 </div> 之后 —— 也就是 logo/标题块之后、
        # 截图块之前，与旧版 README 里切换条的位置一致。
        # 没有 </div> 就退到第一个空行之后；再没有就放最前面。
        k = text.find("</div>")
        k = (k + len("</div>")) if k >= 0 else text.find("\n\n") + 2
        new = text[:k] + "\n" + block + text[k:]

    if new == text:
        return False
    with io.open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(new)
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true",
                    help="只报告缺哪些语言文件，不改文件")
    args = ap.parse_args()

    missing = [name for code, name in LANGUAGES
               if not os.path.isfile(path_of(code))]

    if args.check:
        print("已就绪 %d / %d" % (len(LANGUAGES) - len(missing), len(LANGUAGES)))
        if missing:
            print("缺少文件：%s" % ", ".join(missing))
        return 0

    changed = 0
    for code, _ in LANGUAGES:
        if refresh(code):
            changed += 1
    print("已刷新切换条：%d 个文件有改动，共 %d 种语言"
          % (changed, len(LANGUAGES) - len(missing)))
    if missing:
        print("缺少文件（已跳过）：%s" % ", ".join(missing))
    return 0


if __name__ == "__main__":
    sys.exit(main())
