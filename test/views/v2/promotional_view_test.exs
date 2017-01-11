defmodule Ello.V2.PromotionalViewTest do
  use Ello.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.PromotionalView

  test "promotional.json - it renders with an image" do
    expected = %{
      id: "41",
      category_id: "2",
      user_id: "1",
      links: %{
        user: %{
          href: "/api/v2/users/1",
          id: "1",
          type: "users",
        },
      },
      image: %{
        "hdpi" => %{
          "metadata" => %{"height" => 414, "size" => 93161, "type" => "image/jpeg", "width" => 414},
          "url" => "https://assets.ello.co/uploads/promotional/image/41/ello-hdpi-01c119b5.jpg"
        },
        "optimized" => %{
          "metadata" => %{"height" => 800, "size" => 266621, "type" => "image/jpeg", "width" => 800},
          "url" => "https://assets.ello.co/uploads/promotional/image/41/ello-optimized-01c119b5.jpg"
        },
        "original" => %{
          "url" => "https://assets.ello.co/uploads/promotional/image/41/ello-optimized-da955f87.jpg"
        },
        "xhdpi" => %{
          "metadata" => %{"height" => 800, "size" => 267149, "type" => "image/jpeg", "width" => 800},
          "url" => "https://assets.ello.co/uploads/promotional/image/41/ello-xhdpi-01c119b5.jpg"
        }
      }
    }
    assert render(PromotionalView, "promotional.json", promotional: promo) == expected
  end

  def promo do
    Factory.build(:promotional, %{
      id: 41,
      category_id: 2,
      user_id: 1,
      image: "ello-optimized-da955f87.jpg",
      image_metadata: %{
        "optimized" => %{
          "size"   => 266621,
          "type"   => "image/jpeg",
          "width"  => 800,
          "height" => 800,
        },
        "xhdpi" => %{
          "size"   => 267149,
          "type"   => "image/jpeg",
          "width"  => 800,
          "height" => 800,
        },
        "hdpi" => %{
          "size"   => 93161,
          "type"   => "image/jpeg",
          "width"  => 414,
          "height" => 414,
        }
      },
    })
  end
end
