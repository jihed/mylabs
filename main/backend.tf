terraform {
  backend "s3" {
    bucket = "tf-state-mylabs-bucket"
    key    = "outputs"
    region = "us-east-1"
  }
}
