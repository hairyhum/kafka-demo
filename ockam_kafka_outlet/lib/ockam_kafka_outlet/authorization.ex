defmodule OckamKafkaOutlet.Authorization do

  alias Ockam.ABAC.Authorization
  alias Ockam.ABAC.Policy

  def local_or_from_member(message, state) do
    {:ok, allow_local_policy} = allow_local_policy()
    {:ok, member_policy} = member_policy()
    ## TODO: we could make it an `or` rule, it's the same thing as providing a list of policies
    Authorization.with_policy_check(message, state, [allow_local_policy, member_policy])
  end

  def project_policy_rule(project_id) do
    "(= subject.project_id \"#{project_id}\")"
  end

  def member_policy() do
    project_id = Application.fetch_env!(:ockam_kafka_outlet, :project_id)
    policy_rule = project_policy_rule(project_id)

    Policy.from_rule_string(policy_rule, wildcard_action_id())
  end

  def allow_local_policy() do
    Policy.from_rule_string("(= action.source \"local\")", wildcard_action_id())
  end

  defp wildcard_action_id() do
    Ockam.ABAC.ActionId.new(".*", "handle_message")
  end
end
