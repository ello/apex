defmodule Ello.V2.LinkViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.LinkView

  @social_icons_host Application.get_env(:ello_v2, :social_icons_host)

  @test_links %{
      "appstore.com/asdf/asdf" => [%{url: "http://appstore.com/asdf/asdf", text: "appstore.com/asdf/asdf", type: "Apple Store", icon: "https://#{@social_icons_host}/apple.png"}],
      "https://itunes.apple.com/app/apple-store/asdf" => [%{url: "https://itunes.apple.com/app/apple-store/asdf", text: "itunes.apple.com/app/apple-store/asdf", type: "Apple Store", icon: "https://#{@social_icons_host}/apple.png"}],
      "https://asdfband.bandcamp.com" => [%{url: "https://asdfband.bandcamp.com", text: "asdfband.bandcamp.com", type: "Bandcamp", icon: "https://#{@social_icons_host}/bandcamp.png"}],
      "https://bandcamp.com/asdf" => [%{url: "https://bandcamp.com/asdf", text: "bandcamp.com/asdf", type: "Bandcamp", icon: "https://#{@social_icons_host}/bandcamp.png"}],
      "https://www.behance.net/asdf" => [%{url: "https://www.behance.net/asdf", text: "www.behance.net/asdf", type: "Behance", icon: "https://#{@social_icons_host}/behance.png"}],
      "http://cargocollective.com/asdf" => [%{url: "http://cargocollective.com/asdf", text: "cargocollective.com/asdf", type: "Cargo Collective", icon: "https://#{@social_icons_host}/cargo.png"}],
      "https://dailymotion.com/asdf" => [%{url: "https://dailymotion.com/asdf", text: "dailymotion.com/asdf", type: "Dailymotion", icon: "https://#{@social_icons_host}/dailymotion.png"}],
      "asdf.deviantart.com" => [%{url: "http://asdf.deviantart.com", text: "asdf.deviantart.com", type: "Deviantart", icon: "https://#{@social_icons_host}/deviantart.png"}],
      "https://dribbble.com/asdf" => [%{url: "https://dribbble.com/asdf", text: "dribbble.com/asdf", type: "Dribbble", icon: "https://#{@social_icons_host}/dribbble.png"}],
      "ello.co/asdf" => [%{url: "http://ello.co/asdf", text: "ello.co/asdf", type: "Ello", icon: "https://#{@social_icons_host}/ello.png"}],
      "https://www.etsy.com/shop/asdf" => [%{url: "https://www.etsy.com/shop/asdf", text: "www.etsy.com/shop/asdf", type: "Etsy", icon: "https://#{@social_icons_host}/etsy.png"}],
      "https://www.facebook.com/asdf" => [%{url: "https://www.facebook.com/asdf", text: "www.facebook.com/asdf", type: "Facebook", icon: "https://#{@social_icons_host}/facebook.png"}],
      "https://www.facebook.com/pages/asdf" => [%{url: "https://www.facebook.com/pages/asdf", text: "www.facebook.com/pages/asdf", type: "Facebook", icon: "https://#{@social_icons_host}/facebook.png"}],
      "https://500px.com/asdf" => [%{url: "https://500px.com/asdf", text: "500px.com/asdf", type: "500px", icon: "https://#{@social_icons_host}/500px.png"}],
      "https://www.flickr.com/photos/asdf" => [%{url: "https://www.flickr.com/photos/asdf", text: "www.flickr.com/photos/asdf", type: "Flickr", icon: "https://#{@social_icons_host}/flickr.png"}],
      "https://www.github.com/asdf" => [%{url: "https://www.github.com/asdf", text: "www.github.com/asdf", type: "Github", icon: "https://#{@social_icons_host}/github.png"}],
      "https://www.goodreads.com/user/show/asdf" => [%{url: "https://www.goodreads.com/user/show/asdf", text: "www.goodreads.com/user/show/asdf", type: "Goodreads", icon: "https://#{@social_icons_host}/goodreads.png"}],
      "https://play.google.com/store/apps/details?id=asdf" => [%{url: "https://play.google.com/store/apps/details?id=asdf", text: "play.google.com/store/apps/details?id=asdf", type: "Google Play Store", icon: "https://#{@social_icons_host}/play.png"}],
      "https://plus.google.com/+asdf" => [%{url: "https://plus.google.com/+asdf", text: "plus.google.com/+asdf", type: "Google+", icon: "https://#{@social_icons_host}/google_plus.png"}],
      "https://www.instagram.com/asdf-" => [%{url: "https://www.instagram.com/asdf-", text: "www.instagram.com/asdf-", type: "Instagram", icon: "https://#{@social_icons_host}/instagram.png"}],
      "https://www.linkedin.com/in/asdf" => [%{url: "https://www.linkedin.com/in/asdf", text: "www.linkedin.com/in/asdf", type: "Linkedin", icon: "https://#{@social_icons_host}/linkedin.png"}],
      "https://www.medium.com/@asdf" => [%{url: "https://www.medium.com/@asdf", text: "www.medium.com/@asdf", type: "Medium", icon: "https://#{@social_icons_host}/medium.png"}],
      "https://www.mixcloud.com/asdf/" => [%{url: "https://www.mixcloud.com/asdf/", text: "www.mixcloud.com/asdf/", type: "Mixcloud", icon: "https://#{@social_icons_host}/mixcloud.png"}],
      "www.modelmayhem.com/asdf" => [%{url: "http://www.modelmayhem.com/asdf", text: "www.modelmayhem.com/asdf", type: "Model Mayhem", icon: "https://#{@social_icons_host}/model_mayhem.png"}],
      "https://www.patreon.com/asdf" => [%{url: "https://www.patreon.com/asdf", text: "www.patreon.com/asdf", type: "Patreon", icon: "https://#{@social_icons_host}/patreon.png"}],
      "https://asdf.persona.co/" => [%{url: "https://asdf.persona.co/", text: "asdf.persona.co/", type: "Persona", icon: "https://#{@social_icons_host}/persona.png"}],
      "https://www.pinterest.com/asdf/" => [%{url: "https://www.pinterest.com/asdf/", text: "www.pinterest.com/asdf/", type: "Pinterest", icon: "https://#{@social_icons_host}/pinterest.png"}],
      "http://asdf.myshopify.com/" => [%{url: "http://asdf.myshopify.com/", text: "asdf.myshopify.com/", type: "Shopify", icon: "https://#{@social_icons_host}/shopify.png"}],
      "https://www.snapchat.com/add/asdf" => [%{url: "https://www.snapchat.com/add/asdf", text: "www.snapchat.com/add/asdf", type: "Snapchat", icon: "https://#{@social_icons_host}/snapchat.png"}],
      "https://society6.com/asdf" => [%{url: "https://society6.com/asdf", text: "society6.com/asdf", type: "Society6", icon: "https://#{@social_icons_host}/society6.png"}],
      "https://soundcloud.com/asdf" => [%{url: "https://soundcloud.com/asdf", text: "soundcloud.com/asdf", type: "Soundcloud", icon: "https://#{@social_icons_host}/soundcloud.png"}],
      "https://asdf.threadless.com/" => [%{url: "https://asdf.threadless.com/", text: "asdf.threadless.com/", type: "Threadless", icon: "https://#{@social_icons_host}/threadless.png"}],
      "asdf.tumblr.com" => [%{url: "http://asdf.tumblr.com", text: "asdf.tumblr.com", type: "Tumblr", icon: "https://#{@social_icons_host}/tumblr.png"}],
      "https://twitter.com/asdf" => [%{url: "https://twitter.com/asdf", text: "twitter.com/asdf", type: "Twitter", icon: "https://#{@social_icons_host}/twitter.png"}],
      "https://vimeo.com/asdf" => [%{url: "https://vimeo.com/asdf", text: "vimeo.com/asdf", type: "Vimeo", icon: "https://#{@social_icons_host}/vimeo.png"}],
      "https://vine.co/asdf" => [%{url: "https://vine.co/asdf", text: "vine.co/asdf", type: "Vine", icon: "https://#{@social_icons_host}/vine.png"}],
      "https://vsco.co/asdf" => [%{url: "https://vsco.co/asdf", text: "vsco.co/asdf", type: "VSCO", icon: "https://#{@social_icons_host}/vsco.png"}],
      "https://www.youtube.com/user/asdf" => [%{url: "https://www.youtube.com/user/asdf", text: "www.youtube.com/user/asdf", type: "Youtube", icon: "https://#{@social_icons_host}/youtube.png"}],
      "https://www.youtube.com/channel/asdf" => [%{url: "https://www.youtube.com/channel/asdf", text: "www.youtube.com/channel/asdf", type: "Youtube", icon: "https://#{@social_icons_host}/youtube.png"}]
    }

  test "links.json - returns an array of sanitized links and icon data" do
    Enum.each @test_links, fn {link, link_data} ->
      assert render(LinkView, "links.json", %{links: link}) == link_data
    end
  end
end
