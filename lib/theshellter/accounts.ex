defmodule Theshellter.Accounts do
  alias Theshellter.Repo
  alias __MODULE__.Account
  require Logger

  def get_or_register(%Ueberauth.Auth{info: %{nickname: nickname}} = _params) do
    Logger.debug("nickname:: #{inspect(nickname)}")

    if account = get_by_nickname(nickname) do
      {:ok, account}
    else
      {:error, :not_invited}
    end
  end

  def register(%Ueberauth.Auth{} = params) do
    %Account{}
    |> Account.oauth_changeset(extract_account_params(params))
    |> Repo.insert()
  end

  def get_account(id) do
    Repo.get(Account, id)
  end

  def get_by_email(email) do
    Repo.get_by(Account, email: email)
  end

  def get_by_nickname(nickname) do
    Repo.get_by(Account, nickname: nickname)
  end

  defp extract_account_params(%{credentials: %{other: other}, info: info}) do
    info
    |> Map.from_struct()
    |> Map.merge(other)
  end
end
