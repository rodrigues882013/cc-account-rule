FROM elixir:latest as builder

ARG APP_NAME="authorizer"
ARG MIX_ENV="prod"
ARG VERSION="0.0.1"

WORKDIR /app
ADD . /app

RUN mix local.hex --force && mix local.rebar --force && mix deps.get
RUN MIX_ENV=$MIX_ENV mix escript.build
ENTRYPOINT ["run.sh"]