import 'package:PiliPlus/models/model_owner.dart';

class Guard {
  String? uri;
  String? desc;
  List<Owner>? item;

  Guard({
    this.uri,
    this.desc,
    this.item,
  });

  factory Guard.fromJson(Map<String, dynamic> json) => Guard(
    uri: json['uri'] as String?,
    desc: json['desc'] as String?,
    item: (json['item'] as List<dynamic>?)
        ?.map((e) => Owner.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
