terraform {
  required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
  }
}

resource "aws_scheduler_schedule" "lf_goodnight" {
  name = "lf_goodnight"
  flexible_time_window {
    mode = "FLEXIBLE"
    maximum_window_in_minutes = 5
  }

  schedule_expression = "cron(0 19 * * ? *)"
  schedule_expression_timezone = "America/Chicago"
  
  target {
    arn = var.lf_goodnight_lambda_arn
    role_arn = var.lf_goodnight_lamba_role_arn

    retry_policy {
      maximum_retry_attempts = 4
    }
  }


}