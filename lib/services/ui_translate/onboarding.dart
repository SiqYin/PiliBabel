import 'dart:async';

import 'package:PiliPlus/utils/storage.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

bool _showing = false;

/// First-launch onboarding for the AI interface-translation feature.
/// Shows an English dialog once, explaining where to turn it on and offering a
/// shortcut straight to the settings page. Silently no-ops after the first run.
Future<void> showAiTranslateOnboardingIfNeeded() async {
  if (Pref.uiTranslateOnboarded || _showing) return;
  _showing = true;
  // Wait for the first route / navigator to be ready.
  await Future.delayed(const Duration(milliseconds: 700));
  await Get.dialog<void>(
    AlertDialog(
      title: const Text('AI interface translation'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PiliBabel can translate the whole app — menus, video titles, '
              'authors, comments and danmaku — into the language you choose.',
            ),
            SizedBox(height: 12),
            Text(
              'Enable it under:\n'
              'Settings  →  AI  →  AI interface translation\n'
              'Then add your own API (base URL / key / model) and pick a '
              'language. Every text is translated once and cached.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Pref.uiTranslateOnboarded = true;
            Get.back();
          },
          child: const Text('Got it'),
        ),
        FilledButton(
          onPressed: () {
            Pref.uiTranslateOnboarded = true;
            Get.back();
            Get.toNamed('/aiTranslate');
          },
          child: const Text('Configure AI translation'),
        ),
      ],
    ),
    barrierDismissible: false,
    useSafeArea: true,
  );
  _showing = false;
}
