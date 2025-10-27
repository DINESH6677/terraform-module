data "aws_availability_zones" "available" {
  state = "available" # Optional: Filter for only 'available' zones
}