<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Un client Bilibili tiers avec traduction par IA.</b></p>
    <p>Babel — abattre la barrière de la langue, pour que chacun profite de bilibili dans la sienne.</p>
    <p>Comprend la traduction de 4 langues des minorités ethniques de Chine et de 3 dialectes chinois.</p>
    <p>La traduction fonctionne dès l'installation, sur le modèle gratuit de bilibili — aucune clé d'API requise.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <b>Français</b> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Accueil" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dynamiques" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Moi" />
</div>

<br/>

> **Avertissement.** PiliBabel est un client **non officiel, open source et tiers**. Il n'est **ni affilié à, ni approuvé par, ni sponsorisé par** bilibili / bilibili Inc. Toutes les API proviennent des points d'accès publics officiels ; **aucun contenu payant n'est déverrouillé ni piraté**. Merci de lire en entier les sections [Avertissement](#avertissement) et [Licence](#licence).

## Qu'est-ce que PiliBabel ?

PiliBabel est un **fork tiers indépendant construit au-dessus de [PiliNara](https://github.com/Starfallan/PiliNara)**, et il hérite de tout ce dont PiliNara hérite :

```
bilibili (API publique officielle)
        ▲
   PiliPala / PiliPalaX        — le projet d'origine
        ▲
   PiliPlus                    — fork actif
        ▲
   PiliNara                    — fork de PiliPlus (ajustements personnels)
        ▲
   PiliBabel  ← vous êtes ici   — fork de PiliNara
```

PiliBabel conserve **toutes les fonctionnalités de PiliNara / PiliPlus** (voir le [journal des fonctionnalités héritées](#journal-des-fonctionnalités-héritées-de-pilinara--piliplus) en bas de page) et ajoute **une capacité phare que les clients amont n'ont pas** :

> **Traduction d'interface et de contenu par IA** — toute l'application (libellés d'interface, titres de vidéos, noms des UP, commentaires, dynamiques, fil d'actualité et même les danmaku en direct) s'affiche dans la langue **que vous** choisissez.

Et depuis la 1.0, cela fonctionne **dès l'installation** : le modèle de traduction est **intégré**. bilibili a ouvert son propre modèle de traduction, [Index-Translate](https://github.com/bilibili/Index-Translate), servi par un point d'accès public gratuit. PiliBabel pointe dessus par défaut : la traduction marche dès que vous installez l'application — sans inscription, sans clé, sans facture. Si vous préférez votre propre modèle, la voie « API personnelle » est toujours là, à un clic.

## Fonctionnalités principales

- **La traduction par IA, partout.** Barres de navigation, cartes vidéo, pages de détail, commentaires, dynamiques, ainsi que les écrans Moi / Favoris / Historique / Messages / Recherche — un balayage global couvre **environ 1 650 chaînes d'interface**, plus le contenu dynamique (titres, noms d'auteurs, compteurs).
- **Deux moteurs, un seul réglage.** *Intégré* (par défaut) utilise le point d'accès gratuit du modèle officiel **Index-Translate-35B-A3B** de bilibili — rien à configurer. *API personnelle* conserve le comportement précédent : pointez-le vers n'importe quel point d'accès `/chat/completions` compatible OpenAI, avec votre propre URL de base / clé / modèle. Le résumé vidéo par IA et la traduction par IA gardent des points d'accès et des réglages **totalement indépendants**, réunis dans une seule page **« Fonctions IA »**.
- **Une seule liste de langues, pour les deux moteurs.** La liste des langues cibles n'est pas scindée selon le moteur : c'est la même quel que soit celui que vous choisissez. Elle réunit les **150 langues** du modèle officiel de bilibili et les **4 langues des minorités ethniques de Chine et 3 dialectes chinois** que PiliBabel ajoute — tibétain, ouïghour, zhuang et hmong d'un côté ; cantonais, wu (shanghaïen) et minnan de l'autre — plus le chinois traditionnel. Les variantes régionales et d'écriture restent des **entrées distinctes** plutôt que d'être fusionnées : l'arabe marocain / égyptien / najdi / levantin sont chacun leur propre choix, tout comme le serbe, l'ouzbek et l'urdu en cyrillique ou en latin.
- **Franc sur la couverture.** Les langues incluses dans l'inventaire officiel sont couvertes par le modèle de bilibili. Les quelques-unes qui en sont absentes — chinois traditionnel, et les dialectes chinois et langues minoritaires ci-dessus que bilibili ne référence pas — apparaissent quand même dans la liste, signalées comme telles, pour que vous sachiez d'un coup d'œil qu'un meilleur résultat peut nécessiter votre propre modèle.
- **Traduit une fois, puis figé.** Chaque chaîne source est traduite **exactement une fois** ; le résultat est conservé localement et **jamais retraduit** quand vous rouvrez un écran — le même principe que le client officiel, pour des traductions stables et prévisibles.
- **Bascule Original ⇄ Traduction commentaire par commentaire** (une petite icône, pas un mot). Les `@mentions / [émojis] / #sujets# / liens` sont préservés comme jetons, et **les commentaires contenant des hyperliens sont traduits tout en gardant le lien cliquable**.
- **Traduction des danmaku** — un interrupteur indépendant dans la barre de contrôle en haut à droite du lecteur, **désactivé par défaut** et soumis à une confirmation dont le texte est lui-même traduit. Une fois activé, les danmaku en avance sur la tête de lecture sont prétraduits par **lots d'environ 15 secondes** (un saut au milieu est traité correctement, pas depuis le début), si bien que la traduction est généralement prête quand ils défilent.
- **Interrupteur du mode réflexion** (`enable_thinking`) pour arbitrer entre qualité et rapidité, plus des boutons **« tester la traduction »** et **vider le cache** dans les réglages.
- **Changement de langue rapide** : requêtes par lots avec concurrence limitée sur un cache persistant ; changer de langue reconstruit une fois l'écran courant, pour ne pas vous laisser devant du texte non traduit. Désactiver la traduction par IA restaure tout l'affichage en texte d'origine et n'envoie **absolument aucune requête**.
- **Prise en main au premier lancement.** À la première ouverture, une boîte de dialogue en anglais propose d'activer la traduction. En acceptant, elle active la traduction, sélectionne le modèle intégré, ouvre la page de réglages IA et demande immédiatement quelle langue vous voulez — un nouvel utilisateur passe de « tout juste installé » à « application traduite » en deux appuis.
- **Une lecture qui marche partout dans le monde.** PiliBabel sélectionne le point de terminaison étranger (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) que le `playurl` géo-routé de bilibili propose déjà, au lieu de vous épingler sur un nœud continental (Alibaba Cloud / Shenzhen) — les utilisateurs hors de Chine continentale ne subissent donc plus les blocages « le son continue, l'image se figent ». Vous pouvez toujours épingler un CDN manuellement dans les réglages.
- **Une page « Thème et couleurs » de style Material You.** Clair / sombre / suivre le système se choisissent parmi **trois cartes d'aperçu en direct** — chacune dessine une miniature de l'interface réelle avec les couleurs que ce mode appliquerait (la carte « suivre le système » est coupée en diagonale, clair en haut à gauche, sombre en bas à droite). En dessous : **couleurs dynamiques** (issues du fond d'écran système quand l'appareil le permet), **sombre haute contrastée** (surfaces noires, plus reposantes la nuit) et **lecteur toujours sombre**. La moitié couleur conserve toute la palette FlexScheme — **19 teintes de base**, plus un **« style de palette »** distinct qui décide de la façon dont chaque couleur de conteneur est dérivée de la teinte de base, indépendamment de la teinte choisie.
- **LXGW WenKai est fourni avec l'application.** La police **霞鹜文楷 (LXGW WenKai)** est **incluse et définie par défaut** — une police chinoise chaleureuse et très lisible, disponible dès l'installation, au lieu d'aller la chercher dans un sélecteur. Elle s'applique à toute l'interface *et* aux danmaku. Vous pouvez revenir à la police système, choisir n'importe quelle police installée, ou importer votre propre `.ttf` / `.otf` / `.ttc` ; une police choisie explicitement avant la mise à jour est conservée. Le poids et la taille restent réglables comme avant.

## Les deux moteurs de traduction

| | Intégré (par défaut) | API personnelle |
|---|---|---|
| Modèle | bilibili **Index-Translate-35B-A3B** | n'importe quel modèle compatible OpenAI |
| Point d'accès | `index-translate.bilibili.com/v1` | votre URL de base |
| Clé d'API | **inutile** | la vôtre |
| Coût | gratuit | selon votre fournisseur |
| Requêtes | une chaîne par requête | par lots (≤ 16 par requête) |
| Langues supplémentaires | — | toute langue que votre modèle connaît |

**Pourquoi une requête par chaîne pour le moteur intégré.** Index-Translate est un modèle **spécialisé** en traduction, et la convention d'appel documentée par ses auteurs est un gabarit à un seul élément (« traduis le texte suivant en X, ne renvoie que la traduction »). PiliBabel envoie donc une chaîne par requête sur ce moteur, plutôt que le prompt par lots « liste numérotée / tableau JSON » utilisé pour une API personnelle. Le point d'accès est gratuit : il n'y a rien à gagner à parier sur une sortie par lots — c'est un compromis délibéré : quelques requêtes de plus contre beaucoup moins de façons d'échouer.

**Mise à niveau depuis la 0.3.x.** Vos réglages d'API personnelle — URL de base, clé et modèle — sont **laissés exactement tels que vous les avez configurés**. Le choix du moteur passe simplement au modèle intégré : au premier lancement après la mise à niveau, vous serez donc sur le modèle gratuit de bilibili ; ouvrez *Réglages → IA → Fonctions IA → moteur de traduction* et repassez à *API personnelle* pour revenir instantanément à votre configuration.

## Comment fonctionne la traduction d'interface (technique)

Le dépôt n'a **aucune couche de ressources i18n / ARB** — les chaînes d'interface sont en chinois en dur. Plutôt que de réécrire chaque widget, PiliBabel ajoute une fine couche de traduction par-dessus :

1. **Un habillage de recherche global.** `lib/services/ui_translate/` expose une fonction de premier niveau `uiTx(String src)`. Un `Text('中文')` devient `Text(uiTx('中文'))`. Un **codemod scripté** l'a appliqué à tout le projet (`tool/ui_translate_*.py`) — environ **223 fichiers / 1 650 chaînes** — en retirant automatiquement le mot-clé `const` devenu invalide là où c'était nécessaire (y compris les génériques comme `const X<T>(...)` et les noms pointés comme `const Positioned.fill(...)`), et en convertissant les déclarations `static const` de listes / maps en `static final`.
2. **Un cœur `GetxService`** (`ui_translate_service.dart`) :
   - un cache persistant **source → traduction** (adossé à GetStorage), donc chaque chaîne est traduite une fois et réutilisée pour toujours ;
   - `tx()` lit d'abord un `RxInt revision`, puis décide : si désactivé → retourne l'original ; si la cible est le **chinois simplifié (`zh-CN`)** → retourne l'original sans requête API (le contenu de bilibili est très majoritairement en chinois simplifié). Toute autre cible — y compris le chinois traditionnel, le cantonais, le wu et le minnan — passe par le moteur configuré ; appartenir à la famille chinoise ne suffit pas à sauter la traduction. Ensuite : servir depuis le cache ou **mettre en file** ;
   - les chaînes en file sont traitées par un **pool de workers** avec **application incrémentale par bloc** (chaque bloc renvoyé incrémente `revision`, le texte se met donc à jour progressivement), et les résultats sont **persistés** (avec limitation de fréquence). La taille des lots et la concurrence suivent le moteur : **1 par requête** sur le modèle intégré, **≤ 16 avec ≤ 10 en vol** sur votre propre API.
3. **Résolution du moteur.** `TranslateProvider` (`builtin` / `custom`) détermine l'URL, la clé et le modèle utilisés par la couche de transport ; à cela près, les deux moteurs partagent un seul chemin de code et une seule liste de langues — changer de moteur est donc un simple réglage, **jamais un autre jeu de fonctionnalités**.
4. **Le transport** réutilise le même canal **en flux** que le résumé vidéo par IA — `AiChatService.streamChat` → `{base}/chat/completions` avec `stream: true` (compatible avec les passerelles qui ne gèrent que le flux) — étendu pour que la traduction puisse utiliser ses **propres** `apiUrl` / `apiKey` / `model` et un drapeau `enable_thinking`. Le changement est **rétrocompatible**, le résumé vidéo continue de fonctionner tel quel.
5. **Les phrases interpolées** passent par `uiTxP(template, args)` : une phrase entière avec des marqueurs `{0}`/`{1}` est traduite comme une clé stable (le prompt demande au modèle de conserver les marqueurs), puis les valeurs sont réinjectées — les chaînes du type `"共 {0} 条"` se traduisent donc sans abîmer les parties dynamiques.
6. **Table des langues** (`app_language.dart`) : chaque `AppLanguage` porte un autonyme d'affichage, une chaîne de prompt `toModel` qui encode les conventions d'écriture et de région, et un indicateur précisant si l'inventaire officiel de bilibili la couvre. Les règles d'écriture (simplifié / traditionnel) et les consignes de cohérence dialectale n'atteignent le modèle **que par le prompt**, et une passe déterministe de normalisation côté client corrige ensuite les caractères récalcitrants.
7. **Les commentaires** passent par `uiTxComment(text, id)`, en gardant `@ / [émojis] / #sujet# / lien` comme jetons intacts ; les segments de texte riche portant des liens sont traduits tout en préservant la reconnaissance des liens, et un ensemble d'identifiants par commentaire pilote la bascule Original ⇄ Traduction.
8. **Danmaku** (`danmaku/view.dart`) : lorsque son interrupteur est activé, un écouteur de position parcourt `[tête de lecture, tête de lecture + 15 s]` seconde par seconde et préchauffe `uiTx()` sur le contenu de chaque danmaku, si bien que les éléments sont prétraduits avant d'atteindre l'écran ; l'activation vide et redessine le canevas.
9. **Clés de stockage** : `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Interface de réglages** : une seule page de premier niveau « Fonctions IA » (`lib/pages/setting/ui_translate/`), avec des blocs indépendants pour le résumé vidéo IA et la traduction d'interface.

**CDN mondial (`VideoUtils.getCdnUrl`).** Les URL de flux sont signées, et réécrire l'hôte d'une URL la fait rejeter en 403 — la lecture ne réécrit donc jamais l'hôte. PiliBabel renvoie l'URL géo-routée que bilibili remet à l'IP du client, et lorsque la liste de candidats contient déjà un point de terminaison étranger (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`) c'est celui-là qui est préféré. Les téléchargements, où un échange d'hôte est sans risque, préfèrent en plus le point de terminaison Akamai mondial et passent au candidat signé suivant lorsqu'une ligne se bloque ou refuse une reprise. Les liens P2P bruts `/v/resource` retombent toujours sur le relais existant pour éviter les 404.

**Compromis de conception / limites connues.** Comme les chaînes sont habillées sur place plutôt qu'extraites en ressources, quelques paramètres de chaîne non `Text` et certains segments de texte riche sont encore complétés progressivement. Les chaînes qui servent aussi de **clés logiques** (comparées avec `==`, utilisées comme noms d'onglet tels que `简介`, ou comme libellés d'énumération dans des switch) ne sont **délibérément pas** habillées en bloc, afin de ne pas casser le comportement. La traduction des danmaku est faite au mieux sur un canevas défilant — sous des danmaku très denses, vous pouvez brièvement voir l'original avant que la traduction n'arrive. La traduction nécessite un réseau ; sans lui, les cibles non chinoises ne prennent simplement pas effet. Le point d'accès intégré est un service public gratuit exploité par bilibili — s'il est un jour limité en débit ou indisponible, l'application vous le signale et vous pouvez passer à votre propre API.

## Compilation et vérification

L'application se compile avec un SDK Flutter patché ainsi que des paquets `material_ui` / `cupertino_ui` patchés, via `lib/scripts/patch.ps1` et `lib/scripts/build.ps1` (exactement comme PiliNara / PiliPlus). GitHub Actions produit un **APK de débogage** à chaque push (`.github/workflows/ui-translate-debug.yml`), et **publier un tag `v*` compile et publie automatiquement les artefacts Android, Windows et Linux** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Plateformes
- [x] Android
- [ ] iOS
- [ ] Tablette
- [x] Windows
- [x] Linux

PiliBabel fournit des compilations **Android (APK), Windows et Linux** dans les Releases ; iOS et tablette ne sont pas encore empaquetés dans ce fork.

<br/>

## Téléchargement

Récupérez une compilation dans les **Releases**, ou clonez le dépôt et compilez-le localement.

### Arch Linux

Merci à [@nlsdt](https://github.com/nlsdt) pour l'empaquetage (la recette PiliNara vaut aussi pour PiliBabel).

```bash
sudo pacman -S pilinara      # via le dépôt Arch Linux CN
paru -S pilinara-bin         # ou via AUR : pilinara-bin (précompilé) / pilinara (source)
```

<br/>

## Journal des fonctionnalités héritées (de PiliNara / PiliPlus)

Tout ce qui suit provient de PiliNara (et, transitivement, de PiliPlus) ; PiliBabel ajoute la couche de traduction par IA par-dessus.

**Interface et adaptation aux plateformes**
- [x] Application renommée par plateforme pour que plusieurs clients coexistent (PiliBabel s'installe à côté de PiliNara)
- [x] Rendu Flutter corrigé sous la mini-fenêtre de Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)) ; animation de retour prédictif sous Android
- [x] Ordre et nombre des cartes « Moi » personnalisables ; aperçu des cartes d'historique et section « regarder plus tard »
- [x] Bascule automatique de la barre latérale avec largeur de déclenchement réglable ; copie d'image par appui long / clic droit ; grande refonte de style MD3E

**Système de polices** — un pool d'import unifié avec déduplication par hachage de contenu, les polices de danmaku fusionnées dans le même pool, `loadFontFromList` avec prise en charge des ttc, et des noms de famille de police en ASCII pur.

**Lecture, mini-fenêtre et qualité** — mini-fenêtre intégrée (glisser, redimensionner, saut SponsorBlock, PIP système automatique, barre d'auto-récupération pour le direct), lecture audio concurrente, volume intégré jusqu'à 200 %, domaine CDN vidéo personnalisé et sélection de nœud régional avec test de latence, qualité par défaut distincte en demi-écran et plein écran, verrouillage de la vitesse par balayage vers le haut, contrôle clavier sur tablette, horodatage des SuperChat en direct, battement de cœur pour l'intimité des fans en direct.

**Sous-titres, IA et hors ligne** — sous-titres bilingues avec style indépendant du sous-titre secondaire, analyse de sous-titres par IA (point d'accès compatible OpenAI personnalisé, saut à l'horodatage, gabarits, conversations persistées, repli doux sans sous-titre), export WEBVTT/SRT, double vue du cache hors ligne avec gestion des dossiers et persistance des métadonnées, export des téléchargements vers le dossier Download public (Android).

**Danmaku et blocage** — mise à l'échelle améliorée des danmaku fusionnés (à la [Pakku.js](https://github.com/xmcp/pakku.js)), blocage par expressions régulières visuelles sous forme de liste avec import/export, saut dans le segment SponsorBlock, barre de progression à haute énergie par noyau gaussien.

**Filtrage des recommandations / dynamiques / commentaires** — mots-clés de titre / UP / chaîne, durée, nombre de vues, taux de likes, exemption des UP suivis, filtrage des vidéos non autorisées / réservées aux abonnés, liste blanche partagée, dynamiques commerciales / non autorisées, exemption des commentaires de l'UP et des commentaires épinglés, mode de fil fusionné App + Web.

**Dynamiques, recherche et informations utilisateur** — notes personnalisées pour les UP, note remplaçant le pseudo sur 13 emplacements, tri indépendant des réponses imbriquées, filtre de recherche par mot-clé local, saut des liens courts b23.tv, badge « réservé aux abonnés », réglage pour masquer la raison de recommandation, affichage de l'XP des pièces.

**Améliorations du direct** — panneau de port du fan-medal, diffusion DLNA privilégiant HLS, affichage de l'heure des SuperChat, barre de contrôle inférieure de la mini-fenêtre pour l'auto-récupération.

**Intégration système et bureau** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), gestion du focus audio réécrite.

<details>
<summary>Liste complète des fonctionnalités d'origine (verbatim, de PiliNara — cliquez pour déplier)</summary>

**feat**
编辑动态 · DLNA 投屏 · 离线缓存/播放 · 点击弹幕悬停(点赞/复制/举报) · 播放音频 · 跳过番剧片头/片尾 · 安卓 `loudnorm` · Win/Mac 极验/短信登录 · 视频截取动图 · AI 原声翻译 · SuperChat · 播放课堂视频 · 发起投票 · 发布动态/评论支持富文本/表情/@用户 · 修改消息/聊天设置 · 展示折叠消息 · 查看用户图文 · 动态话题 · 直播分区 · 分享至消息 · 创建/修改/删除关注分组 · 移除粉丝 · 直播弹幕发送表情 · 收藏夹排序 · 稍后再看分类 · WebDAV 备份/恢复 · 保存评论/动态 · 高级弹幕 · 取消/置顶评论 · 记笔记 · 多账号支持 · 屏蔽带货动态/评论 · 互动视频 · 发评/动态反诈 · 高能进度条 · 滑动跳转预览缩略图 · Live Photo · 复制/移动/排序收藏夹 · 超分辨率 · 会员彩色弹幕 · 播放全部/继续/倒序 · Cookie 登录 · 显示视频分段信息 · 调节字幕/全屏弹幕大小 · 收藏夹多选删除 · 搜索用户动态 · 直播弹幕 · 修改资料 · 创建/编辑/删除收藏夹 · 评论楼中楼对话/定位/排序 · 评论点踩 · 私信发图 · 投币动画 · 取消/追番 · 取消/订阅合集 · SponsorBlock · 显示完整合集 · 三连/番剧三连动画 · 带图评论 · 视频 TAG · 筛选搜索 · 转发动态 · 合集图片 · 私信删除/置顶/撤回 · 举报 · 发布/删除/置顶动态

**opt**
专栏界面 · 私信界面 · 收藏面板 · PIP · 视频封面 · 回复界面 · 系统通知 · 评论显示 · 亮度调节 · 视频播放 · 视频 staff · 防止 bottomsheet 遮挡全屏视频

**fix**
番剧分集点赞/投币/收藏 · bugs

**功能**
推荐视频列表(app 端) · 最热视频 · 热门直播 · 番剧列表 · 黑名单屏蔽 · 无痕模式 · 游客模式；用户(粉丝/关注/拉黑、主页、关注取关、离线缓存、稍后再看、观看记录、我的收藏、站内私信)；动态(全部/投稿/番剧、评论与回复)；播放(双击快进快退、播放暂停、亮度音量、上滑全屏、手势快进、全屏方向、倍速、硬件加速、画质/音质/解码、弹幕、字幕、记忆播放、比例)；搜索(热搜、历史、默认词、投稿/番剧/直播/用户、排序与时长筛选)；视频详情(分 P 切换、点赞投币收藏、相关视频、评论身份、排序与二楼、回复、点赞、笔记图)；设置(画质/音质/解码预设、图片质量、主题、震动、高帧率、自动全屏、横屏适配)

</details>

<br/>

## Avertissement

PiliBabel est un projet personnel, motivé par l'intérêt, fourni **à des fins d'apprentissage et de test uniquement** ; merci de le supprimer dans les **24 heures** suivant le téléchargement.

- PiliBabel est un client **tiers non officiel** et n'est **ni affilié à, ni approuvé par, ni sponsorisé par bilibili**.
- Toutes les API proviennent de points d'accès publics officiels ; **aucun contenu piraté, sur-privilégié ou contournant un paywall** n'est fourni.
- **La traduction par IA s'exécute sur un point d'accès de modèle tiers.** Par défaut, il s'agit du service public gratuit Index-Translate de bilibili lui-même ; si vous passez à votre propre API, il s'agit du point d'accès que vous avez configuré. La qualité et la conformité des traductions relèvent de l'utilisateur et du fournisseur de modèle choisi ; ce projet **n'héberge aucun modèle et aucune clé d'API**.
- Respectez le droit d'auteur et les conditions d'utilisation de bilibili. Utilisez-le de manière responsable.

Avec le respect dû aux auteurs d'origine et amont pour leur engagement open source :
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — le projet parent direct de PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — la famille de modèles de traduction open source appelée par le moteur intégré

Si un contenu porte atteinte à vos droits, contactez-nous pour son retrait.

<br/>

## Licence

PiliBabel est distribué sous **GNU General Public License v3.0 (GPL-3.0)** — la même licence que PiliNara, PiliPlus et PiliPala. Parce qu'il s'agit d'une œuvre dérivée, **PiliBabel doit également être distribué sous GPL-3.0** : vous êtes libre de l'utiliser, de l'étudier, de le partager et de le modifier, à condition de conserver la même licence, les mentions de copyright et ce texte de licence. Voir [`LICENSE`](./LICENSE).

Les composants tiers (paquets Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), etc.) restent sous leurs propres licences.


La police **霞鹜文楷** incluse est soumise séparément à la **SIL Open Font License 1.1** ; son texte de licence est distribué avec l'application dans `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Remerciements

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — la famille de modèles de traduction open source de bilibili, et le point d'accès public gratuit derrière le moteur intégré
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — la police chinoise open source incluse dans l'application, sous licence SIL Open Font License 1.1
- et bien d'autres
- Inspiré par la « traduction d'interface par IA » officielle de bilibili.
