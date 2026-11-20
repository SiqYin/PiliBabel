### PiliBabel v3.9.6

**Every search box outside the home screen now shows results as you type — no Enter needed.**

History, favorites, watch-later, followed users, and the download list used to wait for you to press Enter; they now fire a debounced search (200 ms) right after you stop typing, and clear back to the initial state when you empty the box. The two-tab search screens — live, UP space (videos and posts), and in-video comments — behave the same way. Enter still works as an instant search; on live search, a digits-only query is deliberately left to Enter so typing a room number doesn't jump rooms mid-typing. Keyword resolution and the simplified/traditional variant search from 3.9.5 run unchanged under the hood, with per-word caching so continuous typing doesn't multiply requests.

**The chapter (segment) bar under the video no longer shrinks its text into unreadability.** When a segment title is wider than its segment, the bar used to scale the whole label down proportionally — with long original titles and even longer translations, the glyphs ended up a few pixels tall. It now wraps the title automatically inside its own segment, up to 3 lines (ellipsis beyond that), at a fixed, readable font size; the bar simply grows taller to fit the tallest segment, and looks exactly like before when everything fits on one line. Translated titles re-layout as soon as they arrive.

Nothing else changed: the home screen search keeps its suggestion-as-you-type flow, and all variant searches stay first-page-only with per-item de-duplication.
