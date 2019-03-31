defmodule ChatblogWeb.PageController do
  use ChatblogWeb, :controller
  alias Chatblog.Repo

  def index(conn, _params) do
    channels =
      Repo.all(Chatblog.Entry)
      |> Enum.group_by(& &1.channel, & %{&1 | body: {:safe, &1.body}})

    render(conn, "index.html", channels: channels)
  end
end
