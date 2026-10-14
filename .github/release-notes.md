### PiliBabel v1.8.10

**Cover translation actually sends the image now.**

- **A string escape had swallowed the payload.** The base64 data URI was written with an
  escaped dollar sign, so instead of the encoded image the request carried the literal text
  `${base64Encode(bytes)}`. The escape is corrected.
- **Everything from 1.8.9 still applies.** The app downloads the cover itself (with the
  Referer the CDN expects) and sends it inline, so no server side fetch is left to fail;
  request failures surface their own message instead of a generic one; and the result dialog
  uses the same `SmartDialog` + `AlertDialog` + `ColorScheme` style as the update dialog.

Downloads are below.
