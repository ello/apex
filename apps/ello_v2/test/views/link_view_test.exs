defmodule Ello.V2.LinkViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.LinkView

  @social_icons_url Application.get_env(:ello_v2, :social_icons_url)

  defp test_links do
    %{
      "appstore.com/asdf/asdf" => [%{url: "http://appstore.com/asdf/asdf", text: "appstore.com/asdf/asdf", type: "Apple Store", icon: "#{@social_icons_url}/apple.png"}],
      "https://itunes.apple.com/app/apple-store/asdf" => [%{url: "https://itunes.apple.com/app/apple-store/asdf", text: "itunes.apple.com/app/apple-store/asdf", type: "Apple Store", icon: "#{@social_icons_url}/apple.png"}],
      "https://asdfband.bandcamp.com" => [%{url: "https://asdfband.bandcamp.com", text: "asdfband.bandcamp.com", type: "Bandcamp", icon: "#{@social_icons_url}/bandcamp.png"}],
      "https://bandcamp.com/asdf" => [%{url: "https://bandcamp.com/asdf", text: "bandcamp.com/asdf", type: "Bandcamp", icon: "#{@social_icons_url}/bandcamp.png"}],
      "https://www.behance.net/asdf" => [%{url: "https://www.behance.net/asdf", text: "www.behance.net/asdf", type: "Behance", icon: "#{@social_icons_url}/behance.png"}],
      "http://cargocollective.com/asdf" => [%{url: "http://cargocollective.com/asdf", text: "cargocollective.com/asdf", type: "Cargo Collective", icon: "#{@social_icons_url}/cargo.png"}],
      "https://dailymotion.com/asdf" => [%{url: "https://dailymotion.com/asdf", text: "dailymotion.com/asdf", type: "Dailymotion", icon: "#{@social_icons_url}/dailymotion.png"}],
      "asdf.deviantart.com" => [%{url: "http://asdf.deviantart.com", text: "asdf.deviantart.com", type: "Deviantart", icon: "#{@social_icons_url}/deviantart.png"}],
      "https://dribbble.com/asdf" => [%{url: "https://dribbble.com/asdf", text: "dribbble.com/asdf", type: "Dribbble", icon: "#{@social_icons_url}/dribbble.png"}],
      "ello.co/asdf" => [%{url: "http://ello.co/asdf", text: "ello.co/asdf", type: "Ello", icon: "#{@social_icons_url}/ello.png"}],
      "https://www.etsy.com/shop/asdf" => [%{url: "https://www.etsy.com/shop/asdf", text: "www.etsy.com/shop/asdf", type: "Etsy", icon: "#{@social_icons_url}/etsy.png"}],
      "https://www.facebook.com/asdf" => [%{url: "https://www.facebook.com/asdf", text: "www.facebook.com/asdf", type: "Facebook", icon: "#{@social_icons_url}/facebook.png"}],
      "https://www.facebook.com/pages/asdf" => [%{url: "https://www.facebook.com/pages/asdf", text: "www.facebook.com/pages/asdf", type: "Facebook", icon: "#{@social_icons_url}/facebook.png"}],
      "https://500px.com/asdf" => [%{url: "https://500px.com/asdf", text: "500px.com/asdf", type: "500px", icon: "#{@social_icons_url}/500px.png"}],
      "https://www.flickr.com/photos/asdf" => [%{url: "https://www.flickr.com/photos/asdf", text: "www.flickr.com/photos/asdf", type: "Flickr", icon: "#{@social_icons_url}/flickr.png"}],
      "https://www.github.com/asdf" => [%{url: "https://www.github.com/asdf", text: "www.github.com/asdf", type: "Github", icon: "#{@social_icons_url}/github.png"}],
      "https://www.goodreads.com/user/show/asdf" => [%{url: "https://www.goodreads.com/user/show/asdf", text: "www.goodreads.com/user/show/asdf", type: "Goodreads", icon: "#{@social_icons_url}/goodreads.png"}],
      "https://play.google.com/store/apps/details?id=asdf" => [%{url: "https://play.google.com/store/apps/details?id=asdf", text: "play.google.com/store/apps/details?id=asdf", type: "Google Play Store", icon: "#{@social_icons_url}/play.png"}],
      "https://plus.google.com/+asdf" => [%{url: "https://plus.google.com/+asdf", text: "plus.google.com/+asdf", type: "Google+", icon: "#{@social_icons_url}/google_plus.png"}],
      "https://www.instagram.com/asdf-" => [%{url: "https://www.instagram.com/asdf-", text: "www.instagram.com/asdf-", type: "Instagram", icon: "#{@social_icons_url}/instagram.png"}],
      "https://www.linkedin.com/in/asdf" => [%{url: "https://www.linkedin.com/in/asdf", text: "www.linkedin.com/in/asdf", type: "Linkedin", icon: "#{@social_icons_url}/linkedin.png"}],
      "https://www.medium.com/@asdf" => [%{url: "https://www.medium.com/@asdf", text: "www.medium.com/@asdf", type: "Medium", icon: "#{@social_icons_url}/medium.png"}],
      "https://www.mixcloud.com/asdf/" => [%{url: "https://www.mixcloud.com/asdf/", text: "www.mixcloud.com/asdf/", type: "Mixcloud", icon: "#{@social_icons_url}/mixcloud.png"}],
      "www.modelmayhem.com/asdf" => [%{url: "http://www.modelmayhem.com/asdf", text: "www.modelmayhem.com/asdf", type: "Model Mayhem", icon: "#{@social_icons_url}/model_mayhem.png"}],
      "https://www.patreon.com/asdf" => [%{url: "https://www.patreon.com/asdf", text: "www.patreon.com/asdf", type: "Patreon", icon: "#{@social_icons_url}/patreon.png"}],
      "https://asdf.persona.co/" => [%{url: "https://asdf.persona.co/", text: "asdf.persona.co/", type: "Persona", icon: "#{@social_icons_url}/persona.png"}],
      "https://www.pinterest.com/asdf/" => [%{url: "https://www.pinterest.com/asdf/", text: "www.pinterest.com/asdf/", type: "Pinterest", icon: "#{@social_icons_url}/pinterest.png"}],
      "http://asdf.myshopify.com/" => [%{url: "http://asdf.myshopify.com/", text: "asdf.myshopify.com/", type: "Shopify", icon: "#{@social_icons_url}/shopify.png"}],
      "https://www.snapchat.com/add/asdf" => [%{url: "https://www.snapchat.com/add/asdf", text: "www.snapchat.com/add/asdf", type: "Snapchat", icon: "#{@social_icons_url}/snapchat.png"}],
      "https://society6.com/asdf" => [%{url: "https://society6.com/asdf", text: "society6.com/asdf", type: "Society6", icon: "#{@social_icons_url}/society6.png"}],
      "https://soundcloud.com/asdf" => [%{url: "https://soundcloud.com/asdf", text: "soundcloud.com/asdf", type: "Soundcloud", icon: "#{@social_icons_url}/soundcloud.png"}],
      "https://asdf.threadless.com/" => [%{url: "https://asdf.threadless.com/", text: "asdf.threadless.com/", type: "Threadless", icon: "#{@social_icons_url}/threadless.png"}],
      "asdf.tumblr.com" => [%{url: "http://asdf.tumblr.com", text: "asdf.tumblr.com", type: "Tumblr", icon: "#{@social_icons_url}/tumblr.png"}],
      "https://twitter.com/asdf" => [%{url: "https://twitter.com/asdf", text: "twitter.com/asdf", type: "Twitter", icon: "#{@social_icons_url}/twitter.png"}],
      "https://vimeo.com/asdf" => [%{url: "https://vimeo.com/asdf", text: "vimeo.com/asdf", type: "Vimeo", icon: "#{@social_icons_url}/vimeo.png"}],
      "https://vine.co/asdf" => [%{url: "https://vine.co/asdf", text: "vine.co/asdf", type: "Vine", icon: "#{@social_icons_url}/vine.png"}],
      "https://vsco.co/asdf" => [%{url: "https://vsco.co/asdf", text: "vsco.co/asdf", type: "VSCO", icon: "#{@social_icons_url}/vsco.png"}],
      "https://www.youtube.com/user/asdf" => [%{url: "https://www.youtube.com/user/asdf", text: "www.youtube.com/user/asdf", type: "Youtube", icon: "#{@social_icons_url}/youtube.png"}],
      "https://www.youtube.com/channel/asdf" => [%{url: "https://www.youtube.com/channel/asdf", text: "www.youtube.com/channel/asdf", type: "Youtube", icon: "#{@social_icons_url}/youtube.png"}]
    }
  end

  test "links.json - returns an array of sanitized links and icon data" do
    Enum.each test_links, fn {link, link_data} ->
      assert render(LinkView, "links.json", %{links: link}) == link_data
    end
  end
end
