FROM elixir:latest as builder

ARG APP_NAME="authorizer"
ARG MIX_ENV="prod"
ARG VERSION="0.0.1"

ENV PATH=$PATH:/app

RUN mkdir /app
WORKDIR /app
COPY . /app

RUN mix local.hex --force && mix deps.get
RUN MIX_ENV=$MIX_ENV mix escript.build
CMD ["./authorizer"]