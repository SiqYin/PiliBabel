<div align="center">
    <img width="200" height="200" src="assets/images/logo/logo.png">
    <h1>PiliBabel</h1>
    <p><b>AI 번역을 갖춘 서드파티 Bilibili 클라이언트.</b></p>
    <p>Babel — 언어의 벽을 허물어, 누구나 자기 언어로 bilibili를 즐길 수 있도록.</p>
    <p>중국의 소수민족 언어 4종과 중국어 방언 3종의 번역을 포함합니다.</p>
    <p>bilibili 공식 무료 모델을 내장해 설치하자마자 번역되며, API 키가 필요 없습니다.</p>
</div>
<!-- lang-switch:start -->
<div align="center">
    <p><a href="README.md">English</a> · <a href="README.zh.md">中文</a> · <a href="README.yue.md">粵語</a> · <a href="README.ja.md">日本語</a> · <a href="README.fr.md">Français</a> · <a href="README.de.md">Deutsch</a> · <a href="README.es.md">Español</a> · <b>한국어</b> · <a href="README.ar.md">العربية</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.ms.md">Bahasa Melayu</a> · <a href="README.id.md">Bahasa Indonesia</a></p>
</div>
<!-- lang-switch:end -->

<div align="center">
    <img src="assets/screenshots/readme_en_home.jpg" width="32%" alt="홈" />
    <img src="assets/screenshots/readme_en_dynamics.jpg" width="32%" alt="동적" />
    <img src="assets/screenshots/readme_en_mine.jpg" width="32%" alt="내 정보" />
</div>

<br/>

