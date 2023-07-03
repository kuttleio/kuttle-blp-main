data aws_region current {}

data aws_ssm_parameter logdna_service_key {
    name            = "/${local.name_prefix}/logdna_service_key"
    with_decryption = true
}
