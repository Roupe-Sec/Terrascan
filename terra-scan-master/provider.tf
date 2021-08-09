provider "aws" {
  profile = var.profile
  region  = var.region
}

# Exposed AWS Access Keys (easy to spot)
# Overriden by Environment Variables
provider "aws" {
  alias      = "plain_text_access_keys_provider"
  region     = "eu-west-2"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}