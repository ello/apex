defmodule Ello.Serve.VersionStore.SlackNotifications do

  def new_version(app, ver) do
    Task.async fn ->
      notify_slack(%{
        text: "New version of `#{app}` available: #{version_link(app, ver)}",
        attachments: [
          %{
            title: "Compare",
            text: """
            Compare to the active version in each env:
            #{compare_link(app, ver, "stage")}  #{compare_link(app, ver, "rainbow")} #{compare_link(app, ver, "production")}
            """,
            color: "#0366d6",
          },
          %{
            title: "Preview",
            text: """
            Previews are available only by accessing the app with the url with the version link. You will continue seeing the preview version until you refresh.
            You may preview in any environment:
            #{preview_link(app, ver, "stage")} #{preview_link(app, ver, "ninja")} #{preview_link(app, ver, "rainbow")} #{preview_link(app, ver, "production")}
            """,
            color: "good",
          },
          %{
            title: "Publish",
            text: "Publishing makes this version of webapp active for all users visiting the environment.\n\nPublish with caution.",
            color: "warning",
            callback_id: "publish:#{app}",
            actions: [
              %{
                name: "stage",
                text: "stage",
                value: ver,
                type: "button",
                confirm: %{
                  title: "Are you sure?",
                  text: "Publishing this version will push it to stage for all users.",
                  ok_text: "I got this",
                  dismiss_text: "Nope."
                }
              },
              %{
                name: "ninja",
                text: "ninja",
                value: ver,
                type: "button",
                confirm: %{
                  title: "Are you sure?",
                  text: "Publishing this version will push it to ninja for all users.",
                  ok_text: "I got this",
                  dismiss_text: "Nope."
                }
              },
              %{
                name: "rainbow",
                text: "rainbow",
                value: ver,
                type: "button",
                confirm: %{
                  title: "Are you sure?",
                  text: "Publishing this version will push it to rainbow for all users.",
                  ok_text: "I got this",
                  dismiss_text: "Nope."
                }
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

  def version_activated(app, ver, env, nil) do
    Task.async fn ->
      notify_slack(%{
        attachments: [
          %{
            title: "New `#{app}` version published for all users on #{env}.",
            text:  "Version #{version_link(app, ver)}",
            color: "good",
          }
        ]
      })
    end
  end

  def version_activated(app, ver, env, previous) do
    Task.async fn ->
      notify_slack(%{
        attachments: [
          %{
            title: "New `#{app}` version published for all users on #{env}.",
            text:  "Version #{version_link(app, ver)}",
            color: "good",
          },
          %{
            title: "Rollback",
            text: "Rollback version #{version_link(app, ver)} to #{version_link(app, previous)} on #{env}?",
            color: "warning",
            callback_id: "publish:#{app}",
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
        HTTPoison.post!(url, Jason.encode!(body), [], [])
    end
  end

  defp webhook_url do
    Application.get_env(:ello_serve, :slack_webhook_url)
  end

  @github %{
    "webapp" => "https://github.com/ello/webapp",
    "bread"  => "https://github.com/ello/bread",
  }

  defp compare_link(app, ver, env) do
    case Ello.Serve.VersionStore.version_history(app, env) do
      [prev | _] -> "<#{@github[app]}/compare/#{prev}...#{ver}|#{env}>"
      _          -> ""
    end
  end

  defp version_link(app, ver) do
    nice = String.slice(ver, 0, 7)
    "<#{@github[app]}/commit/#{ver}|#{nice}>"
  end

  @env_host %{
    "stage" => "ello-fg-stage.herokuapp.com",
    "ninja" => "ello.ninja",
    "rainbow" => "ello-fg-rainbow.herokuapp.com",
    "production" => "ello.co",
  }

  defp preview_link("webapp", version, env) do
    "<https://#{@env_host[env]}?version=#{version}|#{env}>"
  end

  defp preview_link("bread", version, env) do
    "<https://#{@env_host[env]}/manage?version=#{version}|#{env}>"
  end
end
