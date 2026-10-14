### PiliBabel v1.8.0

**Subtitles and covers translate themselves now.**

- **Built-in Chinese subtitles are translated.** When a video ships a Chinese subtitle track
  (including Bilibili's `ai-zh` auto-generated one) and the interface language is anything
  other than Simplified Chinese, that track is opened automatically and its lines are
  translated into the interface language. Simplified Chinese is left alone, since the source
  is already Simplified Chinese, and a video with no subtitles keeps them off. Auto-opening
  only applies while the subtitle preference is still at its default; if you have picked a
  preference yourself, your choice wins. Translation itself is not optional: whatever Chinese
  track is on screen gets translated.
- **Cover translation.** Every video cover now carries a small button in its bottom-left
  corner. Tapping it asks the built-in multimodal model what the text on that cover says and
  shows the answer in the interface language; a cover with no text says so. The request only
  goes out when you tap.
- **Badges translate too.** The charging-exclusive and interactive-video labels next to the
  video title, and the badges on video cards, used to be hardcoded or taken straight from the
  API and stayed Chinese. They go through the translation table now.
- **Search boxes on the list pages.** Watch history, favourites, following and watch-later
  each have their own search box, and typing in the interface language found nothing because
  Bilibili's search only understands the Chinese original. They now resolve the query the
  same way the video search page does, and fall back to exactly what you typed when
  translation is unavailable.

Downloads are below.
