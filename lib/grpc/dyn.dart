import 'package:PiliPlus/grpc/bilibili/app/dynamic/v1.pb.dart'
    show
        DynRedReq,
        TabOffset,
        DynRedReply,
        DynVideoReq,
        DynVideoReqReply;
import 'package:PiliPlus/grpc/bilibili/app/dynamic/v2.pb.dart'
    show
        OpusType,
        OpusDetailReq,
        OpusDetailResp,
        LikeListReq,
        LikeListReply,
        RepostListReq,
        RepostListRsp,
        RepostType,
        DynAllReq,
        DynAllReply,
        DynSpaceReq,
        DynSpaceRsp;
import 'package:PiliPlus/grpc/grpc_req.dart';
import 'package:PiliPlus/grpc/url.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:fixnum/fixnum.dart';

abstract final class DynGrpc {
  // static Future dynSpace({
  //   required int uid,
  //   required int page,
  // }) {
  //   return _request(
  //     GrpcUrl.dynSpace,
  //     DynSpaceReq(
  //       hostUid: Int64(uid),
  //       localTime: 8,
  //       page: Int64(page),
  //       from: 'space',
  //     ),
  //     DynSpaceRsp.fromBuffer,
  //   );
  // }

  static Future<int?> dynRed() async {
    final res = await GrpcReq.request(
      GrpcUrl.dynRed,
      DynRedReq(tabOffset: [TabOffset(tab: 1)]),
      DynRedReply.fromBuffer,
    );
    return res.dataOrNull?.dynRedItem.count.toInt();
  }

  /// E3.1 动态主 feed（全部/视频等标签页）走 gRPC，参数与官方 App 同源：
  /// page 从 1 开始，翻页带 offset（服务端下发），localTime 为时区偏移。
  static Future<LoadingState<DynAllReply>> dynAll({
    String? offset,
    int? page,
    int? localTime,
    String? from,
    int? coldStart,
    String? updateBaseline,
  }) {
    return GrpcReq.request(
      GrpcUrl.dynAll,
      DynAllReq(
        offset: offset,
        page: page,
        localTime: localTime,
        from: from,
        coldStart: coldStart,
        updateBaseline: updateBaseline,
      ),
      DynAllReply.fromBuffer,
    );
  }

  /// E3.1 动态视频标签页（DynVideo，官方在 v1 命名空间）
  static Future<LoadingState<DynVideoReqReply>> dynVideo({
    String? offset,
    int? page,
    int? refreshType,
    int qn = 32,
    int fnver = 0,
    int fnval = 4048,
    int forceHost = 2,
    int fourk = 1,
    String? updateBaseline,
  }) {
    return GrpcReq.request(
      GrpcUrl.dynVideo,
      DynVideoReq(
        offset: offset,
        page: page,
        refreshType: refreshType,
        qn: qn,
        fnver: fnver,
        fnval: fnval,
        forceHost: forceHost,
        fourk: fourk,
        updateBaseline: updateBaseline,
      ),
      DynVideoReqReply.fromBuffer,
    );
  }

  /// E3.1 空间页动态（DynSpace）走 gRPC，参数与官方一致
  static Future<LoadingState<DynSpaceRsp>> dynSpace({
    required int uid,
    int page = 1,
    String? offset,
    int localTime = 8,
    String from = 'space',
  }) {
    return GrpcReq.request(
      GrpcUrl.dynSpace,
      DynSpaceReq(
        hostUid: Int64(uid),
        page: Int64(page),
        offset: offset,
        localTime: localTime,
        from: from,
      ),
      DynSpaceRsp.fromBuffer,
    );
  }

  static Future<LoadingState<OpusDetailResp>> opusDetail({
    OpusType? opusType,
    required int oid,
  }) {
    return GrpcReq.request(
      GrpcUrl.opusDetail,
      OpusDetailReq(
        opusType: opusType,
        oid: Int64(oid),
      ),
      OpusDetailResp.fromBuffer,
    );
  }

  static Future<LoadingState<LikeListReply>> likeList({
    required String dynamicId,
    Int64? dynType,
    Int64? rid,
    Int64? uidOffset,
    required int page,
  }) {
    return GrpcReq.request(
      GrpcUrl.likeList,
      LikeListReq(
        dynamicId: dynamicId,
        dynType: dynType,
        rid: rid,
        uidOffset: uidOffset,
        page: page,
      ),
      LikeListReply.fromBuffer,
    );
  }

  static Future<LoadingState<RepostListRsp>> repostList({
    required String dynamicId,
    Int64? dynType,
    Int64? rid,
    String? offset,
    String? from,
    RepostType repostType = .repost_general,
  }) {
    return GrpcReq.request(
      GrpcUrl.repostList,
      RepostListReq(
        dynamicId: dynamicId,
        dynType: dynType,
        rid: rid,
        offset: offset,
        repostType: repostType,
      ),
      RepostListRsp.fromBuffer,
    );
  }
}
