
locals {
  ingress_rules = [
    {
      to_port     = 8080
      description = "Allow jenkins port"
      protocol    = "tcp"
      from_port   = 8080
      cidr_blocks = ["71.163.242.34/32"]
    },
    {
      to_port     = 22
      from_port   = 22
      description = "Allow ssh traffic"
      protocol    = "tcp"
      cidr_blocks = [aws_subnet.fleur-public-subnet[0].cidr_block, "71.163.242.34/32"]
    },
    {
      description = "Allow sonarqube traffic traffic"
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = ["71.163.242.34/32"]

    },
    {
      description = "Allow  http traffic traffic"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["71.163.242.34/32"]

    },
    {
      description = "Allow  https traffic traffic"
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["71.163.242.34/32"]

    },
    {
      description = "Allow internal trafic within pub subnet traffic"
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      cidr_blocks = [var.fleur-cidr-block]
    }
  ]

  private = [
    { description = "Allow Postgres traffic"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  ecs = [
    {
      description = format("%s-%s-%s", var.cell_name, var.component_name, "ecs_security_group")
      from_port   = var.container_port
      to_port     = var.container_port
      protocol    = "tcp"
      cidr_blocks = ["71.163.242.34/32"]
    }
  ]

  egree_rule = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }]

  common_secret_values = {
    engine     = var.db_clusters.engine
    port       = var.db_clusters.port
    dbname     = var.db_clusters.dbname
    identifier = var.db_clusters.identifier
    password   = random_string.master_user_password.result
  }
  common_tenable_values = {
    engine   = local.engines_map[var.db_clusters.engine]
    endpoint = aws_db_instance.postgres_rds.address
    port     = var.db_clusters.port
    dbname   = var.db_clusters.dbname
    password = random_string.master_user_password.result
  }
  engines_map = {
    aurora-postgresql = "postgres"
    postgres          = "postgres"
    redshift          = "redshift"
  }
  default_tags = {
    Env               = lower(terraform.workspace)
    service_name      = "reporting"
    cell_name         = "reporting-frontend"
    component_name    = "aws-eksnginx"
    service_tier      = "WEB"
    builder           = "hqr-devops@bellese.io"
    application_owner = "hqr-feedback-and-support-product@bellese.io"
  }
  operational_environment     = aws_vpc.fleur-vpc[0].id
  subnet_ids                  = aws_subnet.fleur-public-subnet.*.id
  operational_environment_ecr = "735972722491.dkr.ecr.us-east-1.amazonaws.com/aws-eksnginx"
}
