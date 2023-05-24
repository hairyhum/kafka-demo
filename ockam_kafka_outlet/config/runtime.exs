import Config


tcp_port = String.to_integer(System.get_env("TCP_PORT", "4000"))

config :ockam_services,
  tcp_transport: [listen: [port: tcp_port, handler_options: [authorization: [:is_local]]]]

sidecar_host = System.get_env("OCKAM_SIDECAR_HOST", "localhost")
sidecar_port = String.to_integer(System.get_env("OCKAM_SIDECAR_PORT", "4100"))

sidecar_services = [
    ## sidecar proxy to verifier API worker (using default sidecar)
    sidecar_proxy: [
      authorization: [:is_local],
      sidecar_host: sidecar_host,
      sidecar_port: sidecar_port,
      service_id: :ca_verifier_sidecar,
      sidecar_address: "verifier"
    ],
    identity_sidecar: [
      authorization: [:is_local],
      sidecar_host: sidecar_host,
      sidecar_port: sidecar_port
    ]
  ]

config :ockam, identity_module: Ockam.Identity.Sidecar

kafka_bootstrap = System.get_env("KAFKA_BOOTSTRAP_SERVER", "localhost:9092")
kafka_use_ssl = System.get_env("KAFKA_USE_SSL", "true") == "true"

kafka_outlet_services = [
  {:static_forwarding,
       authorization: [{OckamKafkaOutlet.Authorization, :local_or_from_member}],
       prefix: "consumer_",
       address: "kafka_consumers",
       extra_addresses: [],
       forwarder_options: [
         authorization: [{OckamKafkaOutlet.Authorization, :local_or_from_member}]
       ]},
    {
      :kafka_interceptor,
      authorization: [{OckamKafkaOutlet.Authorization, :local_or_from_member}],
      outlet: [
        authorization: [:is_local],
        bootstrap: kafka_bootstrap,
        ssl: kafka_use_ssl
      ]
    }
  ]

healthcheck_services = [
    {:echo,
           [
             address: "healthcheck",
             log_level: :debug
           ]}]

config :ockam_services,
  service_providers: [
    # default services
    Ockam.Services.Provider.Routing,
    # kafka services
    Ockam.Services.Kafka.Provider,
    # secure channel services
    Ockam.Services.Provider.SecureChannel,
    # proxies for remote services
    Ockam.Services.Provider.Proxy,
    # sidecar services
    Ockam.Services.Provider.Sidecar,
    # credential exchange API
    Ockam.Services.Provider.CredentialExchange
  ],
  services: healthcheck_services ++ sidecar_services ++ kafka_outlet_services


project_config = case System.get_env("PROJECT_CONFIG", "") do
  "" ->
    IO.puts(:stderr, "PROJECT_CONFIG file should be set")
    exit(:invalid_config)
  file ->
    file
end

config :ockam_kafka_outlet, project_config: project_config

config :ockam_cloud_node, cleanup: []
