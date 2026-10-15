### PiliBabel v2.1.2

Two fixes to image translation output, both about the language it comes back in.

- **The result is now written in the target language, not in Chinese.** A cover full of
  Simplified Chinese used to come back with the original, the translation and the
  description of the picture all in Simplified Chinese - the model was mirroring the
  language of the image, and of the instruction itself. The output language is now stated
  as the single most important rule, spelled out part by part (translation, labels and
  description each have to be in the target language), with the mirroring case called out
  explicitly: the image being Chinese, or the instruction being Chinese, is not a reason
  to answer in Chinese. Only the quoted original keeps its own language.
- **The "original" and "translation" labels follow the target language.** They were
  hard-coded Simplified Chinese in the instruction, so the model copied them verbatim.
  The labels are now required to be written in the target language - Original and
  Translation in English, and so on.

Downloads are below.
