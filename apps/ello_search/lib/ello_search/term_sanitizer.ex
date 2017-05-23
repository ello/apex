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

  def sanitize(%{terms: nil}),   do: ""
  def sanitize(%{terms: ""}),    do: ""
  def sanitize(%{terms: terms}), do: String.replace(terms, regex(), "")
end

