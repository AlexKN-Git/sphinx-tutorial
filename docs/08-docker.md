
# 8. Docker для воспроизводимой сборки

```{note}
Docker позволяет собирать документацию в одинаковом окружении
на любой машине — ноутбуке, сервере, CI.
```

## Зачем

- «У меня собирается, у тебя нет» — больше не проблема.
- Не нужно ставить Python, Sphinx и LaTeX локально.
- Одна команда — одинаковый результат на Windows, macOS и Linux.

## Что нужно

- Docker Desktop (на Windows — с бэкендом WSL2).
- Файлы: `Dockerfile`, `docker-compose.yml`, `requirements.txt`, `.dockerignore`
  в корне проекта.

## `requirements.txt`

```
sphinx
myst-parser
furo
sphinx-autobuild
```

## `Dockerfile`

```dockerfile
FROM python:3.12-slim
WORKDIR /docs
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
EXPOSE 8000
CMD ["sphinx-autobuild", ".", "_build/html", "--host", "0.0.0.0", "--port", "8000"]
```

## `docker-compose.yml`

```yaml
services:
  docs:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - ./docs:/docs
```

## `.dockerignore`

```
.venv
docs/_build
docs/_build/latex
.git
```

## Команды

Сборка образа и запуск:

```bash
docker compose up --build
```

Сайт: `http://localhost:8000`.

Остановить:

```bash
docker compose down
```

Собрать HTML без сервера:

```bash
docker compose run --rm docs sphinx-build -b html . _build/html
```

Собрать LaTeX:

```bash
docker compose run --rm docs sphinx-build -b latex . _build/latex
```

## Что выигрываем

- Новая машина — только Docker Desktop и `docker compose up`.
- CI и локальная сборка используют один и тот же образ.
- Версии Sphinx и расширений фиксируются в `requirements.txt`.