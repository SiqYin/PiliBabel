import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:flutter/material.dart';

extension EditableTextExt on EditableTextState {
  void addLaunchMenuIfNeeded(
    List<ContextMenuButtonItem> buttonItems, {
    required int index,
  }) {
    final selection = textEditingValue.selection;
    if (!selection.isCollapsed) {
      buttonItems.insertOrAdd(
        index,
        ContextMenuButtonItem(
          label: '打开',
          onPressed: () {
            hideToolbar();
            clearSelection(selection);
            PageUtils.launchURL(
              selection.textInside(textEditingValue.text).trim(),
            );
          },
        ),
      );
    }
  }

  void clearSelection(TextSelection currSelection) {
    widget.controller.selection = .collapsed(offset: currSelection.end);
  }

  void clearSelectionIfNeeded() {
    final selection = textEditingValue.selection;
    if (!selection.isCollapsed) {
      clearSelection(selection);
    }
  }
}
