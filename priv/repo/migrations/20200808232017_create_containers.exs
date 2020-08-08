defmodule Theshellter.Repo.Migrations.CreateContainers do
  use Ecto.Migration

  def change do
    create table(:containers) do
      add :name, :string
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end

    create index(:containers, [:account_id])
  end
end
