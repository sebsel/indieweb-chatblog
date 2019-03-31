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
end
