### PiliBabel v2.3.7

Fixes two output problems in image translation.

- When an image contains only a character or two, the model could degenerate into endless repetition, emitting empty "original / translation" pairs or looping the same one or two lines. The prompt only said how many groups to split the text into, with no stop condition, so the model kept padding when there was nothing left to enumerate. It now states that each group may appear only once, that no empty entries may be added, and that the model must stop as soon as it notices a repeat. A `max_tokens` cap was also added.
- The image description was frequently skipped. It is now mandatory, and the output is post-processed to drop empty entries, truncate repeated loops and cap the total number of lines.

Downloads are below.
