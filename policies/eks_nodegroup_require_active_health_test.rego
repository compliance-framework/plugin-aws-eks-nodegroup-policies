package compliance_framework.eks_nodegroup_require_active_health

test_no_violation_when_nodegroup_active_and_healthy if {
	count(violation) == 0 with input as {"nodegroup_context": {"current": {"status": "ACTIVE", "health_issue_count": 0}}}
}

test_violation_when_nodegroup_not_active if {
	count(violation) == 1 with input as {"nodegroup_context": {"current": {"status": "UPDATING", "health_issue_count": 0}}}
}

test_violation_when_nodegroup_has_health_issues if {
	count(violation) == 1 with input as {"nodegroup_context": {"current": {"status": "ACTIVE", "health_issue_count": 2}}}
}

test_no_violation_custom_approved_status if {
	count(violation) == 0 with input as {"nodegroup_context": {"current": {"status": "UPDATING", "health_issue_count": 0}}}
		with data.approved_nodegroup_statuses as ["UPDATING"]
}
