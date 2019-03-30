defmodule Chatblog.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :body, :text
      add :channel, :string

      timestamps()
    end

  end
end
