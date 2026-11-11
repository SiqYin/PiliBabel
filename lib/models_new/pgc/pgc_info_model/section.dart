import 'package:PiliPlus/models_new/pgc/pgc_info_model/episode.dart';

class Section {
  /// 分节标题（正片、PV、花絮……）。
  String? title;
  List<EpisodeItem>? episodes;

  Section({
    this.title,
    this.episodes,
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    episodes: (json['episodes'] as List<dynamic>?)
        ?.map((e) => EpisodeItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
