package compliance_framework.eks_nodegroup_require_active_health

violation[{"id": "eks_nodegroup_not_active"}] if {
	not approved_nodegroup_status
}

violation[{"id": "eks_nodegroup_health_issues_present"}] if {
	health_issue_count > 0
}

approved_nodegroup_status if {
	status := data.approved_nodegroup_statuses[_]
	nodegroup_status == status
}

nodegroup_status := object.get(current, "status", "")

health_issue_count := object.get(current, "health_issue_count", 0)

current := object.get(object.get(input, "nodegroup_context", {}), "current", {})

title := "EKS managed node group should be active and healthy"
description := "EKS managed node group status should be ACTIVE and EKS should report no unresolved node group health issues."
