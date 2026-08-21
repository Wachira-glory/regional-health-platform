# EC2 Runtime and Drift Validation Note

## Architecture decision

The EC2 resource is treated as an infrastructure-as-code deliverable rather
than the executable application runtime for the local lab environment.

The Terraform service module defines the EC2 instance and associated security
configuration and is validated through the static verification gates.

The application runtime is executed separately as a Docker container.

## LocalStack limitation

Attempting to materialize the EC2 resource in the local LocalStack environment
did not produce a usable Docker-backed EC2 runtime.

The Terraform apply reached the EC2 RunInstances operation after successfully
creating the Secrets Manager resources and application security group, but the
EC2 operation failed with:

    MissingParameter: The request must contain the parameter size or snapshotId

Because the local EC2 implementation does not provide the runtime required by
the assignment execution path, EC2 is retained and validated as IaC rather
than used to host the application.

The load balancer follows the same IaC-only approach and is not required for
the local application runtime.

## Runtime validation

The application image is executed directly as a Docker container.

The runtime:

- retrieves the database credential from LocalStack Secrets Manager;
- connects to the externally managed Aiven MySQL database;
- exposes `/healthz` for application liveness;
- exposes `/readyz` for dependency readiness.

Healthy runtime validation produced:

    /healthz -> HTTP 200
    /readyz  -> HTTP 200

A database failure was deliberately introduced and produced:

    /healthz -> HTTP 200
    /readyz  -> HTTP 503

After restoring the valid database credential, readiness recovered to HTTP 200.

## Verification gates

The final `make verify` run passed:

- Terraform formatting
- Terraform validation
- TFLint
- Gitleaks
- Trivy IaC scanning
- live `/healthz`
- live `/readyz`

The command completed with:

    All verification checks passed.
    VERIFY_EXIT=0

The deployed-state drift gate was intentionally not executed because there is
no successfully materialized EC2 runtime state against which that EC2 drift
check can be meaningfully performed in this local execution path.

This limitation is documented rather than treating a skipped drift check as a
successful drift validation.
