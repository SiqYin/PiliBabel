import 'package:flutter/foundation.dart';

/// 网络状态广播（A5.2）：断网恢复 / 换网后通知页面补拉。
///
/// 只广播「网络从不可用变为可用」这一个事件，页面自己决定要不要补拉：
/// 一般是列表处于错误态时才补拉，用户正常浏览中的页面不打扰。
abstract final class NetStatus {
  /// 每次网络恢复 +1；页面 addListener 后自行决定是否补拉。
  static final ValueNotifier<int> restored = ValueNotifier<int>(0);

  /// 当前是否有网（由连通性监听维护）。
  static final ValueNotifier<bool> online = ValueNotifier<bool>(true);

  static void notifyRestored() {
    online.value = true;
    restored.value++;
  }

  static void notifyOffline() {
    online.value = false;
  }
}
