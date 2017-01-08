defmodule IconType do
  def match(link) do
    cond do
      apple?(link)            -> icon_data(:apple)
      bandcamp?(link)         -> icon_data(:bandcamp)
      behance?(link)          -> icon_data(:behance)
      cargo_collective?(link) -> icon_data(:cargo_collective)
      dailymotion?(link)      -> icon_data(:dailymotion)
      deviantart?(link)       -> icon_data(:deviantart)
      dribbble?(link)         -> icon_data(:dribbble)
      ello?(link)             -> icon_data(:ello)
      etsy?(link)             -> icon_data(:etsy)
      facebook?(link)         -> icon_data(:facebook)
      fivehundred_px?(link)   -> icon_data(:fivehundred_px)
      flickr?(link)           -> icon_data(:flickr)
      github?(link)           -> icon_data(:github)
      goodreads?(link)        -> icon_data(:goodreads)
      google_play?(link)      -> icon_data(:google_play)
      google_plus?(link)      -> icon_data(:google_plus)
      instagram?(link)        -> icon_data(:instagram)
      linkedin?(link)         -> icon_data(:linkedin)
      medium?(link)           -> icon_data(:medium)
      mixcloud?(link)         -> icon_data(:mixcloud)
      model_mayhem?(link)     -> icon_data(:model_mayhem)
      patreon?(link)          -> icon_data(:patreon)
      persona?(link)          -> icon_data(:persona)
      pinterest?(link)        -> icon_data(:pinterest)
      shopify?(link)          -> icon_data(:shopify)
      snapchat?(link)         -> icon_data(:shopify)
      society6?(link)         -> icon_data(:society_six)
      soundcloud?(link)       -> icon_data(:soundcloud)
      threadless?(link)       -> icon_data(:threadless)
      tumblr?(link)           -> icon_data(:tumblr)
      twitter?(link)          -> icon_data(:twitter)
      vimeo?(link)            -> icon_data(:vimeo)
      vine?(link)             -> icon_data(:vine)
      vsco?(link)             -> icon_data(:vsco)
      youtube?(link)          -> icon_data(:youtube)
      true -> nil
    end
  end

  def apple?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?itunes\.apple\.com\/app\/apple-store\/([a-zA-Z0-9_]+)|appstore\.com\/([a-zA-Z0-9_]+)\/([a-zA-Z0-9_]+)/, link)
  end

  def bandcamp?(link) do
    Regex.match?(~r/((http(s?):\/\/)*([a-zA-Z0-9\-])*\.bandcamp)|bandcamp\.com\/([a-zA-Z0-9_]+)/, link)
  end

  def behance?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?behance\.net\/([a-zA-Z0-9_]+)|behance.net\/([a-zA-Z0-9_]+)/, link)
  end

  def cargo_collective?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?cargocollective\.com\/([a-zA-Z0-9_]+)|cargocollective.com\/([a-zA-Z0-9_]+)/, link)
  end

  def dailymotion?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?dailymotion\.com\/([a-zA-Z0-9_]+)|dailymotion.com\/([a-zA-Z0-9_]+)/, link)
  end

  def deviantart?(link) do
    Regex.match?(~r/[^"\/www\."](?<!w{3})[A-Za-z0-9]*(?=\.deviantart\.com)/, link)
  end

  def dribbble?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?dribbble\.com\/([a-zA-Z0-9_]+)|dribbble.com\/([a-zA-Z0-9_]+)/, link)
  end

  def ello?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?ello\.co\/([a-zA-Z0-9_]+)|ello.co\/([a-zA-Z0-9_]+)/, link)
  end

  def etsy?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?etsy\.com\/shop\/([a-zA-Z0-9_.-]+)/, link)
  end

  def facebook?(link) do
    Regex.match?(~r/(?:(?:http|https):\/\/)?(?:www.)?facebook.com\/(?:(?:\w)*#!\/)?(?:pages\/)?(?:[?\w\-]*\/)?(?:profile.php\?id=(?=\d.*))?([\w\-]*)?/, link)
  end

  def fivehundred_px?(link) do
    Regex.match?(~r/(?:(?:http|https):\/\/)?(?:www.)?facebook.com\/(?:(?:\w)*#!\/)?(?:pages\/)?(?:[?\w\-]*\/)?(?:profile.php\?id=(?=\d.*))?([\w\-]*)?/, link)
  end

  def flickr?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?flickr\.com\/photos\/([a-zA-Z0-9_.-]+)/, link)
  end

  def github?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?github\.com\/([a-zA-Z0-9_-]+)|github.com\/([a-zA-Z0-9_]+)/, link)
  end

  def goodreads?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?goodreads\.com\/user\/show\/([a-zA-Z0-9_.-]+)/, link)
  end

  def google_play?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?play\.google\.com\/store\/apps\/details\?id=([a-zA-Z0-9._]+)/, link)
  end

  def google_plus?(link) do
    Regex.match?(~r/http(?:s)?:\/\/plus\.google\.com\/([a-zA-Z0-9_+]+)|plus\.google\.com\/([a-zA-Z0-9_+]+)/, link)
  end

  def instagram?(link) do
    Regex.match?(~r/(?:(?:http|https):\/\/)?(?:www.)?(?:instagram.com|instagr.am)\/([A-Za-z0-9\-_]+)/, link)
  end

  def linkedin?(link) do
    Regex.match?(~r/^(http(s)?:\/\/)?([\w]+\.)?linkedin\.com\/(pub|in|profile)/, link)
  end

  def medium?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?medium\.com\/@([a-zA-Z0-9_.-]+)|medium\.com\/@([a-zA-Z0-9_.-]+)/, link)
  end

  def mixcloud?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?mixcloud\.com\/([a-zA-Z0-9_]+)|mixcloud\.com\/([a-zA-Z0-9_]+)/, link)
  end

  def model_mayhem?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?mixcloud\.com\/([a-zA-Z0-9_]+)|mixcloud\.com\/([a-zA-Z0-9_]+)/, link)
  end

  def patreon?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?patreon\.com\/([a-zA-Z0-9_-]+)|patreon\.com\/([a-zA-Z0-9_-]+)/, link)
  end

  def persona?(link) do
    Regex.match?(~r/[^"\/www\."](?<!w{3})[A-Za-z0-9]*(?=\.persona\.co)/, link)
  end

  def pinterest?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?pinterest\.com\/([a-zA-Z0-9_]+)|pinterest\.com\/([a-zA-Z0-9_]+)/, link)
  end

  def shopify?(link) do
    Regex.match?(~r/[^"\/www\."](?<!w{3})[A-Za-z0-9]*(?=\.myshopify\.com)/, link)
  end

  def snapchat?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?snapchat\.com\/add\/([a-zA-Z0-9_.-]+)/, link)
  end

  def society6?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?society6\.com\/([a-zA-Z0-9_]+)|society6\.com\/([a-zA-Z0-9_]+)/, link)
  end

  def soundcloud?(link) do
    Regex.match?(~r/^https?:\/\/(soundcloud\.com|snd\.sc)\/(.*)$/, link)
  end

  def threadless?(link) do
    Regex.match?(~r/[^"\/www\."](?<!w{3})[A-Za-z0-9]*(?=\.threadless\.com)/, link)
  end

  def tumblr?(link) do
    Regex.match?(~r/[^"\/www\."](?<!w{3})[A-Za-z0-9]*(?=\.tumblr\.com)/, link)
  end

  def twitter?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?twitter\.com\/([a-zA-Z0-9_]+)|twitter.com\/([a-zA-Z0-9_]+)/, link)
  end

  def vimeo?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?vimeo\.com\/([a-zA-Z0-9_]+)|vimeo\.com\/([a-zA-Z0-9_]+)/, link)
  end

  def vine?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?vine\.co\/([a-zA-Z0-9_]+)|vine.co\/([a-zA-Z0-9_]+)/, link)
  end

  def vsco?(link) do
    Regex.match?(~r/http(?:s)?:\/\/(?:www\.)?vsco\.co\/([a-zA-Z0-9_]+)|vsco.co\/([a-zA-Z0-9_]+)/, link)
  end

  def youtube?(link) do
    Regex.match?(~r/^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$/, link)
  end

  def icon_data(:apple), do: %{ type: "Apple Store", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/apple.png" }
  def icon_data(:bandcamp), do: %{ type: "Bandcamp", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/bandcamp.png" }
  def icon_data(:behance), do: %{ type: "Behance", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/behance.png" }
  def icon_data(:cargo_collective), do: %{ type: "Cargo Collective", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/cargo.png" }
  def icon_data(:dailymotion), do: %{ type: "Dailymotion", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/dailymotion.png" }
  def icon_data(:deviantart), do: %{ type: "Deviantart", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/deviantart.png" }
  def icon_data(:dribbble), do: %{ type: "Dribbble", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/dribbble.png" }
  def icon_data(:ello), do: %{ type: "Ello", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/ello.png" }
  def icon_data(:etsy), do: %{ type: "Etsy", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/etsy.png" }
  def icon_data(:facebook), do: %{ type: "Facebook", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/facebook.png" }
  def icon_data(:fivehundred_px), do: %{ type: "500px", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/500px.png" }
  def icon_data(:flickr), do: %{ type: "Flickr", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/flickr.png" }
  def icon_data(:github), do: %{ type: "Github", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/github.png" }
  def icon_data(:goodreads), do: %{ type: "Goodreads", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/goodreads.png" }
  def icon_data(:google_play), do: %{ type: "Google Play Store", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/play.png" }
  def icon_data(:google_plus), do: %{ type: "Google+", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/google_plus.png" }
  def icon_data(:instagram), do: %{ type: "Instagram", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/instagram.png" }
  def icon_data(:linkedin), do: %{ type: "Linkedin", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/linkedin.png" }
  def icon_data(:medium), do: %{ type: "Medium", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/medium.png" }
  def icon_data(:mixcloud), do: %{ type: "Mixcloud", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/mixcloud.png" }
  def icon_data(:model_mayhem), do: %{ type: "Model Mayhem", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/model_mayhem.png" }
  def icon_data(:patreon), do: %{ type: "Patreon", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/patreon.png" }
  def icon_data(:persona), do: %{ type: "Persona", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/persona.png" }
  def icon_data(:pinterest), do: %{ type: "Pinterest", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/pinterest.png" }
  def icon_data(:shopify), do: %{ type: "Shopify", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/shopify.png" }
  def icon_data(:snapchat), do: %{ type: "Snapchat", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/snapchat.png" }
  def icon_data(:society_six), do: %{ type: "Society6", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/society6.png" }
  def icon_data(:soundcloud), do: %{ type: "Soundcloud", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/soundcloud.png" }
  def icon_data(:threadless), do: %{ type: "Threadless", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/threadless.png" }
  def icon_data(:tumblr), do: %{ type: "Tumblr", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/tumblr.png" }
  def icon_data(:twitter), do: %{ type: "Twitter", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/twitter.png" }
  def icon_data(:vimeo), do: %{ type: "Vimeo", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/vimeo.png" }
  def icon_data(:vine), do: %{ type: "Vine", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/vine.png" }
  def icon_data(:vsco), do: %{ type: "VSCO", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/vsco.png" }
  def icon_data(:youtube), do: %{ type: "Youtube", icon: "#{System.get_env("SOCIAL_ICONS_URL")}/youtube.png" }
end
