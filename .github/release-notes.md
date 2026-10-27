### PiliBabel v3.3.13

**Faster loading: data requests now go direct by default instead of through the in-app self-resolver proxy.**

**Problem.** Since v3.3.0 every request was routed through the app's local DNS-resolver proxy (DnsProxy, a 127.0.0.1 CONNECT tunnel). Each tunnel connection re-runs self-resolution, re-connects, and re-does the TLS handshake, and upstream connections are not reused — measured at roughly **2–3× slower** than v3.0.5's direct connections.

**Fix.** Data requests now connect directly by default (`Pref.netDirect`, on by default): neither the HTTP/2 connection pool nor the global HttpClient is pointed at the local proxy anymore, and image downloads keep an explicit `findProxy = DIRECT` as a second safeguard. With HTTPS + SNI everywhere, self-resolution's anti-hijacking benefit is marginal while the direct-connection speed win is substantial.

**Revertible.** A new setting, "Network direct connection (turn off to use the self-resolver proxy)", lets you switch back if your network can only reach the service through self-resolution. Switching rebuilds the connection pool immediately — no app restart needed.

Downloads are below.