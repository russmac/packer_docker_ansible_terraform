///### IAM
### ECS Instance

resource "aws_iam_role" "pdat-ec2-role" {
  name = "pdat-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "pdat-ec2-policy" {
  name = "pdat-ec2-policy"
  role = "${aws_iam_role.pdat-ec2-role.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
EOF
  depends_on = ["aws_iam_role.pdat-ec2-role"]
}

resource "aws_iam_instance_profile" "pdat-ec2-profile" {
  name = "pdat-ec2-profile"
  roles = ["${aws_iam_role.pdat-ec2-role.name}"]
  depends_on = ["aws_iam_role.pdat-ec2-role"]
}


### ECS Scheduler (service)

  resource "aws_iam_role" "pdat-ecs-role" {
    name = "pdat-ecs-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  }


  resource "aws_iam_role_policy" "pdat-ecs-policy" {
    name = "pdat-ecs-policy"
    role = "${aws_iam_role.pdat-ecs-role.name}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
      ],
      "Resource": "*"
    }
  ]
}
EOF
  depends_on = ["aws_iam_role.pdat-ecs-role"]
}