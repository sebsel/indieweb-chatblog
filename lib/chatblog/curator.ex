defmodule Chatblog.Curator do
  use GenServer
  alias Ecto.Changeset
  alias Chatblog.Repo
  alias Chatblog.Entry

  def start_link(args, opts \\ []) do
    name = name(Keyword.get(args, :channel))
    GenServer.start_link(__MODULE__, args, opts ++ [name: name])
  end

  def notify(channel, type, message) do
    GenServer.cast(name(channel), {type, message})
  end

  defp name(channel), do: {:via, Registry, {Chatblog.Curators, channel}}

  # GenServer callbacks

  def init(args) do
    {:ok,
     %{
       channel: Keyword.get(args, :channel),
       last_message_at: nil,
       entry: nil,
       messages: []
     }}
  end

  def handle_cast({:message, message}, %{messages: messages, entry: entry} = state) do
    new_entry? = should_be_new_entry?(message, state)

    entry =
      if new_entry? do
        Repo.insert!(%Entry{
          body: message.html,
          channel: state.channel,
          start_at: message.published,
          end_at: message.published
        })
      else
        entry
        |> Changeset.change(%{body: entry.body <> message.html, end_at: message.published})
        |> Repo.update!()
      end

    messages =
      if new_entry?, do: [message], else: [message] ++ messages

    Entry.notify_updated(entry)

    {:noreply,
      state
      |> Map.put(:entry, entry)
      |> Map.put(:messages, messages)
      |> Map.put(:last_message_at, DateTime.utc_now())
    }
  end

  def handle_cast(_, state), do: {:noreply, state}

  defp should_be_new_entry?(_html, %{entry: nil}), do: true
  defp should_be_new_entry?(_html, %{last_message_at: nil}), do: true

  defp should_be_new_entry?(_html, %{last_message_at: time}) do
    five_minutes_ago =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> Kernel.-(5 * 60)
      |> DateTime.from_unix!()

    case DateTime.compare(time, five_minutes_ago) do
      :gt -> false
      :lt -> true
      :eq -> true
    end
  end

  defp should_be_new_entry?(_html, _state), do: true
end
