### PiliBabel v1.8.16

**Image translation: faster, and it now covers comments and articles.**

- **Much faster on big images.** Recognition used to fetch the original picture - often a
  megabyte or more - and upload it in full. It now asks the image service for a compressed
  copy first and only falls back to the original if that fails, which is where the long
  waits were coming from.
- **Comments and article illustrations too.** The button is no longer only on video covers:
  pictures in comments and images inside articles get it as well. It is called "image
  translation" everywhere now.
- **Animated images are skipped.** GIFs, and WebP files that carry an animation block, are
  refused with a short message instead of being sent for recognition.

Downloads are below.
