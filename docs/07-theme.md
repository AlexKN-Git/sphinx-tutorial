
# 7. Тема и метаданные

```{note}
Тема отвечает за внешний вид сайта. Метаданные — за то, как проект
представляется в браузере, поиске и PDF.
```

## Тема

Sphinx по умолчанию использует `alabaster`. У нас подключена `furo`.
Указать тему можно в `conf.py`:

```python
html_theme = "furo"
```

Популярные темы:

| Тема | Особенности |
|---|---|
| `alabaster` | встроенная, минималистичная |
| `furo` | современная, тёмная тема, читаемая |
| `sphinx_rtd_theme` | классика Read the Docs |
| `sphinx_book_theme` | для книг и больших документов |
| `pydata_sphinx_theme` | для научных библиотек |

## Метаданные

```python
project = "Переход с LaTeX на Sphinx и Docker"
copyright = "2026, Alexey"
author = "Alexey"
release = "0.1"
language = "ru"
html_title = "Переход с LaTeX на Sphinx и Docker"
html_short_title = "Sphinx Tutorial"
```

`project` — имя проекта в подвале и метатегах.
`html_title` — заголовок в `<title>` браузера.
`html_short_title` — короткое имя для логотипа в меню.

## Логотип и favicon

Положи файлы в `_static/`:

```
docs/_static/logo.svg
docs/_static/favicon.ico
```

И укажи в `conf.py`:

```python
html_logo = "_static/logo.svg"
html_favicon = "_static/favicon.ico"
```

## Настройка цветов furo

```python
html_theme_options = {
    "light_css_variables": {
        "color-brand-primary": "#2962FF",
        "color-brand-content": "#2962FF",
    },
    "dark_css_variables": {
        "color-brand-primary": "#82B1FF",
        "color-brand-content": "#82B1FF",
    },
    "sidebar_hide_name": False,
    "navigation_with_keys": True,
}
```

`color-brand-primary` — цвет ссылок и акцентов. Переключатель светлой/тёмной
темы в furo появляется в правом верхнем углу автоматически.

## Сборка

```bash
python -m sphinx -b html docs docs/_build/html
```

Проверяем:

1. Заголовок вкладки — «Переход с LaTeX на Sphinx и Docker».
2. В правом верхнем углу — переключатель светлой/тёмной темы.
3. Ссылки в цвете бренда.
4. Логотип отображается в левом верхнем углу (если ты его добавил).