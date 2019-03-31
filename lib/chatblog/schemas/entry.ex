defmodule Chatblog.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :body, :string
    field :channel, :string
    field :start_at, :utc_datetime
    field :end_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:body, :channel])
    |> validate_required([:body, :channel])
  end

  def notify_updated(entry) do
    ChatblogWeb.Endpoint.broadcast("chat:updates", "message", %{
      id: entry.id,
      html:
        ChatblogWeb.PageView
        |> Phoenix.View.render("_entry.html", entry: Map.update!(entry, :body, &{:safe, &1}))
        |> Phoenix.HTML.safe_to_string()
    })
  end
end