> **면책 조항.** PiliBabel은 **비공식 오픈소스 서드파티** 클라이언트이며, **bilibili / bilibili Inc.와 제휴·보증·후원 관계가 전혀 없습니다**. 모든 API는 공식 공개 엔드포인트에서 가져왔고, **유료 콘텐츠를 해제하거나 크랙하지 않습니다**. [면책 조항](#면책-조항)과 [라이선스](#라이선스) 두 절을 끝까지 읽어 주세요.

## PiliBabel이란?

PiliBabel은 **[PiliNara](https://github.com/Starfallan/PiliNara)를 기반으로 만들어진 독립적인 서드파티 포크**이며, PiliNara가 물려받은 모든 것을 그대로 물려받았습니다:

```
bilibili (공식 공개 API)
        ▲
   PiliPala / PiliPalaX        — 최초 프로젝트
        ▲
   PiliPlus                    — 활발한 포크
        ▲
   PiliNara                    — PiliPlus의 포크 (개인 조정)
        ▲
   PiliBabel  ← 여기          — PiliNara의 포크
```

PiliBabel은 **PiliNara / PiliPlus의 모든 기능을 그대로 유지**하고(아래 [상속된 기능 목록](#상속된-기능-목록-pilinara--piliplus-출처) 참고), 원본 클라이언트에는 없는 **핵심 기능 하나**를 더했습니다:

> **AI 인터페이스·콘텐츠 번역** — 앱 전체(인터페이스 문구, 영상 제목, UP 이름, 댓글, 동적, 피드, 나아가 라이브 탄막까지)가 **당신이** 고른 언어로 표시됩니다.

그리고 1.0부터는 이 기능이 **설치하자마자 바로 동작합니다**. 번역 모델이 **내장**되어 있기 때문입니다. bilibili는 자사의 번역 모델 [Index-Translate](https://github.com/bilibili/Index-Translate)를 오픈소스로 공개하고 무료 공개 엔드포인트로 제공합니다. PiliBabel은 기본적으로 그곳을 가리키므로 **앱을 설치하면 바로 번역이 됩니다** — 가입도, 키도, 요금도 필요 없습니다. 직접 만든 모델을 쓰고 싶다면 자체 API 경로가 그대로 남아 있고, 한 번의 터치로 전환할 수 있습니다.

## 주요 기능

- **앱 전체를 번역합니다.** 내비게이션 바, 영상 카드, 상세 페이지, 댓글, 동적, 그리고 내 정보 / 즐겨찾기 / 기록 / 메시지 / 검색 화면까지 — 전역 치환이 **약 1,650개 이상의 인터페이스 문구**를 덮고, 여기에 제목·작성자 이름·재생 수 같은 동적 콘텐츠가 더해집니다.
- **엔진 두 개, 스위치 하나.** *내장*(기본값)은 bilibili 공식 **Index-Translate-35B-A3B** 무료 엔드포인트를 사용하므로 설정할 것이 없습니다. *자체 API*는 기존 동작을 유지합니다. OpenAI 호환 `/chat/completions` 엔드포인트에 자신의 베이스 URL / 키 / 모델을 지정하면 됩니다. AI 영상 요약과 AI 번역은 여전히 **완전히 독립된** 엔드포인트와 설정을 가지며, 하나의 **"AI 기능"** 페이지에 함께 있습니다.
- **언어 목록 하나를 두 엔진이 공유합니다.** 번역 대상 언어 목록은 엔진별로 나뉘지 않습니다. 어느 엔진을 고르든 같은 목록을 씁니다. bilibili 공식 모델의 **150개 언어**와 PiliBabel이 추가로 넣은 **중국의 소수민족 언어 4종과 중국어 방언 3종**을 하나로 합친 것입니다 — 소수민족 언어는 티베트어·위구르어·좡어·먀오어, 중국어 방언은 광둥어·우어(상하이어)·민난어 — 여기에 번체 중국어가 더해집니다. 지역·문자 변종은 **합치지 않고 각각 별도 항목**으로 둡니다. 모로코 / 이집트 / 나지드 / 레반트 아랍어가 각각 독립된 선택지이고, 세르비아어·우즈베크어·우르두어의 키릴 / 라틴 표기도 마찬가지입니다.
- **지원 범위를 솔직하게 표시합니다.** 공식 목록 안의 언어는 bilibili 모델이 담당합니다. 목록 밖의 몇몇 — 번체 중국어, 그리고 bilibili가 수록하지 않은 위의 중국어 방언과 소수민족 언어 — 도 목록에 그대로 나오지만 그렇게 표시되므로, 더 나은 결과가 필요하면 자체 모델이 필요할 수 있음을 한눈에 알 수 있습니다.
- **한 번 번역하면 고정됩니다.** 각 원문은 **정확히 한 번** 번역되고, 결과는 로컬에 저장되어 화면을 다시 열어도 **다시 번역되지 않습니다** — 공식 클라이언트와 같은 원칙으로, 번역이 안정적이고 예측 가능합니다.
- **댓글별 원문 ⇄ 번역 전환**(중국어 단어가 아닌 작은 아이콘). `@멘션 / [이모지] / #토픽# / 링크`는 토큰으로 보존되며, **하이퍼링크가 있는 댓글도 번역되면서 링크는 계속 눌립니다**.
- **탄막 번역** — 플레이어 오른쪽 위 컨트롤 줄에 있는 독립 스위치로, **기본값은 꺼짐**이며 확인 문구 자체도 번역되는 확인 절차를 거칩니다. 켜면 재생 위치보다 앞선 탄막을 **약 15초 단위 묶음**으로 미리 번역합니다(중간으로 건너뛰어도 처음이 아니라 그 지점부터 처리합니다). 그래서 탄막이 화면을 지날 때쯤이면 번역이 준비되어 있습니다.
- **사고 모드 스위치**(`enable_thinking`)로 품질과 속도를 선택할 수 있고, 설정에 **"번역 테스트"**와 **캐시 비우기** 버튼도 있습니다.
- **빠른 언어 전환**: 지속 캐시 위에서 동시 실행 수를 제한한 묶음 요청을 사용하고, 언어를 바꾸면 현재 화면을 한 번 강제로 다시 그려서 번역되지 않은 텍스트를 멍하니 보게 되는 일이 없습니다. AI 번역을 끄면 인터페이스 전체가 원문으로 돌아가고 **요청을 전혀 보내지 않습니다**.
- **첫 실행 안내.** 앱을 처음 열면 영어 대화상자가 번역을 켤지 물어봅니다. 동의하면 번역을 켜고, 내장 모델을 선택하고, AI 설정 페이지를 연 뒤 곧바로 어떤 언어를 쓸지 묻습니다 — 새 사용자는 두 번의 터치로 "방금 설치"에서 "이미 번역됨"까지 갑니다.
- **전 세계에서 재생됩니다.** PiliBabel은 당신을 중국 본토(알리바바 클라우드 / 선전) 노드에 고정하는 대신, bilibili가 IP에 따라 내려주는 해외 엣지(글로벌 **Akamai**, `mirror*ov`, `cn-hk-eq-bcache`)를 우선 선택합니다. 그래서 중국 본토 밖 사용자에게 나타나던 "소리는 나오는데 화면이 멈추는" 현상이 사라집니다. 물론 설정에서 CDN을 직접 지정할 수도 있습니다.

## 두 가지 번역 엔진

| | 내장(기본값) | 자체 API |
|---|---|---|
| 모델 | bilibili **Index-Translate-35B-A3B** | OpenAI 호환이면 무엇이든 |
| 엔드포인트 | `index-translate.bilibili.com/v1` | 당신의 베이스 URL |
| API 키 | **불필요** | 당신의 것 |
| 비용 | 무료 | 사용하는 제공자에 따름 |
| 요청 방식 | 요청당 한 건 | 묶음(요청당 ≤ 16건) |
| 추가 언어 | — | 당신의 모델이 아는 모든 언어 |

**내장 엔진이 왜 한 건씩 보내는가.** Index-Translate는 번역 **전문** 모델이고, 제작자가 문서화한 호출 방식은 단일 항목 템플릿("다음 텍스트를 X로 번역하고 번역문만 출력하세요")입니다. 그래서 이 엔진에서는 자체 API에 쓰는 "번호 목록 + JSON 배열 반환" 묶음 프롬프트 대신 요청당 한 건을 보냅니다. 엔드포인트가 무료이므로 요청 수를 아끼려고 묶음 출력에 걸 위험을 질 이유가 없습니다 — **요청을 조금 더 쓰고 실패할 여지를 크게 줄이는** 의도적인 맞바꿈입니다.

**0.3.x에서 업그레이드하는 경우.** 직접 설정한 API(베이스 URL, 키, 모델)는 **그대로 보존되며 덮어쓰지 않습니다**. 엔진 선택만 기본적으로 내장 모델로 바뀌므로, 업그레이드 후 처음 실행하면 bilibili의 무료 모델을 쓰게 됩니다. *설정 → AI → AI 기능 → 번역 엔진*에서 '자체 API'로 되돌리면 즉시 원래 설정으로 복귀합니다.

## AI 인터페이스 번역은 어떻게 동작하는가 (기술)

이 저장소에는 **i18n / ARB 리소스 계층이 전혀 없습니다** — 인터페이스 문구가 모두 중국어로 하드코딩되어 있습니다. PiliBabel은 모든 위젯을 다시 쓰는 대신 그 위에 얇은 번역 계층을 얹었습니다:

1. **전역 조회 래퍼.** `lib/services/ui_translate/`가 최상위 함수 `uiTx(String src)`를 제공합니다. `Text('中文')`이던 곳이 `Text(uiTx('中文'))`이 됩니다. **스크립트화된 codemod**가 프로젝트 전체에 적용했습니다(`tool/ui_translate_*.py`) — 약 **223개 파일 / 1,650개 문구** — 이 과정에서 무효가 된 `const` 키워드를 필요한 곳에서 자동으로 제거하고(제네릭 `const X<T>(...)`나 점 표기 `const Positioned.fill(...)` 포함), `static const` 목록 / 맵 선언을 `static final`로 바꿨습니다.
2. **`GetxService` 코어** (`ui_translate_service.dart`):
   - 영속적인 **원문 → 번역** 캐시(GetStorage 기반)로, 각 문구는 한 번만 번역되고 이후 영구히 재사용됩니다;
   - `tx()`는 먼저 `RxInt revision`을 읽고 판단합니다: 꺼져 있으면 → 원문 반환; 대상이 **중국어 간체(`zh-CN`)**면 → API 요청 없이 원문 반환(bilibili 콘텐츠는 압도적으로 간체입니다). 그 밖의 모든 대상 — 번체 중국어, 광둥어, 우어, 민난어 포함 — 은 설정된 엔진을 거칩니다. **중국어 계열이라는 사실만으로는 번역을 건너뛰지 않습니다.** 그다음 캐시를 확인하고, 없으면 **대기열에 넣습니다**;
   - 대기열에 들어간 문구는 **worker 풀**이 처리하며 **블록 단위로 점진 반영**합니다(블록이 돌아올 때마다 `revision`을 올려 텍스트가 차례로 갱신됩니다). 결과는 **스로틀링하여 영속화**합니다. 묶음 크기와 동시 실행 수는 엔진을 따릅니다: 내장 모델은 **요청당 1건**, 자체 API는 **요청당 ≤ 16건, 동시 ≤ 10**.
3. **엔진 결정.** `TranslateProvider`(`builtin` / `custom`)가 전송 계층이 쓸 URL·키·모델을 정합니다. 그 외에는 두 엔진이 같은 코드 경로와 같은 언어 목록을 공유하므로, 엔진 전환은 설정 하나일 뿐 **기능 집합이 달라지는 일은 없습니다**.
4. **전송 계층**은 AI 영상 요약과 동일한, 이미 검증된 **스트리밍** 경로를 재사용합니다 — `AiChatService.streamChat` → `{base}/chat/completions`에 `stream: true`(스트리밍만 지원하는 게이트웨이와도 호환) — 그리고 번역 **전용** `apiUrl` / `apiKey` / `model`과 `enable_thinking` 플래그를 쓸 수 있게 확장했습니다. 이 변경은 **하위 호환**이라 영상 요약은 그대로 동작합니다.
5. **자리표시자가 있는 문장**은 `uiTxP(template, args)`를 씁니다. `{0}`/`{1}`가 들어간 문장을 하나의 안정된 키로 번역하고(프롬프트에서 자리표시자를 보존하도록 요청), 이후 값을 되돌려 채웁니다 — `"共 {0} 条"` 같은 문구도 동적 부분을 망가뜨리지 않습니다.
6. **언어 표** (`app_language.dart`): 각 `AppLanguage`는 표시용 자기 이름, 문자·지역 규범을 담은 `toModel` 프롬프트 문자열, 그리고 bilibili 공식 목록이 이를 포함하는지 나타내는 표시를 가집니다. 문자 규칙(간체 / 번체)과 방언 일관성 지침은 **오직 프롬프트를 통해서만** 모델에 전달되고, 이후 클라이언트 측에서 결정론적 문자 정규화를 한 번 돌려 어긋난 글자를 바로잡습니다.
7. **댓글**은 `uiTxComment(text, id)`를 거치며 `@ / [이모지] / #토픽# / 링크`를 온전한 토큰으로 유지합니다. 링크가 있는 리치 텍스트 구간도 번역하면서 링크 인식을 보존하고, 댓글별 id 집합이 원문 ⇄ 번역 전환을 구동합니다.
8. **탄막** (`danmaku/view.dart`): 스위치가 켜져 있으면 위치 리스너가 `[재생 위치, 재생 위치 + 15초]`를 1초 단위로 훑으며 각 탄막 내용에 `uiTx()`를 미리 데웁니다. 그래서 화면에 올라오기 전에 번역이 끝나 있습니다. 켤 때는 캔버스를 비우고 다시 그립니다.
9. **저장 키**: `uiTranslate{Enabled,Provider,Lang,Model,ApiUrl,ApiKey,Thinking,Cache,Onboarded}`. **설정 UI**: 하나의 1차 페이지 "AI 기능"(`lib/pages/setting/ui_translate/`)에 AI 영상 요약과 인터페이스 번역 블록이 독립적으로 놓입니다.

**전 세계 CDN (`VideoUtils.getCdnUrl`).** 스트림 URL은 서명되어 있고 호스트를 바꾸면 403으로 거부되므로, **재생 측은 절대 호스트를 바꾸지 않습니다**. PiliBabel은 bilibili가 클라이언트 IP에 따라 내려주는 지리 라우팅 URL을 그대로 쓰고, 후보 목록에 이미 해외 엣지(`*.akamaized.net`, `mirror(cos|ali|hw)ov`, `cn-hk-eq-bcache`)가 있으면 그것을 우선합니다. 호스트 교체가 안전한 다운로드에서는 추가로 전역 Akamai 엣지를 우선하고, 회선이 멈추거나 이어받기를 거부하면 다음 서명된 후보로 넘어갑니다. 원시 `/v/resource`(P2P) 링크는 404를 피하기 위해 기존 중계로 폴백합니다.

**설계상의 맞바꿈 / 알려진 한계.** 문구를 리소스로 추출하지 않고 제자리에서 감싸기 때문에, `Text`가 아닌 일부 문자열 매개변수와 일부 리치 텍스트 구간은 아직 순차적으로 채워지고 있습니다. **논리 키를 겸하는** 문자열(`==`로 비교되거나 `简介` 같은 탭 이름, 스위치의 열거 라벨로 쓰이는 것)은 동작을 깨지 않기 위해 **의도적으로** 일괄 래핑하지 않았습니다. 탄막 번역은 움직이는 캔버스 위에서의 최선 노력 방식이라, 탄막이 극도로 빽빽하면 번역이 도착하기 전에 원문이 잠깐 보일 수 있습니다. 번역에는 네트워크가 필요하며, 없으면 중국어 이외 대상은 반영되지 않습니다. 내장 엔드포인트는 bilibili가 운영하는 무료 공개 서비스로, 만약 속도 제한이나 중단이 있으면 앱이 명확히 알려주고 자체 API로 전환할 수 있습니다.

## 빌드와 검증

빌드 방식은 PiliNara / PiliPlus와 완전히 같습니다. 패치된 Flutter SDK와 패치된 `material_ui` / `cupertino_ui` 패키지를 `lib/scripts/patch.ps1`과 `lib/scripts/build.ps1`로 처리합니다. GitHub Actions는 푸시마다 **디버그 APK**를 만들고(`.github/workflows/ui-translate-debug.yml`), **`v*` 태그를 푸시하면 Android / Windows / Linux 산출물을 자동으로 빌드·배포**합니다(`.github/workflows/release.yml`, `win_x64.yml`, `linux_x64.yml`).

<br/>

## 플랫폼
- [x] Android
- [ ] iOS
- [ ] 태블릿
- [x] Windows
- [x] Linux

PiliBabel은 Releases에서 **Android(APK), Windows, Linux** 빌드를 제공합니다. 이 포크에서는 iOS와 태블릿은 아직 패키징하지 않습니다.

<br/>

## 다운로드

**Releases**에서 빌드를 받거나, 저장소를 복제해 직접 빌드하세요.

### Arch Linux

패키징해 주신 [@nlsdt](https://github.com/nlsdt)께 감사드립니다(PiliNara 레시피가 PiliBabel에도 그대로 적용됩니다).

```bash
sudo pacman -S pilinara      # Arch Linux CN 저장소에서
paru -S pilinara-bin         # 또는 AUR: pilinara-bin(미리 빌드됨) / pilinara(소스)
```

<br/>

## 상속된 기능 목록 (PiliNara / PiliPlus 출처)

아래는 모두 PiliNara(그리고 거슬러 올라가 PiliPlus)에서 물려받은 것입니다. PiliBabel은 그 위에 AI 번역 계층을 더했습니다.

**인터페이스와 플랫폼 적응**
- [x] 플랫폼별로 앱 이름을 바꿔 여러 클라이언트 공존 가능(PiliBabel은 PiliNara와 나란히 설치됩니다)
- [x] Xiaomi HyperOS 미니 창에서의 Flutter 렌더링 문제 수정([#161086](https://github.com/flutter/flutter/issues/161086), [venera#467](https://github.com/venera-app/venera/pull/467) 경유); Android 예측형 뒤로 가기 애니메이션
- [x] "내 정보" 카드 순서·개수 사용자 지정; 기록 카드 미리보기와 "나중에 볼" 섹션
- [x] 사이드바 자동 전환과 트리거 너비 조정; 길게 누르기 / 오른쪽 클릭으로 이미지 복사; MD3E 스타일 대규모 개편

**글꼴 시스템** — 콘텐츠 해시로 중복을 제거하는 통합 가져오기 풀, 탄막 글꼴도 같은 풀에 통합, ttc를 지원하는 `loadFontFromList`, 순수 ASCII 해시 글꼴 패밀리 이름.

**재생·미니 창·화질** — 앱 내 미니 창(드래그, 크기 조절, SponsorBlock 건너뛰기, 시스템 PIP 자동 전환, 라이브 자구제 바), 동시 오디오 재생, 앱 내 볼륨 최대 200%, 사용자 지정 영상 CDN 도메인과 지역 노드 선택(지연 측정 포함), 반화면 / 전체 화면 별도 기본 화질, 위로 밀어 속도 잠금, 태블릿 키보드 제어, 라이브 SuperChat 시각 표시, 라이브 팬 친밀도 하트비트.

**자막·AI·오프라인** — 이중 언어 자막(보조 자막 스타일 독립), AI 자막 분석(사용자 지정 OpenAI 호환 엔드포인트, 타임스탬프 이동, 템플릿, 대화 영속화, 자막 없음 소프트 폴백), WEBVTT/SRT 내보내기, 오프라인 캐시 이중 보기(폴더 관리와 메타데이터 영속화), 다운로드를 공용 Download 폴더로 내보내기(Android).

**탄막과 차단** — 병합 탄막 확대 개선([Pakku.js](https://github.com/xmcp/pakku.js) 스타일), 목록형 시각적 정규식 차단(가져오기 / 내보내기 지원), SponsorBlock 구간 내부 건너뛰기, 가우시안 커널 고에너지 진행 바.

**추천 / 동적 / 댓글 필터링** — 제목 / UP / 채널 키워드, 길이, 재생 수, 좋아요 비율, 팔로우한 UP 예외, 미인증 / 유료 전용 필터, 공유 화이트리스트, 상업 / 미인증 동적, UP 본인 댓글과 고정 댓글 예외, App + Web 통합 피드 모드.

**동적·검색·사용자 정보** — UP 메모, 메모로 닉네임 대체(13개 이름 슬롯), 중첩 답글 독립 정렬, 로컬 키워드 검색 필터, b23.tv 단축 링크 이동, 유료 전용 배지, 추천 이유 숨기기 스위치, 코인 경험치 표시.

**라이브 개선** — 팬 메달 착용 패널, DLNA 캐스팅의 HLS 우선, SuperChat 시각 표시, 미니 창 하단 자구제 컨트롤 바.

**시스템 통합·데스크톱** — Windows SMTC, Linux MPRIS(`audio_service_mpris`), 오디오 포커스 처리 재작성.

<details>
<summary>원래 기능 체크리스트 전문(PiliNara에서 그대로, 눌러서 펼치기)</summary>

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

## 면책 조항

PiliBabel은 개인적 흥미로 만든 프로젝트이며 **학습과 테스트 용도로만** 제공됩니다. 다운로드 후 **24시간 이내**에 삭제해 주세요.

- PiliBabel은 **비공식 서드파티** 클라이언트이며 **bilibili와 제휴·보증·후원 관계가 없습니다**.
- 모든 API는 공식 공개 엔드포인트에서 가져왔고, **크랙·과도한 권한·유료 장벽 우회 콘텐츠는 제공하지 않습니다**.
- **AI 번역은 서드파티 모델 엔드포인트에서 실행됩니다.** 기본값은 bilibili 자체의 무료 공개 Index-Translate 서비스이고, 자체 API로 바꾸면 당신이 설정한 엔드포인트입니다. 번역 품질과 규정 준수는 사용자와 선택한 모델 제공자의 책임입니다. 이 프로젝트는 **어떤 모델도 호스팅하지 않으며 API 키도 제공하지 않습니다**.
- 저작권과 bilibili 이용약관을 존중하고 책임 있게 사용해 주세요.

오픈소스에 헌신한 원작자와 상위 프로젝트 저자들에게 존경을 표합니다:
- [guozhigq/pilipala](https://github.com/guozhigq/pilipala)
- [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX)
- [bggRGjQaUbCoE/PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus)
- [Starfallan/PiliNara](https://github.com/Starfallan/PiliNara) — PiliBabel의 직계 상위 프로젝트
- [bilibili/Index-Translate](https://github.com/bilibili/Index-Translate) — 내장 엔진이 호출하는 오픈소스 번역 모델 패밀리

권리를 침해하는 내용이 있다면 알려 주시면 삭제하겠습니다.

<br/>

## 라이선스

PiliBabel은 **GNU General Public License v3.0(GPL-3.0)** 으로 배포됩니다 — PiliNara, PiliPlus, PiliPala와 같은 라이선스입니다. 파생 저작물이므로 **PiliBabel 역시 GPL-3.0으로 배포되어야 합니다**. 동일한 라이선스, 저작권 고지, 그리고 이 라이선스 전문을 유지하는 한 자유롭게 사용·연구·공유·수정할 수 있습니다. [`LICENSE`](./LICENSE)를 참고하세요.

서드파티 구성 요소(각종 Flutter 패키지, [`bilibili-API-collect`](https://github.com/SocialSisterYi/bilibili-API-collect), [`media-kit`](https://github.com/media-kit/media-kit), [`flutter_meedu_videoplayer`](https://github.com/zezo357/flutter_meedu_videoplayer), [`dio`](https://pub.dev/packages/dio) 등)는 각자의 라이선스를 따릅니다.

<br/>

## 감사의 말

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- [Index-Translate](https://github.com/bilibili/Index-Translate) — bilibili가 오픈소스로 공개한 번역 모델 패밀리이자, 내장 엔진 뒤에 있는 무료 공개 엔드포인트
- 그리고 더 많은 프로젝트
- bilibili 공식 "AI 인터페이스 번역"에서 영감을 받았습니다.
