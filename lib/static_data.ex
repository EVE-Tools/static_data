defmodule StaticData do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [

      # Caches

      # Cache locations from CREST indefinitely
      worker(ConCache, [[], [name: :static_location_cache]], id: :static_location_cache),

      # Cache outposts and citadels for an hour
      worker(ConCache, [[
          ttl_check: :timer.minutes(5),
          ttl: :timer.hours(1)
        ], [name: :dynamic_location_cache]], id: :dynamic_location_cache),

      # Cache types from CREST indefinitely
      worker(ConCache, [[], [name: :type_cache]], id: :type_cache),


      # Start the endpoint when the application starts
      supervisor(StaticData.Endpoint, []),
      # Start your own worker by calling: StaticData.Worker.start_link(arg1, arg2, arg3)
      # worker(StaticData.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StaticData.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    StaticData.Endpoint.config_change(changed, removed)
    :ok
  end
end
