defmodule Ello.Events do

  @moduledoc """
  Main API for Ello event publishing
  """

  @doc """
  What module handles publishing this event - should be Ello.Event.Sidekiq or
  any other event module.
  """
  @callback handler() :: module

  @doc """
  Publish an event to Sidekiq or Kinesis.
  """
  def publish(%{__struct__: module} = input) do
    handler = module.handler()
    handler.publish(module, input)
  end

end
