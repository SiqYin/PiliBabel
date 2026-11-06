### PiliBabel v3.7.5

**Danmaku translation now actually works — and the queue, the cover button and the archive got their long-overdue fixes.**

**Bullet comments arrive translated instead of mostly Chinese.** Danmaku used to be queued for translation one line at a time just 15 seconds ahead of the playhead, while the built-in engine issues one request per line — popular videos could never keep up, and a comment whose translation missed its birth moment displayed the original forever (canvas items render once). Whole segments are now batch pre-translated the moment they load, so comments appear in the target language from the first frame; toggling the switch warms everything already loaded too.

**Freshly refreshed titles no longer starve behind pre-warmed labels.** Pre-translation used to dump 200+ strings into the top-priority queue and drain it exclusively, leaving newly pulled titles waiting tens of seconds. Pre-warming now feeds the normal queue, and the two queues take turns, so new titles get service within a round or two.

**The cover button's ring turns into a checkmark the moment it fills.** It used to stop at a complete circle with no completion cue at all. Now a filled ring becomes a small green check and stays; the ring itself is larger with a bigger hollow centre, making progress easier to read while loading.

**Old translated tracks are reused instead of retranslated.** Legacy tracks named by bare language tags (`zh-app-ai`) now recover their full target code from metadata, so a Traditional Chinese translation made months ago is found again when you switch back; wrong-script files are still refused.

**Housekeeping.** The release-notes archive is complete again (34 versions from 3.4.0 to 3.7.2 recovered from history), and 17 slow async file checks were modernised. A deeper speed pass on the subtitle chunk pipeline is evaluated and deferred to the next release.

Downloads are below.
