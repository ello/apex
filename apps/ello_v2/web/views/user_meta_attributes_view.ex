defmodule Ello.V2.UserMetaAttributesView do
  use Ello.V2.Web, :view
  import Ello.V2.ImageView, only: [image_url: 2]

  def render("user.json", %{user: user}) do
    %{
      title: title(user),
      robots: robots(user),
      image: image(user),
      description: description(user),
    }
  end

  defp title(%{name: nil, username: username}), do: "@#{username} | Ello"
  defp title(user), do: "#{user.name} (@#{user.username}) | Ello"

  defp robots(%{bad_for_seo: true}), do: "noindex, follow"
  defp robots(_), do: "index, follow"

  defp image(user) do
    case Enum.find(user.cover_image_struct.versions, &(&1.name == "optimized")) do
      nil     -> nil
      version -> image_url(user.cover_image_struct.path, version.filename)
    end
  end

  defp description(%{formatted_short_bio: nil} = user), do: default_description(user)
  defp description(user) do
    user.formatted_short_bio
    |> Curtail.truncate(length: 160)
    |> HtmlSanitizeEx.strip_tags
    |> String.trim
    |> case do
        ""    -> default_description(user)
        desc  -> desc
    end
  end

  defp default_description(%{name: nil, username: username}),
    do: "See @#{username}'s work on Ello"
  defp default_description(%{name: name}),
    do: "See #{name}'s work on Ello"
end
