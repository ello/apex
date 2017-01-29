defmodule Ello.V2.JsonSchema do
  alias ExJsonSchema.{
    Validator,
    Schema,
  }

  def validate_json(schema_name, json) do
    %{"$ref" => "https://ello.ninja/api/schema/#{schema_name}.json"}
    |> Schema.resolve()
    |> Validator.validate(json)
  end

  def resolve("https://ello.ninja/api/schema/" <> _ = url) do
    url
    |> HTTPoison.get!
    |> Map.get(:body)
    |> Poison.decode!
  end

  def resolve(name) do
    resolve("https://ello.ninja/api/schema/" <> name)
  end
end
