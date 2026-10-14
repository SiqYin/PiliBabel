### PiliBabel v1.8.1

**The cover translation button answers every time it is pressed.**

- **No more dead taps.** The button used to bail out silently in three cases: an empty cover
  URL, the translation service not being registered yet, and the request throwing an
  exception. Any of them made a tap do nothing at all - not even a spinner. All three now end
  in a dialog: the translation on success, and the reason for the failure otherwise.
- **Bigger tap target.** The icon grew from 13 to 19, and the button now reserves a fixed
  32x32 area with an opaque hit test, so the padding around the icon is tappable as well.
- **Tooltip removed from the tap path.** It sat between the gesture detector and the icon and
  could swallow the press on some platforms.

Downloads are below.
