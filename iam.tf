///### IAM

resource "aws_iam_instance_profile" "pdat-ecs-profile" {
  name = "pdat-ecs-profile"
  roles = ["${aws_iam_role.pdat-ecs-role.name}"]
  depends_on = ["aws_iam_role.pdat-ecs-role"]
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
        "ecr:BatchGetImage",
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
