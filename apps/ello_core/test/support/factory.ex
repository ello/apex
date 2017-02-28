defmodule Ello.Core.Factory do
  alias Ello.Core.{Repo, Discovery, Network, Content}
  alias Discovery.{Category, Promotional}
  alias Network.{User, Relationship}
  alias Content.{Post, Love, Watch, Asset}
  use ExMachina.Ecto, repo: Repo

  def user_factory do
    %User{
      username:   sequence(:username, &"username#{&1}"),
      email:      sequence(:user_email, &"user-#{&1}@example.com"),
      email_hash: sequence(:user_email_hash, &"emailhash#{&1}"),
      settings:   %User.Settings{},

      created_at: DateTime.utc_now,
      updated_at: DateTime.utc_now,
    } |> User.load_images
  end

  def settings_factory do
    %User.Settings{}
  end

  def post_factory do
    %Post{
      author:    build(:user),
      token:     sequence(:post_token, &"testtoken#{&1}wouldberandom"),
      seo_title: "test post",
      is_adult_content: false,
      is_disabled: false,
      has_nudity: false,
      is_saleable: false,
      loves_count: 1,
      comments_count: 2,
      reposts_count: 3,
      views_count: 4_123,
      body: [%{"kind" => "text", "data" => "Phrasing!"}],
      rendered_content: [%{
                           "kind" => "text",
                           "data" => "<p>Phrasing!</p>",
                           "link_url" => nil
                         }],
      rendered_summary: [%{
                           "kind" => "text",
                           "data" => "<p>Phrasing!</p>",
                           "link_url" => nil
                         }],
      created_at: DateTime.utc_now,
      updated_at: DateTime.utc_now,
    }
  end

  @doc "add 2 assets to a post"
  def add_assets(%Post{} = post) do
    add_assets(post, [insert(:asset, post: post), insert(:asset, post: post)])
  end

  @doc "add given assets to a post"
  def add_assets(%Post{body: body} = post, assets) do
    new_bodies = Enum.map assets, fn(%{id: id}) ->
      %{"kind" => "image", "data" => %{asset_id: id, url: "skipped"}}
    end

    post
    |> Ecto.Changeset.change(body: new_bodies ++ body)
    |> Repo.update!
    |> Repo.preload(:assets)
  end

  def repost_factory do
    post_factory()
    |> Map.merge(%{
      reposted_source: build(:post)
    })
  end

  def asset_factory do
    %Asset{
      user: build(:user),
      post: build(:post),
      attachment: "ello-a9c0ede1-aeca-45af-9723-5750babf541e.jpeg",
      attachment_metadata: %{
        "optimized" => %{"size"=>433_286, "type"=>"image/jpeg", "width"=>1_280, "height"=>1_024},
        "xhdpi" => %{"size"=>434_916, "type"=>"image/jpeg", "width"=>1_280, "height"=>1_024},
        "hdpi" => %{"size"=>287_932, "type"=>"image/jpeg", "width"=>750, "height"=>600},
        "mdpi" => %{"size"=>77_422, "type"=>"image/jpeg", "width"=>375, "height"=>300},
        "ldpi" => %{"size"=>19_718, "type"=>"image/jpeg", "width"=>180, "height"=>144}
      },
      created_at: DateTime.utc_now,
      updated_at: DateTime.utc_now,
    }
  end

  def love_factory do
    %Love{
      user: build(:user),
      post: build(:post),
      created_at: DateTime.utc_now,
      updated_at: DateTime.utc_now,
    }
  end

  def watch_factory do
    %Watch{
      user: build(:user),
      post: build(:post),
      created_at: DateTime.utc_now,
      updated_at: DateTime.utc_now,
    }
  end

  def comment_factory do
    post_factory()
    |> Map.merge(%{
      parent_post: build(:post)
    })
  end

  def category_factory do
    %Category{
      name:        sequence(:category_name, &"category#{&1}"),
      slug:        sequence(:category_slug, &"category#{&1}"),
      description: "Posts about this categories",
      is_sponsored: false,
      level:       "Primary",
      order:        Enum.random(0..10),
      promotionals: [build(:promotional)],
      created_at:   DateTime.utc_now,
      updated_at:   DateTime.utc_now,
    } |> Category.load_images
  end

  def promotional_factory do
    %Promotional{
      image: "ello-optimized-da955f87.jpg",
      image_metadata: %{},
      user: build(:user),
      created_at: DateTime.utc_now,
      updated_at: DateTime.utc_now,
    } |> Promotional.load_images
  end

  def relationship_factory do
    %Relationship{
      priority: "friend",
      owner:    build(:user),
      subject:  build(:user),
    }
  end

  defmodule Script do
    use ExMachina.Ecto, repo: Repo

    def archer_factory do
      %User{
        id: 42,
        username: "archer",
        name: "Sterling Archer",
        email: "archer@ello.co",
        email_hash: "archerelloco",
        bad_for_seo?: false,
        location: "New York, NY",
        background_position: "50% 50%",
        short_bio: "I have been spying for a while now",
        formatted_short_bio: "<p>I have been spying for a while now</p>",
        links: "http://www.twitter.com/ArcherFX",
        rendered_links: [
          %{"url"=>"http://www.twitter.com/ArcherFX",
            "text"=>"twitter.com/ArcherFX",
            "type"=>"Twitter",
            "icon"=>"https://social-icons.ello.co/twitter.png"},
        ],
        avatar: "ello-2274bdfe-57d8-4499-ba67-a7c003d5a962.png",
        avatar_metadata: %{
          "large" => %{
            "size" => 220_669,
            "type" => "image/png",
            "width" => 360,
            "height" => 360
          },
          "regular" => %{
            "size" => 36_629,
            "type" => "image/png",
            "width" => 120,
            "height" => 120
          },
          "small" => %{
            "size" => 17_753,
            "type" => "image/png",
            "width" => 60,
            "height" => 60
          }
        },
        cover_image: "ello-e76606cf-44b0-48b5-9918-1efad8e0272c.jpeg",
        cover_image_metadata: %{
          "optimized" => %{
            "size" => 1_177_127,
            "type" => "image/jpeg",
            "width" => 1_880,
            "height" => 1_410
          },
          "xhdpi" => %{
            "size" => 582_569,
            "type" => "image/jpeg",
            "width" => 1_116,
            "height" => 837
          },
          "hdpi" => %{
            "size" => 150_067,
            "type" => "image/jpeg",
            "width" => 552,
            "height" => 414
          },
          "mdpi" => %{
            "size" => 40_106,
            "type" => "image/jpeg",
            "width" => 276,
            "height" => 207
          },
          "ldpi" => %{
            "size" => 10_872,
            "type" => "image/jpeg",
            "width" => 132,
            "height" => 99
          }
        },
        settings: %User.Settings{
          views_adult_content: true,
        }
      } |> User.load_images
    end


    def featured_category_factory do
      %Category{
        name: "Featured",
        slug: "featured",
        cta_caption: nil,
        cta_href: nil,
        description: nil,
        is_sponsored: false,
        level: "meta",
        order: 0,
        uses_page_promotionals: true,
        created_at: DateTime.utc_now,
        updated_at: DateTime.utc_now,
      } |> Category.load_images
    end

    def espionage_category_factory do
      %Category{
        id: 100_000,
        name: "Espionage",
        slug: "espionage",
        cta_caption: nil,
        cta_href: nil,
        description: "All things spying related",
        is_sponsored: false,
        level: nil,
        order: 0,
        uses_page_promotionals: false,
        created_at: DateTime.utc_now,
        updated_at: DateTime.utc_now,
        promotionals: [],
      } |> Category.load_images
    end

    def lacross_category_factory do
      %Category{
        id: 100_001,
        name: "Lacross",
        slug: "lacross",
        cta_caption: nil,
        cta_href: nil,
        description: "All things lacross related",
        is_sponsored: false,
        level: "Primary",
        order: 0,
        uses_page_promotionals: false,
        created_at: DateTime.utc_now,
        updated_at: DateTime.utc_now,
        tile_image: "ello-optimized-8bcedb76.jpg",
        tile_image_metadata: %{
          "large" => %{
            "size"   => 855_144,
            "type"   => "image/png",
            "width"  => 1_000,
            "height" => 1_000
          },
          "regular" => %{
            "size"   => 556_821,
            "type"   => "image/png",
            "width"  => 800,
            "height" => 800
          },
          "small" => %{
            "size"   => 126_225,
            "type"   => "image/png",
            "width"  => 360,
            "height" => 360
          },
        },
        promotionals: [Ello.Core.Factory.build(:promotional)]
      } |> Category.load_images
    end
  end
end
