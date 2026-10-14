### PiliBabel v1.10.7

**The home feed blocks now grow and shrink with the switch.**

- The grid delegate on the home feed was a `late final` field: it was computed once and
  then cached, so rebuilding the page never picked up the new height. It is a getter now
  and is recomputed on every build.
- Turning the option on stretches the home blocks to fit four title lines; turning it off
  puts them back immediately. The same applies to the member, ranking, live and search grids.

Downloads are below.
