defmodule Ello.Search.TermSanitizer.Regex do
  defmacro __before_compile__(_) do
    expression = "lib/ello_search/nsfw_stopwords.txt"
                 |> File.read!
                 |> String.split
                 |> Enum.map(&("(\\b|#)?#{&1}\\b"))
                 |> Enum.join("|")

    {:ok, compiled_regex} = Regex.compile(expression)

    quote do
      def regex, do: unquote(Macro.escape(compiled_regex))
    end
  end
end

defmodule Ello.Search.TermSanitizer do
  @before_compile Ello.Search.TermSanitizer.Regex

  def sanitize(%{terms: nil} = search),       do: %{search | terms: ""}
  def sanitize(%{terms: ""} = search),        do: %{search | terms: ""}
  def sanitize(%{allow_nsfw: true} = search), do: search
  def sanitize(%{terms: terms} = search),
    do: %{search | terms: String.replace(terms, regex(), "")}
end

