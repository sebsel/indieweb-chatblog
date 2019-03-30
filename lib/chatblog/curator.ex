defmodule Chatblog.Curator do
  use GenServer
  alias Ecto.Changeset
  alias Chatblog.Repo
  alias Chatblog.Entry

  def start_link(args, opts \\ []) do
    name = name(Keyword.get(args, :channel))
    GenServer.start_link(__MODULE__, args, opts ++ [name: name])
  end

  def notify(channel, type, html) do
    GenServer.cast(name(channel), {type, html})
  end

  defp name(channel), do: {:via, Registry, {Chatblog.Curators, channel}}

  # GenServer callbacks

  def init(args) do
    channel = Keyword.get(args, :channel)
    {:ok, %{channel: channel, last_message_at: nil, entry: nil}}
  end

  def handle_cast({:message, html}, %{channel: channel, entry: entry} = state) do
    entry =
      if should_be_new_entry?(html, state) do
        Repo.insert!(%Entry{body: html, channel: channel})
      else
        entry
        |> Changeset.change(%{body: entry.body <> html})
        |> Repo.update!()
      end

    state = %{state | entry: entry, last_message_at: DateTime.utc_now()}
    {:noreply, state}
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
