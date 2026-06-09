package compliance_framework.eks_nodegroup_require_scaling_headroom

violation[{"id": "eks_nodegroup_scaling_config_missing"}] if {
	data.require_nodegroup_scaling_headroom
	not scaling_config_present
}

violation[{"id": "eks_nodegroup_desired_below_minimum"}] if {
	data.require_nodegroup_scaling_headroom
	scaling_config_present
	not desired_at_or_above_min
}

violation[{"id": "eks_nodegroup_insufficient_scale_out_headroom"}] if {
	data.require_nodegroup_scaling_headroom
	scaling_config_present
	scale_out_headroom < data.minimum_nodegroup_scaling_headroom
}

scaling_config_present if {
	is_number(desired_size)
	is_number(min_size)
	is_number(max_size)
	is_number(scale_out_headroom)
}

desired_at_or_above_min if {
	object.get(current, "desired_at_or_above_min", false)
}

desired_size := object.get(current, "desired_size", null)

min_size := object.get(current, "min_size", null)

max_size := object.get(current, "max_size", null)

scale_out_headroom := object.get(current, "scale_out_headroom", null)

current := object.get(object.get(input, "nodegroup_context", {}), "current", {})

title := "EKS managed node group should have scaling headroom"
description := "EKS managed node group scaling configuration should be valid and retain enough scale-out headroom above desired capacity."
