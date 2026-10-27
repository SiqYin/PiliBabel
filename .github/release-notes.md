### PiliBabel v3.3.15

**Stability follow-up and documentation completion.**

**Media proxy now hard-wired to direct connections.** Since v3.3.14 enabled multi-connection segmented transfer by default, the upstream connections opened by `MediaProxy` were still subject to the global `HttpOverrides`. If you manually turned off "network direct connection" (routing through the self-resolver proxy), each of the N concurrent range requests would have become its own tunnel through the in-app DNS proxy — risking overwhelming that proxy and starving data requests (the same class of failure as v3.3.11). Its upstream client now sets `findProxy = DIRECT` explicitly, fully decoupling it from the data path.

**README documentation completed (backlog items 84–86).** All 44 language READMEs now carry a note that the documentation is written and maintained with AI translation tooling, with the English version as the reference. Also verified that the "offline audio caching / download to local" sections exist in every language version.

Downloads are below.