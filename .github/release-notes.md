### PiliBabel v2.4.5

- Searching in Simplified Chinese no longer goes through AI translation: the query is sent as-is, and titles in the results stay in the original language.
- "Simplified Chinese" is now decided by glyph: the text must contain Han characters, contain no kana or Hangul, and every Han character must be a simplified or shared (inherited) form - traditional-only forms and Japanese shinjitai are excluded.
- Searching in a foreign language still translates the query into Chinese, and now also searches with the original text; both result sets are merged by rank with duplicates removed.

Downloads are below.
