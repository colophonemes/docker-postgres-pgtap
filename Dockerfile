FROM postgres:13 AS base

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    postgresql-13-pgtap
