defmodule Theshellter.Repo.Migrations.AddNicknameToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :nickname, :string
    end

    create unique_index(:accounts, [:nickname])
  end
end
