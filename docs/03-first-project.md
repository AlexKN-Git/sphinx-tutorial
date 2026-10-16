# 3. Первый проект и сборка HTML

## Создание

```bash
sphinx-quickstart docs
```

Отвечаем на вопросы мастера:

- Separate source and build directories: **n**
- Project name: любое
- Author name: любое
- Project release: 0.1
- Project language: `ru`

## Структура проекта

В свежих версиях Sphinx папка `source/` **не создаётся**. Всё лежит прямо
в `docs/`:

```
docs/
├── _build/       # сюда собирается результат
├── _static/      # статика (картинки, css)
├── _templates/   # шаблоны
├── conf.py       # конфигурация
├── index.md      # точка входа
└── Makefile
```

## Сборка

Кросс-платформенная команда (работает везде, где есть Python):

```bash
python -m sphinx -b html docs docs/_build/html
```

Результат открываем в браузере: `docs/_build/html/index.html`.

## Живой предпросмотр

```bash
sphinx-autobuild docs docs/_build/html
```

```{warning}
В Git Bash, WSL и Linux обратный слэш `\` — это символ экранирования,
а не разделитель пути. Пишите пути через **прямой** слэш:

```bash
docs/_build/html   ✅
docs\_build\html   ❌ превратится в `docs_buildhtml`
```
```