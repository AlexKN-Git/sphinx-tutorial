# 10. Проверки: линтеры, ссылки, орфография

```{note}
Автоматические проверки помогают держать документацию в порядке:
стиль, битые ссылки, опечатки, забытые термины.
```

## Встроенные проверки Sphinx

### Warnings as errors

По умолчанию Sphinx печатает предупреждения, но не прерывает сборку.
Если хочешь, чтобы CI падал на любом предупреждении — используй флаг `-W`:

    sphinx-build -b html -W docs docs/_build/html

Мягкий вариант — превращать в ошибки только определённые предупреждения,
не останавливаясь на первой:

    sphinx-build -b html -W --keep-going docs docs/_build/html

`--keep-going` не останавливает сборку, но возвращает код ошибки в конце.

### linkcheck — проверка битых ссылок

    sphinx-build -b linkcheck docs docs/_build/linkcheck

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

    npx markdownlint-cli2 "docs/**/*.md"

Или через Docker:

    docker run --rm -v "$PWD:/workdir" davidanson/markdownlint-cli2 "docs/**/*.md"

Конфиг `.markdownlint.json` в корне:

```json
{
  "MD013": false,
  "MD033": false
}
```

`MD013` — ограничение длины строк, отключено (в MyST длинные строки —
норма). `MD033` — inline HTML, отключено (иногда нужен).

## Vale — проверка стиля прозы

Vale — линтер для текста. Проверяет терминологию, тон, повторяющиеся
слова, слишком длинные предложения. Поддерживает Markdown и RST.

Установка на macOS:

    brew install vale

Или через Docker:

    docker run --rm -v "$PWD:/docs" jdkato/vale /docs/docs

Конфиг `.vale.ini` в корне:

```ini
StylesPath = .vale/styles

MinAlertLevel = suggestion

[*.md]
BasedOnStyles = Vale
```

## Орфография

`codespell` — простой и быстрый спелчекер. Ловит опечатки и типичные
ошибки (например, `recieve` → `receive`).

    pip install codespell
    codespell docs/

Через Docker:

    docker run --rm -v "$PWD:/workdir" codespellproject/codespell docs/

Игнорировать слова можно в `pyproject.toml`:

```toml
[tool.codespell]
ignore-words-list = "nd,ba"
skip = "*.svg,*.min.js"
```

## Всё вместе в CI

Обнови `.github/workflows/docs.yml` — добавь отдельный job `checks`,
который запускается перед сборкой:

```yaml
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
```

Если любой шаг падает — PR не пройдёт. Это заставляет писать чище
и не оставлять битых ссылок и опечаток.

## Что проверять и что игнорировать

- **Битые ссылки** — всегда проверять, это критично.
- **Warnings Sphinx** — всегда проверять, они реально указывают на проблемы.
- **markdownlint** — использовать выборочно, некоторые правила мешают.
- **Vale** — настраивать под свой стиль, не включать всё подряд.
- **codespell** — почти всегда полезно.

## Собираем и проверяем

    sphinx-build -b html -W --keep-going docs docs/_build/html
    sphinx-build -b linkcheck docs docs/_build/linkcheck
    codespell docs/

Если всё чисто — можно добавить эти проверки в CI.