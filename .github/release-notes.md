### PiliBabel v2.3.2

- The frozen-picture line switch from 2.3.0 did not compile: it passed the flag as a
  named argument on the recovery method, and the compiler refused it even though the
  parameter was declared. The flag now travels on a field that the recovery method reads
  once, which compiles and behaves the same. Nothing else changes.

Downloads are below.
