defmodule Ello.Events do
  @moduledoc """
  Main API for Ello event publishing
  """

  @doc """
  Publish an event to Sidekiq or Kinesis.
  """
  def publish(%{__struct__: module} = in) do
    handler = module.__handler()
    handler.publish(module, in)
  end

end
