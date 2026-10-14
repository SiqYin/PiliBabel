### PiliBabel v1.8.9

**Cover translation works, and the dialog matches the rest of the app.**

- **The cover is fetched by the app now.** The image used to be handed to the model as a
  plain Bilibili CDN URL and the server did the fetching, which fails silently because that
  CDN expects a Referer. The app downloads the cover itself and sends it inline as a data
  URI, so there is no server side fetch left to fail.
- **Failures are readable.** The request layer no longer swallows its exceptions: a failed
  image download, an empty response or an HTTP error each surface as their own message in the
  dialog instead of the generic "no content returned".
- **The dialog follows the app theme.** It uses the same `SmartDialog` animation, `AlertDialog`
  and `ColorScheme` as the update dialog, so it picks up the current theme instead of being a
  hardcoded dark card.

Downloads are below.
