### PiliBabel v1.8.15

**Cover recognition no longer gives up after 15 seconds.**

- **The wait was too short.** Reading a cover means downloading the image, uploading it and then
  waiting for a vision model to answer - far slower than plain text translation, and slower
  still on a poor connection. The 15 second limit was cutting the request off before the model
  could reply; it is now 60 seconds, which is what the HTTP layer was already allowing.
- **The timeout message says something useful.** Instead of the raw exception text, it now
  explains the wait and points at the "detect again" button.

Downloads are below.
