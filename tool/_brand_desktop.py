#!/usr/bin/env python3
# Full desktop branding: PiliNara/pilinara/com.example.pilinara -> PiliBabel/pilibabel/com.example.pilibabel
# across Linux + Windows build/packaging files and their workflows.
import io, os, sys
APPLY = "--apply" in sys.argv

REPL = {
 "linux/CMakeLists.txt": [
   ('set(BINARY_NAME "pilinara")', 'set(BINARY_NAME "pilibabel")'),
   ('set(APPLICATION_ID "com.example.pilinara")', 'set(APPLICATION_ID "com.example.pilibabel")'),
 ],
 "linux/runner/my_application.cc": [
   ('"com.example.pilinara"', '"com.example.pilibabel"'),
   ('gtk_header_bar_set_title(header_bar, "pilinara");', 'gtk_header_bar_set_title(header_bar, "PiliBabel");'),
   ('gtk_window_set_title(window, "pilinara");', 'gtk_window_set_title(window, "PiliBabel");'),
 ],
 "assets/linux/DEBIAN/control": [
   ('Package: PiliNara', 'Package: PiliBabel'),
   ('Homepage: https://github.com/Starfallan/PiliNara', 'Homepage: https://github.com/SiqYin/PiliBabel'),
 ],
 "assets/linux/DEBIAN/postinst": [
   ('ln -sf /opt/PiliNara/pilinara /usr/bin/pilinara', 'ln -sf /opt/PiliBabel/pilibabel /usr/bin/pilibabel'),
   ('chmod +x /usr/bin/pilinara', 'chmod +x /usr/bin/pilibabel'),
 ],
 "assets/linux/DEBIAN/postrm": [
   ('rm /usr/bin/pilinara', 'rm /usr/bin/pilibabel'),
   ('rm -rf /home/*/.local/share/com.example.PiliNara', 'rm -rf /home/*/.local/share/com.example.PiliBabel'),
   ('rm -rf /root/.local/share/com.example.PiliNara', 'rm -rf /root/.local/share/com.example.PiliBabel'),
 ],
 "assets/linux/DEBIAN/prerm": [
   ('Stopping PiliNara if running...', 'Stopping PiliBabel if running...'),
   ('pkill -x pilinara', 'pkill -x pilibabel'),
 ],
 "windows/CMakeLists.txt": [
   ('project(pilinara LANGUAGES CXX)', 'project(pilibabel LANGUAGES CXX)'),
   ('set(BINARY_NAME "pilinara")', 'set(BINARY_NAME "pilibabel")'),
 ],
 "windows/runner/main.cpp": [
   ('::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"pilinara");', '::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"PiliBabel");'),
   ('window.Create(L"pilinara", origin, size)', 'window.Create(L"PiliBabel", origin, size)'),
 ],
 "windows/runner/Runner.rc": [
   ('VALUE "FileDescription", "PiliNara"', 'VALUE "FileDescription", "PiliBabel"'),
   ('VALUE "InternalName", "pilinara"', 'VALUE "InternalName", "pilibabel"'),
   ('VALUE "OriginalFilename", "pilinara.exe"', 'VALUE "OriginalFilename", "pilibabel.exe"'),
   ('VALUE "ProductName", "PiliNara"', 'VALUE "ProductName", "PiliBabel"'),
 ],
 "windows/packaging/exe/make_config.yaml": [
   ('publisher_url: https://github.com/Starfallan/PiliNara', 'publisher_url: https://github.com/SiqYin/PiliBabel'),
   ('display_name: PiliNara', 'display_name: PiliBabel'),
   ("install_dir_name: '{autopf64}\\PiliNara'", "install_dir_name: '{autopf64}\\PiliBabel'"),
   ('# 这里显式指定为 PiliNara，避免装进 PiliPlus 的目录。', '# 这里显式指定为 PiliBabel，避免装进 PiliPlus/PiliNara 的目录。'),
 ],
 ".github/workflows/win_x64.yml": [
   ('PiliNara-Win', 'PiliBabel-Win'),
   ('PiliNara_windows', 'PiliBabel_windows'),
 ],
}

# linux workflow: order matters (do PiliNara_windows-none; handle linux names/paths/binary/desktop)
LINUXWF = ".github/workflows/linux_x64.yml"
linux_wf_pairs = [
  ('PiliNara_linux', 'PiliBabel_linux'),
  ('opt/PiliNara', 'opt/PiliBabel'),
  ('com.example.pilinara.desktop', 'com.example.pilibabel.desktop'),
  ('assets/pilinara.png', 'assets/pilibabel.png'),
  ('pilinara.png', 'pilibabel.png'),
  ('PiliNara Linux Version', 'PiliBabel Linux Version'),
  ('Name:           pilinara', 'Name:           pilibabel'),
  ('pilinara-${{ env.version }}', 'pilibabel-${{ env.version }}'),
  ('/opt/PiliBabel/pilinara', '/opt/PiliBabel/pilibabel'),
  ('/usr/bin/pilinara', '/usr/bin/pilibabel'),
  ('bin/pilinara', 'bin/pilibabel'),   # /usr/bin symlink target + AppRun
  ('usr/bin/pilinara', 'usr/bin/pilibabel'),
  ('BINARY', 'BINARY'),
]
REPL[LINUXWF] = linux_wf_pairs

for f, pairs in REPL.items():
    if not os.path.exists(f):
        print("MISS", f); continue
    s = open(f, encoding="utf-8").read(); orig = s; hits = 0
    for a, b in pairs:
        if a in s:
            hits += s.count(a); s = s.replace(a, b)
    if s != orig:
        print(f"{f}: {hits} repl")
        if APPLY: open(f, "w", encoding="utf-8").write(s)
    else:
        print(f"{f}: NO CHANGE")

# Desktop file content
DESK = "assets/linux/com.example.pilinara.desktop"
if os.path.exists(DESK):
    s = open(DESK, encoding="utf-8").read()
    s = s.replace("Name=PiliNara", "Name=PiliBabel")
    s = s.replace("Exec=pilinara", "Exec=pilibabel")
    s = s.replace("Icon=pilinara", "Icon=pilibabel")
    s = s.replace("StartupWMClass=com.example.pilinara", "StartupWMClass=com.example.pilibabel")
    if APPLY:
        open("assets/linux/com.example.pilibabel.desktop", "w", encoding="utf-8").write(s)
    print("desktop content -> com.example.pilibabel.desktop")
print("MODE", "APPLY" if APPLY else "DRY")
