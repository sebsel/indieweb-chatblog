defmodule ChatblogWeb.UpdatesChannel do
  use ChatblogWeb, :channel

  def join("chat:updates", _payload, socket) do
    {:ok, socket}
  end
end
