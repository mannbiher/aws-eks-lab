# data sources used in this file are not safe to use
data "http" "my_ip" {
  url = "https://ifconfig.me/"
}
