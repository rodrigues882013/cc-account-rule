import Config

config :some_app,
  key1: "value1",
  key2: "value2"

import_config "#{config_env()}.exs"
