# Define provider and AWS region
provider "aws" {
  region = "us-east-1" # Specify your desired region
}

# Create a VPC for the ECS cluster
resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create subnets within the VPC for the ECS cluster
resource "aws_subnet" "ecs_subnet_1" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "ecs_subnet_2" {
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create an ECS cluster
resource "aws_ecs_cluster" "jenkins_cluster" {
  name = "jenkins-cluster"
}

# Define a task definition for your ECS service
resource "aws_ecs_task_definition" "jenkins_task_definition" {
  family                   = "jenkins-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  container_definitions    = <<TASK_DEFINITION
  [
    {
      "name": "jenkins-container",
      "image": "jenkins",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080,
          "protocol": "tcp"
        }
      ]
    }
  ]
TASK_DEFINITION
}

# Define a service that runs tasks using the previously defined task definition
resource "aws_ecs_service" "jenkins_service" {
  name            = "jenkins-service"
  cluster         = aws_ecs_cluster.jenkins_cluster.id
  task_definition = aws_ecs_task_definition.jenkins_task_definition.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.ecs_subnet_1.id, aws_subnet.ecs_subnet_2.id]
    assign_public_ip = "true"
    security_groups  = [] # You can specify security groups if needed
  }

  depends_on = [aws_ecs_task_definition.jenkins_task_definition]
}