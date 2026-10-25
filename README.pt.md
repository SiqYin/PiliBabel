<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>Um cliente de terceiros para a bilibili com tradução por IA.</b></p>
    <p>Babel — derrubando a barreira do idioma, para que todos possam aproveitar a bilibili no seu próprio idioma.</p>
    <p>Une o inventário oficial de 151 idiomas da bilibili com mais 6 que ele não cobre - chinês tradicional, wu simplificado e tradicional, hokkien do continente e de Taiwan, e zhuang.</p>
    <p>A tradução funciona logo de cara no modelo gratuito da própria bilibili — não é necessária chave de API.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.nan.md">台語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <a href="README.ko.md">한국어</a> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.mn.md">Монгол</a> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.hi.md">हिन्दी</a> · <b>Português</b> · <a href="README.bn.md">বাংলা</a> · <a href="README.th.md">ไทย</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.it.md">Italiano</a> · <a href="README.fa.md">فارسی</a> · <a href="README.fil.md">Filipino</a> · <a href="README.ur.md">اردو</a> · <a href="README.mr.md">मराठी</a> · <a href="README.te.md">తెలుగు</a> · <a href="README.ta.md">தமிழ்</a> · <a href="README.pa.md">ਪੰਜਾਬੀ</a> · <a href="README.gu.md">ગુજરાતી</a> · <a href="README.ha.md">Hausa</a> · <a href="README.sw.md">Kiswahili</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.my.md">မြန်မာ</a> · <a href="README.pl.md">Polski</a> · <a href="README.is.md">Íslenska</a> · <a href="README.nb.md">Norsk</a> · <a href="README.fi.md">Suomi</a> · <a href="README.sv.md">Svenska</a> · <a href="README.da.md">Dansk</a> · <a href="README.be.md">Беларуская</a> · <a href="README.ug.md">ئۇيغۇرچە</a> · <a href="README.kk.md">Қазақша</a> · <a href="README.bo.md">བོད་ཡིག</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="Início" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="Dinâmicas" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="Meu perfil" />
</div>

<br/>

