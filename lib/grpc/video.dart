import 'package:PiliPlus/grpc/bilibili/app/playurl/v1.pb.dart';
import 'package:PiliPlus/grpc/grpc_req.dart';
import 'package:PiliPlus/grpc/url.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:fixnum/fixnum.dart';

/// 视频取流（官方 APP 协议）。
///
/// 与官方 Android APP 同源：走 gRPC `bilibili.app.playurl.v1.PlayURL/PlayView`，
/// 而不是 Web 端 `/x/player/wbi/playurl`。
///
/// 两条路下发的**候选主机是同一批**（实测同一 IP、同一稿件两者返回的主机集合
/// 完全一致），但**直链令牌按客户端类型签发**，CDN 端会按令牌校验请求指纹：
///
/// | 令牌来源 | 允许的媒体请求指纹 |
/// |---|---|
/// | Web（`/x/player/wbi/playurl`） | 必须带 `Referer: https://www.bilibili.com`，且 `upos-*-mirror*ov` 只接受 Safari/macOS 的 UA |
/// | APP（`PlayView`） | 必须**不带** `Referer`（带非空 Referer 会被 403），UA 不限 |
///
/// 所以换到 APP 取流后，媒体请求也必须同步成 APP 的指纹，见
/// `PlPlayerController._createVideoController` 里按 [NetworkSource.appSource]
/// 切换 `user-agent` / `referrer`。
abstract final class VideoGrpc {
  /// [qn] 传最高档（如 129）时，B 站仍会返回**全部**清晰度的 stream（有权限的
  /// 那些才带 dash_video），与 Web 端行为一致，因此画质切换不需要额外请求。
  static Future<LoadingState<PlayViewReply>> playView({
    required int aid,
    required int cid,
    required int qn,
    int fnval = 4048,
    int fnver = 0,
    bool fourk = true,
    /// 2 = 使用 https（明文 http 会被运营商劫持/注入）
    int forceHost = 2,
    bool voiceBalance = false,
  }) {
    return GrpcReq.request(
      GrpcUrl.playView,
      PlayViewReq(
        aid: Int64(aid),
        cid: Int64(cid),
        qn: Int64(qn),
        fnver: fnver,
        fnval: fnval,
        forceHost: forceHost,
        fourk: fourk,
        voiceBalance: Int64(voiceBalance ? 1 : 0),
      ),
      PlayViewReply.fromBuffer,
    );
  }
}
