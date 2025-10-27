locals{
    common_tags={
        Project = var.project
        Environment = var.environment
        Terraform = true
    }

    common_name_suffix = "${var.project}-${var.environment}"
    az_names = slice(data.aws_availability_zones.available.names,0,2)

}