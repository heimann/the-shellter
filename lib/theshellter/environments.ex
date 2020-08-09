defmodule Theshellter.Environments do
  alias Theshellter.Repo
  alias __MODULE__.Container
  require Logger

  def get_container(account_id) do
    Repo.get_by(Container, account_id: account_id)
  end

  def get_or_create_container(account_id) do
    if container = get_container(account_id) do
      {:ok, container}
    else
      create_container_for_user(account_id)
    end
  end

  def create_container_for_user(account_id) do
    containerid = spawn_container()

    %Container{}
    |> Container.changeset(%{account_id: account_id, name: containerid})
    |> Repo.insert()
  end

  def spawn_container() do
    container = System.cmd("docker", ["run", "-itd", "theshellter:base"])
    String.trim(elem(container, 0), "\n")
  end
end
