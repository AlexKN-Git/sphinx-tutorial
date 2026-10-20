# 10. Проверки: линтеры, ссылки, орфография

```{note}
Автоматические проверки помогают держать документацию в порядке:
стиль, битые ссылки, опечатки, забытые термины.
```

## Встроенные проверки Sphinx

### Warnings as errors

По умолчанию Sphinx печатает предупреждения, но не прерывает сборку.
Если хочешь, чтобы CI падал на любом предупреждении — используй флаг `-W`:

```bash
sphinx-build -b html -W docs docs/_build/html
```

`--keep-going` не останавливает сборку на первой ошибке, но возвращает
код ошибки в конце:

```bash
sphinx-build -b html -W --keep-going docs docs/_build/html
```

Типичные предупреждения, которые ловит `-W`:

- `document isn't included in any toctree` — файл не добавлен в оглавление;
- `undefined label` — ссылка `{ref}` на несуществующую метку;
- `unknown target name` — ссылка `{doc}` на отсутствующий файл;
- `duplicate label` — две одинаковые метки в разных местах.

### linkcheck — проверка внешних ссылок

```bash
sphinx-build -b linkcheck docs docs/_build/linkcheck
```

Отчёт появится в `docs/_build/linkcheck/output.txt`. Каждая строка —
статус ссылки: `ok`, `broken`, `redirected`, `timeout`.

Игнорировать определённые домены можно в `conf.py`:

```python
linkcheck_ignore = [
    r"https://example\.com/.*",
    r"https://localhost:\d+/",
]
```

## Линтер Markdown

`markdownlint` проверяет разметку: пустые строки вокруг блоков кода,
правильные заголовки, отсутствие trailing spaces и т.д.

Через `npx` (нужен Node.js):

```bash
npx markdownlint-cli2 "docs/**/*.md"
```

Через Docker:

```bash
docker run --rm -v "$PWD:/workdir" davidanson/markdownlint-cli2 "docs/**/*.md"
```

Конфиг `.markdownlint.json` в корне:

```json
{
  "MD013": false,
  "MD033": false
}
```

`MD013` — ограничение длины строк, отключено (в MyST длинные строки норма).
`MD033` — inline HTML, отключено (иногда нужен).

## Vale — проверка стиля прозы

Vale — линтер для текста. Проверяет терминологию, тон, повторяющиеся
слова, слишком длинные предложения.

Установка на macOS:

```bash
brew install vale
```

Через Docker:

```bash
docker run --rm -v "$PWD:/docs" jdkato/vale /docs/docs
```

Конфиг `.vale.ini` в корне:

```ini
StylesPath = .vale/styles
MinAlertLevel = suggestion

[*.md]
BasedOnStyles = Vale
```

## Орфография: codespell

`codespell` — простой и быстрый спелчекер. Ловит опечатки и типичные
ошибки в английских словах.

Установка:

```bash
pip install codespell
```

Запуск:

```bash
codespell docs/
```

### Конфигурация: `.codespellrc` vs `pyproject.toml`

`codespell` поддерживает несколько мест, где ищет конфиг. Порядок
приоритета (от высшего к низшему):

1. Файл, указанный через `--config` или `--toml` в командной строке.
2. `.codespellrc` — в текущей директории.
3. `setup.cfg` — секция `[codespell]`.
4. `tox.ini` — секция `[codespell]`.
5. `pyproject.toml` — секция `[tool.codespell]`.

То есть **`.codespellrc` имеет приоритет над `pyproject.toml`**, если
оба лежат в одной папке.

**Разница в синтаксисе.**

`.codespellrc` — формат как `.ini`:

```ini
[codespell]
skip = *.svg,*.min.js,docs/_build/*
ignore-words-list = nd
```

`pyproject.toml` — TOML:

```toml
[tool.codespell]
skip = "*.svg,*.min.js,docs/_build/*"
ignore-words-list = "nd"
```

Семантика ключей одинаковая. В TOML значения строк — обязательно
в кавычках, ключи — через дефисы.

**Что выбрать.**

- Для проекта, где Python — только рантайм для Sphinx, лучше `.codespellrc`:
  файл явно про `codespell`, работает во всех версиях, приоритет выше.
- Если в `pyproject.toml` уже живут другие Python-инструменты
  (`[tool.ruff]`, `[tool.black]`, `[tool.pytest]`), `codespell` логично
  держать там же.

### Важно: шаблоны в `skip`

Шаблоны в `skip` матчатся **относительно путей, которые обходит codespell**.
Если запускать `codespell docs/`, путь к файлу будет `docs/_build/html/...`,
поэтому шаблон `_build/*` не сработает, а `docs/_build/*` или `*_build/*` — сработает.

Универсальный конфиг:

```ini
[codespell]
skip = *.svg,*.min.js,docs/_build/*,*_build/*,*.map
ignore-words-list = nd
```

### Ложные срабатывания на русском

