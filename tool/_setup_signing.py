import base64, json, os, secrets, string, subprocess, urllib.request, urllib.error
REPO = "SiqYin/PiliBabel"
TOK = os.environ["GH_TOKEN"]
KEYDIR = "/c/Users/29736/.qwenworkcn/workspace/mu2p5u7hxrufda0h/keystore"
os.makedirs(KEYDIR, exist_ok=True)
KS = os.path.join(KEYDIR, "pilibabel-release.jks")
ALIAS = "pilibabel"
def pwd(n=24):
    a = string.ascii_letters + string.digits
    return ''.join(secrets.choice(a) for _ in range(n))
sp = pwd(); kp = pwd()
if os.path.exists(KS): os.remove(KS)
subprocess.run(["keytool","-genkeypair","-keystore",KS,"-alias",ALIAS,
  "-keyalg","RSA","-keysize","2048","-validity","10950",
  "-storepass",sp,"-keypass",kp,
  "-dname","CN=PiliBabel, OU=PiliBabel, O=PiliBabel, C=US","-storetype","JKS"],
  check=True)
ks_b64 = base64.b64encode(open(KS,"rb").read()).decode()
# backup file (user must keep) — not in repo
with open(os.path.join(KEYDIR,"BACKUP-README.txt"),"w",encoding="utf-8") as f:
    f.write("PiliBabel release signing key BACKUP — keep safe, losing it means future updates can't upgrade in place.\n"
            f"keystore: pilibabel-release.jks\nkeyAlias: {ALIAS}\nstorePassword: {sp}\nkeyPassword: {kp}\n")
with open(os.path.join(KEYDIR,"keystore.b64"),"w") as f:
    f.write(ks_b64)
def api(method, url, data=None):
    req = urllib.request.Request(url, method=method,
        data=json.dumps(data).encode() if data else None,
        headers={"Authorization":"Bearer "+TOK,"Accept":"application/vnd.github+json",
                 "X-GitHub-Api-Version":"2022-11-28","Content-Type":"application/json"})
    with urllib.request.urlopen(req) as r:
        return r.status, r.read()
# repo public key
st, body = api("GET", f"https://api.github.com/repos/{REPO}/actions/secrets/public-key")
pk = json.loads(body); box_pub = pk["key"]; key_id = pk["key_id"]
from nacl.public import PublicKey, SealedBox
def put_secret(name, value):
    sealed = SealedBox(PublicKey(base64.b64decode(box_pub))).encrypt(value.encode())
    st, b = api("PUT", f"https://api.github.com/repos/{REPO}/actions/secrets/{name}",
        {"key_id": key_id, "encrypted_data": base64.b64encode(sealed).decode()})
    print(name, st)
put_secret("KEYSTORE_B64", ks_b64)
put_secret("KEYSTORE_PASSWORD", sp)
put_secret("KEY_ALIAS", ALIAS)
put_secret("KEY_PASSWORD", kp)
print("keystore at", KS, "size", os.path.getsize(KS))
print("DONE — secrets set (values only in keystore/backup, never in repo)")
