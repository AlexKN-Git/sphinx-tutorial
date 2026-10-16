

(struct-toc)=
# 5. Структура документа

```markdown
(struct-toc)=
# 5. Структура документа

```{note}
Здесь разбираем то, что в LaTeX делалось через `\section`, `\label`,
`\ref`, `\includegraphics` и окружение `figure`.
```

## Оглавление

За оглавление отвечает директива `{toctree}` — аналог `\tableofcontents`,
но с явным списком страниц:

```markdown
```{toctree}
:maxdepth: 2
:caption: Содержание

01-latex-vs-sphinx
02-install
03-first-project
```