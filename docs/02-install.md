# 2. Установка Sphinx

## Локально через Python

```bash
python -m venv .venv
source .venv/bin/activate       # Linux / macOS
source .venv/Scripts/activate   # Windows Git Bash
.venv\Scripts\Activate.ps1      # Windows PowerShell
pip install sphinx sphinx-autobuild myst-parser furo
```

```{warning}
`make` в Windows обычно отсутствует. Это не ошибка установки.
Вместо `make html` используем `sphinx-build` напрямую — см. раздел 3.
```

## Через Docker

```bash
docker run --rm -it -v "$PWD:/docs" -w /docs sphinxdoc/sphinx sphinx-quickstart
```

Подробнее про Docker — в разделе 8.