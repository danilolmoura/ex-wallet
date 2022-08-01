FROM hexpm/elixir:1.13.0-rc.1-erlang-25.0-rc1-alpine-3.16.0 as builder

RUN apk update \
  && apk add --no-cache bash make gcc libc-dev postgresql-client ca-certificates inotify-tools \
  && update-ca-certificates   

WORKDIR app

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# install mix dependencies
COPY mix.exs ./
COPY mix.lock ./

# start application
CMD mix deps.get && mix phx.server
