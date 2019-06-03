defmodule Ello.Serve.VersionStore.Redis.Client do
  use Supervisor
  @moduledoc """
  Supervises a "pool" of redis workers and provides interface to using them.

  Each worker can handle multiple concurrent requests, so this is more of a
  load balancing technique then a real "checkout" style pool.
  """

  # 2019-05-07 - the 'newrelic' repo has out of date dependencies, disabling
  # newrelic until we have bandwidth to update our code, maybe to new_relic
  # import NewRelicPhoenix, only: [measure_segment: 2]
  import Ello.Core, only: [measure_segment: 2]

  @doc "Start supervisor"
  def start_link, do: Supervisor.start_link(__MODULE__, [])

  @doc "Start pool of n workers on start"
  def init([]) do
    workers = Enum.map 1..redis_pool_size(), fn(i) ->
      worker(Redix, [redis_url(), [name: :"serve_redis_#{i}"]], id: {Redix, i})
    end
    supervise(workers, strategy: :one_for_one)
  end

  @doc "Execute any redis command and get response back."
  def command([operation | _] = command, opts \\ []) do
    measure_segment {:db, "Redis.#{operation}-#{opts[:name] || "Ello.Serve.Unnamed"}"} do
      Redix.command(random_worker(), command, timeout: redis_timeout())
    end
  end

  defp random_worker do
    :"serve_redis_#{Enum.random(1..redis_pool_size())}"
  end

  defp redis_url, do: Application.get_env(:ello_serve, :redis_url)
  defp redis_pool_size, do: Application.get_env(:ello_serve, :redis_pool_size)
  defp redis_timeout, do: Application.get_env(:ello_serve, :redis_timeout)
end
