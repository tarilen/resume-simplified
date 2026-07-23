# Resume Site (Azure Static Web App via OpenTofu)

**Live:** https://yellow-beach-03778770f.7.azurestaticapps.net

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
- Push to `main`
- Workflow provisions RG + Storage Static Site
- CI uploads `site/` to `$web` container
- Find the URL in the job output (static_web_url)

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