# 官方分发与安装包校验 / Official distribution and verification

## 中文

### 唯一官方渠道

PiliBabel 只通过 **GitHub Releases** 发布：

```
https://github.com/SiqYin/PiliBabel/releases
```

我们没有授权任何网站、应用商店、公众号、网盘或社群分发本软件。除上述地址外，任何来源的安装包都不代表本项目，我们无法为其完整性、更新与安全性背书。

### 为什么需要校验

国内多个下载站（西西软件园、嗨客手机站、游吧乐下载、289手游网、乐乐游戏等）在未告知、未授权的情况下收录并分发本软件的安装包，部分页面使用「官方正版」「原始安装包」等表述。详见 `glossary/evidence-2026-11-13/EVIDENCE.md`（维护者本地证据目录）。

已核实的样本：这些站点提供的 v3.8.6 安装包 SHA-256 为
`289027d937bc5952045dd02b296c8435f1d1fb26a8afe1da49209b09425d7b9a`，
与官方 Release 的 `PiliBabel.apk` 完全一致——即文件未被篡改，但分发行为未经授权，且未随附 GPLv3 许可证与源码入口。

### 如何校验

1. 在 Release 页面找到安装包，同时记下页面给出的 SHA-256。
2. 下载后计算哈希：
   - Windows：`certutil -hashfile PiliBabel.apk SHA256`
   - Linux / macOS：`sha256sum PiliBabel.apk`（macOS 用 `shasum -a 256`）
3. 与 Release 页面公布的哈希逐位比对，一致即为官方原件。

每个 Release 的资产元数据同时可通过 GitHub API 获取，`digest` 字段即为 SHA-256：

```
https://api.github.com/repos/SiqYin/PiliBabel/releases/tags/v3.9.3
```

### 关于「破解版」「付费版」

本软件免费、无广告、无付费版本，也不存在「破解版」。任何要求付费、关注公众号、加群、先安装下载器的「PiliBabel」，都不是我们发布的。

## English

### The only official channel

PiliBabel is released **only** through **GitHub Releases**:

```
https://github.com/SiqYin/PiliBabel/releases
```

No website, app store, social account, cloud drive or group has been authorised to distribute this software. Builds from any other source do not represent this project, and we cannot vouch for their integrity, updates or safety.

### Why verification matters

Several Chinese download sites (西西软件园, 嗨客手机站, 游吧乐下载, 289手游网, 乐乐游戏) list and distribute this software without notice or permission, some of them labelling it "official" or "the original installer". The verified sample: the v3.8.6 build served by those sites has SHA-256
`289027d937bc5952045dd02b296c8435f1d1fb26a8afe1da49209b09425d7b9a`,
identical to the official `PiliBabel.apk` — the file was not tampered with, but the distribution is unauthorised and ships neither the GPLv3 licence nor a source link.

### How to verify

1. On the release page, note the SHA-256 listed for the asset.
2. After downloading, compute it locally:
   - Windows: `certutil -hashfile PiliBabel.apk SHA256`
   - Linux: `sha256sum PiliBabel.apk`
   - macOS: `shasum -a 256 PiliBabel.apk`
3. Compare digit by digit with the published value.

Asset metadata for every release is also available through the GitHub API; the `digest` field is the SHA-256:

```
https://api.github.com/repos/SiqYin/PiliBabel/releases/tags/v3.9.3
```

### On "cracked" or "paid" builds

This software is free, ad-free, has no paid edition and no "cracked" build. Any "PiliBabel" that asks for payment, a follow, a group join or a separate downloader first is not ours.
