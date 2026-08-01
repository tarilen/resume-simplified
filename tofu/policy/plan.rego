# Repo policy gate. Conftest evaluates these `deny` rules against the
# `tofu show -json` plan output. ANY deny message => Conftest exits non-zero
# => the terraform-plan job fails => merge is blocked. These are OUR rules,
# not generic best practices (that's Checkov's job).
package main

import rego.v1

# ---------------------------------------------------------------------------
# Rule 1 — WORKED EXAMPLE: the Static Web App must stay on the Free tier.
# Budget guardrail; pairs with the Infracost check. Study this, then mirror it.
#
#   input.resource_changes[]  -> every resource in the plan
#   .type                     -> the terraform resource type
#   .change.after             -> the post-apply attribute values
#   .address                  -> human-readable resource address for the message
# ---------------------------------------------------------------------------
deny contains msg if {
	some rc in input.resource_changes
	rc.type == "azurerm_static_web_app"
	rc.change.after.sku_tier != "Free"
	msg := sprintf("%s: sku_tier must be \"Free\" (got %q)", [rc.address, rc.change.after.sku_tier])
}

# ---------------------------------------------------------------------------
# Rule 2 — YOUR TURN: resource group location must be in an allowed set.
#   hints:
#   - type is "azurerm_resource_group"; field is .change.after.location
#   - declare an allowed set near the top, e.g.  allowed_locations := {"eastus2"}
#     (use the region you ACTUALLY deploy — check tofu/variables.tf first)
#   - with `import rego.v1` you have the `in` keyword: deny when the location
#     is `not <x> in allowed_locations`
# ---------------------------------------------------------------------------
deny contains msg if {
    allowed_locations := {"eastus"}
    some rc in input.resource_changes
    rc.type == "azurerm_resource_group"
    not rc.change.after.location in allowed_locations
    msg := sprintf("%s: location must be in allowed locations (got %q)", [rc.address, rc.change.after.location])
}

# ---------------------------------------------------------------------------
# Rule 3 — YOUR TURN: custom domain must use cname-delegation validation.
#   hints:
#   - type "azurerm_static_web_app_custom_domain"; field .change.after.validation_type
#   - deny when it's anything other than "cname-delegation"
#   - this one is nearly a copy of Rule 1 with different type/field/value
# ---------------------------------------------------------------------------
deny contains msg if {
	some rc in input.resource_changes
	rc.type == "azurerm_static_web_app_custom_domain"
	rc.change.after.validation_type != "cname-delegation"
	msg := sprintf("%s: validation_type must be \"cname-delegation\" (got %q)", [rc.address, rc.change.after.validation_type])
}
