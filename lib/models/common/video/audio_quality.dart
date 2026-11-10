enum AudioQuality {
  u_100010(100010, '100010'),
  u_100009(100009, '100009'),
  u_100008(100008, '100008'),
  hiRes(30251, 'Hi-Res无损', rank: 60),
  dolby_30250(30250, '杜比全景声', rank: 50),
  dolby_30255(30255, '杜比全景声', rank: 50),
  k192(30280, '192K', rank: 40),
  k132(30232, '132K', rank: 30),
  k64(30216, '64K', rank: 20),
  ;

  final int code;
  final String desc;

  /// 音质优先级，数值越大音质越高。未知音质为 0。
  final int rank;

  const AudioQuality(this.code, this.desc, {this.rank = 0});

  /// 是否为 HiRes 无损音质（B 站 code 30251）。
  bool get isHiRes => this == AudioQuality.hiRes;

  /// 比 [this] 低一档里最高的那档；已经是最低档时返回自身。
  ///
  /// HiRes 熄灭时用它落到「HiRes 以下的下一档最高」。只比较 `rank`，
  /// 所以杜比（rank 50）会排在 192K（rank 40）之前，与 B 站音质排序一致。
  AudioQuality get nextLower {
    AudioQuality? best;
    for (final candidate in values) {
      if (candidate.rank >= rank) continue;
      if (best == null || candidate.rank > best.rank) best = candidate;
    }
    return best ?? this;
  }

  @override
  String toString() => 'code: $code, desc: $desc';

  static final _codeMap = {for (final i in values) i.code: i};

  static AudioQuality fromCode(int code) => _codeMap[code]!;

  /// 宽松版 [fromCode]：未知 code 返回 null 而不是抛异常。
  ///
  /// B 站随时可能下发新的音质 code（例如 30255 就是这么来的）。播放栏要按
  /// 「本条视频有没有 HiRes 轨」遍历全部音轨，那里一旦遇到未知 code 不能崩——
  /// 一个新增音质码不该让整个播放栏构建失败。
  static AudioQuality? maybeFromCode(int? code) =>
      code == null ? null : _codeMap[code];
}
