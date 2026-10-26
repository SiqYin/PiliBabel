import base64, json, os, secrets, string, subprocess, urllib.request
REPO = "SiqYin/PiliBabel"
TOK = os.environ["GH_TOKEN"]
KEYDIR = os.path.join(os.environ.get("USERPROFILE", os.path.expanduser("~")), "pilibabel-keystore")
os.makedirs(KEYDIR, exist_ok=True)
KS = os.path.join(KEYDIR, "pilibabel-release.jks")
ALIAS = "pilibabel"
def pwd(n=28):
    a = string.ascii_letters + string.digits
    return ''.join(secrets.choice(a) for _ in range(n))
sp, kp = pwd(), None  # PKCS12: key password must equal store password
kp = sp
if os.path.exists(KS): os.remove(KS)
subprocess.run(["keytool","-genkeypair","-keystore",KS,"-alias",ALIAS,
  "-keyalg","RSA","-keysize","2048","-validity","10950",
  "-storepass",sp,"-keypass",kp,
  "-dname","CN=PiliBabel, OU=PiliBabel, O=PiliBabel, C=US","-storetype","PKCS12"], check=True)
ks_b64 = base64.b64encode(open(KS,"rb").read()).decode()
with open(os.path.join(KEYDIR,"BACKUP-keystore-info.txt"),"w",encoding="utf-8") as f:
    f.write("PiliBabel release signing key BACKUP (KEEP SAFE / DO NOT SHARE)\n"
            f"path: {KS}\nstoreFile name: pilibabel-release.jks\nkeyAlias: {ALIAS}\n"
            f"storePassword: {sp}\nkeyPassword: {kp}\n")
with open(os.path.join(KEYDIR,"keystore.b64"),"w") as f: f.write(ks_b64)
def api(method,url,data=None):
    req=urllib.request.Request(url,method=method,data=json.dumps(data).encode() if data else None,
        headers={"Authorization":"Bearer "+TOK,"Accept":"application/vnd.github+json",
                 "X-GitHub-Api-Version":"2022-11-28","Content-Type":"application/json"})
    try:
        with urllib.request.urlopen(req) as r: return r.status, r.read()
    except urllib.error.HTTPError as e: return e.code, e.read()
from nacl.public import PublicKey, SealedBox
st, body = api("GET", f"https://api.github.com/repos/{REPO}/actions/secrets/public-key")
print("public-key:", st)
pk = json.loads(body); key_id = pk["key_id"]
def put_secret(name, value):
    sealed = SealedBox(PublicKey(base64.b64decode(pk["key"]))).encrypt(value.encode())
    s,b = api("PUT", f"https://api.github.com/repos/{REPO}/actions/secrets/{name}",
        {"key_id": key_id, "encrypted_value": base64.b64encode(sealed).decode()})
    print(name, s, (b[:120] if s>=400 else ""))
put_secret("KEYSTORE_B64", ks_b64)
put_secret("KEYSTORE_PASSWORD", sp)
put_secret("KEY_ALIAS", ALIAS)
put_secret("KEY_PASSWORD", kp)
print("keystore:", KS, os.path.getsize(KS), "bytes")
print("DONE")
