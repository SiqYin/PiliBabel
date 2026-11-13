# 官方分發與安裝包校驗 / Official distribution and verification

## 中文

### 唯一官方渠道

PiliBabel 只通過 **GitHub Releases** 發佈：

```
https://github.com/SiqYin/PiliBabel/releases
```

我們沒有授權任何網站、應用商店、公眾號、網盤或社群分發本軟件。除上述地址外，任何來源的安裝包都不代表本項目，我們無法為其完整性、更新與安全性背書。

### 為什麼需要校驗

國內多個下載站（西西软件园、嗨客手机站、游吧乐下载、289手游网、乐乐游戏等）在未告知、未授權的情況下收錄並分發本軟件的安裝包，部分頁面使用「官方正版」「原始安裝包」等表述。詳見 `glossary/evidence-2026-11-13/EVIDENCE.md`（維護者本地證據目錄）。

已核實的樣本：這些站點提供的 v3.8.6 安裝包 SHA-256 為
`289027d937bc5952045dd02b296c8435f1d1fb26a8afe1da49209b09425d7b9a`，
與官方 Release 的 `PiliBabel.apk` 完全一致——即檔案未被篡改，但分發行為未經授權，且未隨附 GPLv3 許可證與源碼入口。

### 如何校驗

1. 在 Release 頁面找到安裝包，同時記下頁面給出的 SHA-256。
2. 下載後計算哈希：
   - Windows：`certutil -hashfile PiliBabel.apk SHA256`
   - Linux / macOS：`sha256sum PiliBabel.apk`（macOS 用 `shasum -a 256`）
3. 與 Release 頁面公佈的哈希逐位比對，一致即為官方原件。

每個 Release 的資產元數據同時可通過 GitHub API 獲取，`digest` 欄位即為 SHA-256：

```
https://api.github.com/repos/SiqYin/PiliBabel/releases/tags/v3.9.3
```

### 關於「破解版」「付費版」

本軟件免費、無廣告、無付費版本，也不存在「破解版」。任何要求付費、關注公眾號、加群、先安裝下載器的「PiliBabel」，都不是我們發佈的。

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
