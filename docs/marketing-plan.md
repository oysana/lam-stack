# L.A.M. — позиционирование и план роста (ресерч 2026-11-09)

## Что такое LAM одним абзацем

LAM — это **дисциплина как продукт**: сжатый skill-pack, который заставляет
агента вести себя как штатный инженер — спека перед кодом, тест после фикса,
репо-гейты зелёными, механический floor вместо «промптных пожеланий».
Три крупнейших пака (pstack, mattpocock, addyosmani — ~130 скиллов, ~36KB
метаданных) утрамбованы в 13 фазовых скиллов (~4.3KB) с роутером
(7-seam state machine) и механическими воротами (`floor-guard`, `seam-gate`,
`validate-lam`). Плюс единственная в нише честная опубликованная дуэль
с сырым grader-JSON — включая свои ничьи.

**Чего LAM не является:** убийцей pstack, набором «130 скиллов в одном»,
ещё одним awesome-списком.

## Что залетело у конкурентов — паттерны (по звёздам, факт)

| Проект | ★ | Паттерн |
|---|---|---|
| obra/superpowers | 315k | Методология, не набор скиллов + *принуждение* к её использованию |
| mattpocock/skills | 318k | Известный автор + практичность |
| DietrichGebert/ponytail | 187k | Персона с мнением: «lazy senior dev, forces simplest solution» |
| claude-mem | 115k | Одна боль у всех: «memory that survives sessions» |
| impeccable | 106k | Острый враг в позиционировании («anti-slop») |
| oh-my-claudecode | 41k | oh-my-zsh брендинг + multi-agent без кривой обучения |
| awesome-списки | 26–57k | Кураторство как канал дистрибуции |

**Общий код успеха:**
1. Питч в одно предложение, называющий *ощущаемую боль* — не фичу.
2. Мнение/позиция, а не каталог («forces X», «anti-Y», «methodology»).
3. **Принуждение**: что-то заставляет агента реально применять (hooks, гейты) — ключевая строка superpowers.
4. Установка в одну команду (`/plugin install`, `npx skills add`).
5. Имя, которое повторяют вслух.
6. Демо за 30 секунд (gif/asciinema) — звёзды конвертирует видео, не текст.

## Где LAM уже сильнее рынка (использовать)

- **Механический floor** — единственный пак, где качество enforced скриптами,
  а не надеждой. Это ровно паттерн #3 победителей.
- **Публикуемая честная дуэль** — воспроизводимый eval-харнесс в репо
  (`/tmp/opencode/lam-eval` → перенести в `evals/`). НИКТО не публикует
  где он проиграл. Это и есть «инженерный/очень умный вид» — доверие
  через доказательства.
- **Измеренный context tax** — 1.1k токенов стартовой поверхности.
  «Senior-engineer discipline за 1/8 контекстной цены».

## Репозиционирование README (что поменять)

Сейчас первый экран продаёт «synthesis of three packs» — фичу, никому
не интересную. Поменять на боль+принуждение:

- **Теглайн:** «Your agent, held to a staff-engineer bar — mechanically,
  not hopefully.»
- **Подзаголовок:** «The three biggest skill packs, distilled to 13 phase
  skills + a hard floor. ~1.1k token startup surface. Evals published,
  including our losses.»
- Hero-раздел: 30-секундный asciinema — агент без LAM скипает тест/бамп
  версии, с LAM гоняет гейт. Это конвертит звёзды.
- FAQ «Why not just install all three packs?» — конфликты неймспейсов,
  9× контекст, отсутствие floor.
- GitHub repo description = теглайн; social preview image.
- Topics: `claude-code`, `claude-skills`, `agent-skills`, `ai-agents`,
  `plugin`, `llm`, `context-engineering`, `prompt-engineering`.
- Первые 120 символов README = ключевые слова (индексируется GitHub/Google).

## Список развития (приоритет → эффект)

**P0 — продукт (без этого маркетинг пустой):**
1. `lam doctor` — standalone CLI, аудит любого репо на floor-нарушения
   без установки пака. Верх воронки: тулзу ставят быстрее плагина.
2. Демо-gif/asciinema 30с в README hero (oyvoice hostname-кейс — готовая история).
3. Перенести eval-харнесс в репо публично: `evals/harness/` + `make duel` —
   «benchmark yourself against us» никто не предлагает.
4. CI badge: GitHub Action на validate-lam + floor-guard + claude plugin validate.
   «Proof in CI» = вайб.
5. Убедиться что `/plugin marketplace add oysana/lam-stack` работает —
   инструкция первой строкой README.

**P1 — покрытие (реальные дыры):**
6. Оркестрационный пробел: либо лёгкий `lam-orchestrate` seam, либо честное
   позиционирование «core discipline pack — pair with your orchestrator»
   (второе честнее и легче).
7. `npx skills add` путь установки (skills.sh CLI совместимость).
8. Gemini/Codex команды сверить на живых харнессах, не только schema.

**P2 — дистрибуция:**
9. PR в awesome-листы: hesreallyhim/awesome-claude-code (57k),
   VoltAgent lists, travisvn, ComposioHQ — это канал, не подарок.
10. Show HN / r/ClaudeAI / dev.to: угол = «я пробенчил свой пак против топов
    и опубликовал сырой JSON, где мы сыграли вничью». Честность тут —
    контент, который сам распространяется.
11. Документация: `docs/` — quickstart, the floor explained, evals methodology.
12. Star-history + visitors badges, issue templates, CONTRIBUTING-lite.

## Честная оценка потолка

Виральность не гарантируется ничем. У LAM есть один реальный,
не подделываемый козырь — **принуждение + честные доказательства**.
Если коммуникация держится на этом (а не на «еще один скилл-пак»),
пак стоит в редкой категории «вещи, которым верят». Это конвертит
медленнее хайпа, но удерживает.
