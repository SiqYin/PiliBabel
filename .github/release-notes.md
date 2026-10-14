### PiliBabel v1.8.11

**The cover image is sent with its real format.**

- **Why the server answered 500.** The cover was always declared as `image/jpeg`, but the
  Bilibili CDN hands WebP to a mobile user agent. The server tried to decode WebP bytes as
  JPEG and failed. The format is now read from the image's own header - WebP, PNG, GIF and
  JPEG are all recognised.
- **A fallback for the data URI.** If the server rejects an inline image with a 5xx, the
  request is retried once with the plain image URL, which is how the endpoint originally
  expected to receive it.
- **Failures stay readable.** A failed image download, an empty response and an HTTP error
  each report themselves, so the reason is visible rather than guessed.

Downloads are below.
