### PiliBabel v1.6.3

- **Fixed: the "choose app language" dialog only offered 6 languages.** With the default Simplified Chinese interface the list showed nothing but the 6 entries outside Bilibili's official inventory - 繁體中文, 简体吴语, 繁體吳語, 大陆闽南语, 臺灣閩南語, Vahcuengh - so a fresh install could not even pick 简体中文 back. The other 151 languages were simply missing.
- **The data was never the problem.** `appLanguages` holds all 151 official entries plus those 6, and the coverage note above the list ("covers 151 languages") was correct the whole time. The 151 rows were being dropped while rendering.
- **Why they vanished.** Each row sits in its own `Obx` so it refreshes when a translation arrives. An official row has no subtitle, so it never calls `uiTx`, which left that `Obx` with no observable at all - and the row failed to build. A release build shows no red screen for that, it just drops the row silently. The 6 unofficial rows do call `uiTx`, which is exactly why only those 6 survived.
- Every row now reads `UiTranslateService.to.revision.value` up front, the same idiom the page body and the cancel button already use, so all 151 official languages are back.

Downloads are below.
