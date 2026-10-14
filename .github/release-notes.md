### PiliBabel v1.8.17

**The covers that used to spin forever should stop doing that.**

- **The fetch is width-capped now.** A few covers were taking so long to come down that the
  whole request timed out before the model ever saw them - typically very large uploads on a
  slow image node. The picture is now requested at 720px wide and 60 quality, which is still
  plenty for reading the text, and the original is only used if that fails.
- **Downloads give up sooner.** Send and receive limits on the image fetch are 10 and 20
  seconds, so a stuck node no longer eats the whole budget before the fallback is tried.
- **Plain http image addresses are upgraded to https.** Some covers are served over http,
  which Android can stall on.

Downloads are below.
