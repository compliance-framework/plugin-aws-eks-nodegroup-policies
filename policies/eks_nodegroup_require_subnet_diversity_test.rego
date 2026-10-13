package compliance_framework.eks_nodegroup_require_subnet_diversity

test_no_violation_when_nodegroup_has_default_minimum_subnets if {
	count(violation) == 0 with input as {"nodegroup_context": {"current": {"subnet_count": 2}}}
}

test_violation_when_nodegroup_has_too_few_subnets if {
	count(violation) == 1 with input as {"nodegroup_context": {"current": {"subnet_count": 1}}}
}

test_no_violation_with_custom_minimum_subnet_count if {
	count(violation) == 0 with input as {"nodegroup_context": {"current": {"subnet_count": 1}}}
		with data.minimum_nodegroup_subnet_count as 1 # regal ignore:unresolved-reference
}

test_uses_raw_nodegroup_subnets_when_context_count_missing if {
	count(violation) == 0 with input as {
		"nodegroup": {"Subnets": ["subnet-1", "subnet-2"]},
		"nodegroup_context": {"current": {}},
	}
}
