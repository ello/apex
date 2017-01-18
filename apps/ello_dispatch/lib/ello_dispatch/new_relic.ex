defmodule Ello.Dispatch.NewRelic do
  alias Phoenix.Controller
  alias Discorelic.Tracker

  def phoenix_controller_call(:start, _compile_meta_data, %{conn: conn}) do
    controller = Controller.controller_module(conn)
    action = Controller.action_name(conn)
    name = "/#{controller}##{action}"
    Tracker.init_transaction(name)
  end

  def phoenix_controller_call(:stop, _time_diff, tracker) do
    Tracker.publish(tracker)
  end

  # The next version of phoenix should have conn available here
  # That would enable us to add a "view rendering" segment to our trace.
  # def phoenix_controller_render(:start, compile_time, run_time) do
  # end

  # def phoenix_controller_render(:stop, time_diff, results) do
  # end
end
