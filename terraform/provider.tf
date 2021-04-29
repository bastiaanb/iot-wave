#
# Our credentials.
#
provider "google" {
  credentials = file("account.json")
  project = "global-datacenter"
  region = "europe-west1"
}
