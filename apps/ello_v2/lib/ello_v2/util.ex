defmodule Ello.V2.Util do

  @billion 1_000_000_000
  @million 1_000_000
  @thousand 1_000

  def number_to_human(number, rounding \\ 2)
  def number_to_human(nil, _), do: ""
  def number_to_human(number, rounding) do
    rounding_factor = :math.pow(10, rounding) |> round

    {divisor, suffix} =
      cond do
        number >= @billion  -> {@billion, "B"}
        number >= @million  -> {@million, "M"}
        number >= @thousand -> {@thousand, "K"}
        true                -> {1, ""}
      end

    rounded_number = round(number / divisor * rounding_factor) / rounding_factor
    str = "#{rounded_number}"
    [int_str | [decimal]] = String.split(str, ".")

    if decimal == "0" do
      "#{int_str}#{suffix}"
    else
      "#{str}#{suffix}"
    end
  end

end
