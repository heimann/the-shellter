defmodule Theshellter.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :email, :string
    field :nickname, :string

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end

  @doc false
  def oauth_changeset(struct, params) do
    struct
    |> cast(params, [:email, :nickname])
    |> validate_required([:email, :nickname])
    |> unique_constraint(:email)
    |> unique_constraint(:nickname)
  end
end
