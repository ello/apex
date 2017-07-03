defmodule Ello.Serve.VersionStore.SlackNotifications do

  def new_version("webapp", ver) do
    Task.async fn ->
      notify_slack(%{
        text: "New version of `webapp` available: #{version_link(ver)}",
        attachments: [
          %{
            title: "Compare",
            text: """
            Compare to the active version in each env:
            #{compare_link(ver, "stage1")} #{compare_link(ver, "stage2")} #{compare_link(ver, "ninja")} #{compare_link(ver, "rainbow")} #{compare_link(ver, "production")}
            """,
            color: "#0366d6",
          },
          %{
            title: "Preview",
            text: """
            Previews are available only by accessing the app with the url with the version link. You will continue seeing the preview version until you refresh.
            You may preview in any environment:
            <https://ello-fg-stage1.herokuapp.com?version=#{ver}|stage1> <https://ello-fg-stage2.herokuapp.com?version=#{ver}|stage2> <https://ello.ninja?version=#{ver}|ninja> <https://ello-fg-rainbow.herokuapp.com?version=#{ver}|rainbow> <https://ello.co?version=#{ver}|production>
            """,
            color: "good",
          },
          %{
            title: "Publish",
            text: "Publishing makes this version of webapp active for all users visiting the environment.\n\nPublish with caution.",
            color: "warning",
            callback_id: "publish:webapp",
            actions: [
              %{
                name: "stage1",
                text: "stage1",
                value: ver,
                type: "button"
              },
              %{
                name: "stage2",
                text: "stage2",
                value: ver,
                type: "button"
              },
              %{
                name: "ninja",
                text: "ninja",
                value: ver,
                type: "button"
              },
              %{
                name: "rainbow",
                text: "rainbow",
                value: ver,
                type: "button"
              },
              %{
                name: "production",
                text: "production",
                value: ver,
                style: "danger",
                type: "button",
                confirm: %{
                  title: "Are you sure?",
                  text: "Publishing this version will push it to production for all users.",
                  ok_text: "I got this",
                  dismiss_text: "Nope."
                }
              },
            ]
          }
        ]
      })
    end
  end

  def version_activated("webapp", ver, env, nil) do
    Task.async fn ->
      notify_slack(%{
        attachments: [
          %{
            title: "New version published for all users on #{env}.",
            text:  "Version #{version_link(ver)}",
            color: "good",
          }
        ]
      })
    end
  end

  def version_activated("webapp", ver, env, previous) do
    Task.async fn ->
      notify_slack(%{
        attachments: [
          %{
            title: "New version published for all users on #{env}.",
            text:  "Version #{version_link(ver)}",
            color: "good",
          },
          %{
            title: "Rollback",
            text: "Rollback version #{version_link(ver)} to #{version_link(previous)} on #{env}?",
            color: "warning",
            callback_id: "publish:webapp",
            actions: [
              %{
                name: env,
                text: "Rollback!",
                value: previous,
                style: "danger",
                type: "button",
                confirm: %{
                  title: "Are you sure?",
                  text: "You are about to rollback this version for all users.",
                  ok_text: "I got this",
                  dismiss_text: "Nope.",
                },
              },
            ],
          },
        ],
      })
    end
  end

  def notify_slack(body) do
    case webhook_url() do
      nil -> :ok
      url ->
        HTTPoison.post!(url, Poison.encode!(body), [], [])
    end
  end

  defp webhook_url do
    Application.get_env(:ello_serve, :slack_webhook_url)
  end

  defp compare_link(ver, env) do
    case Ello.Serve.VersionStore.version_history("webapp", env) do
      [_, prev | _] -> "<https://github.com/ello/webapp/compare/#{ver}...#{prev}|#{env}>"
      _             -> ""
    end
  end

  def version_link(ver) do
    nice = String.slice(ver, 0, 7)
    "<https://github.com/ello/webapp/commit/#{ver}|#{nice}>"
  end
end
