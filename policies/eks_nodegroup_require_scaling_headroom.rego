# METADATA
# title: EKS managed node group should have scaling headroom
# description: Node groups without enough scale-out headroom between desired and maximum capacity cannot absorb load spikes, risking workload disruption when the cluster needs to scale.
# custom:
#   controls:
#     - A1.2
#     - CC6.7
#   schedule: "0 */6 * * *"

package compliance_framework.eks_nodegroup_require_scaling_headroom

violation[{"id": "eks_nodegroup_scaling_config_missing"}] if {
	data.require_nodegroup_scaling_headroom # regal ignore:unresolved-reference
	not scaling_config_present
}

violation[{"id": "eks_nodegroup_desired_below_minimum"}] if {
	data.require_nodegroup_scaling_headroom # regal ignore:unresolved-reference
	scaling_config_present
	not desired_at_or_above_min
}

violation[{"id": "eks_nodegroup_insufficient_scale_out_headroom"}] if {
	data.require_nodegroup_scaling_headroom # regal ignore:unresolved-reference
	scaling_config_present
	scale_out_headroom < data.minimum_nodegroup_scaling_headroom # regal ignore:unresolved-reference
}

scaling_config_present if {
	is_number(desired_size)
	is_number(min_size)
	is_number(max_size)
	is_number(scale_out_headroom)
}

desired_at_or_above_min if {
	object.get(current, "desired_at_or_above_min", false) != false
}

desired_size := object.get(current, "desired_size", null)

min_size := object.get(current, "min_size", null)

max_size := object.get(current, "max_size", null)

scale_out_headroom := object.get(current, "scale_out_headroom", null)

current := object.get(object.get(input, "nodegroup_context", {}), "current", {})

title := "EKS managed node group should have scaling headroom"
description := "EKS managed node group scaling configuration should be valid and retain enough scale-out headroom above desired capacity."

risk_templates := [
	{
		"name": "EKS node group scaling configuration is missing",
		"title": "EKS managed node group has no valid scaling configuration",
		"statement": "The node group is missing numeric values for desired, minimum, maximum, or scale-out headroom, which prevents evaluating scaling safety.",
		"likelihood_hint": "low",
		"impact_hint": "medium",
		"violation_ids": ["eks_nodegroup_scaling_config_missing"],
		"remediation": {
			"title": "Set a valid scaling configuration on the node group",
			"description": "Ensure the node group has numeric desired, min, and max sizes configured via a scaling configuration.",
			"tasks": [
				{"title": "Set desired_size, min_size, and max_size in the node group scaling configuration"},
				{"title": "Verify the scaling configuration is reflected in the EKS console"},
			],
		},
	},
	{
		"name": "EKS node group desired count is below minimum",
		"title": "EKS managed node group desired capacity is below minimum size",
		"statement": "The desired node count is less than the configured minimum size, indicating a misconfiguration that may lead to Auto Scaling Group violations or insufficient capacity.",
		"likelihood_hint": "medium",
		"impact_hint": "high",
		"violation_ids": ["eks_nodegroup_desired_below_minimum"],
		"remediation": {
			"title": "Align desired capacity with minimum size",
			"description": "Update the node group scaling configuration so that desired_size is at least min_size.",
			"tasks": [
				{"title": "Increase desired_size to at least min_size"},
				{"title": "Verify the Auto Scaling Group converges to the updated desired count"},
			],
		},
	},
	{
		"name": "EKS node group has insufficient scale-out headroom",
		"title": "EKS managed node group scale-out headroom is below the required minimum",
		"statement": "The gap between desired and maximum node count is less than the policy-defined minimum, which limits the cluster's ability to absorb sudden load increases without disruption.",
		"likelihood_hint": "medium",
		"impact_hint": "high",
		"violation_ids": ["eks_nodegroup_insufficient_scale_out_headroom"],
		"remediation": {
			"title": "Increase max_size to provide adequate scale-out headroom",
			"description": "Raise the node group max_size so that the difference between max and desired is at least minimum_nodegroup_scaling_headroom.",
			"tasks": [
				{"title": "Calculate the required max_size: desired_size + minimum_nodegroup_scaling_headroom"},
				{"title": "Update max_size to the required value in the node group scaling configuration"},
				{"title": "Verify the Auto Scaling Group reflects the updated max size"},
			],
		},
	},
]
