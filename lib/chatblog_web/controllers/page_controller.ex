defmodule ChatblogWeb.PageController do
  use ChatblogWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
