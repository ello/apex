defmodule Ello.Core.FactoryTime do
  def now do
    DateTime.utc_now |> DateTime.truncate(:second)
  end

  def now_offset(seconds) do
    now()
    |> DateTime.to_unix
    |> Kernel.+(seconds * 1000)
    |> DateTime.from_unix!
  end
end
