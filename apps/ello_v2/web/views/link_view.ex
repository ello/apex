defmodule Ello.V2.LinkView do
  use Ello.V2.Web, :view

  def render("links.json", %{links: nil}), do: nil
  def render("links.json", %{links: links}) do
    links
    |> String.split(~r/,? +/)
    |> Enum.map(fn link ->
      link
      |> sanitize_url
      |> match_url_to_icon_and_format
    end)
  end

  defp sanitize_url(link) do
    if String.match?(link, ~r/\Ahttp/i) do
      link
    else
      "http://" <> link
    end
  end

  defp sanitize_text(link), do: String.replace(link, ~r/\Ahttps?:\/\//i, "")

  defp match_url_to_icon_and_format(url) do
    icon_types()
    |> Enum.find(&Regex.match?(&1.regex, url))
    |> format_link(url)
  end

  defp format_link(nil, url), do: %{url: url, text: sanitize_text(url)}
  defp format_link(icon_type, url) do
    icon_type
    |> Map.delete(:regex)
    |> social_icon_url
    |> Map.merge(%{url: url, text: sanitize_text(url)})
  end

  defp social_icon_url(icon_type) do
    social_icons_host = Application.get_env(:ello_v2, :social_icons_host)
    Map.put(icon_type, :icon, "https://#{social_icons_host}/#{icon_type.icon}")
  end

  defp icon_types do
    [
      %{type: "Apple Store", icon: "apple.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?itunes\.apple\.com\/app\/apple-store\/([a-za-z0-9_]+)|appstore\.com\/([a-za-z0-9_]+)\/([a-za-z0-9_]+)/},
      %{type: "Bandcamp", icon: "bandcamp.png", regex: ~r/((http(s?):\/\/)*([a-zA-Z0-9\-])*\.bandcamp)|bandcamp\.com\/([a-zA-Z0-9_]+)/},
      %{type: "Behance", icon: "behance.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?behance\.net\/([a-zA-Z0-9_]+)|behance.net\/([a-zA-Z0-9_]+)/},
      %{type: "Cargo Collective", icon: "cargo.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?cargocollective\.com\/([a-zA-Z0-9_]+)|cargocollective.com\/([a-zA-Z0-9_]+)/},
      %{type: "Dailymotion", icon: "dailymotion.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?dailymotion\.com\/([a-zA-Z0-9_]+)|dailymotion.com\/([a-zA-Z0-9_]+)/},
      %{type: "Deviantart", icon: "deviantart.png", regex: ~r/[^"\/www\."](?<!w{3})[A-Za-z0-9]*(?=\.deviantart\.com)/},
      %{type: "Dribbble", icon: "dribbble.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?dribbble\.com\/([a-zA-Z0-9_]+)|dribbble.com\/([a-zA-Z0-9_]+)/},
      %{type: "Ello", icon: "ello.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?ello\.co\/([a-zA-Z0-9_]+)|ello.co\/([a-zA-Z0-9_]+)/},
      %{type: "Etsy", icon: "etsy.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?etsy\.com\/shop\/([a-zA-Z0-9_.-]+)/},
      %{type: "Facebook", icon: "facebook.png", regex: ~r/(?:(?:http|https):\/\/)?(?:www.)?facebook.com\/(?:(?:\w)*#!\/)?(?:pages\/)?(?:[?\w\-]*\/)?(?:profile.php\?id=(?=\d.*))?([\w\-]*)?/},
      %{type: "500px", icon: "500px.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?500px\.com\/([a-zA-Z0-9_]+)|500px.com\/([a-zA-Z0-9_]+)/},
      %{type: "Flickr", icon: "flickr.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?flickr\.com\/photos\/([a-zA-Z0-9_.-]+)/},
      %{type: "Github", icon: "github.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?github\.com\/([a-zA-Z0-9_-]+)|github.com\/([a-zA-Z0-9_]+)/},
      %{type: "Goodreads", icon: "goodreads.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?goodreads\.com\/user\/show\/([a-zA-Z0-9_.-]+)/},
      %{type: "Google Play Store", icon: "play.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?play\.google\.com\/store\/apps\/details\?id=([a-zA-Z0-9._]+)/},
      %{type: "Google+", icon: "google_plus.png", regex: ~r/http(?:s)?:\/\/plus\.google\.com\/([a-zA-Z0-9_+]+)|plus\.google\.com\/([a-zA-Z0-9_+]+)/},
      %{type: "Instagram", icon: "instagram.png", regex: ~r/(?:(?:http|https):\/\/)?(?:www.)?(?:instagram.com|instagr.am)\/([A-Za-z0-9\-_]+)/},
      %{type: "Linkedin", icon: "linkedin.png", regex: ~r/^(http(s)?:\/\/)?([\w]+\.)?linkedin\.com\/(pub|in|profile)/},
      %{type: "Medium", icon: "medium.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?medium\.com\/@([a-zA-Z0-9_.-]+)|medium\.com\/@([a-zA-Z0-9_.-]+)/},
      %{type: "Mixcloud", icon: "mixcloud.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?mixcloud\.com\/([a-zA-Z0-9_]+)|mixcloud\.com\/([a-zA-Z0-9_]+)/},
      %{type: "Model Mayhem", icon: "model_mayhem.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?modelmayhem\.com\/([a-zA-Z0-9_-]+)|modelmayhem\.com\/([a-zA-Z0-9_-]+)/},
      %{type: "Patreon", icon: "patreon.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?patreon\.com\/([a-zA-Z0-9_-]+)|patreon\.com\/([a-zA-Z0-9_-]+)/},
      %{type: "Persona", icon: "persona.png", regex: ~r/[^"\/www\."](?<!w{3})[A-Za-z0-9]*(?=\.persona\.co)/},
      %{type: "Pinterest", icon: "pinterest.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?pinterest\.com\/([a-zA-Z0-9_]+)|pinterest\.com\/([a-zA-Z0-9_]+)/},
      %{type: "Shopify", icon: "shopify.png", regex: ~r/[^"\/www\."](?<!w{3})[A-Za-z0-9]*(?=\.myshopify\.com)/},
      %{type: "Snapchat", icon: "snapchat.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?snapchat\.com\/add\/([a-zA-Z0-9_.-]+)/},
      %{type: "Society6", icon: "society6.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?society6\.com\/([a-zA-Z0-9_]+)|society6\.com\/([a-zA-Z0-9_]+)/},
      %{type: "Soundcloud", icon: "soundcloud.png", regex: ~r/^https?:\/\/(soundcloud\.com|snd\.sc)\/(.*)$/},
      %{type: "Threadless", icon: "threadless.png", regex: ~r/[^"\/www\."](?<!w{3})[A-Za-z0-9]*(?=\.threadless\.com)/},
      %{type: "Tumblr", icon: "tumblr.png", regex: ~r/[^"\/www\."](?<!w{3})[A-Za-z0-9]*(?=\.tumblr\.com)/},
      %{type: "Twitter", icon: "twitter.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?twitter\.com\/([a-zA-Z0-9_]+)|twitter.com\/([a-zA-Z0-9_]+)/},
      %{type: "Vimeo", icon: "vimeo.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?vimeo\.com\/([a-zA-Z0-9_]+)|vimeo\.com\/([a-zA-Z0-9_]+)/},
      %{type: "Vine", icon: "vine.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?vine\.co\/([a-zA-Z0-9_]+)|vine.co\/([a-zA-Z0-9_]+)/},
      %{type: "VSCO", icon: "vsco.png", regex: ~r/http(?:s)?:\/\/(?:www\.)?vsco\.co\/([a-zA-Z0-9_]+)|vsco.co\/([a-zA-Z0-9_]+)/},
      %{type: "Youtube", icon: "youtube.png", regex: ~r/^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$/}
    ]
  end
end
