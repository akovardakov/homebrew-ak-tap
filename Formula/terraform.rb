class Terraform < Formula
  desc "Tool to build, change, and version infrastructure"
  homepage "https://www.terraform.io/"
  url "https://github.com/hashicorp/terraform/archive/refs/tags/v1.10.3.tar.gz"
  sha256 "cd721c5c9fa192549680c71f3bf5b715cfb283311800af2e8d44bb4edc26a1d8"
  head "https://github.com/hashicorp/terraform.git", branch: "main"

  depends_on "go" => :build

  conflicts_with "terraform", because: "older version in hombrew repo"
  conflicts_with "tenv", because: "both install terraform binary"
  conflicts_with "tfenv", because: "tfenv symlinks terraform binaries"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    minimal = testpath/"minimal.tf"
    minimal.write <<~HCL
      variable "aws_region" {
        default = "us-west-2"
      }

      variable "aws_amis" {
        default = {
          eu-west-1 = "ami-b1cf19c6"
          us-east-1 = "ami-de7ab6b6"
          us-west-1 = "ami-3f75767a"
          us-west-2 = "ami-21f78e11"
        }
      }

      # Specify the provider and access details
      provider "aws" {
        access_key = "this_is_a_fake_access"
        secret_key = "this_is_a_fake_secret"
        region     = var.aws_region
      }

      resource "aws_instance" "web" {
        instance_type = "m1.small"
        ami           = var.aws_amis[var.aws_region]
        count         = 4
      }
    HCL
    system bin/"terraform", "init"
    system bin/"terraform", "graph"
  end
end
