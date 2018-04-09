defmodule Ello.V3.Schema.ContestTypes do
  use Absinthe.Schema.Notation

  object :artist_invite do
    field :id, :id
    field :slug, :string
    field :title, :string
  end

  object :artist_invite_submission do
    field :id, :id
    field :status, :string, resolve: &submission_status/2
    field :artist_invite, :artist_invite
    field :actions, :artist_invite_submission_actions, resolve: &actions/2
  end

  object :artist_invite_submission_actions do
    field :approve, :artist_invite_submission_action
    field :decline, :artist_invite_submission_action
    field :unapprove, :artist_invite_submission_action
    field :select, :artist_invite_submission_action
    field :unselect, :artist_invite_submission_action
  end

  object :artist_invite_submission_action do
    field :href, :string
    field :label, :string
    field :method, :string
    field :body, :artist_invite_submission_action_body
  end

  object :artist_invite_submission_action_body do
    field :status, :string
  end

  defp submission_status(_, %{source: %{status: "approved"}}),
    do: {:ok, "approved"}
  defp submission_status(_, %{source: %{status: "selected", artist_invite: %{status: "closed"}}}),
    do: {:ok, "selected"}
  defp submission_status(_, %{source: %{status: "selected"}}), do: {:ok, "approved"}
  defp submission_status(_, _), do: {:ok, nil}


  defp actions(_, %{
    source: submission,
    context: %{current_user: %{is_staff: true}}
  }), do: {:ok, actions_map(submission)}
  defp actions(_, %{
    source: %{artist_invite: %{brand_account_id: user_id}} = submission,
    context: %{current_user: %{id: user_id}},
  }), do: {:ok, actions_map(submission)}
  defp actions(_, args),
    do: {:ok, nil}

  defp actions_map(%{status: "declined", id: id}) do
    %{
      approve: %{
        label:  "Approve",
        href:   "/api/v2/artist_invite_submissions/#{id}/approve",
        method: "PUT",
        body:   %{status: "approved"},
      }
    }
  end

  defp actions_map(%{status: "unapproved", id: id}) do
    %{
      decline: %{
        label:  "Decline",
        href:   "/api/v2/artist_invite_submissions/#{id}/decline",
        method: "PUT",
        body:   %{status: "declined"},
      },
      approve: %{
        label:  "Approve",
        href:   "/api/v2/artist_invite_submissions/#{id}/approve",
        method: "PUT",
        body:   %{status: "approved"},
      },
    }
  end

  defp actions_map(%{status: "approved", id: id}) do
    %{
      unapprove: %{
        label:  "Approved",
        href:   "/api/v2/artist_invite_submissions/#{id}/unapprove",
        method: "PUT",
        body:   %{status: "unapproved"},
      },
      select: %{
        label:  "Select",
        href:   "/api/v2/artist_invite_submissions/#{id}/select",
        method: "PUT",
        body:   %{status: "selected"},
      }
    }
  end

  defp actions_map(%{status: "selected", id: id}) do
    %{
      unselect: %{
        label:  "Selected",
        href:   "/api/v2/artist_invite_submissions/#{id}/deselect",
        method: "PUT",
        body:   %{status: "approved"},
      }
    }
  end
end
