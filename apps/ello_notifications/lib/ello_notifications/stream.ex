defmodule Ello.Notifications.Stream do
  alias __MODULE__.{
    Item,
    Client,
  }
  @moduledoc """
  Public API for interacting with the Ello Notifications Streams (in app notifications) via elixir.
  """

  defstruct [
    current_user: nil,
    allow_nsfw: false,
    allow_nudity: false,
    per_page: 25,
    before: nil,
    next: nil,
    __response: nil,
    __models: nil,
  ]

  @doc """
  Fetch a page of in app notifications as a stream.

  """
  def fetch(opts) do
    __MODULE__
    |> struct(opts)
    |> Client.fetch
    |> Loader.load
  end

  @doc """
  Create a single in app notification.
  """
  def create(opts) do
    Item
    |> struct(opts)
    |> Item.validate
    |> Client.create
  end

  @doc """
  Delete a single in app notification.
  """
  def delete(opts) do
    Item
    |> struct(opts)
    |> Item.validate
    |> Client.delete
  end
end
