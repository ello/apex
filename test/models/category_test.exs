defmodule Ello.CategoryTest do
  use Ello.ModelCase

  alias Ello.Category

  @valid_attrs %{level: "some content", name: "some content", order: 42, slug: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Category.changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end
end
