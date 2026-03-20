class UinfoMedal {
  String? name;
  int? level;
  int? colorBorder;
  int? color;
  int? id;
  int? ruid;
  String? v2MedalColorStart;
  String? v2MedalColorEnd;
  String? v2MedalColorBorder;
  String? v2MedalColorText;
  String? v2MedalColorLevel;

  UinfoMedal({
    this.name,
    this.level,
    this.colorBorder,
    this.color,
    this.id,
    this.ruid,
    this.v2MedalColorStart,
    this.v2MedalColorEnd,
    this.v2MedalColorBorder,
    this.v2MedalColorText,
    this.v2MedalColorLevel,
  });

  factory UinfoMedal.fromJson(Map<String, dynamic> json) => UinfoMedal(
    name: json['name'] as String?,
    level: json['level'] as int?,
    colorBorder: json['color_border'] as int?,
    color: json['color'] as int?,
    id: json['id'] as int?,
    ruid: json['ruid'] as int?,
    v2MedalColorStart: json['v2_medal_color_start'] as String?,
    v2MedalColorEnd: json['v2_medal_color_end'] as String?,
    v2MedalColorBorder: json['v2_medal_color_border'] as String?,
    v2MedalColorText: json['v2_medal_color_text'] as String?,
    v2MedalColorLevel: json['v2_medal_color_level'] as String?,
  );
}
