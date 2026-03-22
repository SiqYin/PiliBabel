class UinfoMedal {
  String? name;
  int? level;
  int? id;
  int? ruid;
  String? v2MedalColorStart;
  String? v2MedalColorText;

  UinfoMedal({
    this.name,
    this.level,
    this.id,
    this.ruid,
    this.v2MedalColorStart,
    this.v2MedalColorText,
  });

  factory UinfoMedal.fromJson(Map<String, dynamic> json) => UinfoMedal(
    name: json['name'] as String?,
    level: json['level'] as int?,
    id: json['id'] as int?,
    ruid: json['ruid'] as int?,
    v2MedalColorStart: json['v2_medal_color_start'] as String?,
    v2MedalColorText: json['v2_medal_color_text'] as String?,
  );
}
