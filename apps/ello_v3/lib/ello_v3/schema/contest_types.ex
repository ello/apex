defmodule Ello.V3.Schema.ContestTypes do
  use Absinthe.Schema.Notation

  object :artist_invite_submission do
    field :id, :id
    field :status, :string, resolve: &submission_status/2
    field :artist_invite, :artist_invite
  end

  object :artist_invite do
    field :id, :id
    field :slug, :string
    field :title, :string
  end

  defp submission_status(_, %{source: %{status: "approved"}}),
    do: {:ok, "approved"}
  defp submission_status(_, %{source: %{status: "selected", artist_invite: %{status: "closed"}}}),
    do: {:ok, "selected"}
  defp submission_status(_, %{source: %{status: "selected"}}), do: {:ok, "approved"}
  defp submission_status(_, _), do: {:ok, nil}
end
