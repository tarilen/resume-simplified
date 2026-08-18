# Resume Site — a DevOps/SRE portfolio

**Live:** https://resume.theginger.dev · **Status:** https://theginger.betteruptime.com/

A single-page terminal-style resume that doubles as a working reference implementation of a
production delivery pipeline: infrastructure-as-code, policy-as-code, supply-chain scanning,
SLO-based alerting, and a full local-to-cloud Kubernetes path — all versioned in this repo.

The application is deliberately simple (a static site) so the interesting engineering is the
platform around it.

---

## The site

A self-contained "terminal" resume — no build step, no runtime fetches.
- Inspect facets with commands: `about`, `skills`, `experience [name]`, `contact`, plus `ls`/`cd`/`cat`/`pwd`.
- Read the whole thing at once via the `resume` command or the `▤ full resume` button, and save it with "Save as PDF".
- All content lives in one place: the `<script type="application/json" id="resume-data">` block near the top of `site/index.html`.

## Repo layout

| Path | What it is |
|------|------------|
| `site/` | The static site (HTML/CSS/JS, no build step) |
| `Dockerfile` / `.dockerignore` | Container image (`nginx:1.31-alpine`), published to GHCR |
| `tofu/` | OpenTofu for the Azure Static Web App + remote state, policy, and cost checks |
| `tofu/aks/` | Standalone, **manually-applied** OpenTofu root module for an ephemeral AKS cluster |
| `tofu/policy/` | Conftest/OPA Rego policies gating the plan |
| `k8s/` | Raw Kubernetes manifests (pre-Helm reference) |
| `chart/` | Helm chart for the site: Deployment, Service, Ingress, HPA, PrometheusRule |
| `kind/` | `kind` cluster config (local Kubernetes) |
| `argocd/` | Argo CD `Application` (GitOps) |
| `docs/observability.md` | SLOs, alerting design, runbook notes |
| `.github/workflows/` | CI/CD (see below) |

---

## Deployment (Azure Static Web App via OpenTofu)

Production hosting is an Azure Static Web App provisioned by OpenTofu with remote state in Azure
Storage. CI authenticates to Azure with **GitHub OIDC — no stored client secret**.

**Flow:**
- Open a PR → `terraform-plan` runs `tofu plan`, validates, runs policy + cost checks, and posts a plan summary.
- Merge to `main` → `deploy` provisions the RG + Static Web App, uploads the site, and runs a post-deploy smoke test.

