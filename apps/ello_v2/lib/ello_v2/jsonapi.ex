defmodule Ello.V2.JSONAPI do
  @moduledoc """
  Functions and behaviour to help render JSON API reponses in the V2 fashion.

  Use in a view to get rendering utilities.
  """

  defmacro __using__(_) do
    quote do
      import Ello.V2.JSONAPI
      @behaviour Ello.V2.JSONAPI

      #Default callbacks
      def attributes, do: []
      def computed_attributes, do: []
      def links(_, _), do: %{}

      defoverridable [attributes: 0, computed_attributes: 0, links: 2]
    end
  end

  @callback attributes() :: [atom]
  @callback computed_attributes() :: [atom]
  @callback links(struct, Plug.Conn.t) :: map

  import Phoenix.View, only: [render_many: 4, render_one: 4, render: 3]

  def json_response, do: %{}

  def render_resource(resp, _name, [], _view, _opts), do: resp
  def render_resource(resp, name, data, view, opts) when is_list(data) do
    Map.put(resp, name, p_render_many(data, view, template_name(view), opts))
  end
  def render_resource(resp, name, data, view, opts) do
    Map.put(resp, name, render_one(data, view, template_name(view), opts))
  end

  def include_linked(resp, _name, nil, _view, _opts), do: resp
  def include_linked(resp, _name, [], _view, _opts), do: resp
  def include_linked(resp, name, data, view, opts) when is_list(data) do
    data = data
           |> Enum.reject(&is_nil/1)
           |> Enum.uniq_by(&(&1.id))
    resp
    |> Map.put_new(:linked, %{})
    |> put_in([:linked, name], p_render_many(data, view, template_name(view), opts))
  end
  def include_linked(resp, name, data, view, opts) do
    resp
    |> Map.put_new(:linked, %{})
    |> put_in([:linked, name], render_one(data, view, template_name(view), opts))
  end

  defp template_name(view) do
    view
    |> Module.split
    |> List.last
    |> String.replace("View", "")
    |> Macro.underscore
    |> Kernel.<>(".json")
  end

  @doc """
  Render one representation of the current view's resource.

  Typically called from render/2 in the view when rendering.
  """
  def render_self(data, view, opts) do
    computed = Enum.reduce view.computed_attributes, %{}, fn(attr, resp) ->
      Map.put(resp, attr, apply(view, attr, [data, opts[:conn]]))
    end
    data
    |> Map.take(view.attributes)
    |> Map.put(:id, "#{data.id}")
    |> Map.merge(computed)
    |> Map.put(:links, view.links(data, opts[:conn]))
  end


  @doc """
  Like Phoenix.View.render_many/4, but parallelized.

  Only parallelized if collection is at least as big as the threshold setting.
  """
  def p_render_many(collection, view, template, assigns \\ %{})
  def p_render_many(collection, view, template, assigns) when is_list(assigns),
    do: p_render_many(collection, view, template, :maps.from_list(assigns))
  def p_render_many(collection, view, template, assigns) do
    if length(collection) < Application.get_env(:ello_v2, :parallel_render_threshold) do
      render_many(collection, view, template, assigns)
    else
      collection
      |> Enum.map(&Task.async(Phoenix.View, :render, [view, template, assign_model(assigns, view, &1)]))
      |> Enum.map(&Task.await/1)
    end
  end

  # Copied from Phoenix.View
  defp assign_model(assigns, view, model) do
    as = Map.get(assigns, :as) || view.__resource__
    Map.put(assigns, as, model)
  end

end
