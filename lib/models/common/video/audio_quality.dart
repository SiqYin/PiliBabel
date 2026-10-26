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

  @override
  String toString() => 'code: $code, desc: $desc';

  static final _codeMap = {for (final i in values) i.code: i};

  static AudioQuality fromCode(int code) => _codeMap[code]!;
}
