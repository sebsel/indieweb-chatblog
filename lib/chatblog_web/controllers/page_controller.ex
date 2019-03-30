defmodule ChatblogWeb.PageController do
  use ChatblogWeb, :controller
  alias Chatblog.Repo

  def index(conn, _params) do
    entries =
      Repo.all(Chatblog.Entry)
      |> Enum.map(&{&1.channel, {:safe, &1.body}})

    render(conn, "index.html", entries: entries)
  end
end
