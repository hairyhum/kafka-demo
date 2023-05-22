defmodule OckamKafkaOutlet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = []

    opts = [strategy: :one_for_one, name: OckamKafkaOutlet.Supervisor]

    with :ok <- read_project_config(),
         {:ok, pid} <- Supervisor.start_link(children, opts),
         :ok <- start_api_gateway(),
         :ok <- setup_credential_authorization() do
      {:ok, pid}
    end
  end

  defp read_project_config() do
    project_config = Application.get_env(:ockam_kafka_outlet, :project_config)
    with {:ok, data} <- File.read(project_config),
         {:ok, config} <- Jason.decode(data),
         {:ok, authority_identity_data} <- Map.fetch(config, "authority_identity"),
         {:ok, authority_identity} = make_identity(authority_identity_data) do
      project_id = Map.get(config, "id")


      Application.put_env(:ockam_kafka_outlet, :project_id, project_id)
      Application.put_env(:ockam_kafka_outlet, :authority_identity, authority_identity)

      :ok
    else
      {:error, reason} ->
        IO.puts(:stderr, "PROJECT_CONFIG file read error #{inspect(reason)}")
        {:error, :invalid_config}
    end
  end

  defp make_identity(identity_data) do
    with {:ok, binary} <- Base.decode16(identity_data, case: :lower) do
      Ockam.Identity.make_identity(binary)
    end
  end

  defp setup_credential_authorization() do
    ca_identity = Application.fetch_env!(:ockam_kafka_outlet, :authority_identity)
    authorities = [ca_identity]

    [{:ok, _, "credentials"}] =
      Ockam.Services.start_service(:credential_exchange,
        authorization: [:from_identiy_secure_channel],
        authorities: authorities,
        verifier_module: Ockam.Credential.Verifier.Sidecar,
        address: "credentials"
      )
    :ok
  end

  defp start_api_gateway() do
    with {:ok, own_identity, _own_identity_id} <- Ockam.Identity.create() do
      [{:ok, _, _}] = Ockam.Services.start_service(
      :secure_channel,
      [
        identity: own_identity,
        address: "api",
        additional_metadata: %{},
        trust_policies: [],
        responder_authorization: [{OckamKafkaOutlet.Authorization, :local_or_from_member}],
        idle_timeout: :timer.hours(24)
      ])
      :ok
    end
  end
end

