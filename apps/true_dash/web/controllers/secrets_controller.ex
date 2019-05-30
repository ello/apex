defmodule TH.TrueDash.SecretsController do
  use TH.TrueDash.Web, :controller

  def index(conn, _) do
    json(conn, %{
      twitter: %{
        auth: "QzgydnU2TWpkMlUxOUhtVzR6a1g2UTpqZDlxMTY5WXJHYTBlc3J5eEdzRUVGTENjaTl0ZncxanBmS2RwZEQ2Yw==",
        key: "C82vu6Mjd2U19HmW4zkX6Q",
        secret: "jd9q169YrGa0esryxGsEEFLCci9tfw1jpfKdpdD6c",
      },
      bitly: %{
        auth: "Nzc0YmY5MzkxYmI5M2NkOGQ2ZTI4NjJjNDkwMTM3YmE4NTU2YTNhYjpjOTg2MDAwODQ1NTc4NzE5MzZhOGEwYzA3NjYwZmMyMGVkZGQ1ODg4",
        },
      })
  end
end
