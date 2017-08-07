defmodule Ello.V2.ArtistInviteView do
  use Ello.V2.Web, :view
  use Ello.V2.JSONAPI
  alias Ello.V2.{ImageView}

  def stale_checks(_, %{data: artist_invites}) do
    [etag: etag(artist_invites)]
  end

  def render("index.json", %{data: artist_invites} = opts) do
    json_response()
    |> render_resource(:artist_invites, artist_invites, __MODULE__, opts)
  end

  def render("show.json", %{data: artist_invite} = opts) do
    json_response()
    |> render_resource(:artist_invites, artist_invite, __MODULE__, opts)
  end

  def render("artist_invite.json", %{artist_invite: artist_invite} = opts), do:
    render_self(artist_invite, __MODULE__, opts)

  def attributes, do: [
    :title,
    :slug,
    :invite_type,
    :opened_at,
    :closed_at,
    :submission_body_block,
  ]

  def computed_attributes, do: [
    :header_image,
    :logo_image,
    :description,
    :short_description,
    :guide,
    :status,
  ]

  def header_image(artist_invite, conn),
    do: render(ImageView, "image.json", conn: conn, image: artist_invite.header_image_struct)

  def logo_image(artist_invite, conn),
    do: render(ImageView, "image.json", conn: conn, image: artist_invite.logo_image_struct)

  def description(artist_invite, _),
    do: artist_invite.rendered_description

  def short_description(artist_invite, _),
    do: artist_invite.rendered_short_description

  def guide(%{guide: guide}, _),
    do: Enum.map(guide, &(Map.delete(&1, "raw_body")))

  def links(invite, conn) do
    user = conn.assigns[:current_user]

    %{}
    |> add_unapproved_link(invite, user)
    |> add_approved_link(invite, user)
    |> add_selected_link(invite, user)
  end

  defp add_unapproved_link(links, %{id: id, brand_account_id: user_id}, %{id: user_id}) do
    Map.put(links, :unapproved_submissions, %{
      label: "To Review",
      type:  "artist_invite_submission_stream",
      href:  "/api/v2/artist_invites/#{id}/submissions?status=unapproved",
    })
  end
  defp add_unapproved_link(links, %{id: id}, %{is_staff: true}) do
    Map.put(links, :unapproved_submissions, %{
      label: "To Review",
      type:  "artist_invite_submission_stream",
      href:  "/api/v2/artist_invites/#{id}/submissions?status=unapproved",
    })
  end
  defp add_unapproved_link(links, _, _), do: links

  defp add_approved_link(links, %{id: id, status: status}, _) when status in ["open", "closed"] do
    Map.put(links, :approved_submissions, %{
      label: "Approved",
      type:  "artist_invite_submission_stream",
      href:  "/api/v2/artist_invites/#{id}/submissions?status=approved",
    })
  end
  defp add_approved_link(links, _, _), do: links

  defp add_selected_link(links, %{id: id, brand_account_id: user_id}, %{id: user_id}) do
    Map.put(links, :selected_submissions, %{
      label: "Selected",
      type:  "artist_invite_submission_stream",
      href:  "/api/v2/artist_invites/#{id}/submissions?status=selected",
    })
  end
  defp add_selected_link(links, %{id: id}, %{is_staff: true}) do
    Map.put(links, :selected_submissions, %{
      label: "Selected",
      type:  "artist_invite_submission_stream",
      href:  "/api/v2/artist_invites/#{id}/submissions?status=selected",
    })
  end
  defp add_selected_link(links, %{id: id, status: "closed"}, _) do
    Map.put(links, :selected_submissions, %{
      label: "Selected",
      type:  "artist_invite_submission_stream",
      href:  "/api/v2/artist_invites/#{id}/submissions?status=selected",
    })
  end
  defp add_selected_link(links, _, _), do: links

  def status(%{status: "open", closed_at: nil}, _), do: "open"
  def status(%{status: "open", opened_at: nil}, _), do: "upcoming"
  def status(%{status: "open"} = invite, _) do
    now    = DateTime.utc_now |> DateTime.to_unix
    open   = DateTime.to_unix(invite.opened_at)
    closed = DateTime.to_unix(invite.closed_at)
    cond do
      now < open   -> "upcoming"
      now > closed -> "selecting"
      true         -> "open"
    end
  end
  def status(%{status: status}, _), do: status
end
