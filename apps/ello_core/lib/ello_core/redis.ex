defmodule Ello.Core.Redis do
  use Supervisor
  @moduledoc """
  Supervises a "pool" of redis workers and provides interface to using them.

  Each worker can handle multiple concurrent requests, so this is more of a
  load balancing technique then a real "checkout" style pool.
  """
  import NewRelicPhoenix, only: [measure_segment: 2]

  @doc "Start supervisor"
  def start_link, do: Supervisor.start_link(__MODULE__, [])

  @doc "Start pool of n workers on start"
  def init([]) do
    workers = Enum.map 1..redis_pool_size(), fn(i) ->
      worker(Redix, [redis_url(), [name: :"redis_#{i}"]], id: {Redix, i})
    end
    supervise(workers, strategy: :one_for_one)
  end

  @doc "Execute any redis command and get response back."
  def command([operation | _] = command, opts \\ []) do
    timeout = Application.get_env(:ello_core, :redis_timeout, 5_000)
    measure_segment {:db, "Redis.#{operation}-#{opts[:name] || "unnamed"}"} do
      Redix.command(random_worker(), command, timeout: timeout)
    end
  end

  defp random_worker do
    :"redis_#{Enum.random(1..redis_pool_size())}"
  end

  defp redis_url, do: Application.get_env(:ello_core, :redis_url)

  defp redis_pool_size, do: Application.get_env(:ello_core, :redis_pool_size)
end
