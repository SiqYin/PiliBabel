class Elec {
  int? total;
  List<ElecItem>? list;

  Elec({
    this.total,
    this.list,
  });

  factory Elec.fromJson(Map<String, dynamic> json) => Elec(
    total: json['total'] as int?,
    list: (json['list'] as List<dynamic>?)
        ?.map((e) => ElecItem.fromJson(e))
        .toList(),
  );
}

class ElecItem {
  String? uname;
  String? avatar;

  ElecItem({
    this.uname,
    this.avatar,
  });

  factory ElecItem.fromJson(Map<String, dynamic> json) => ElecItem(
    uname: json['uname'] as String?,
    avatar: json['avatar'] as String?,
  );
}
