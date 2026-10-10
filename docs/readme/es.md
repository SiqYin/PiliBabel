<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Un cliente de Bilibili de terceros con traducción por IA.</b></p>
    <p>Babel — derribar la barrera del idioma, para que cada persona disfrute de bilibili en el suyo.</p>
    <p>Incluye traducción de 4 lenguas de las minorías étnicas de China y 3 dialectos chinos.</p>
    <p>La traducción funciona nada más instalar, con el modelo gratuito de bilibili: no hace falta clave de API.</p>
</div>

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Inicio" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dinámicas" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Yo" />
</div>

<br/>

> **Aviso legal.** PiliBabel es un cliente **no oficial, de código abierto y de terceros**. **No está afiliado a bilibili / bilibili Inc., ni cuenta con su respaldo o patrocinio**. Todas las API provienen de puntos de acceso públicos oficiales; **no se desbloquea ni se piratea ningún contenido de pago**. Lee íntegramente las secciones [Aviso legal](#aviso-legal) y [Licencia](#licencia).

## ¿Qué es PiliBabel?

PiliBabel es un **fork independiente de terceros construido sobre [PiliNara](https://github.com/Starfallan/PiliNara)**, y hereda todo lo que PiliNara hereda:

```
bilibili (API pública oficial)
        ▲
   PiliPala / PiliPalaX        — el proyecto original
        ▲
   PiliPlus                    — fork activo
        ▲
   PiliNara                    — fork de PiliPlus (ajustes personales)
        ▲
   PiliBabel  ← estás aquí      — fork de PiliNara
```

PiliBabel conserva **todas las funciones de PiliNara / PiliPlus** (consulta el [registro de funciones heredadas](#registro-de-funciones-heredadas-de-pilinara--piliplus) al final) y añade **una capacidad principal que los clientes originales no tienen**:

> **Traducción de interfaz y contenido por IA**: toda la aplicación (etiquetas de la interfaz, títulos de vídeos, nombres de los UP, comentarios, dinámicas, el feed e incluso los danmaku en directo) se muestra en el idioma **que tú** elijas.

Y desde la 1.0 funciona **nada más instalar**: el modelo de traducción viene **integrado**. bilibili publicó su propio modelo de traducción, [Index-Translate](https://github.com/bilibili/Index-Translate), servido desde un punto de acceso público y gratuito. PiliBabel apunta ahí por defecto, así que la traducción funciona en cuanto instalas la aplicación: sin registro, sin clave y sin factura. Si prefieres tu propio modelo, la vía de «API propia» sigue ahí, a un toque.

## Funciones principales

- **Traducción por IA, en todas partes.** Barras de navegación, tarjetas de vídeo, páginas de detalle, comentarios, dinámicas y las pantallas Yo / Favoritos / Historial / Mensajes / Búsqueda: un barrido global cubre **unos 1650 textos de interfaz**, más el contenido dinámico (títulos, nombres de autores, contadores).
- **Dos motores, un solo ajuste.** *Integrado* (por defecto) usa el punto de acceso gratuito del modelo oficial **Index-Translate-35B-A3B** de bilibili: nada que configurar. *API propia* mantiene el comportamiento anterior: apúntala a cualquier punto de acceso `/chat/completions` compatible con OpenAI, con tu propia URL base / clave / modelo. El resumen de vídeo por IA y la traducción por IA siguen teniendo puntos de acceso y ajustes **totalmente independientes**, reunidos en una sola página **«Funciones de IA»**.
- **Una sola lista de idiomas, para ambos motores.** La lista de idiomas de destino no se divide por motor: es la misma elijas el que elijas. Reúne los **150 idiomas** del modelo oficial de bilibili con las **4 lenguas de las minorías étnicas de China y 3 dialectos chinos** que añade PiliBabel — tibetano, uigur, zhuang y hmong por un lado; cantonés, wu (shanghainés) y minnan por otro — más el chino tradicional. Las variantes regionales y de escritura se mantienen como **entradas separadas** en lugar de fusionarse: el árabe marroquí / egipcio / najdí / levantino son cada uno su propia opción, igual que el serbio, el uzbeko y el urdu en cirílico o en latino.
- **Honesto con la cobertura.** Los idiomas dentro del inventario oficial los cubre el modelo de bilibili. Los pocos que quedan fuera —el chino tradicional y los dialectos chinos y lenguas minoritarias anteriores que bilibili no recoge— siguen apareciendo en la lista, marcados como tales, para que veas de un vistazo que un mejor resultado puede requerir tu propio modelo.
- **Se traduce una vez y queda fijado.** Cada cadena de origen se traduce **exactamente una vez**; el resultado se guarda en local y **nunca se vuelve a traducir** al reabrir una pantalla, el mismo principio que el cliente oficial, para conseguir traducciones estables y predecibles.
- **Conmutador Original ⇄ Traducción por comentario** (un icono pequeño, no una palabra). Las `@menciones / [emojis] / #temas# / enlaces` se conservan como tokens, y **los comentarios con hipervínculos se traducen manteniendo el enlace pulsable**.
- **Traducción de danmaku**: un interruptor independiente en la barra de control superior derecha del reproductor, **desactivado por defecto** y protegido por una confirmación cuyo propio texto también se traduce. Una vez activado, los danmaku por delante de la posición de reproducción se pretraducen en **lotes de unos 15 segundos** (un salto al medio se trata correctamente, no desde el principio), de modo que la traducción suele estar lista cuando pasan por pantalla.
- **Interruptor del modo de razonamiento** (`enable_thinking`) para elegir entre calidad y velocidad, más los botones **«probar traducción»** y **vaciar caché** en los ajustes.
- **Cambio de idioma rápido**: peticiones por lotes con concurrencia limitada sobre una caché persistente; cambiar de idioma reconstruye una vez la pantalla actual, para no dejarte mirando texto sin traducir. Desactivar la traducción por IA devuelve toda la interfaz al texto original y **no envía ninguna petición**.
- **Guía en el primer arranque.** La primera vez que abres la aplicación, un diálogo en inglés ofrece activar la traducción. Si aceptas, activa la traducción, selecciona el modelo integrado, abre la página de ajustes de IA y pregunta de inmediato qué idioma quieres: un usuario nuevo pasa de «recién instalado» a «ya traducido» con dos toques.
- **Reproducción que funciona en todo el mundo.** PiliBabel selecciona el nodo extranjero (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) que el `playurl` con enrutado geográfico de bilibili ya ofrece, en lugar de clavarte a un nodo de China continental (Alibaba Cloud / Shenzhen), así que quienes están fuera de China continental ya no sufren los bloqueos de «el audio sigue, la imagen se congela». Aun así, puedes fijar un CDN manualmente en los ajustes.

## Los dos motores de traducción

| | Integrado (por defecto) | API propia |
|---|---|---|
| Modelo | bilibili **Index-Translate-35B-A3B** | cualquiera compatible con OpenAI |
| Punto de acceso | `index-translate.bilibili.com/v1` | tu URL base |
| Clave de API | **no hace falta** | la tuya |
| Coste | gratuito | según tu proveedor |
| Peticiones | una cadena por petición | por lotes (≤ 16 por petición) |
| Idiomas adicionales | — | cualquier idioma que conozca tu modelo |

**Por qué una cadena por petición en el motor integrado.** Index-Translate es un modelo **especializado** en traducción, y la convención de llamada que documentan sus autores es una plantilla de un solo elemento («traduce el texto siguiente a X, devuelve solo la traducción»). Por eso PiliBabel envía una cadena por petición en este motor, en lugar del prompt por lotes con «lista numerada / array JSON» que usa para las API propias. El punto de acceso es gratuito, así que no hay nada que ganar apostando por una salida por lotes: es un intercambio deliberado de unas pocas peticiones más por muchas menos formas de fallar.

**Actualización desde la 0.3.x.** Tus ajustes de API propia —URL base, clave y modelo— se **dejan exactamente como los configuraste**. La selección de motor simplemente pasa al modelo integrado, así que en el primer arranque tras la actualización estarás con el modelo gratuito de bilibili; abre *Ajustes → IA → Funciones de IA → motor de traducción* y vuelve a *API propia* para regresar al instante a tu configuración.

## Cómo funciona la traducción de interfaz (técnico)

El repositorio **no tiene ninguna capa de recursos i18n / ARB**: los textos de la interfaz están escritos en chino directamente en el código. En lugar de reescribir cada widget, PiliBabel añade una fina capa de traducción por encima:

1. **Un envoltorio global de consulta.** `lib/services/ui_translate/` expone una función de nivel superior `uiTx(String src)`. Donde antes había `Text('中文')` ahora hay `Text(uiTx('中文'))`. Un **codemod con script** lo aplicó a todo el proyecto (`tool/ui_translate_*.py`): unos **223 archivos / 1650 cadenas**, quitando automáticamente la palabra clave `const` que dejaba de ser válida donde hacía falta (incluidos genéricos como `const X<T>(...)` y nombres con punto como `const Positioned.fill(...)`), y convirtiendo las declaraciones `static const` de listas y mapas en `static final`.
2. **Un núcleo `GetxService`** (`ui_translate_service.dart`):
   - una caché persistente **origen → traducción** (respaldada por GetStorage), de modo que cada cadena se traduce una vez y se reutiliza para siempre;
   - `tx()` lee primero un `RxInt revision` y luego decide: si está desactivado → devuelve el original; si el destino es el **chino simplificado (`zh-CN`)** → devuelve el original sin petición a la API (el contenido de bilibili es abrumadoramente chino simplificado). Cualquier otro destino —incluidos el chino tradicional, el cantonés, el wu y el minnan— pasa por el motor configurado; pertenecer a la familia china no basta para saltarse la traducción. Después: servir desde la caché o **encolar**;
   - las cadenas encoladas las procesa un **grupo de workers** con **aplicación incremental por bloque** (cada bloque devuelto incrementa `revision`, así que el texto se actualiza de forma progresiva), y los resultados se **persisten** (con limitación de frecuencia). El tamaño de lote y la concurrencia siguen al motor: **1 por petición** en el modelo integrado, **≤ 16 con ≤ 10 en vuelo** en tu propia API.
3. **Resolución del motor.** `TranslateProvider` (`builtin` / `custom`) determina qué URL, clave y modelo usa la capa de transporte; aparte de eso, ambos motores comparten una única ruta de código y una única lista de idiomas, así que cambiar de motor es un solo ajuste y **nunca un conjunto de funciones distinto**.
4. **El transporte** reutiliza el mismo canal **en streaming** ya probado que el resumen de vídeo por IA: `AiChatService.streamChat` → `{base}/chat/completions` con `stream: true` (compatible con pasarelas que solo admiten streaming), ampliado para que la traducción pueda usar sus **propios** `apiUrl` / `apiKey` / `model` y un indicador `enable_thinking`. El cambio es **retrocompatible**, así que el resumen de vídeo sigue funcionando igual.
5. **Las frases con marcadores** pasan por `uiTxP(template, args)`: una frase entera con marcadores `{0}`/`{1}` se traduce como una clave estable (el prompt pide al modelo que conserve los marcadores) y luego se sustituyen los valores, de modo que cadenas como `"共 {0} 条"` se traducen sin estropear las partes dinámicas.
6. **Tabla de idiomas** (`app_language.dart`): cada `AppLanguage` lleva un autónimo para mostrar, una cadena de prompt `toModel` que codifica convenciones de escritura y región, y un indicador de si el inventario oficial de bilibili la cubre. Las reglas de escritura (simplificado / tradicional) y las indicaciones de coherencia dialectal llegan al modelo **solo a través del prompt**, y después una pasada determinista de normalización en el cliente corrige los caracteres rebeldes.
7. **Los comentarios** pasan por `uiTxComment(text, id)`, manteniendo `@ / [emojis] / #tema# / enlace` como tokens intactos; los tramos de texto enriquecido con enlaces se traducen preservando el reconocimiento de enlaces, y un conjunto de identificadores por comentario gobierna el conmutador Original ⇄ Traducción.
8. **Danmaku** (`danmaku/view.dart`): cuando su interruptor está activado, un escucha de posición recorre `[posición de reproducción, posición de reproducción + 15 s]` segundo a segundo y precalienta `uiTx()` sobre el contenido de cada danmaku, de modo que los elementos llegan ya traducidos a la pantalla; al activarlo se vacía y se repinta el lienzo.
9. **Claves de almacenamiento**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Interfaz de ajustes**: una sola página de primer nivel «Funciones de IA» (`lib/pages/setting/ui_translate/`), con bloques independientes para el resumen de vídeo por IA y la traducción de interfaz.

**CDN global (`VideoUtils.getCdnUrl`).** Las URL de streaming van firmadas, y reescribir el host de una URL provoca un 403, así que la reproducción nunca reescribe el host. PiliBabel devuelve la URL con enrutado geográfico que bilibili entrega a la IP del cliente y, cuando la lista de candidatos ya incluye un nodo extranjero (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`), se prefiere ese. Las descargas, donde cambiar el host sí es seguro, además prefieren el nodo global de Akamai y rotan al siguiente candidato firmado cuando una línea se atasca o rechaza una reanudación. Los enlaces P2P directos `/v/resource` siguen recurriendo al relé existente para evitar errores 404.

**Compromisos de diseño / límites conocidos.** Como las cadenas se envuelven en su sitio en lugar de extraerse a recursos, algunos parámetros de cadena que no son `Text` y ciertos tramos de texto enriquecido aún se van completando poco a poco. Las cadenas que además sirven como **claves lógicas** (comparadas con `==`, usadas como nombres de pestaña como `简介`, o como etiquetas de enumeración en conmutadores) **deliberadamente no** se envuelven en bloque, para no romper el comportamiento. La traducción de danmaku es de mejor esfuerzo sobre un lienzo en movimiento: con danmaku muy densos puede que veas brevemente el original antes de que llegue la traducción. La traducción necesita red; sin ella, los destinos distintos del chino simplemente no surten efecto. El punto de acceso integrado es un servicio público gratuito operado por bilibili: si alguna vez se limita o deja de estar disponible, la aplicación te lo indica y puedes cambiar a tu propia API.

## Compilación y verificación

La aplicación se compila con un SDK de Flutter parcheado y paquetes `material_ui` / `cupertino_ui` parcheados, mediante `lib/scripts/patch.ps1` y `lib/scripts/build.ps1` (igual que PiliNara / PiliPlus). GitHub Actions produce un **APK de depuración** en cada push (`.github/workflows/ui-translate-debug.yml`), y **publicar una etiqueta `v*` compila y publica automáticamente los artefactos de Android, Windows y Linux** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Plataformas
- [x] Android
- [ ] iOS
- [ ] Tableta
- [x] Windows
- [x] Linux

PiliBabel ofrece compilaciones de **Android (APK), Windows y Linux** en Releases; iOS y tableta aún no se empaquetan en este fork.

<br/>

## Descarga

Consigue una compilación en **Releases**, o clona el repositorio y compílalo en local.

### Arch Linux

Gracias a [@nlsdt](https://github.com/nlsdt) por el empaquetado (la receta de PiliNara sirve igual para PiliBabel).

```bash
sudo pacman -S pilinara      # desde el repositorio Arch Linux CN
paru -S pilinara-bin         # o vía AUR: pilinara-bin (precompilado) / pilinara (código fuente)
```

<br/>

## Registro de funciones heredadas (de PiliNara / PiliPlus)

Todo lo siguiente proviene de PiliNara (y, de forma transitiva, de PiliPlus); PiliBabel añade encima la capa de traducción por IA.

**Interfaz y adaptación a plataformas**
- [x] Aplicación renombrada por plataforma para que varios clientes convivan (PiliBabel se instala junto a PiliNara)
- [x] Renderizado de Flutter corregido en la miniventana de Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), vía [venera#467](https://github.com/venera-app/venera/pull/467)); animación de retroceso predictivo en Android
- [x] Orden y número de las tarjetas de «Yo» personalizables; vista previa de las tarjetas de historial y sección «ver más tarde»
- [x] Cambio automático de la barra lateral con ancho de activación configurable; copiar imagen con pulsación larga / clic derecho; gran renovación de estilo MD3E

**Sistema de fuentes** — un grupo de importación unificado con deduplicación por hash de contenido, fuentes de danmaku fusionadas en el mismo grupo, `loadFontFromList` con soporte de ttc y nombres de familia de fuente en ASCII puro.

**Reproducción, miniventana y calidad** — miniventana integrada (arrastrar, redimensionar, salto de SponsorBlock, PIP del sistema automático, barra de autorrescate en directo), reproducción de audio concurrente, volumen dentro de la app hasta el 200 %, dominio CDN de vídeo personalizado y selección de nodo regional con prueba de latencia, calidad predeterminada distinta en media pantalla y pantalla completa, bloqueo de velocidad con deslizamiento hacia arriba, control por teclado en tabletas, marcas de tiempo de SuperChat en directo, latido para la intimidad de los fans en directo.

**Subtítulos, IA y sin conexión** — subtítulos bilingües con estilo independiente del subtítulo secundario, análisis de subtítulos por IA (punto de acceso compatible con OpenAI personalizado, salto a la marca de tiempo, plantillas, conversaciones persistidas, reserva suave cuando no hay subtítulos), exportación a WEBVTT/SRT, doble vista de la caché sin conexión con gestión de carpetas y persistencia de metadatos, exportación de descargas a la carpeta Download pública (Android).

**Danmaku y bloqueo** — escalado mejorado de danmaku fusionados (estilo [Pakku.js](https://github.com/xmcp/pakku.js)), bloqueo visual por expresiones regulares en forma de lista con importación y exportación, salto dentro del segmento de SponsorBlock, barra de progreso de alta energía con núcleo gaussiano.

**Filtrado de recomendaciones / dinámicas / comentarios** — palabras clave de título / UP / sección, duración, número de reproducciones, tasa de «me gusta», exención de UP seguidos, filtrado de no autorizados / exclusivos para cargadores, lista blanca compartida, dinámicas comerciales / no autorizadas, exención de los comentarios propios del UP y de los fijados, modo de feed combinado App + Web.

**Dinámicas, búsqueda e información de usuario** — notas personalizadas para los UP, la nota sustituye el apodo en 13 posiciones, ordenación independiente de respuestas anidadas, filtro de búsqueda por palabra clave local, salto de enlaces cortos b23.tv, distintivo «exclusivo para cargadores», ajuste para ocultar el motivo de la recomendación, visualización de la experiencia de monedas.

**Mejoras del directo** — panel de colocación de la medalla de fan, emisión DLNA con preferencia por HLS, visualización de la hora de los SuperChat, barra de control inferior de la miniventana para el autorrescate.

**Integración con el sistema y escritorio** — Windows SMTC, Linux MPRIS (`audio_service_mpris`), gestión del foco de audio reescrita.

<details>
<summary>Lista completa de funciones originales (literal, de PiliNara — pulsa para desplegar)</summary>

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

## Aviso legal

PiliBabel es un proyecto personal, movido por el interés, y se ofrece **solo para aprendizaje y pruebas**; elimínalo en las **24 horas** siguientes a su descarga.

- PiliBabel es un cliente **de terceros no oficial** y **no está afiliado a bilibili ni cuenta con su respaldo o patrocinio**.
- Todas las API provienen de puntos de acceso públicos oficiales; **no se ofrece contenido pirateado, con privilegios excesivos ni que eluda muros de pago**.
- **La traducción por IA se ejecuta en un punto de acceso de modelo de terceros.** Por defecto es el servicio público y gratuito Index-Translate de la propia bilibili; si cambias a tu propia API, es el punto de acceso que hayas configurado. La calidad y el cumplimiento de las traducciones son responsabilidad del usuario y del proveedor de modelo elegido; este proyecto **no aloja ningún modelo ni proporciona ninguna clave de API**.
- Respeta los derechos de autor y las condiciones de uso de bilibili. Úsalo con responsabilidad.

Con respeto a los autores originales y anteriores por su dedicación al código abierto:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — el proyecto padre directo de PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — la familia de modelos de traducción de código abierto que llama el motor integrado

Si algún contenido infringe tus derechos, contáctanos para retirarlo.

<br/>

## Licencia

PiliBabel se distribuye bajo la **GNU General Public License v3.0 (GPL-3.0)**, la misma licencia que PiliNara, PiliPlus y PiliPala. Al ser una obra derivada, **PiliBabel también debe distribuirse bajo GPL-3.0**: eres libre de usarlo, estudiarlo, compartirlo y modificarlo siempre que conserves la misma licencia, los avisos de copyright y este texto de licencia. Consulta [`LICENSE`](./LICENSE).

Los componentes de terceros (paquetes de Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), etc.) siguen bajo sus propias licencias.

<br/>

## Agradecimientos

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — la familia de modelos de traducción de código abierto de bilibili y el punto de acceso público gratuito que hay detrás del motor integrado
- y más
- Inspirado en la «traducción de interfaz por IA» oficial de bilibili.
