# Define the provider
provider "aws" {
  region = "ap-southeast-1"  # Specify your AWS region
}

# Define the IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "my-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeBuildAdminAccess"  # Attach a managed policy for CodeBuild
  role     = aws_iam_role.codebuild_role.name
}

# Define the CodeBuild project
resource "aws_codebuild_project" "my_project" {
  name          = "my-codebuild-project"
  description   = "My CodeBuild project"
  build_timeout  = "60"  # Timeout in minutes

  source {
    type            = "GITHUB"
    location        = "https://github.com/your-repo/your-project.git"  # Replace with your repository URL
  }

  artifacts {
    type     = "S3"
    location = aws_s3_bucket.codebuild_bucket.bucket
    path     = "artifacts/"
    name     = "output.zip"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"  # Choose appropriate compute type
    image                       = "aws/codebuild/standard:5.0"  # Choose appropriate build image
    type                        = "LINUX_CONTAINER"
    environment_variable {
      name  = "MY_ENV_VAR1"
      value = "value1"
    }
    environment_variable {
      name  = "MY_ENV_VAR2"
      value = "value2"
    }
    environment_variable {
      name  = "MY_ENV_VAR3"
      value = "value3"
    }    
  }

  service_role = aws_iam_role.codebuild_role.arn

  # Optional: Define buildspec file (if you have one)
  buildspec = file("buildspec.yml")  # Path to your buildspec file
}

# Output the project name
output "codebuild_project_name" {
  value = aws_codebuild_project.my_project.name
}
