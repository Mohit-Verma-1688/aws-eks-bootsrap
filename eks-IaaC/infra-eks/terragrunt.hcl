remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    #profile = "mohit"
    role_arn = "arn:aws:iam::8XXXXXXXXXX:role/terraform"
    bucket = "wrc-terraform-state"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
  provider "aws" {
   region  = "us-west-2"
   #profile = "mohit"

  assume_role {
    session_name = "devlab"
    role_arn = "arn:aws:iam::8XXXXXX:role/terraform"
  }
}
EOF
}
