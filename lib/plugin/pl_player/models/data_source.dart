import 'package:PiliPlus/utils/path_utils.dart';
import 'package:path/path.dart' as path;

sealed class DataSource {
  final String videoSource;
  final String? audioSource;

  DataSource({
    required this.videoSource,
    required this.audioSource,
  });
}

class NetworkSource extends DataSource {
  /// B 站为该流下发的**全部已签名**候选地址（baseUrl + backupUrl）。
  /// 播放停摆时按序换用其中另一条。只能“挑现成的地址”，
  /// 绝不可改写主机——签名与主机绑定，改写会被 403 拒绝（v0.1.8 教训）。
  final List<String> videoUrls;
  final List<String> audioUrls;

  /// 直链是否来自官方 APP 的取流接口（gRPC `PlayView`）。
  ///
  /// CDN 会按直链令牌的签发方校验请求指纹：APP 令牌要求**不带** `Referer`，
  /// Web 令牌要求带 `Referer`（且部分海外主机只认 Safari 的 UA）。指纹不对
  /// 一律 403，所以媒体请求头必须跟着这个标记走。
  final bool appSource;

  NetworkSource({
    required super.videoSource,
    required super.audioSource,
    this.videoUrls = const [],
    this.audioUrls = const [],
    this.appSource = false,
  });
}

class FileSource extends DataSource {
  final String dir;
  final bool isMp4;

  FileSource({
    required this.dir,
    required this.isMp4,
    required bool hasDashAudio,
    required String typeTag,
  }) : super(
         videoSource: path.join(
           dir,
           typeTag,
           isMp4 ? PathUtils.videoNameType1 : PathUtils.videoNameType2,
         ),
         audioSource: isMp4 || !hasDashAudio
             ? null
             : path.join(dir, typeTag, PathUtils.audioNameType2),
       );
}