> **Aviso legal.** O PiliBabel é um cliente **não oficial, de código aberto e de terceiros**. Ele **não é afiliado, endossado nem patrocinado** pela bilibili / bilibili Inc. Todas as APIs são coletadas de endpoints públicos oficiais; **nenhum conteúdo pago é desbloqueado ou crackeado**. Por favor, leia as seções completas de [Aviso legal](#aviso-legal) e [Licença](#licença).

## O que é o PiliBabel?

O PiliBabel é um **fork de terceiros e independente, construído sobre o [PiliNara](https://github.com/Starfallan/PiliNara)**, e herda tudo o que o PiliNara herda:

```
bilibili (API pública oficial)
        ▲
   PiliPala / PiliPalaX        — o projeto original
        ▲
   PiliPlus                    — fork ativo
        ▲
   PiliNara                    — fork do PiliPlus (ajustes pessoais)
        ▲
   PiliBabel  ← você está aqui — fork do PiliNara
```

O PiliBabel mantém **todos os recursos do PiliNara / PiliPlus** (veja o [registro de recursos herdados](#registro-de-recursos-herdados-do-pilinara--piliplus) perto do final) e adiciona **duas capacidades de destaque que os clientes upstream não têm**:

> **Tradução de interface e conteúdo por IA** — o aplicativo inteiro (rótulos da interface, títulos de vídeos, nomes de UP, comentários, dinâmicas, feed e até danmaku ao vivo, os comentários flutuantes que atravessam a tela) é renderizado no idioma que **você** escolher.

E desde a versão 1.0 ele faz isso **pronto para uso**: o modelo de tradução vem **embutido**. A bilibili abriu o código da sua própria família de modelos de tradução, a [Index-Translate](https://github.com/bilibili/Index-Translate), e a serve de um endpoint público gratuito. O PiliBabel já vem apontado para ela, então a tradução funciona no momento em que você instala o aplicativo — sem cadastro, sem chave, sem cobrança. Se você preferir usar o seu próprio modelo, o caminho da API própria continua lá, a um toque de distância.

> **Áudio no fone de ouvido que realmente fica em sincronia** — com fones Bluetooth ou com fio, o som não fica mais atrás da imagem. O aplicativo oficial acerta nisso; PiliNara e PiliPlus, não, como vêm de fábrica. O PiliBabel agora pede ao mpv o **AudioTrack** primeiro, que *mede* a latência da saída de áudio do mesmo jeito que o cliente oficial, em vez do **OpenSL ES**, que apenas a *estima*.

## Principais recursos

- **Áudio do fone em sincronia.** O player agora usa por padrão o backend **AudioTrack** do mpv (ordem `audiotrack,aaudio,opensles`) em vez do **OpenSL ES**. O AudioTrack informa uma latência de saída *medida* — ele lê a contagem de quadros reproduzidos e o timestamp de apresentação do dispositivo — que é exatamente como o aplicativo oficial da bilibili e o próprio `MediaSync` do Android mantêm imagem e som juntos. O OpenSL ES apenas a *estima*, então em fones Bluetooth o relógio do áudio derivava e a imagem era exibida adiantada. Em testes, o atraso praticamente desapareceu. Reordene quando quiser em Configurações → Vídeo → Dispositivo de saída de áudio.

- **Tradução por IA, em todos os lugares.** Abas de navegação, cards de vídeo, páginas de detalhe, comentários, dinâmicas e as telas Meu / Favoritos / Histórico / Mensagens / Busca — uma varredura global cobre **~1.650+ textos de interface**, além de conteúdo dinâmico (títulos, nomes de autores, contagens de ações).
- **Dois motores, um interruptor.** *Integrado* (padrão) usa o endpoint gratuito oficial **Index-Translate-35B-A3B** da bilibili — nada a configurar. *API própria* mantém o comportamento anterior: aponte-o para qualquer endpoint compatível com OpenAI `/chat/completions`, com a sua própria URL base / chave / modelo. O recurso de resumo de vídeo por IA e o de tradução por IA continuam com endpoints e configurações **completamente independentes**, ambos dentro de uma única página de **"Recursos de IA"**.
- **Uma só lista de idiomas para os dois motores.** A lista de idiomas de destino não é dividida por motor — a mesma lista é oferecida qualquer que seja o motor escolhido. Ela une os **151 idiomas** do modelo oficial da bilibili com **mais 6 que ele não cobre** — chinês tradicional, wu simplificado e tradicional, hokkien do continente e de Taiwan, e zhuang. Variantes regionais e de escrita são mantidas como **entradas separadas** em vez de fundidas — árabe marroquino / egípcio / najdi / levantino são cada um uma escolha própria, assim como sérvio, uzbeque e urdu cirílico versus latino.
- **Honestidade sobre a cobertura.** Os idiomas dentro do inventário oficial são cobertos pelo modelo da bilibili. Os poucos fora dele — chinês tradicional, wu simplificado e tradicional, hokkien do continente e de Taiwan e zhuang — continuam aparecendo na lista, marcados como tal, para que você saiba de imediato que um resultado melhor pode exigir o seu próprio modelo.
- **Traduz uma vez, e fica fixo.** Cada texto de origem é traduzido **exatamente uma vez**; o resultado é persistido localmente e **nunca é traduzido de novo** quando você reabre uma tela — o mesmo princípio do cliente oficial, para traduções estáveis e previsíveis.
- **Alternância por comentário entre Original ⇄ Tradução** (um pequeno ícone, não uma palavra em chinês). `@menções / [emoji] / #tópicos# / links` são preservados como tokens, e **comentários com hyperlinks ainda são traduzidos mantendo o link clicável**.
- **Tradução de danmaku (弹幕)** — uma alternância independente na fileira de controles do canto superior direito do player, **desligada por padrão** e protegida por uma confirmação cujo próprio texto é traduzido. Uma vez ativada, os danmaku à frente do ponto de reprodução são pré-traduzidos em **lotes de ~15 segundos** (pular para o meio é tratado corretamente, não a partir do início), então a tradução normalmente fica pronta na hora em que o comentário rola para a tela.
- **Interruptor do modo de raciocínio** (`enable_thinking`) para qualidade versus velocidade, além dos botões de **"testar tradução"** e **limpar cache** nas configurações.
- **Troca de idioma rápida**: requisições em lote com concorrência limitada sobre um cache persistente; trocar de idioma força a reconstrução da tela atual uma única vez, para você não ficar olhando para um texto não traduzido. Desligar a tradução por IA reverte toda a interface para o texto original e não emite requisição nenhuma.
- **Boas-vindas na primeira execução.** Na primeira vez que você abrir o aplicativo, um diálogo em inglês oferece ativar a tradução. Aceitar ativa a tradução, seleciona o modelo integrado, abre a página de configurações de IA e pergunta imediatamente qual idioma você quer — então um novo usuário vai da instalação ao aplicativo traduzido em dois toques.
- **Reprodução que funciona no mundo inteiro.** O PiliBabel seleciona o ponto de borda internacional (global **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`) que o `playurl` com roteamento geográfico da bilibili já oferece, em vez de prender você a um nó do continente (Aliyun/Shenzhen) — assim, usuários fora da China continental não travam mais ("o áudio continua tocando, o vídeo congela"). Você ainda pode fixar um CDN manualmente nas Configurações.
- **Uma página "Tema e cor", estilo Material You.** Claro / escuro / seguir o sistema são escolhidos entre **três cards de pré-visualização ao vivo** — cada um renderiza uma miniatura da interface real nas cores exatas que aquele modo aplicaria (o card "seguir o sistema" é dividido na diagonal, claro sobre escuro). Abaixo deles: **cor dinâmica** (extraída do papel de parede do sistema, onde o aparelho suporta), **escuro de alto contraste** (superfícies em preto absoluto, mais suave para os olhos à noite) e **player sempre escuro**. A metade de cores mantém a paleta completa do FlexScheme — **19 cores-base** mais um **"estilo de paleta"** separado que decide como cada cor de contêiner é derivada da cor-base, independentemente de qual cor-base você escolher.
- **A LXGW WenKai acompanha o aplicativo.** A fonte **LXGW WenKai (霞鹜文楷)** vem **embutida e definida como padrão** — uma fonte chinesa acolhedora e altamente legível, que você tem no momento em que instala, em vez de sair procurando uma num seletor. Ela se aplica a toda a interface *e* aos danmaku. Você ainda pode voltar à fonte do sistema, escolher qualquer fonte de sistema instalada ou importar a sua própria `.ttf` / `.otf` / `.ttc`; uma fonte que você tinha escolhido explicitamente antes é preservada na atualização. Peso e tamanho continuam ajustáveis como antes.

## Cache de áudio offline e download para pasta local (exclusivo do PiliBabel)

Duas capacidades que o PiliNara / PiliPlus upstream não têm — ambas voltadas para você realmente possuir a sua mídia offline.

### Cache de áudio (cache offline somente de áudio)

- **A faixa, não o vídeo.** Uma entrada *Cache de áudio* fica logo abaixo de *Cache de vídeo* no menu da página do vídeo, além de um botão dedicado de cache de áudio na barra superior da página de vídeo para ouvir.
- **Escolha o nível de qualidade.** Hi-Res sem perdas, Dolby Atmos, 192K, 132K ou 64K — a mesma lista predefinida que o seletor de qualidade de vídeo usa.
- **Contêiner original, sem transcodificação.** O arquivo é gravado exatamente como o CDN o entrega: `m4a`, `mp3`, `flac`, `wav`, `aac` ou `ogg`.
- **Módulo próprio.** A página de cache é dividida em *Vídeos em cache* / *Áudios em cache* e lembra em qual módulo você estava da última vez.
- Tocar em um item de áudio em cache abre o player de áudio imediatamente; itens são excluídos um a um ou em massa.

### Download para pasta local

- **Entrada de menu própria.** *Download para pasta local* é uma entrada separada no menu da página do vídeo, logo abaixo de *Cache de áudio* — fazer cache dentro do aplicativo e salvar em uma pasta são duas ações diferentes.
- **Baixar vídeo ou baixar áudio.** A entrada primeiro pergunta qual dos dois, depois pergunta o nível de qualidade (seletor de qualidade de vídeo / de áudio).
- **Sua pasta, suas regras.** Escolha qualquer pasta pelo gerenciador de arquivos do sistema (Configurações → *Download para pasta local*) e altere-a ou limpe-a quando quiser. Se você ainda não tiver escolhido nenhuma, o seletor de pasta abre na hora.
- **Arquivos reproduzíveis diretamente.** O vídeo é baixado como um único fluxo já muxado (`fnval=1`), então o que chega ao disco é um MP4 comum que você pode entregar a qualquer player — sem fluxos paralelos para costurar.
- **O áudio mantém o formato original** — sem transcodificação, exatamente como o cache dentro do aplicativo.
- Os arquivos recebem o nome do título do vídeo e nunca sobrescrevem um download existente.

## Os dois motores de tradução

| | Integrado (padrão) | API própria |
|---|---|---|
| Modelo | **Index-Translate-35B-A3B** da bilibili | qualquer coisa compatível com OpenAI |
| Endpoint | `index-translate.bilibili.com/v1` | a sua URL base |
| Chave de API | **não necessária** | a sua |
| Custo | gratuito | o que o seu provedor cobrar |
| Requisições | um texto por requisição | em lote (≤ 16 por requisição) |
| Idiomas extras | — | qualquer idioma que o seu modelo conheça |

**Por que uma requisição por texto no motor integrado.** O Index-Translate é um *especialista* em tradução, e a convenção de chamada que seus autores documentam é um modelo de item único ("traduza o texto a seguir para X, produza apenas a tradução"). Por isso o PiliBabel envia um texto por requisição nesse motor, em vez do prompt de lote com lista numerada/array JSON que ele usa nas configurações de API própria. O endpoint é gratuito, então não há nada a ganhar apostando em saídas em lote — é uma troca deliberada de algumas requisições a mais por bem menos formas de falhar.

**Atualizando do 0.3.x.** As suas configurações de API própria — URL base, chave e modelo — são **mantidas exatamente como você as configurou**. A seleção de motor simplesmente passa a padrão no modelo integrado, então na primeira execução após a atualização você estará no modelo gratuito da bilibili; abra *Configurações → IA → Recursos de IA → motor de tradução* e volte para *API própria* para retornar instantaneamente à sua configuração anterior.

## Como a tradução da interface por IA funciona (técnico)

O repositório **não tem camada de recursos de i18n / ARB** — os textos da interface são chinês fixado no código. Em vez de reescrever cada widget, o PiliBabel adiciona uma camada fina de tradução por cima:

1. **Um wrapper global de consulta.** `lib/services/ui_translate/` expõe um `uiTx(String src)` de nível superior. O texto de widget que antes era `Text('中文')` passa a ser `Text(uiTx('中文'))`. Um **codemod** roteirizado aplicou isso pelo projeto inteiro (`tool/ui_translate_*.py`) — cerca de **223 arquivos / ~1.650+ textos** — descartando automaticamente a palavra-chave `const` agora inválida onde fosse necessário (incluindo genéricos como `const X<T>(...)` e nomes pontilhados como `const Positioned.fill(...)`, e convertendo declarações de lista/mapa `static const` em `static final`).
2. **Um núcleo `GetxService`** (`ui_translate_service.dart`):
   - um cache persistente **origem → tradução** (sobre GetStorage), de modo que cada texto é traduzido uma vez e reutilizado para sempre;
   - `tx()` lê primeiro um `RxInt revision` e então decide: se desativado → devolve o original; se o destino for **chinês simplificado (`zh-CN`)**, devolve o original sem requisição à API (o conteúdo de origem da bilibili é esmagadoramente chinês simplificado). Qualquer outro destino — incluindo chinês tradicional, cantonês, wu/xangainês e hokkien/min nan — passa pelo motor configurado; só pertencer à família chinesa não pula a tradução. Em seguida, serve do cache ou **enfileira**;
   - os textos enfileirados são descarregados por um **pool de workers** com **aplicação incremental por bloco** (cada bloco retornado incrementa `revision`, então o texto atualiza progressivamente), e os resultados são **persistidos** (com limitação de frequência). O tamanho do lote e a concorrência seguem o motor: **1 por requisição** no modelo integrado, **≤ 16 com ≤ 10 em voo** na sua API própria.
3. **Resolução do motor.** `TranslateProvider` (`builtin` / `custom`) decide qual URL, chave e modelo o transporte usa; fora isso, os dois motores compartilham um único caminho de código e uma única lista de idiomas, então trocar de motor é uma única configuração e nunca um conjunto de recursos diferente.
4. **O transporte** reutiliza o mesmo canal de **streaming** já verificado do resumo de vídeo por IA — `AiChatService.streamChat` → `{base}/chat/completions` com `stream: true` (compatível com gateways que só suportam streaming) — estendido para que a tradução possa usar `apiUrl` / `apiKey` / `model` **próprios** e uma flag `enable_thinking`. A mudança é **retrocompatível**, então o resumo de vídeo continua funcionando sem alterações.
5. **Frases interpoladas** usam `uiTxP(template, args)`: uma frase inteira com marcadores `{0}`/`{1}` é traduzida como uma chave estável (o prompt pede ao modelo que mantenha os marcadores) e, então, os valores são substituídos de volta — assim, textos no estilo `"共 {0} 条"` são traduzidos sem mutilar as partes dinâmicas.
6. **Tabela de idiomas** (`app_language.dart`): cada `AppLanguage` carrega um autônimo de exibição, um texto de prompt `toModel` que codifica convenções de escrita/região e uma flag indicando se o inventário oficial da bilibili o cobre. As regras de escrita (simplificado versus tradicional, e as instruções de consistência de dialeto) chegam ao modelo apenas pelo prompt, e uma passada de normalização determinística no cliente corrige depois os glifos desviantes.
7. **Comentários** passam por `uiTxComment(text, id)`, mantendo `@ / [emoji] / #tópico# / link` como tokens intactos; spans de rich text que carregam links são traduzidos com o reconhecedor de links preservado, e um conjunto de ids por comentário comanda a alternância Original ⇄ Tradução.
8. **Danmaku** (`danmaku/view.dart`): quando a alternância está ligada, um listener de posição percorre `[playhead, playhead + 15s]` um segundo por vez e aquece o `uiTx()` no conteúdo de cada danmaku, de modo que os itens sejam pré-traduzidos antes de chegar à tela; ativá-la limpa e repinta o canvas.
9. **Chaves de armazenamento**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **Interface de configurações**: uma única página de primeiro nível de "Recursos de IA" (`lib/pages/setting/ui_translate/`) com blocos independentes para o resumo de vídeo por IA e a tradução por IA.

**CDN mundial (`VideoUtils.getCdnUrl`).** As URLs de stream são assinadas, e reescrever o host de uma URL faz com que ela seja rejeitada com 403 — portanto a reprodução nunca reescreve hosts. O PiliBabel devolve a URL com roteamento geográfico que a bilibili entrega ao IP do cliente e, quando a lista de candidatas já contém uma borda internacional (`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`), essa é a preferida. Os downloads, nos quais a troca de host é segura, preferem adicionalmente a borda global da Akamai e rotacionam para a próxima candidata assinada quando uma linha trava ou rejeita um resume. Links P2P `/v/resource` brutos ainda caem no relay existente para evitar 404s.

**Compromissos de design / limitações conhecidas.** Como os textos são envolvidos no próprio lugar em vez de extraídos para recursos, alguns parâmetros de texto fora de `Text` e alguns spans de rich text ainda estão sendo preenchidos incrementalmente. Textos que também servem de **chaves de lógica** (comparados com `==`, usados como nomes de abas como `简介`, ou rótulos de enum usados em switches) deliberadamente **não** são envolvidos indiscriminadamente, para não quebrar o comportamento. A tradução de danmaku é best-effort em um canvas de rolagem — sob danmaku extremamente densos você pode ver brevemente o original antes de a tradução chegar. A tradução precisa de rede; sem ela, destinos não chineses simplesmente não surtem efeito. O endpoint integrado é um serviço público gratuito mantido pela bilibili — se algum dia for limitado ou ficar indisponível, o aplicativo avisa e você pode trocar para a sua própria API.

## Compilação e verificação

O aplicativo é construído com um SDK do Flutter corrigido por patch, além dos pacotes `material_ui` / `cupertino_ui` também corrigidos, via `lib/scripts/patch.ps1` e `lib/scripts/build.ps1` (exatamente como o PiliNara / PiliPlus). O GitHub Actions produz um **APK de debug** a cada push (`.github/workflows/ui-translate-debug.yml`), e **publicar uma tag `v*` compila e publica automaticamente artefatos Android, Windows e Linux** (`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## Plataformas
- [x] Android
- [ ] iOS
- [ ] Pad
- [x] Windows
- [x] Linux

O PiliBabel distribui compilações **Android (APK), Windows e Linux** pelos Releases; iOS/Pad ainda não são empacotados neste fork.

<br/>

## Download

Baixe uma compilação em **Releases**, ou clone o repositório e compile localmente.

### Arch Linux

Agradecimentos a [@nlsdt](https://github.com/nlsdt) pelo empacotamento (a receita do PiliNara vale para o PiliBabel).

```bash
sudo pacman -S pilinara      # via o repositório Arch Linux CN
paru -S pilinara-bin         # ou via AUR: pilinara-bin (pré-compilado) / pilinara (código-fonte)
```

<br/>

## Registro de recursos herdados (do PiliNara / PiliPlus)

Tudo abaixo é herdado do PiliNara (e, por transitividade, do PiliPlus); o PiliBabel adiciona a camada de tradução por IA por cima.

**Adaptação de interface e plataforma**
- [x] Aplicativo renomeado por plataforma para que vários clientes possam coexistir (o PiliBabel instala ao lado do PiliNara)
- [x] Corrigida a renderização do Flutter na mini-janela do Xiaomi HyperOS ([#161086](https://github.com/flutter/flutter/issues/161086), via [venera#467](https://github.com/venera-app/venera/pull/467)); animação de back preditivo no Android
- [x] Ordem/contagem de cards de "Meu" personalizáveis; pré-visualização nos cards de histórico e seções de "assistir depois"
- [x] Alternância automática de barra lateral com largura de disparo configurável; copiar imagem por toque longo / clique com o botão direito; grande atualização de estilo MD3E

**Sistema de fontes** — um pool de importação unificado com deduplicação por hash de conteúdo, fontes de danmaku fundidas no mesmo pool, `loadFontFromList` com suporte a ttc e nomes de família em hash de ASCII puro.

**Reprodução, mini-janela e qualidade** — mini-janela dentro do aplicativo (arrastar, redimensionar, saltos do SponsorBlock, PIP de sistema automático, barra de auto-resgate em lives), reprodução de áudio simultânea, volume no aplicativo de até 200%, domínio de CDN de vídeo personalizado e seleção de nó regional com teste de latência, qualidade padrão separada para meia tela/tela cheia, bloqueio de velocidade ao deslizar para cima, controle por teclado no tablet, timestamps de SuperChat ao vivo, heartbeat de live para intimidade com fãs.

**Legendas, IA e offline** — legendas bilíngues com estilo independente da legenda secundária, análise de legendas por IA (endpoint personalizado compatível com OpenAI, salto por timestamp, modelos, conversas persistidas, fallback suave quando não há legenda), exportação WEBVTT/SRT, visão dupla do cache offline com gerenciamento de pastas e persistência de metadados, exportação de downloads para a pasta pública Download (Android).

**Danmaku e bloqueio** — dimensionamento aprimorado de danmaku mesclados (ao estilo [Pakku.js](https://github.com/xmcp/pakku.js)), bloqueio visual por regex baseado em listas com importação/exportação, skip do SponsorBlock ao buscar dentro do segmento, barra de progresso de alta energia com kernel gaussiano.

**Filtragem de recomendações / dinâmicas / comentários** — palavras-chave de título/UP/canal, duração, contagem de reproduções, taxa de curtidas, isenção para UPs seguidos, filtragem de não autorizados/somente pagos, lista branca compartilhada, dinâmicas comerciais/não autorizadas, isenções para comentário do próprio UP e comentário fixado, modo de feed mesclado App+Web.

**Dinâmicas, busca e informações do usuário** — notas personalizadas para UPs, nota substituindo apelido em 13 slots de nome, ordenação independente de comentários aninhados, filtro local de busca por palavra-chave, salto por link curto b23.tv, selo de conteúdo somente pago, alternância para ocultar o motivo da recomendação, exibição de XP de moedas.

**Melhorias de live** — painel para vestir medalhas de fã, transmissão DLNA preferindo HLS, exibição de horário do SuperChat, barra de controle na parte inferior da mini-janela para auto-resgate.

**Integração com o sistema e desktop** — SMTC no Windows, MPRIS no Linux (`audio_service_mpris`), tratamento de audio-focus reconstruído.

<details>
<summary>Lista completa original de recursos/checklist (literal, do PiliNara — clique para expandir)</summary>

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

O PiliBabel é um projeto pessoal, movido por interesse, fornecido **apenas para aprendizado e testes**; por favor, exclua-o dentro de **24 horas** após o download.

- O PiliBabel é um cliente **de terceiros e não oficial** e **não é afiliado, endossado ou patrocinado pela bilibili**.
- Todas as APIs são coletadas de endpoints públicos oficiais; **nenhum conteúdo crackeado, com privilégios excessivos ou que contorne paywalls** é fornecido.
- **A tradução por IA roda em um endpoint de modelo de terceiros.** Por padrão, esse é o próprio serviço público gratuito Index-Translate da bilibili; se você mudar para a sua própria API, é o endpoint que você configurou. A qualidade e a conformidade da tradução são responsabilidade do usuário e do provedor de modelo escolhido; este projeto hospeda **nenhum modelo e nenhuma chave de API**.
- Respeite os direitos autorais e os Termos de Serviço da bilibili. Use com responsabilidade.

Com respeito aos autores originais e upstream pela dedicação ao código aberto:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — o projeto pai direto do PiliBabel
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — a família de modelos de tradução de código aberto que o motor integrado chama

Se qualquer conteúdo infringir os seus direitos, entre em contato para remoção.

<br/>

## Licença

O PiliBabel é licenciado sob a **GNU General Public License v3.0 (GPL-3.0)** — a mesma licença do PiliNara, PiliPlus e PiliPala. Por ser um trabalho derivado, **o PiliBabel também deve ser distribuído sob a GPL-3.0**: você é livre para usá-lo, estudá-lo, compartilhá-lo e modificá-lo, desde que mantenha a mesma licença, os avisos de direitos autorais e este texto de licença. Veja [`LICENSE`](./LICENSE).

Componentes de terceiros (pacotes do Flutter, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio), etc.) permanecem sob as suas próprias licenças.

A fonte **LXGW WenKai** embutida é licenciada separadamente sob a **SIL Open Font License 1.1**; o texto da licença acompanha o aplicativo como `assets/fonts/LXGWWenKai-OFL.txt`.

<br/>

## Agradecimentos

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — a família de modelos de tradução de código aberto da bilibili e o endpoint público gratuito por trás do motor integrado
- [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) (霞鹜文楷) — a fonte chinesa de código aberto embutida no aplicativo, sob a SIL Open Font License 1.1
- e mais
- Inspirado pela "tradução de interface por IA" oficial da bilibili.