**Secrets required on the repo:** `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, `AZURE_SUBSCRIPTION_ID`.
Create an Azure AD app with **Federated Credentials** for GitHub OIDC (no client secret). Assign it
`Contributor` on the RG/subscription for provisioning, plus `Storage Blob Data Contributor` on the
OpenTofu **state** storage account (`tfstateresumesimplified`) so CI can read/write remote state.

**Run locally (optional):**
```bash
cd tofu
tofu init
tofu apply
```
Change `resource_prefix` or `location` in `tofu/variables.tf` to retarget.

## IaC & supply-chain hardening

- **Checkov** (`iac-scan.yml`) scans the OpenTofu on every PR that touches `tofu/**` and uploads SARIF to the GitHub **Security** tab.
- **Conftest / OPA** (`tofu/policy/*.rego`) is a hard gate in `terraform-plan.yml`: it runs against the JSON plan and fails the required check if policy is violated (e.g. AKS must stay on the Free tier, RG must be in an allowed region, custom-domain validation type is enforced).
- **Infracost** posts an estimated cost delta on infra PRs.
- CI is careful with credentials: cloud-auth steps are guarded so **Dependabot never receives cloud secrets**, and the plan summary posted to this **public** repo exposes only resource addresses and change actions — never resource values.

## Observability & SLOs

Full write-up in [`docs/observability.md`](docs/observability.md). In short:
- **SLO:** 99.9% availability (≈43.2 min error budget / 30 days).
- **Fast-burn:** Better Stack synthetic monitor with a sustained-failure confirmation window and a de-flap recovery window → email page.
- **Slow-burn:** a scheduled GitHub Actions job (`burn-rate.yml`) queries the Better Stack SLA API daily and files/updates a `burn-rate` GitHub issue when the 1-day or 30-day budget burn crosses threshold.
- The same SLO logic is reproduced **in-cluster** from ingress-nginx RED metrics (see Kubernetes below).

## Rollback

The deploy workflow ends with a **post-deploy smoke test**: it stamps the commit SHA into
`site/version.txt`, then polls the live site until `/version.txt` matches the deployed SHA **and**
the homepage still contains the expected content. If that check fails, the workflow goes red.

A red smoke test means the deploy already shipped — the bad or incomplete version is **live** (Static
Web Apps uploads before the check runs; this is post-deploy verification, not a pre-merge gate). To recover:

1. Identify the offending commit on `main` (the one the failed run deployed).
2. Open a **revert PR** — on GitHub, the merged PR's **"Revert"** button creates the branch and PR for you (`git revert <sha>` on a branch works too). Merging the revert is what redeploys the previous good state; direct pushes to `main` are not the path once branch protection is on.
3. The merge re-triggers the workflow, which redeploys the previous good state and re-runs the smoke test to confirm recovery (watch for the green ✅ in the Actions log).
4. If the deploy itself is fine but the site is unreachable for infra reasons (DNS/cert/Cloudflare), check the [status page](https://theginger.betteruptime.com/) — the outage may be upstream of this repo.

> **Break-glass:** the revert PR must pass the same required checks as any change. For a genuine emergency, a repo admin can merge the revert without waiting (admin bypass) — a deliberate, logged action, not the default.

---

## Kubernetes

A soup-to-nuts Kubernetes track, built local-first (free) and graduating to cloud only for
cloud-specific work. The static site is the workload throughout.

**Container** — `Dockerfile` (`nginx:1.31-alpine`, pinned) builds an image published to
`ghcr.io/tarilen/resume`.

**Local cluster (`kind`)** — `kind/cluster.yaml` defines a reproducible single-node cluster with
ingress-ready port mappings. Raw manifests live in `k8s/` as a pre-Helm reference.

**Helm chart (`chart/`)** — everything values-driven:
- `deployment.yaml` — replicas, image, readiness/liveness probes, CPU requests/limits, `imagePullSecrets` for private GHCR.
- `service.yaml`, `ingress.yaml` — ClusterIP + ingress-nginx routing (`resume.local`).
- `hpa.yaml` — `autoscaling/v2`, CPU-target autoscaling.
- `monitoring.yaml` — a **PrometheusRule** implementing multiwindow-multiburn error-budget alerting (1h + 5m windows on the 99.9% SLO) from ingress-nginx metrics — the in-cluster mirror of the Better Stack alerting above.

**GitOps (Argo CD)** — `argocd/application.yaml` watches `chart/` on `main` with `selfHeal` + `prune`.
Once bootstrapped, **a merge to `main` is the deploy**; Argo reconciles drift automatically.

**Cloud (AKS)** — `tofu/aks/` is a **standalone, manually-applied** OpenTofu root module (its own
state key), never wired into auto-apply CI. It provisions an **ephemeral** AKS cluster (Free
control-plane tier) for cloud-specific reps, then `tofu destroy` tears it down. Ephemerality is the
cost control: `apply → lab → destroy`.

**Observability** — `kube-prometheus-stack` (Prometheus Operator + Grafana) scrapes ingress-nginx RED
metrics; the availability SLI and error-budget burn are computed in PromQL and alerted via the
chart's PrometheusRule.

### Quick start (local)
```bash
kind create cluster --config kind/cluster.yaml
# install ingress-nginx + kube-prometheus-stack (see docs/observability.md)
kubectl apply -f argocd/application.yaml     # bootstrap GitOps once
# thereafter: merge to main → Argo syncs
```

---

## Prereqs
- Azure subscription with permissions (for the SWA deploy and, optionally, AKS)
- GitHub repo with OIDC federation to Azure
- For the k8s track: Docker, `kind`, `kubectl`, `helm` (local); `az` + OpenTofu (for AKS)
