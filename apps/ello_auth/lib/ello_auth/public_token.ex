defmodule Ello.Auth.PublicToken do
  @moduledoc """
  Retreives and manages public tokens.
  """
  use GenServer
  alias __MODULE__.Client

  @table :public_token_bucket

  ## Client

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end


  @doc """
  Fetch a token given the client id and secret.

  Returns from ETS immediately if present and unexpired.

  If expired or missing the singleton gen server will be called to
  request a new token.
  """
  def fetch(client_id, client_secret) do
    case fetch_from_ets(client_id, client_secret) do
      {:ok, token} -> token
      _ -> fetch_from_server(client_id, client_secret)
    end
  end

  defp fetch_from_server(id, secret) do
    GenServer.call(__MODULE__, {:fetch_from_server, id, secret})
  end

  defp fetch_from_ets(id, secret) do
    with [{_, token}] <- :ets.lookup(@table, {id, secret}),
         false <- expired?(token) do
      {:ok, token}
    else
      [] ->   :token_not_found
      true -> :expired_token
    end
  end

  defp expired?(%{"expires_in" => expires_in, "created_at" => created_at}) do
    (created_at + expires_in) <= DateTime.to_unix(DateTime.utc_now)
  end

  ## Server

  def init(_) do
    :ets.new(@table, [:named_table])
    {:ok, %{}}
  end

  def handle_call({:fetch_from_server, id, secret}, _from, state) do
    # check ETS again - make sure token hasn't been updated
    case fetch_from_ets(id, secret) do
      {:ok, token} -> {:reply, token, state}
      _ ->
        {:ok, token} = client().fetch_token(id, secret)
        :ets.insert(@table, {{id, secret}, token})
        {:reply, token, state}
    end
  end

  defp client() do
    Application.get_env(:ello_auth, :http_client, Client)
  end
end
