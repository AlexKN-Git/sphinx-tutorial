
# 4. Markdown через MyST

```{note}
MyST — это мост между Markdown и Sphinx. Он позволяет писать контент
в привычном Markdown и при этом пользоваться всеми директивами Sphinx.
```

## Зачем MyST

Чистый Sphinx понимает только reStructuredText. Но писать техдокументацию
в RST после LaTeX непривычно. MyST (Markedly Structured Text) добавляет
поддержку Markdown и директив в фигурных скобках.

## Включаем MyST

Открываем `docs/conf.py` и правим две вещи.

### Расширения

```python
extensions = [
    "myst_parser",
]
```

### Расширения файлов

```python
source_suffix = {
    ".rst": "restructuredtext",
    ".md": "markdown",
}
```

Так можно держать в проекте и `.md`, и `.rst` одновременно — удобно
на переходный период.

## Полезные расширения MyST

Добавляем в `conf.py`:

```python
myst_enable_extensions = [
    "colon_fence",   # директивы через ::: вместо ```{...}
    "deflist",       # списки определений
    "dollarmath",    # формулы через $...$ и $$...$$
    "amsmath",       # \begin{aligned}, \begin{pmatrix} и т.п.
    "tasklist",      # чек-боксы - [ ] и - [x]
]
```

## Что становится доступно

### Директивы Sphinx

В RST это выглядело бы так:

```rst
.. note::

   Это заметка.
```

В MyST — так:

```markdown
:::{note}
Это заметка.
:::
```

Или через тройные бэктики:

````markdown
```{note}
Это заметка.
```