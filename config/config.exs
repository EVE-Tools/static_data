# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :static_data, StaticData.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "65U2B/A+42Dq8c5LjdRlW/WSGBHqn2vHPsALQXlmhoDcS22kThPaEbDtrFBpVXVv",
  render_errors: [view: StaticData.ErrorView, accepts: ~w(json)],
  pubsub: [name: StaticData.PubSub,
           adapter: Phoenix.PubSub.PG2],
  user_agent: "Element43 Static Data Service (https://github.com/EVE-Tools/static_data)"

config :crest,
  host: "crest-tq.eveonline.com", # Change host to point it at e.g. sisi
  port: 443,                      # Change port if you're using a custom proxy (TLS must be supported)
  max_sessions: 20,               # Maximum number of parallel connections
  max_pipeline_size: 150          # Maximum size of HTTP pipeline per connection

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
