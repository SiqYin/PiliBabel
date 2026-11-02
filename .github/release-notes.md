### PiliBabel v3.5.9

**Fixes trending keywords growing to three lines: it should be one line → two lines.**

In v3.5.6, when trending keywords were made to wrap onto a second line, `maxLines` was written as `full ? 3 : 1` — so expanding produced **three** lines instead of the intended two, which is why many trending entries showed an extra blank line.

It is now `full ? 2 : 1`: **one line by default, two lines when "show full title" is enabled.**

The third line was originally reserved out of concern that a label would get clipped when the text filled two full lines. But the label is a `WidgetSpan` that flows with the text rather than occupying its own line, so two lines are enough for the keyword plus its label.

Downloads are below.
