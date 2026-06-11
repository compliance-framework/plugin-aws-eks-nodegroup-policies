# AWS EKS Nodegroup policies

Standalone OPA/Rego policy bundle for EKS managed node group evidence emitted by the `plugin-aws-eks` collector.

## Input schema

Each policy evaluates one EKS managed node group at a time using:

- `input.nodegroup`
- `input.nodegroup_context`

Current node group context includes node group status, EKS health issue count, cluster name, Kubernetes version, capacity type, AMI type, subnet count, scaling configuration (desired, min, max sizes), scale-out headroom, desired-at-or-above-min flag, and parent cluster reference.

## Current coverage

This bundle currently checks managed node group posture:

- node group is active and has no unresolved EKS health issues
- scaling configuration is valid with sufficient scale-out headroom above desired capacity
- node group is configured across enough subnets for Availability Zone diversity

Cluster-level and add-on policies live in separate bundles (`plugin-aws-eks-policies` and `plugin-aws-eks-addon-policies`).

## Policy data

Default baselines live in `policies/data.json` and can be overridden by agent-supplied policy data.

| Key | Type | Default | Policies that read it |
|-----|------|---------|----------------------|
| `approved_nodegroup_statuses` | `array<string>` | `["ACTIVE"]` | `eks_nodegroup_require_active_health` |
| `require_nodegroup_scaling_headroom` | `boolean` | `true` | `eks_nodegroup_require_scaling_headroom` |
| `minimum_nodegroup_scaling_headroom` | `number` | `1` | `eks_nodegroup_require_scaling_headroom` |
| `minimum_nodegroup_subnet_count` | `number` | `2` | `eks_nodegroup_require_subnet_diversity` |

## Testing

Run local checks with:

```shell
opa check policies
opa test policies
```

Or use the Makefile wrappers:

```shell
make validate
make test
```

## Bundling

Build the distributable bundle with:

```shell
make build
```

This writes `dist/bundle.tar.gz`.
