defmodule Ello.Events.Exq do

  @doc "Sidekiq/Exq queue to enqueue in"
  @callback queue() :: String.t

  @doc "Sidekiq/Exq worker to process the event"
  @callback worker() :: String.t

  @doc "List of arguments to pass into Sidekiq"
  @callback args(opts :: struct) :: [any()]

  defmacro __using__(_) do
    quote do
      @behaviour Ello.Events
      @behaviour Ello.Events.Exq

      def handler, do: Ello.Events.Exq
      def queue, do: "default"
      def worker, do: List.last(Module.split(__MODULE__))

      defoverridable [queue: 0, worker: 0, handler: 0]
    end
  end

  def publish(module, struct) do
    Exq.enqueue(Exq, module.queue(), module.worker(), module.args(struct))
  end

end
