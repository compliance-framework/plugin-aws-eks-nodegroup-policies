package compliance_framework.eks_nodegroup_require_subnet_diversity

violation[{"id": "eks_nodegroup_insufficient_subnet_diversity"}] if {
	subnet_count < data.minimum_nodegroup_subnet_count
}

subnet_count := object.get(current, "subnet_count", count(object.get(object.get(input, "nodegroup", {}), "Subnets", [])))

current := object.get(object.get(input, "nodegroup_context", {}), "current", {})

title := "EKS managed node group should span enough subnets"
description := "EKS managed node group should be configured with at least the policy-defined number of subnet IDs. This validates subnet diversity only, not Availability Zone placement."
