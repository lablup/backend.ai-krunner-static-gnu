FROM python:3.9.6-bullseye

RUN apt-get update \
    && apt-get install -y \
	build-essential \
	ca-certificates

COPY requirements.txt /root/

RUN set -ex \
    && cd /root \
    && pip wheel -w ./wheels -r requirements.txt


# vim: ft=dockerfile
