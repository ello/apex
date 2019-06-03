defmodule Ello.V3.Plug.NewRelic do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    # 2019-05-07 - the 'newrelic' repo has out of date dependencies, disabling
    # newrelic until we have bandwidth to update our code, maybe to new_relic
    # NewRelicPhoenix.start_transaction("/graphql#unknown")
    register_before_send conn, fn(outgoing_conn) ->
      # NewRelicPhoenix.finish_transaction()
      outgoing_conn
    end
  end
end
