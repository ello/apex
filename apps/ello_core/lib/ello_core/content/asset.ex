defmodule Ello.Core.Content.Asset do
  use Ecto.Schema
  alias Ello.Core.{Network.User, Content.Post}
  alias __MODULE__.Attachment

  @type t :: %__MODULE__{}

  schema "assets" do
    field :attachment_struct, :map, virtual: true
    field :attachment, :string
    field :attachment_metadata, :map

    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime

    belongs_to :user, User
    belongs_to :post, Post
  end

  @doc """
  Converts attachment metadata into attachment_struct
  """
  def build_attachment(asset) do
    Map.put(asset, :attachment_struct, Attachment.from_asset(asset))
  end

end
