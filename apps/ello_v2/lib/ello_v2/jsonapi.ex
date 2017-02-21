defmodule Ello.V2.JSONAPI do
  @moduledoc """
  Functions to help render JSON API reponses in the V2 fashion.

  Included by default in V2 views.
  """

  import Phoenix.View, only: [render_many: 4, render_one: 4]

  def json_response, do: %{}

  def render_resource(resp, _name, [], _view, _opts), do: resp
  def render_resource(resp, name, data, view, opts) when is_list(data) do
    Map.put(resp, name, render_many(data, view, template_name(view), opts))
  end
  def render_resource(resp, name, data, view, opts) do
    Map.put(resp, name, render_one(data, view, template_name(view), opts))
  end

  def include_resource(resp, _name, [], _view, _opts), do: resp
  def include_resource(resp, name, data, view, opts) when is_list(data) do
    data = Enum.uniq_by(data, &(&1.id))
    resp
    |> Map.put_new(:linked, %{})
    |> put_in([:linked, name], render_many(data, view, template_name(view), opts))
  end
  def include_resource(resp, name, data, view, opts) do
    resp
    |> Map.put_new(:linked, %{})
    |> put_in([:linked, name], render_one(data, view, template_name(view), opts))
  end

  defp template_name(view) do
    view
    |> Atom.to_string
    |> String.split(".")
    |> Enum.reverse
    |> hd
    |> String.replace("View", "")
    |> Macro.underscore
    |> Kernel.<>(".json")
  end

  def render_self(data, view, opts) do
    computed_attributes = Enum.reduce view.computed_attributes, %{}, fn(attr, resp) ->
      Map.put(resp, attr, apply(view, attr, [data, opts[:conn]]))
    end
    data
    |> Map.take(view.attributes)
    |> Map.put(:id, "#{data.id}")
    |> Map.merge(computed_attributes)
    |> Map.put(:links, view.links(data, opts[:conn]))
  end

end
