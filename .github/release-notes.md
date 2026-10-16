### PiliBabel v2.2.0

A layout pass for the sidebar, and for the screens where it appears.

**The sidebar now sizes itself to your language**

- On a tablet in landscape, the left column is a drawer, and its width was pinned at
  130 logical pixels. That fits two or three Chinese characters; a word like
  "Recommendations" in a longer language does not, so the first entries came out cut in
  half. The drawer now measures the longest navigation label in the current language and
  sizes itself accordingly, up to 45% of the screen so a very long language cannot eat
  the content area.
- The icon-and-label rail used elsewhere had the same problem from the other direction:
  Flutter's default minimum width of 72 pixels, with labels laid out inside it. It now
  takes the measured label width as well, so the rail widens instead of clipping.
- Both keep a single-line ellipsis as a last resort, so nothing is ever hard-cut again.

**Phone in landscape no longer gets a vertical sidebar**

- The breakpoint only looked at width. A phone in landscape is wide enough to qualify
  for the sidebar but only 360 to 420 pixels tall, which is not enough height for the
  navigation entries plus the header above them. Mobile devices under 480 pixels tall
  now stay on the bottom navigation bar, where the height is not a problem.

**What this covers**

- Phone portrait and landscape, tablet portrait and landscape, and desktop all share the
  same sidebar code, so the sizing fix applies to every one of them. Desktop windows are
  unaffected by the short-screen rule, which is limited to mobile.

Downloads are below.
