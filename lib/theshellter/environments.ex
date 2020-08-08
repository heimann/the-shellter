defmodule Theshellter.Environments do
  alias Theshellter.Repo
  alias __MODULE__.Container
  require Logger

  def get_container(account_id) do
    Repo.get_by(Container, account_id: account_id)
  end
end
