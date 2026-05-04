
# Azure CLI shortcuts
# add to your ~/.zshrc with syntax: 
# source ~/[az.zsh path] (e.g. `source ~/zcfg/az.zsh`)

az-whoami() {
  echo "zsh function: ~/zcfg/az.zsh/az-whoami"
  az account show --query '{user:user.name, sub:name, subId:id, tenant:tenantId}' -o table
}

az-subs() {
  echo "zsh function: ~/zcfg/az.zsh/az-subs"
  az account list --query '[].{user:user.name, sub:name, subId:id, tenant:tenantId, state:state, default:isDefault}' -o table
}

az-rg-vms() {
  echo "zsh function: ~/zcfg/az.zsh/az-rg-vms"
  if [[ -z "$1" ]]; then
    echo "usage: az-rg-vms <resource-group>" >&2
    return 1
  fi
  az vm list -g "$1" -o table
}

az-find-rg() {
  echo "zsh function: ~/zcfg/az.zsh/az-find-rg"
  if [[ -z "$1" ]]; then
    echo "usage: az-find-rg <name-substring>" >&2
    return 1
  fi
  az graph query --first 1000 --query "data" -q "ResourceContainers
    | where type == 'microsoft.resources/subscriptions/resourcegroups'
    | where name contains '$1'
    | project name, location, subscriptionId
    | order by name asc" -o table
}

az-find-res() {
  echo "zsh function: ~/zcfg/az.zsh/az-find-res"
  if [[ -z "$1" ]]; then
    echo "usage: az-find-res <name-substring>" >&2
    return 1
  fi
  az graph query --first 1000 --query "data" -q "Resources
    | where name contains '$1'
    | project name, type, location, resourceGroup, subscriptionId
    | order by type asc" -o table
}

# Reference list of Azure Resource Graph tables. See:
# https://learn.microsoft.com/azure/governance/resource-graph/reference/supported-tables-resources
az-tables() {
  echo "zsh function: ~/zcfg/az.zsh/az-tables"
  cat <<'EOF'
Core tables:
  Resources                    ARM resources (default; most queries)
  ResourceContainers           Subscriptions, resource groups, management groups
  ResourceChanges              Change history for resources
  ResourceContainerChanges     Change history for subs/RGs/MGs
  AuthorizationResources       Role assignments, definitions, classic admins
  AdvisorResources             Azure Advisor recommendations
  AlertsManagementResources    Active alerts
  SecurityResources            Defender for Cloud findings
  ServiceHealthResources       Service Health events
  TagsResources                Tag namespaces

Specialty tables (use only if relevant):
  AppServiceResources, AwsResources, BatchResources, ChaosResources,
  CommunityGalleryResources, ComputeResources, DeploymentResources,
  DesktopVirtualizationResources, DnsResources, EdgeOrderResources,
  ElasticSanResources, KustoResources, MaintenanceResources,
  ManagedServiceResources, ServiceFabricResources, SpotResources,
  SupportResources, CapabilityResources
EOF
}

# Distinct resource types present in your current subscription for a given table.
# Defaults to the Resources table.
az-types() {
  echo "zsh function: ~/zcfg/az.zsh/az-types"
  local table="${1:-Resources}"
  az graph query --first 1000 --query "data" \
    -q "$table | distinct type | order by type asc" -o tsv
}

# Sample one row from a table to see the available columns/shape.
az-table-sample() {
  echo "zsh function: ~/zcfg/az.zsh/az-table-sample"
  local table="${1:-Resources}"
  az graph query --first 1 --query "data" -q "$table | limit 1" -o jsonc
}

# Internal helper: per-table wrappers below delegate here.
# Prints the caller's function name so the existing echo convention is preserved.
_az-types() {
  echo "zsh function: ~/zcfg/az.zsh/${funcstack[2]}"
  az graph query --first 1000 --query "data" \
    -q "$1 | distinct type | order by type asc" -o tsv
}

# Core tables
az-types-resources()           { _az-types Resources }
az-types-containers()          { _az-types ResourceContainers }
az-types-changes()             { _az-types ResourceChanges }
az-types-container-changes()   { _az-types ResourceContainerChanges }
az-types-authorization()       { _az-types AuthorizationResources }
az-types-advisor()             { _az-types AdvisorResources }
az-types-alerts()              { _az-types AlertsManagementResources }
az-types-security()            { _az-types SecurityResources }
az-types-servicehealth()       { _az-types ServiceHealthResources }
az-types-tags()                { _az-types TagsResources }

# Specialty tables
az-types-appservice()          { _az-types AppServiceResources }
az-types-aws()                 { _az-types AwsResources }
az-types-batch()               { _az-types BatchResources }
az-types-capability()          { _az-types CapabilityResources }
az-types-chaos()               { _az-types ChaosResources }
az-types-communitygallery()    { _az-types CommunityGalleryResources }
az-types-compute()             { _az-types ComputeResources }
az-types-deployments()         { _az-types DeploymentResources }
az-types-avd()                 { _az-types DesktopVirtualizationResources }
az-types-dns()                 { _az-types DnsResources }
az-types-edgeorder()           { _az-types EdgeOrderResources }
az-types-elasticsan()          { _az-types ElasticSanResources }
az-types-kusto()               { _az-types KustoResources }
az-types-maintenance()         { _az-types MaintenanceResources }
az-types-managedservice()      { _az-types ManagedServiceResources }
az-types-servicefabric()       { _az-types ServiceFabricResources }
az-types-spot()                { _az-types SpotResources }
az-types-support()             { _az-types SupportResources }
