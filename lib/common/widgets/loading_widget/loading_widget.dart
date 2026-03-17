import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:flutter/material.dart';

const Widget circularLoading = Center(child: CircularProgressIndicator());

const Widget linearLoading = SliverToBoxAdapter(
  child: LinearProgressIndicator(),
);

const Widget scrollableError = CustomScrollView(slivers: [HttpError()]);

Widget scrollErrorWidget({
  String? errMsg,
  VoidCallback? onReload,
  ScrollController? controller,
}) => CustomScrollView(
  controller: controller,
  slivers: [
    HttpError(
      errMsg: errMsg,
      onReload: onReload,
    ),
  ],
);
