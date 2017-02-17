defmodule Ello.Events.Exq do

  @doc "Sidekiq/Exq queue to enqueue in"
  @callback queue() :: String.t

  @doc "Sidekiq/Exq worker to process the event"
  @callback worker() :: String.t

  @doc "List of arguments to pass into Sidekiq"
  @callback args() :: [any()]

  @doc "What module handles publishing this event - should be Ello.Event.Exq"
  @callback __handler() :: module

  defmacro __using__(_) do
    quote do
      @behaviour Ello.Events
      def __handler, do: Ello.Events.Exq
      def queue, do: "default"
      def worker, do: "#{__MODULE__}"
      @overridable [queue: 0, worker: 0, __handler: 0]
    end
  end

  def publish(module, struct) do
    Exq.enqueue(Exq, module.queue(), module.worker(), module.args(struct))
  end
end
