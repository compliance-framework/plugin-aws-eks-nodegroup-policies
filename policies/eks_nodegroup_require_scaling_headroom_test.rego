package compliance_framework.eks_nodegroup_require_scaling_headroom

test_no_violation_with_valid_scaling_headroom if {
	count(violation) == 0 with input as {"nodegroup_context": {"current": {
		"desired_size": 3,
		"min_size": 2,
		"max_size": 5,
		"scale_out_headroom": 2,
		"desired_at_or_above_min": true,
	}}}
}

test_violation_when_scaling_config_missing if {
	count(violation) == 1 with input as {"nodegroup_context": {"current": {
		"desired_size": null,
		"min_size": null,
		"max_size": null,
		"scale_out_headroom": null,
		"desired_at_or_above_min": null,
	}}}
}

test_violation_when_desired_below_minimum if {
	count(violation) == 1 with input as {"nodegroup_context": {"current": {
		"desired_size": 1,
		"min_size": 2,
		"max_size": 5,
		"scale_out_headroom": 4,
		"desired_at_or_above_min": false,
	}}}
}

test_violation_when_scale_out_headroom_too_low if {
	count(violation) == 1 with input as {"nodegroup_context": {"current": {
		"desired_size": 3,
		"min_size": 2,
		"max_size": 3,
		"scale_out_headroom": 0,
		"desired_at_or_above_min": true,
	}}}
}

test_no_violation_when_scaling_headroom_not_required if {
	count(violation) == 0 with input as {"nodegroup_context": {"current": {
		"desired_size": null,
		"min_size": null,
		"max_size": null,
		"scale_out_headroom": null,
		"desired_at_or_above_min": null,
	}}}
		with data.require_nodegroup_scaling_headroom as false
}

test_no_violation_when_headroom_exactly_at_default_minimum if {
	count(violation) == 0 with input as {"nodegroup_context": {"current": {
		"desired_size": 3,
		"min_size": 2,
		"max_size": 4,
		"scale_out_headroom": 1,
		"desired_at_or_above_min": true,
	}}}
}

test_no_violation_with_custom_minimum_headroom if {
	count(violation) == 0 with input as {"nodegroup_context": {"current": {
		"desired_size": 3,
		"min_size": 2,
		"max_size": 3,
		"scale_out_headroom": 0,
		"desired_at_or_above_min": true,
	}}}
		with data.minimum_nodegroup_scaling_headroom as 0
}
