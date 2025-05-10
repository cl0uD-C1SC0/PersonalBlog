# =========================
# =    AWS VPC CONFIG     =
# =========================
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    "Name" = "VPC-TF"
  }

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
}
# ===================================
# =    AWS PUBLIC SUBNET CONFIG     =
# ===================================
resource "aws_subnet" "public-subnet-01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "TF-PublicSubnet-1A"
  }
}
resource "aws_subnet" "public-subnet-02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "TF-PublicSubnet-1B"
  }
}
# ====================================
# =    AWS PRIVATE SUBNET CONFIG     =
# ====================================
resource "aws_subnet" "private-subnet-01" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.2.0/24"
    availability_zone   = "us-east-1a"

    tags = {
        Name = "TF-PrivateSubnet-1A"
  }
}
resource "aws_subnet" "private-subnet-02" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.3.0/24"
    availability_zone   = "us-east-1b"

    tags = {
        Name = "TF-PrivateSUbnet-1B"
  }
}
# ==================================
# =    INTERNET GATEWAY CONFIG     =
# ==================================
resource "aws_internet_gateway" "internet-gateway" {
    vpc_id      = aws_vpc.main.id

    tags = {
        Name = "TF-InternetGateway"
  }

  depends_on = [aws_vpc.main]
}
# =================================
# =    AWS NAT GATEWAY CONFIG     =
# =================================
resource "aws_nat_gateway" "nat-gateway" {
    allocation_id = aws_eip.eip.id
    subnet_id  = aws_subnet.public-subnet-01.id

    depends_on = [aws_internet_gateway.internet-gateway, aws_vpc.main, aws_subnet.public-subnet-01, aws_eip.eip]
}
# =========================================
# =    AWS PUBLIC ROUTE TABLE CONFIG      =
# =========================================
resource "aws_route_table" "TF-PublicRouteTable" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway.id
  }
    tags = {
        Name = "TF-PublicRouteTable"
  }
    depends_on = [aws_internet_gateway.internet-gateway]
}
resource "aws_route_table_association" "association-1a-public" {
    subnet_id       = aws_subnet.public-subnet-01.id
    route_table_id  = aws_route_table.TF-PublicRouteTable.id

    depends_on = [aws_subnet.public-subnet-01, aws_route_table.TF-PublicRouteTable, aws_internet_gateway.internet-gateway]
}
resource "aws_route_table_association" "association-1b-public" {
    subnet_id       = aws_subnet.public-subnet-02.id
    route_table_id  = aws_route_table.TF-PublicRouteTable.id
    depends_on = [aws_subnet.public-subnet-02, aws_route_table.TF-PublicRouteTable, aws_internet_gateway.internet-gateway]
}
# ==========================================
# =    AWS PRIVATE ROUTE TABLE CONFIG      =
# ==========================================
resource "aws_eip" "eip" {
    depends_on = [aws_vpc.main, aws_internet_gateway.internet-gateway]
}
resource "aws_route_table" "PrivateRouteTable" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat-gateway.id
  }
    tags = {
        Name = "TF-PrivateRouteTable"
  }
    depends_on = [aws_nat_gateway.nat-gateway, aws_internet_gateway.internet-gateway]
}
resource "aws_route_table_association" "association-1a-private" {
    subnet_id       = aws_subnet.private-subnet-01.id
    route_table_id  = aws_route_table.PrivateRouteTable.id
    depends_on = [aws_subnet.private-subnet-01, aws_route_table.PrivateRouteTable, aws_internet_gateway.internet-gateway]
}
resource "aws_route_table_association" "association-1b-private" {
    subnet_id       = aws_subnet.private-subnet-02.id
    route_table_id  = aws_route_table.PrivateRouteTable.id
    depends_on = [aws_subnet.private-subnet-02, aws_route_table.PrivateRouteTable, aws_internet_gateway.internet-gateway]
}
# =======================
# =    EKS IAM ROLE     =
# =======================
resource "aws_iam_role" "eks-iam-role" {
    name = "hyundai-cluster"
    assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.eks-iam-role.name  
}
# =============================
# =    EKS CLUSTER CONFIG     =
# =============================
resource "aws_eks_cluster" "hyundai-cluster" {
    name        = "hyundai-cluster"
    role_arn    = aws_iam_role.eks-iam-role.arn
    vpc_config {
      subnet_ids = [aws_subnet.private-subnet-01.id, aws_subnet.private-subnet-02.id, aws_subnet.public-subnet-01.id, aws_subnet.public-subnet-02.id]
    }
    depends_on = [
      aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
    ] 
}
# ============================
# =    NODES IAM CONFIG      =
# ============================
resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": "arn:aws:ecr:*:*:repository/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeRegistry",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
})
}
resource "aws_iam_role" "nodes" {
    name = "eks-node-group-nodes"

    assume_role_policy = jsonencode({
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal   = {
                Service = "ec2.amazonaws.com"
            }
        }]
        Version = "2012-10-17"
    })
}
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.nodes.name  
}
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.nodes.name
}
resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.nodes.name
}
resource "aws_iam_role_policy_attachment" "nodes-EKS" {
    policy_arn = aws_iam_policy.policy.arn
    role = aws_iam_role.nodes.name
}
# ===========================
# =    EKS NODES CONFIG     =
# ===========================
resource "aws_eks_node_group" "private-nodes" {
    cluster_name = aws_eks_cluster.hyundai-cluster.name
    node_group_name = "EKS-Node"
    node_role_arn =  aws_iam_role.nodes.arn
    subnet_ids = [
        aws_subnet.public-subnet-01.id, 
        aws_subnet.public-subnet-02.id
    ]
    capacity_type = "ON_DEMAND"
    instance_types = ["t3.small"]
    scaling_config {
      desired_size = 2
      max_size = 10
      min_size = 2
    }
    update_config {
      max_unavailable = 1
    }
    depends_on = [
      aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
      aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy
    ]
}
# =========================
# =     SECRETS MANAGER   =
# =========================
variable "GITHUB" {
    default = {
        GITHUB_CREDENTIAL = "ghp_EX4PL3T0KEN"
    }
}
variable "DOCKER" {
    default = {
        DOCKER_PASSWD = "examplepassword"
        DOCKER_USR = "exampleuser"
    }
}
resource "aws_secretsmanager_secret" "GHP_TOKEN-SECRET" {
    name = "GHP_TOKEN"
}
resource "aws_secretsmanager_secret" "DOCKER_CREDENTIALS-SECRET" {
    name = "DOCKER_CREDENTIALS"
}
resource "aws_secretsmanager_secret_version" "GHP_TOKEN" {
  secret_id     = aws_secretsmanager_secret.GHP_TOKEN-SECRET.id
  secret_string = jsonencode(var.GITHUB)
}
resource "aws_secretsmanager_secret_version" "DOCKER_CREDENTIALS" {
  secret_id     = aws_secretsmanager_secret.DOCKER_CREDENTIALS-SECRET.id
  secret_string = jsonencode(var.DOCKER)
}
# =====================================
# =     EKS-DESCRIBE TO CODEBUILD     =
# =====================================
resource "aws_iam_policy" "eks-describe" {
  name        = "eks-describe"
  path        = "/"
  description = "eks-describe"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster"
            ],
            "Resource": "*"
        }
    ]
})
}
# ==============================
# =    CODEBUILD IAM ROLE      =
# ==============================
resource "aws_iam_role" "codebuild" {
    name = "codebuild-iam-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole"
                ],
                "Principal": {
                    "Service": [
                        "codebuild.amazonaws.com"
                    ]
                }
            }
        ]
    })
}
resource "aws_iam_role_policy_attachment" "codebuild-SecretsManagerReadWrite" {
    policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
    role = aws_iam_role.codebuild.name
}
resource "aws_iam_role_policy_attachment" "codebuild-AmazonEC2ContainerRegistryFullAccess" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
    role = aws_iam_role.codebuild.name
}
resource "aws_iam_role_policy_attachment" "codebuild-AWSCodePipelineReadOnlyAccess" {
    policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineReadOnlyAccess"
    role = aws_iam_role.codebuild.name
}
resource "aws_iam_role_policy_attachment" "codebuild-EKSDescribe" {
    policy_arn = aws_iam_policy.eks-describe.arn
    role = aws_iam_role.codebuild.name
}
resource "aws_iam_role_policy_attachment" "codebuild-CloudWatchLogs" {
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    role = aws_iam_role.codebuild.name
}
# ===============
# =  CODEBUILD  =
# ===============
resource "aws_codebuild_project" "codebuild-hyundai" {
    name =  "hyundai-project"
    description = "hyundai-project"
    build_timeout =  "5"
    service_role = aws_iam_role.codebuild.arn
    artifacts {
      type = "NO_ARTIFACTS"
    }
    environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image =  "aws/codebuild/standard:6.0"
      type = "LINUX_CONTAINER"
      image_pull_credentials_type = "CODEBUILD"
      privileged_mode = true
    }
    logs_config {
        cloudwatch_logs {
          group_name = "hyundai-project"
          stream_name = "log-stream"
        }
    }
    source {
      type = "GITHUB"
      location = "https://github.com/<usergit>/<project-name>.git"
      git_clone_depth = 1

      git_submodules_config {
        fetch_submodules = true
      }
      buildspec = "buildspec.yaml"
    }
}
# ===============
# =    ECR     =
# ==============
resource "aws_ecr_repository" "ECR" {
  name = "hyundai-project"
  image_scanning_configuration {
    scan_on_push = true
  }
}
# OUTPUTS
output "CodeBuild-Role-Name" {
    value = aws_iam_role.codebuild.name
}
output "CodeBuild-Role-Arn" {
    value = aws_iam_role.codebuild.arn
}
output "Cluster-Name" {
    value = aws_eks_cluster.hyundai-cluster.name
}
output "Node-Role-Name" {
    value = aws_iam_role.nodes.name
}
output "Node-Role-Arn" {
    value = aws_iam_role.nodes.arn
}
output "ECR-Repository" {
    value = aws_ecr_repository.ECR.name
}
output "CodeBuild-Project" {
    value = aws_codebuild_project.codebuild-hyundai.name
}
output "CodeBuild-Project-Arn" {
    value = aws_codebuild_project.codebuild-hyundai.arn
}