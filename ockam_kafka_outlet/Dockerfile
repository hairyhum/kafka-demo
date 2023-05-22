# Matches Controller, contains: Erlang 24.3.4.4, Elixir 1.13.4, Debian 11
FROM elixir:1.13.4@sha256:fd1b66f10b2c3d47095f9a400f932c5d30b6fe25624b53bc7a4c8909dcb7aa54 AS build

# install build dependencies
RUN apt-get update; \
  apt-get install -y --no-install-recommends \
  openssl \
  libncurses5 \
  git

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# uncomment COPY if priv/ exists
# COPY priv priv

# compile and build release
COPY lib lib
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release

# prepare release image
FROM debian:bullseye AS app
RUN apt-get update; \
  apt-get install -y --no-install-recommends \
  openssl \
  libncurses5 

WORKDIR /app

RUN chown nobody:nogroup /app

USER nobody:nogroup

COPY --from=build --chown=nobody:nogroup /app/_build/prod/rel/ockam_kafka_outlet ./

ENV HOME=/app

CMD ["bin/ockam_kafka_outlet", "start"]
