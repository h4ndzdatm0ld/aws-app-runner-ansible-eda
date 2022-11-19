terraform {
  cloud {
    organization = "dev-knot"
    workspaces {
      name = "aws-app-runner-ansible-eda"
    }
  }
}
