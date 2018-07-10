defmodule Ello.Notifications.Stream do
  alias __MODULE__.{
    Item,
    Client,
    Loader,
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
    models: [],
    __response: nil,
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
  Delete a collection of notifications.

  Either:
    * delete all notifications for a user by passing user_id
    * delete all notifications for a subject by passing subject_id and subject_type

  """
  def delete_many(%{} = opts) do
    Client.delete_many(opts)
  end
end
