defmodule Chatblog.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :body, :text
      add :channel, :string
      add :start_at, :datetime
      add :end_at, :datetime

      timestamps()
    end

  end
end
