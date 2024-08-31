resource "aws_iam_policy" "lb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "Policy for AWS Load Balancer Controller for Kubernetes"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Statement" = [
      {
        "Action" = [
          "iam:CreateServiceLinkedRole",
        ]
        "Condition" = {
          "StringEquals" = {
            "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
          }
        }
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Action" = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTrustStores",
        ]
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Action" = [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection",
        ]
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Action" = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
        ]
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Action" = [
          "ec2:CreateSecurityGroup",
        ]
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Action" = [
          "ec2:CreateTags",
        ]
        "Condition" = {
          "Null" = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
          "StringEquals" = {
            "ec2:CreateAction" = "CreateSecurityGroup"
          }
        }
        "Effect"   = "Allow"
        "Resource" = "arn:${data.aws_partition.current.partition}:ec2:*:*:security-group/*"
      },
      {
        "Action" = [
          "ec2:CreateTags",
          "ec2:DeleteTags",
        ]
        "Condition" = {
          "Null" = {
            "aws:RequestTag/elbv2.k8s.aws/cluster"  = "true"
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
        "Effect"   = "Allow"
        "Resource" = "arn:${data.aws_partition.current.partition}:ec2:*:*:security-group/*"
      },
      {
        "Action" = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup",
        ]
        "Condition" = {
          "Null" = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Action" = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
        ]
        "Condition" = {
          "Null" = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Action" = [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
        ]
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Action" = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
        ]
        "Condition" = {
          "Null" = {
            "aws:RequestTag/elbv2.k8s.aws/cluster"  = "true"
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
        "Effect" = "Allow"
        "Resource" = [
          "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:loadbalancer/app/*/*",
        ]
      },
      {
        "Action" = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
        ]
        "Effect" = "Allow"
        "Resource" = [
          "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:listener-rule/app/*/*/*",
        ]
      },
      {
        "Action" = [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup",
        ]
        "Condition" = {
          "Null" = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
        "Effect"   = "Allow"
        "Resource" = "*"
      },
      {
        "Action" = [
          "elasticloadbalancing:AddTags",
        ]
        "Condition" = {
          "Null" = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
          "StringEquals" = {
            "elasticloadbalancing:CreateAction" = [
              "CreateTargetGroup",
              "CreateLoadBalancer",
            ]
          }
        }
        "Effect" = "Allow"
        "Resource" = [
          "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:loadbalancer/app/*/*",
        ]
      },
      {
        "Action" = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
        ]
        "Effect"   = "Allow"
        "Resource" = "arn:${data.aws_partition.current.partition}:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        "Action" = [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule",
        ]
        "Effect"   = "Allow"
        "Resource" = "*"
      },
    ]
    "Version" = "2012-10-17"
  })
}

resource "aws_iam_role" "lb_controller_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}
