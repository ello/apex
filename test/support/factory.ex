defmodule Ello.Factory do
  use ExMachina.Ecto, repo: Ello.Repo

  def user_factory do
    %Ello.User{
      username:   sequence(:username, &"username#{&1}"),
      email:      sequence(:user_email, &"user-#{&1}@example.com"),
      email_hash: sequence(:user_email_hash, &"emailhash#{&1}"),
      settings:   %Ello.User.Settings{},

      created_at: Ecto.DateTime.utc,
      updated_at: Ecto.DateTime.utc,
    }
  end

  def category_factory do
    %Ello.Category{

      created_at: Ecto.DateTime.utc,
      updated_at: Ecto.DateTime.utc,
    }
  end

  def promotional_factory do
    %Ello.Promotional{
      image: "ello-optimized-da955f87.jpg",
      image_metadata: %{},
      user: build(:user),
      created_at: Ecto.DateTime.utc,
      updated_at: Ecto.DateTime.utc,
    }
  end

  def relationship_factory do
    %Ello.Relationship{

    }
  end

  defmodule Script do
    use ExMachina.Ecto, repo: Ello.Repo

    def archer_factory do
      %Ello.User{
        id: 42,
        username: "archer",
        name: "Sterling Archer",
        email: "archer@ello.co",
        email_hash: "archerelloco",
        bad_for_seo?: false,
        location: "New York, NY",
        background_position: "50% 50%",
        avatar: "ello-2274bdfe-57d8-4499-ba67-a7c003d5a962.png",
        avatar_metadata: %{
          "large" => %{
            "size" => 220669,
            "type" => "image/png",
            "width" => 360,
            "height" => 360
          },
          "regular" => %{
            "size" => 36629,
            "type" => "image/png",
            "width" => 120,
            "height" => 120
          },
          "small" => %{
            "size" => 17753,
            "type" => "image/png",
            "width" => 60,
            "height" => 60
          }
        },
        cover_image: "ello-e76606cf-44b0-48b5-9918-1efad8e0272c.jpeg",
        cover_image_metadata: %{
          "optimized" => %{
            "size" => 1177127,
            "type" => "image/jpeg",
            "width" => 1880,
            "height" => 1410
          },
          "xhdpi" => %{
            "size" => 582569,
            "type" => "image/jpeg",
            "width" => 1116,
            "height" => 837
          },
          "hdpi" => %{
            "size" => 150067,
            "type" => "image/jpeg",
            "width" => 552,
            "height" => 414
          },
          "mdpi" => %{
            "size" => 40106,
            "type" => "image/jpeg",
            "width" => 276,
            "height" => 207
          },
          "ldpi" => %{
            "size" => 10872,
            "type" => "image/jpeg",
            "width" => 132,
            "height" => 99
          }
        },
        settings: %Ello.User.Settings{
          views_adult_content: true,
        }
      }
    end


    def featured_category_factory do
      %Ello.Category{
        name: "Featured",
        slug: "featured",
        cta_caption: nil,
        cta_href: nil,
        description: nil,
        is_sponsored: false,
        level: "meta",
        order: 0,
        uses_page_promotionals: true,
        created_at: Ecto.DateTime.utc,
        updated_at: Ecto.DateTime.utc,
      }
    end

    def espionage_category_factory do
      %Ello.Category{
        name: "Espionage",
        slug: "espionage",
        cta_caption: nil,
        cta_href: nil,
        description: "All things spying related",
        is_sponsored: false,
        level: nil,
        order: 0,
        uses_page_promotionals: false,
        created_at: Ecto.DateTime.utc,
        updated_at: Ecto.DateTime.utc,
        promotionals: [],
      }
    end

    def lacross_category_factory do
      %Ello.Category{
        name: "Lacross",
        slug: "lacross",
        cta_caption: nil,
        cta_href: nil,
        description: "All things lacross related",
        is_sponsored: false,
        level: "Primary",
        order: 0,
        uses_page_promotionals: false,
        created_at: Ecto.DateTime.utc,
        updated_at: Ecto.DateTime.utc,
        tile_image: "ello-optimized-8bcedb76.jpg",
        tile_image_metadata: %{
          "large" => %{
            "size"   => 855144,
            "type"   => "image/png",
            "width"  => 1000,
            "height" => 1000
          },
          "regular" => %{
            "size"   => 556821,
            "type"   => "image/png",
            "width"  => 800,
            "height" => 800
          },
          "small" => %{
            "size"   => 126225,
            "type"   => "image/png",
            "width"  => 360,
            "height" => 360
          },
        },
        promotionals: [Ello.Factory.build(:promotional)]
      }
    end
  end
end
