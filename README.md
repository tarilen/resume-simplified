# Resume Site (Azure Static Website via OpenTofu)

## Secrets you’ll need on the repo

AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_SUBSCRIPTION_ID
Create an Azure AD app with Federated Credentials for GitHub OIDC (no client secret needed). Assign it “Storage Blob Data Contributor” on the storage account scope and “Contributor” on the RG/subscription for provisioning.

(Tip: the workflow prints the final static website URL in the logs.)

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
- Edit `site/index.html` and `site/styles.css`
- Replace `site/Damian-Ortega-Engineer.pdf` with your latest PDF
- Change `resource_prefix` or `location` in `tofu/variables.tf`