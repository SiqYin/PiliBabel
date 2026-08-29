import 'dart:ffi';
import 'dart:io' show Directory, File;
import 'dart:typed_data' show ByteData;

import 'package:PiliPlus/models/common/danmaku/danmaku_font_sync_mode.dart';
import 'package:PiliPlus/utils/android/bindings.g.dart';
import 'package:PiliPlus/utils/font_name_parser.dart';
import 'package:PiliPlus/utils/fontconfig.g.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:ffi/ffi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode, defaultTargetPlatform, debugPrint;
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:jni/jni.dart';
import 'package:path/path.dart' as path;
import 'package:win32/win32.dart';

abstract final class FontUtils {
  static final _fonts = <String>{};
  static bool _initialized = false;

  static const _kFontExts = ['ttf', 'otf'];
  static final _kFontDir = path.join(appSupportDirPath, 'font');

  /// 旧版单槽位实现的字体目录，迁移完成后删除
  static const _kLegacyFontDirs = ['fonts', 'danmaku_fonts'];

  static final _loadedFonts = <String>{};
  static final _loadingFonts = <String, Future<void>>{};

  /// 已导入字体池：key 形如 `<内容哈希>/<字体族名>`，value 为文件绝对路径。
  /// 哈希前缀既保证 key 唯一、不与系统字体同名，又让同一文件重复导入天然去重。
  static final customFonts = Pref.customAppFont;

  /// 池 key 的显示名，即族名部分
  static String displayName(String fontFamily) =>
      fontFamily.substring(fontFamily.indexOf('/') + 1);

  /// 启动初始化：迁移旧格式 → 剔除失效条目 → 清理孤儿文件 → 装载在用字体
  static Future<void> init() async {
    await _migrateLegacyFonts();
    await _pruneMissingFonts();
    await _cleanupOrphanFiles();
    await _loadActiveFonts();
  }

  /// 只装载当前真正会用到的字体：应用字体 + 独立弹幕字体
  static Future<void> _loadActiveFonts() {
    final families = <String>{
      ?Pref.appFont,
      if (Pref.enableCustomDanmakuFont &&
          Pref.danmakuFontSyncMode == DanmakuFontSyncMode.custom)
        ?Pref.customDanmakuFontFamily,
    };
    return Future.wait([
      for (final family in families)
        if (customFonts.containsKey(family)) ?loadFontIfNecessary(family),
    ]);
  }

  static Future<void>? loadFontIfNecessary(String fontFamily) {
    if (_loadedFonts.contains(fontFamily)) return null;
    // 同一字体的并发装载合流到同一个 Future，避免重复注册
    return _loadingFonts.putIfAbsent(
      fontFamily,
      () => _loadFont(
        fontFamily,
      ).whenComplete(() => _loadingFonts.remove(fontFamily)),
    );
  }

  /// 装载失败时不记入 _loadedFonts，后续仍可重试
  @pragma('vm:notify-debugger-on-exception')
  static Future<void> _loadFont(String fontFamily) async {
    try {
      final filePath = customFonts[fontFamily];
      if (filePath == null) return;
      final bytes = await File(filePath).readAsBytes();
      await (FontLoader(fontFamily)
            ..addFont(Future.value(ByteData.sublistView(bytes))))
          .load();
      _loadedFonts.add(fontFamily);
    } catch (_) {}
  }

