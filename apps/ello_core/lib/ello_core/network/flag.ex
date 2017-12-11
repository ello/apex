defmodule Ello.Core.Network.Flag do
  use Ecto.Schema
  alias Ello.Core.Network.User

  schema "flags" do
    field :subject_id, :integer
    field :subject_type, :string
    field :kind, :string
    field :verified, :boolean

    field :resolved_at, :utc_datetime
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    belongs_to :reporting_user, User
    belongs_to :subject_user, User
  end
end
