# Regional Health — Group Platform (Assignment 2)

Shared infrastructure for rehosting the Regional Health capacity lab app onto
LocalStack-emulated AWS. This repo holds the group-owned pieces; each team
member's individual rehost lives in their own repo and composes these modules.

## Structure

modules/data/      RDS/Aiven MySQL + Secrets Manager  (owner: TBD)
modules/service/   EC2 + nginx + health wiring          (owner: Glory)
.github/workflows/   Golden CI: gitleaks, trivy, zizmor, build+scan (owner: TBD)
.devcontainer/       Codespaces config (Linux required for LocalStack)

## Group rule

Every member is sole author of at least one module PR and approving
reviewer on at least two others. Enforced via required PR reviews on main.

## Note on DB provider

Originally spec'd for RDS on LocalStack; switched to Aiven MySQL (free
managed MySQL) since RDS isn't on LocalStack's free Hobby tier. Everything
else (Secrets Manager, EC2, gates, pipeline) is unchanged.