  /// 导入字体文件（可多选），返回本批次第一个成功导入的池 key
  @pragma('vm:notify-debugger-on-exception')
  static Future<String?> pickFonts() async {
    try {
      final files = await FilePicker.pickFiles(
        type: .custom,
        allowedExtensions: _kFontExts,
      );
      if (files.isEmpty) return null;

      final dir = Directory(_kFontDir);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }

      // 逐个导入：并发落盘会让多个大字体同时占用内存和磁盘带宽
      final newFonts = <String, String>{};
      String? firstFont;
      var failed = 0;
      for (final file in files) {
        final imported = await _importFont(file);
        if (imported == null) {
          failed++;
          continue;
        }
        firstFont ??= imported.key;
        newFonts[imported.key] = imported.value;
      }

      if (firstFont == null) {
        SmartDialog.showToast('字体导入失败');
        return null;
      }
      if (failed != 0) {
        SmartDialog.showToast('$failed 个字体导入失败');
      }

      customFonts.addAll(newFonts);
      await GStorage.setting.put(SettingBoxKey.customAppFont, customFonts);
      await loadFontIfNecessary(firstFont);
      return firstFont;
    } catch (_) {
      if (kDebugMode) rethrow;
      SmartDialog.showToast('字体导入失败');
    }
    return null;
  }

  /// 落盘 → 内容哈希 → 解析族名 → 生成池 key。
  /// 先写临时文件再改名，中断不会在池目录留下半个字体。
  static Future<MapEntry<String, String>?> _importFont(
    PlatformFile file,
  ) async {
    final xFile = file.xFile;
    final tmpFile = File(
      path.join(
        _kFontDir,
        '.importing-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    try {
      await xFile.saveTo(tmpFile.path);

      final hash = await _hashFile(tmpFile);
      if (hash == null) return null;

      final key = '$hash/${await _resolveFamily(tmpFile.path, xFile.name)}';

      // 同一文件已经导入过，直接复用
      final existing = customFonts[key];
      if (existing != null && File(existing).existsSync()) {
        await _deleteFile(tmpFile);
        return MapEntry(key, existing);
      }

      final saveTo = path.join(_kFontDir, '$hash${_extensionOf(xFile.name)}');
      await _deleteFile(File(saveTo));
      await tmpFile.rename(saveTo);
      return MapEntry(key, saveTo);
    } catch (_) {
      await _deleteFile(tmpFile);
      return null;
    }
  }

  /// 族名优先取字体文件内部的名字，解析不出来才回落到文件名
  static Future<String> _resolveFamily(
    String filePath,
    String? fallbackName,
  ) async {
    final family = await FontNameParser.parse(filePath);
    if (family != null) return family;
    if (fallbackName != null) {
      final name = Utils.getFileName(fallbackName, fileExt: false);
      if (name.isNotEmpty) return name;
    }
    return '未命名字体';
  }

  /// 取内容哈希前 16 位十六进制：足够防碰撞，又不会让 key 过长
  static Future<String?> _hashFile(File file) async {
    try {
      final digest = await sha1.bind(file.openRead()).first;
      return digest.toString().substring(0, 16);
    } catch (_) {
      return null;
    }
  }

  static String _extensionOf(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    return _kFontExts.contains(ext.replaceFirst('.', '')) ? ext : '.ttf';
  }

  /// 移除单个已导入字体
  static Future<void> removeFont(String fontFamily) async {
    final filePath = customFonts.remove(fontFamily);
    if (filePath == null) return;
    _loadedFonts.remove(fontFamily);
    await _deleteFile(File(filePath));
    await GStorage.setting.put(SettingBoxKey.customAppFont, customFonts);
    await _resetSelection({fontFamily});
  }

  /// 清空整个导入池。只回收指向池内字体的选中项，系统字体的选择不受影响。
  static Future<void> clearFonts() async {
    final removed = customFonts.keys.toSet();
    customFonts.clear();
    _loadedFonts.clear();

    final dir = Directory(_kFontDir);
    if (dir.existsSync()) {
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
    }
    await GStorage.setting.put(SettingBoxKey.customAppFont, customFonts);
    await _resetSelection(removed);
  }

  /// 被移除的字体若正在使用，立即回落到默认，
  /// 避免设置项指向一个已经不存在的字体
  static Future<void> _resetSelection(Set<String> removed) async {
    final updates = <String, dynamic>{};
    if (removed.contains(Pref.appFont)) {
      updates[SettingBoxKey.appFont] = null;
    }
    if (removed.contains(Pref.customDanmakuFontFamily)) {
      updates[SettingBoxKey.customDanmakuFontFamily] = null;
      if (Pref.danmakuFontSyncMode == DanmakuFontSyncMode.custom) {
        updates[SettingBoxKey.danmakuFontSyncMode] =
            DanmakuFontSyncMode.global.index;
      }
    }
    if (updates.isNotEmpty) {
      await GStorage.setting.putAll(updates);
    }
  }

  /// 剔除文件已丢失的池条目（用户手动删了文件、跨设备恢复设置等）
  static Future<void> _pruneMissingFonts() async {
    final missing = <String>{
      for (final entry in customFonts.entries)
        if (!File(entry.value).existsSync()) entry.key,
    };
    if (missing.isEmpty) return;
    for (final key in missing) {
      customFonts.remove(key);
      _loadedFonts.remove(key);
    }
    await GStorage.setting.put(SettingBoxKey.customAppFont, customFonts);
    await _resetSelection(missing);
  }

  /// 删除池里已无引用的字体文件（导入中断、异常退出留下的残留）
  static Future<void> _cleanupOrphanFiles() async {
    final dir = Directory(_kFontDir);
    if (!dir.existsSync()) return;
    final referenced = customFonts.values.map(path.canonicalize).toSet();
    try {
      await for (final entity in dir.list()) {
        if (entity is File &&
            !referenced.contains(path.canonicalize(entity.path))) {
          await _deleteFile(entity);
        }
      }
    } catch (_) {}
  }

  static Future<void> _deleteFile(File file) async {
    if (!file.existsSync()) return;
    try {
      await file.delete();
    } catch (_) {}
  }

  /// 迁移旧版单槽位字体（customFontPath / customDanmakuFontPath）到导入池。
  /// 迁移后清空旧键，只会执行一次。
  static Future<void> _migrateLegacyFonts() async {
    final legacyAppPath = Pref.customFontPath;
    final legacyDanmakuPath = Pref.customDanmakuFontPath;
    if (legacyAppPath == null && legacyDanmakuPath == null) return;

    final updates = <String, dynamic>{};
    var poolChanged = false;

    if (legacyAppPath != null) {
      final legacyFamily = Pref.customFontFamily;
      final key = await _adoptLegacyFont(legacyAppPath, Pref.customFontName);
      poolChanged |= key != null;
      // 旧字体文件已丢失时 key 为 null，选中项一并置空
      if (legacyFamily != null && Pref.appFont == legacyFamily) {
        updates[SettingBoxKey.appFont] = key;
      }
    }

    if (legacyDanmakuPath != null) {
      final legacyFamily = Pref.customDanmakuFontFamily;
      final key = await _adoptLegacyFont(
        legacyDanmakuPath,
        Pref.customDanmakuFontName,
      );
      poolChanged |= key != null;
      if (legacyFamily != null) {
        // customDanmakuFontFamily 语义变更：改为存池 key
        updates[SettingBoxKey.customDanmakuFontFamily] = key;
        if (key == null &&
            Pref.danmakuFontSyncMode == DanmakuFontSyncMode.custom) {
          updates[SettingBoxKey.danmakuFontSyncMode] =
              DanmakuFontSyncMode.global.index;
        }
      }
    }

    if (poolChanged) {
      await GStorage.setting.put(SettingBoxKey.customAppFont, customFonts);
    }
    if (updates.isNotEmpty) {
      await GStorage.setting.putAll(updates);
    }
    await GStorage.setting.deleteAll(const {
      SettingBoxKey.customFontPath,
      SettingBoxKey.customFontFamily,
      SettingBoxKey.customFontName,
      SettingBoxKey.customDanmakuFontPath,
      SettingBoxKey.customDanmakuFontName,
    });

    for (final name in _kLegacyFontDirs) {
      final dir = Directory(path.join(appSupportDirPath, name));
      if (dir.existsSync()) {
        try {
          await dir.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  /// 把旧版字体文件复制进导入池，返回新的池 key；文件已丢失时返回 null
  static Future<String?> _adoptLegacyFont(
    String filePath,
    String? legacyName,
  ) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;

      final dir = Directory(_kFontDir);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }

      final hash = await _hashFile(file);
      if (hash == null) return null;

      final key = '$hash/${await _resolveFamily(filePath, legacyName)}';

      final existing = customFonts[key];
      if (existing != null && File(existing).existsSync()) return key;

      final saveTo = path.join(
        _kFontDir,
        '$hash${_extensionOf(legacyName ?? filePath)}',
      );
      await _deleteFile(File(saveTo));
      await file.copy(saveTo);
      customFonts[key] = saveTo;
      return key;
    } catch (_) {
      return null;
    }
  }

  static Set<String> getFont() {
    if (_initialized) return _fonts;
    _initialized = true;
    if (!switch (defaultTargetPlatform) {
      .android => _initAndroid(),
      .windows => _initWindows(),
      .linux => _initLinux(),
      _ => true,
    }) {
      // TODO: ios/macos CTFontManagerCopyAvailableFontFamilyNames
      SmartDialog.showToast('加载系统字体失败');
    }
    return _fonts;
  }

  static int _enumFontCallback(
    Pointer<LOGFONT> lpelfe,
    Pointer<TEXTMETRIC> lpntme,
    int fontType,
    int lParam,
  ) {
    final familyName = lpelfe.ref.lfFaceName;
    if (familyName.startsWith('@')) return 1;
    _fonts.add(lpelfe.ref.lfFaceName);
    return 1;
  }

  @pragma('vm:prefer-inline')
  static bool _initWindows() {
    final hdc = GetDC(null);

    final logfont = calloc<LOGFONT>();
    logfont.ref.lfCharSet = DEFAULT_CHARSET;
    logfont.ref.lfFaceName = '';

    try {
      final result = EnumFontFamiliesEx(
        hdc,
        logfont,
        Pointer.fromFunction(_enumFontCallback, 0),
        const LPARAM(0),
        0,
      );

      return result != 0;
    } finally {
      calloc.free(logfont);
      ReleaseDC(null, hdc);
    }
  }

  @pragma('vm:prefer-inline')
  static bool _initLinux() {
    final FontConfig fc;
    try {
      fc = FontConfig(DynamicLibrary.open('libfontconfig.so.1'));
    } catch (e) {
      if (kDebugMode) debugPrint('无法加载 Fontconfig 库: $e');
      return false;
    }

    final config = fc.FcInitLoadConfigAndFonts();
    if (config == nullptr) {
      if (kDebugMode) debugPrint('Fontconfig 初始化失败');
      return false;
    }

    final fontSet = fc.FcConfigGetFonts(config, FcSetName.FcSetSystem);
    if (fontSet == nullptr) {
      if (kDebugMode) debugPrint('无法获取系统字体集');
      fc.FcConfigDestroy(config);
      return false;
    }

    final nfont = fontSet.ref.nfont;
    final family = FC_FAMILY.toNativeUtf8().cast<Char>();
    for (int i = 0; i < nfont; i++) {
      final pattern = fontSet.ref.fonts[i];
      if (pattern == nullptr) continue;

      final outPtr = calloc<Pointer<UnsignedChar>>();

      try {
        final result = fc.FcPatternGetString(pattern, family, 0, outPtr);

        if (result == 0) {
          final strPtr = outPtr.value;
          if (strPtr != nullptr) {
            _fonts.add(strPtr.cast<Utf8>().toDartString());
          }
        }
      } finally {
        calloc.free(outPtr);
      }
    }
    calloc.free(family);
    fc.FcConfigDestroy(config);

    return true;
  }

  @pragma('vm:prefer-inline')
  static bool _initAndroid() {
    final fontFamilies = AndroidHelper.fontFamilies();
    if (fontFamilies != null) {
      try {
        final length = fontFamilies.length;
        for (var i = 0; i < length; i++) {
          _fonts.add(fontFamilies[i]!.toDartString(releaseOriginal: true));
        }
        return true;
      } finally {
        fontFamilies.release();
      }
    }
    return false;
  }
}
