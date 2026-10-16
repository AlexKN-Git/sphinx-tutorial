

# 6. Сборка PDF


```{note}
Тут пригодится твой опыт с LaTeX: Sphinx собирает `.tex`-файл,
а дальше работает привычный `pdflatex` / `xelatex`.
```

## Сборка через Sphinx

```bash
python -m sphinx -b latex docs docs/_build/latex
```

На выходе — файл `docs/_build/latex/<имя-проекта>.tex`. Компилируем его
привычным способом:

```bash
cd docs/_build/latex
pdflatex <имя-проекта>.tex
pdflatex <имя-проекта>.tex    # второй проход — для оглавления и ссылок
```

Если нужны русские буквы и системные шрифты — используем `xelatex`:

```bash
xelatex <имя-проекта>.tex
xelatex <имя-проекта>.tex
```

## Прямая сборка PDF через latexmk

```bash
python -m sphinx -b latex docs docs/_build/latex
cd docs/_build/latex
latexmk -pdf <имя-проекта>.tex
```

`latexmk` сам разберётся с числом проходов.

## Формулы

В HTML формулы рендерит MathJax, в PDF — сам LaTeX. Синтаксис один и тот же.

### Инлайн

```markdown
Эйнштейн показал, что $E = mc^2$, где $m$ — масса.
```

Эйнштейн показал, что $E = mc^2$, где $m$ — масса.

### Блочная формула с меткой

```{math}
:label: gauss-integral

\int_0^\infty e^{-x^2}\,dx = \frac{\sqrt{\pi}}{2}
```

Ссылка на формулу:

```markdown
См. {eq}`gauss-integral`.
```

### Система уравнений

```{math}
:label: maxwell

\begin{aligned}
\nabla \cdot \mathbf{E} &= \frac{\rho}{\varepsilon_0} \\
\nabla \cdot \mathbf{B} &= 0 \\
\nabla \times \mathbf{E} &= -\frac{\partial \mathbf{B}}{\partial t} \\
\nabla \times \mathbf{B} &= \mu_0 \mathbf{J} + \mu_0 \varepsilon_0 \frac{\partial \mathbf{E}}{\partial t}
\end{aligned}
```

### Матрицы, дроби, пределы

```{math}
A = \begin{pmatrix} a & b \\ c & d \end{pmatrix},
\qquad
\lim_{n \to \infty} \left(1 + \frac{1}{n}\right)^n = e
```

## Соответствие LaTeX ↔ MyST

| Задача | LaTeX | MyST |
|---|---|---|
| Инлайн-формула | `$x^2$` | `$x^2$` |
| Блочная формула | `\begin{equation}...\end{equation}` | `{math}` |
| Метка | `\label{eq:x}` | `:label: eq-x` |
| Ссылка на формулу | `\eqref{eq:x}` | `{eq}` |
| Система | `align` | `{math}` + `aligned` |
| Матрица | `pmatrix` | `pmatrix` |

## Настройки PDF в `conf.py`

Полезно задать:

```python
latex_documents = [
    ("index", "project.tex", "Название проекта", "Автор", "manual"),
]
latex_engine = "xelatex"      # если нужны системные шрифты и Unicode
latex_elements = {
    "papersize": "a4paper",
    "pointsize": "11pt",
    "preamble": r"""
        \usepackage{amsmath, amssymb}
        \usepackage{fontspec}
        \setmainfont{DejaVu Serif}
    """,
}
```

`latex_elements["preamble"]` — это твой аналог преамбулы LaTeX-документа:
можно подключать пакеты, менять шрифты, поля, колонтитулы.

## Проверяем

```bash
python -m sphinx -b html docs docs/_build/html
python -m sphinx -b latex docs docs/_build/latex
```

Смотрим:

1. В HTML формулы отрисованы MathJax.
2. В `.tex`-файле формулы выглядят как настоящий LaTeX-код.
3. `{eq}` ссылается на формулу.