{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _} = Application.ensure_all_started(:ello_core)
ExUnit.start
Ecto.Adapters.SQL.Sandbox.mode(Ello.Core.Repo, :manual)
