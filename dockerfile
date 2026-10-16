FROM python:3.12-slim

WORKDIR /docs

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

EXPOSE 8000

CMD ["sphinx-autobuild", ".", "_build/html", "--host", "0.0.0.0", "--port", "8000"]