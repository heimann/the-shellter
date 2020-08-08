defmodule Theshellter.Environments.Container do
  use Ecto.Schema
  import Ecto.Changeset

  schema "containers" do
    field :name, :string
    field :account_id, :id

    timestamps()
  end

  @doc false
  def changeset(container, attrs) do
    container
    |> cast(attrs, [:name, :account_id])
    |> validate_required([:name])
  end
end
