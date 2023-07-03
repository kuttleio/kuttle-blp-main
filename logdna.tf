# ---------------------------------------------------
#    LogDNA
# ---------------------------------------------------

module "logdna" {
    source = "./modules/logdna"

    name_prefix         = local.name_prefix
    short_region_name   = local.short_region_name
    clp_zenv            = var.clp_zenv
    clp_region          = var.clp_region
    clp_account         = var.clp_account
    mezmo_account_id    = var.mezmo_account_id
    standard_tags       = var.standard_tags
}
