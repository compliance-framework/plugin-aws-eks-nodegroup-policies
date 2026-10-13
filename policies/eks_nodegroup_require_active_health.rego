# METADATA
# title: EKS managed node group should be active and healthy
# description: An EKS managed node group that is not ACTIVE or has unresolved health issues may be unable to schedule workloads, affecting cluster capacity and availability.
# custom:
#   controls:
#     - A1.2
#     - CC7.2
#   schedule: "0 */6 * * *"

package compliance_framework.eks_nodegroup_require_active_health

violation[{"id": "eks_nodegroup_not_active"}] if {
	not approved_nodegroup_status
}

violation[{"id": "eks_nodegroup_health_issues_present"}] if {
	health_issue_count > 0
}

approved_nodegroup_status if {
	status := data.approved_nodegroup_statuses[_] # regal ignore:unresolved-reference
	nodegroup_status == status
}

nodegroup_status := object.get(current, "status", "")

health_issue_count := object.get(current, "health_issue_count", 0)

current := object.get(object.get(input, "nodegroup_context", {}), "current", {})

title := "EKS managed node group should be active and healthy"
description := "EKS managed node group status should be ACTIVE and EKS should report no unresolved node group health issues."

risk_templates := [
	{
		"name": "EKS node group is not active",
		"title": "EKS managed node group is not in ACTIVE state",
		"statement": "The node group is not reporting an ACTIVE status, which may indicate a provisioning failure or degraded state that prevents workload scheduling.",
		"likelihood_hint": "low",
		"impact_hint": "high",
		"violation_ids": ["eks_nodegroup_not_active"],
		"remediation": {
			"title": "Investigate and restore node group to ACTIVE state",
			"description": "Review EKS node group events and AWS health dashboard to identify the cause of the non-ACTIVE state.",
			"tasks": [
				{"title": "Check node group status and events in the EKS console or via AWS CLI"},
				{"title": "Review EC2 instance health for nodes in the group"},
				{"title": "Contact AWS support if the node group is stuck in a transitional state"},
			],
		},
	},
	{
		"name": "EKS node group has unresolved health issues",
		"title": "EKS managed node group has unresolved health issues reported by AWS",
		"statement": "AWS has reported one or more unresolved health issues for this node group that may affect the availability of worker nodes for workload scheduling.",
		"likelihood_hint": "medium",
		"impact_hint": "high",
		"violation_ids": ["eks_nodegroup_health_issues_present"],
		"remediation": {
			"title": "Resolve EKS node group health issues",
			"description": "Review the node group health dashboard for specific issue codes and follow AWS remediation guidance for each issue type.",
			"tasks": [
				{"title": "Review node group health issues via the EKS console or AWS CLI"},
				{"title": "Address root cause of each reported health issue"},
				{"title": "Verify health issue count returns to zero after remediation"},
			],
		},
	},
]
