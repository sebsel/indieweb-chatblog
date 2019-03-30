defmodule Chatblog.Lurker do
  use GenServer
  alias Chatblog.{Curator, Message}

  @stream_endpoint "https://chat.indieweb.org/__/sub?id=chat"

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(_) do
    {:ok, pid} = EventsourceEx.new(@stream_endpoint, stream_to: self())
    Process.link(pid)
    {:ok, :no_state}
  end

  def handle_info(%EventsourceEx.Message{} = message, state) do
    %{"text" => data} = Jason.decode!(message.data)
    %{"channel" => "#" <> channel, "html" => html} = data

    type =
      case data do
        %{"type" => "message"} -> :message
        %{"type" => "join"} -> :join
        %{"type" => "part"} -> :part
        %{"type" => "leave"} -> :leave
        %{"type" => "topic"} -> :topic
        _ -> :unknown
      end

    Curator.notify(channel, type, Message.from_html(html))
    {:noreply, state}
  end
end