`codespell` заточен под английский. На русских словах возможны ложные
срабатывания — например, `nd` из середины слова. Их добавляют в
`ignore-words-list`. Не добавляй туда реальные английские опечатки —
тогда `codespell` их больше не поймает.

## Орфография в Docker

В сервисе `checks` из `docker-compose.yml` используется `codespell`:

```yaml
  checks:
    build: .
    volumes:
      - ./docs:/docs
      - ./.codespellrc:/docs/.codespellrc:ro
    command: >
      sh -c "sphinx-build -b html -W --keep-going . _build/html &&
             sphinx-build -b linkcheck . _build/linkcheck &&
             codespell ."
```

### Почему конфиг монтируется отдельным томом

`codespell` ищет `.codespellrc` в **текущей рабочей директории** — внутри
контейнера это `/docs`. Если монтировать только `./docs:/docs`, файл
`.codespellrc` из корня проекта в контейнер **не попадёт**, и настройки
проигнорируются — `codespell` будет ругаться на всё подряд, включая
`_build` и ложные срабатывания.

Решение — смонтировать конфиг явно:

```yaml
volumes:
  - ./.codespellrc:/docs/.codespellrc:ro
```

`:ro` — только для чтения: контейнер не должен менять файл на хосте.

Альтернативы:

- Положить `.codespellrc` в `docs/` — тогда он попадёт в контейнер
  при монтировании `./docs:/docs`. Но файл «уезжает» из корня проекта.
- Передать путь явно: `codespell --config /tmp/.codespellrc .` и
  смонтировать в `/tmp`.
- Прописать все параметры в `command` — громоздко при большом конфиге.

### Запуск проверок в контейнере

```bash
docker compose run --rm checks
```

Один контейнер — три проверки последовательно. Если `sphinx-build -W`
упал, `linkcheck` и `codespell` не запускаются. `--rm` удаляет контейнер
после выполнения.

## CI: цепочка job'ов

В `.github/workflows/docs.yml` три job'а, связанные через `needs`:

```yaml
jobs:
  checks:
    runs-on: ubuntu-latest
    steps:
      - ...

  build:
    needs: [checks]
    runs-on: ubuntu-latest
    steps:
      - ...

  deploy:
    needs: [checks, build]
    runs-on: ubuntu-latest
    steps:
      - ...
```

Как это работает:

- `checks` запускается сразу.
- `build` ждёт **успешного** завершения `checks`. Если `checks` упал —
  `build` не запускается.
- `deploy` ждёт успешного завершения `checks` **и** `build`.

Без `needs` job'ы запускаются параллельно и независимо: `checks` падает,
а `deploy` спокойно публикует сайт. Это декоративные проверки.
С `needs` — настоящий гейт: плохая документация не попадает на прод.

Формы записи `needs`:

- Одна зависимость: `needs: checks`.
- Несколько: `needs: [checks, build]`.

Для цепочки `checks → build → deploy` достаточно `needs: [checks]` у
`build` и `needs: [build]` у `deploy`, но явный список `[checks, build]`
нагляднее и защищает от ошибок при рефакторинге.

## Полный CI workflow

```yaml
name: Build and publish docs

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  checks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install dependencies
        run: pip install -r requirements.txt codespell
      - name: Sphinx build with warnings as errors
        run: sphinx-build -b html -W --keep-going docs docs/_build/html
      - name: Link check
        run: sphinx-build -b linkcheck docs docs/_build/linkcheck
      - name: Spell check
        run: codespell docs/

  build:
    needs: [checks]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Build HTML
        run: sphinx-build -b html docs docs/_build/html
      - uses: actions/upload-pages-artifact@v3
        with:
          path: docs/_build/html

  deploy:
    needs: [checks, build]
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

## Проверка блокировки

Чтобы убедиться, что `needs` реально блокирует публикацию:

1. Временно сломай что-нибудь — например, добавь ссылку `{ref}` на
   несуществующую метку.
2. Запушь.
3. Открой вкладку **Actions** — увидишь, что `checks` упал, а `build`
   и `deploy` в статусе **skipped**.
4. Убери поломку, запушь снова — всё пройдёт зелёным.

## Что проверять и что игнорировать

- **Битые ссылки** — всегда проверять, это критично.
- **Warnings Sphinx** — всегда проверять, они реально указывают на проблемы.
- **codespell** — почти всегда полезно; ложные срабатывания на русском
  добавлять в `ignore-words-list`.
- **markdownlint** — использовать выборочно, некоторые правила мешают.
- **Vale** — настраивать под свой стиль, не включать всё подряд.

## Локальная проверка перед push

Минимальный набор:

```bash
rm -rf docs/_build
sphinx-build -b html -W --keep-going docs docs/_build/html
sphinx-build -b linkcheck docs docs/_build/linkcheck
codespell docs/
```

Или через Docker — в чистом окружении, как на CI:

```bash
docker compose run --rm checks
```

Если оба варианта зелёные — push пройдёт без сюрпризов.