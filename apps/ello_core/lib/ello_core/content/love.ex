defmodule Ello.Core.Content.Love do
  use Ecto.Schema
  alias Ello.Core.{
    Content.Post,
    Network.User
  }

  @type t :: %__MODULE__{}

  schema "loves" do
    belongs_to :post, Post
    belongs_to :user, User
    field :deleted, :boolean, default: false
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
  end

  @doc """
  Don't return assets that are unused or invalid.

  In particular done include assets that have a nil attachment field or are not
  included in the content of the post.
  """
  def filter_assets(%__MODULE__{post: %{assets: %{}}} = love), do: love
  def filter_assets(%__MODULE__{post: %{assets: []}} = love), do: love
  def filter_assets(%__MODULE__{post: %{assets: assets}} = love) do
    linked_asset_ids = Enum.reduce love.post.body, [], fn
      (%{"kind" => "image", "data" => %{"asset_id" => id}}, ids) -> [id | ids]
      (_, ids) -> ids
    end

    filtered_assets = Enum.reject assets, fn
      %{attachment: nil} -> true
      %{attachment: ""}  -> true
      %{id: id}          -> not id in linked_asset_ids
    end

    %{love | assets: filtered_assets}
  end
end
