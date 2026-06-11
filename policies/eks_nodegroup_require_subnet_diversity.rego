# METADATA
# title: EKS managed node group should span enough subnets
# description: Deploying a node group across multiple subnets increases Availability Zone coverage, reducing the risk of a zone outage taking all nodes offline simultaneously.
# custom:
#   controls:
#     - A1.2
#     - CC6.6
#   schedule: "0 */6 * * *"

package compliance_framework.eks_nodegroup_require_subnet_diversity

violation[{"id": "eks_nodegroup_insufficient_subnet_diversity"}] if {
	subnet_count < data.minimum_nodegroup_subnet_count
}

subnet_count := object.get(current, "subnet_count", count(object.get(object.get(input, "nodegroup", {}), "Subnets", [])))

current := object.get(object.get(input, "nodegroup_context", {}), "current", {})

title := "EKS managed node group should span enough subnets"
description := "EKS managed node group should be configured with at least the policy-defined number of subnet IDs. This validates subnet diversity only, not Availability Zone placement."

risk_templates := [{
	"name":            "EKS node group spans insufficient subnets",
	"title":           "EKS managed node group is configured with fewer subnets than required",
	"statement":       "The node group is configured with fewer subnets than the policy-defined minimum, reducing Availability Zone diversity and the cluster's resilience to zone failures.",
	"likelihood_hint": "low",
	"impact_hint":     "high",
	"violation_ids":   ["eks_nodegroup_insufficient_subnet_diversity"],
	"remediation": {
		"title":       "Add subnets to the node group to meet the minimum subnet count",
		"description": "Update the node group subnet configuration to include at least minimum_nodegroup_subnet_count subnets, ideally one per Availability Zone.",
		"tasks": [
			{"title": "Identify available subnets across the required number of Availability Zones"},
			{"title": "Update the node group subnet IDs to include the additional subnets"},
			{"title": "Verify nodes launch successfully in all configured subnets"}
		]
	}
}]
