defmodule Ello.Search.TermSanitizer.Regex do
  defmacro __before_compile__(_) do
    expression = "lib/nsfw_stopwords.txt"
                 |> File.read!
                 |> String.split
                 |> Enum.map(&("\\b#?#{&1}\\b"))
                 |> Enum.join("|")

    regex = Regex.compile(expression)

    quote do
      @regex unquote(regex)
    end
  end
end

defmodule Ello.Search.TermSanitizer do
  @before_compile Ello.Search.TermSanitizer.Regex

  def sanitize(terms), do: String.replace(terms, @regex, "") #@regex, "")
end

