defmodule Ello.Events.Sidekiq do

  @doc "Sidekiq queue to enqueue in"
  @callback queue() :: String.t

  @doc "Sidekiq worker to process the event"
  @callback worker() :: String.t

  @doc "List of arguments to pass into Sidekiq"
  @callback args(opts :: struct) :: [any()]

  defmacro __using__(_) do
    quote do
      @behaviour Ello.Events
      @behaviour Ello.Events.Sidekiq

      def handler, do: Ello.Events.Sidekiq
      def queue, do: "default"
      def worker, do: List.last(Module.split(__MODULE__))

      defoverridable [queue: 0, worker: 0, handler: 0]
    end
  end

  def publish(module, struct) do
    Task.async fn ->
      now = DateTime.to_unix(DateTime.utc_now(), :microseconds) / 1_000_000

      retries = 10 # max_retries
      job = %{
        queue: module.queue(),
        retry: retries,
        class: module.worker(),
        args: module.args(struct),
        jid: UUID.uuid4,
        enqueued_at: now,
      }
      job_serialized = Poison.encode!(job)

      redis(["LPUSH", "queue:#{queue}", job_serialized])
    end
  end

  defp redis(args) do
    case Application.get_env(:ello_events, :redis, {Ello.Core.Redis, :command}) do
      {mod, fun}                   -> apply(mod, fun, [args])
      fun when is_function(fun, 1) -> fun.(args)
    end
  end

end
