FROM python:3.13

WORKDIR /dbapp

COPY . .

RUN pip install --no-cache-dir -r deps/requirements.txt

RUN apt update && apt-get install -y jq tree vim iputils-ping curl

ENV PYTHONPATH="/dbapp/src"


