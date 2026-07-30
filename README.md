# Resume Site (Azure Static Web App via OpenTofu)

**Live:** https://resume.theginger.dev

## Secrets you’ll need on the repo

AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_SUBSCRIPTION_ID
Create an Azure AD app with Federated Credentials for GitHub OIDC (no client secret needed). Assign it “Contributor” on the RG/subscription for provisioning, plus “Storage Blob Data Contributor” on the OpenTofu **state** storage account (`tfstateresumesimplified`) so CI can read/write remote state.

(Tip: the workflow prints the final site URL in the logs.)

## Prereqs
- Azure subscription + permissions
- GitHub repo with OIDC to Azure:
  - Secrets: AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_SUBSCRIPTION_ID

## First run locally (optional)
cd tofu
tofu init
tofu apply

## Deploy via CI
- Push to branch
- Open PR
- OpenTofu plan, validate, and infracost workflows run
- Merge to main triggers workflow to provision RG + Azure Static Web App
- Post-deploy smoke test validation


## Rollback
The deploy workflow ends with a **post-deploy smoke test**: it stamps the commit SHA into `site/version.txt`, then polls the live site until `/version.txt` matches the deployed SHA **and** the homepage still contains the expected content. If that check fails, the workflow goes red.

A red smoke test means the deploy already shipped — the bad or incomplete version is **live** (Static Web Apps uploads before the check runs; this is post-deploy verification, not a pre-merge gate). To recover:

1. Identify the offending commit on `main` (the one the failed run deployed).
2. Open a **revert PR** — on GitHub, the merged PR's **"Revert"** button creates the branch and PR for you (`git revert <sha>` on a branch works too). Merging the revert is what redeploys the previous good state; direct pushes to `main` are not the path once branch protection is on.
3. The merge re-triggers the workflow, which redeploys the previous good state and re-runs the smoke test to confirm recovery (watch for the green ✅ in the Actions log).
4. If the deploy itself is fine but the site is unreachable for infra reasons (DNS/cert/Cloudflare), check the [status page](https://theginger.betteruptime.com/) — the outage may be upstream of this repo, in which case a revert won't help.

> **Break-glass:** the revert PR must pass the same required checks as any change, which can slow an urgent rollback. For a genuine emergency, a repo admin can merge the revert without waiting (admin bypass) — a deliberate, logged action, not the default.
>
> **Follow-up:** a true pre-promotion gate (deploy to a staging environment, smoke-test *that*, then promote) is tracked via SWA PR preview environments.

## Customize
- All resume content lives in one place: the `<script type="application/json" id="resume-data">` block near the top of `site/index.html`. Edit that JSON (summary, skills, experience, contact) and the terminal, the section commands, and the full-resume view all update from it.
- Tweak the look in `site/styles.css` (CRT theme + the print stylesheet used by "Save as PDF").
- There's no committed PDF to maintain: the `pdf` command and the "Save as PDF" button render the full resume from the JSON and hand it to the browser's print-to-PDF dialog, so the downloadable PDF is always in sync with the content.
- The source resume doc lives in `resume-source/` (outside `site/`, so it isn't published with the deploy).
- Change `resource_prefix` or `location` in `tofu/variables.tf`.

## The site
A single-page, self-contained "terminal" resume — no build step, no runtime fetches.
- Inspect facets with commands: `about`, `skills`, `experience [name]`, `contact`, plus `ls`/`cd`/`cat`/`pwd`.
- Read the whole thing at once via the `resume` command or the `▤ full resume` button, and save it with "Save as PDF".