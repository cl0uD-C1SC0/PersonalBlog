# Hyundai HPA - AWS Project (CI/CD)

<p>Seja bem-vindo ao projeto Hyundai HPA, um projeto pessoal que contém algumas tecnologias da área de DevOps, como AWS e automação utilizando o AWS Code Build, além disso é claro, o uso do AWS Elastic Kubernetes Service. Aqui nesta página você encontrará uma documentação técnica/tutorial de como executar esse projeto, fora que terá algumas informações de quando foi feito, o responsável e outros. Vamos lá!</p>

<div align="center">
    <img src="../../../assets/projects_files/hyundai_hpa/hyundaihpa.png" alt="Hyundai HPA Project logo">
</div>

## Informações adicionais

```bash
echo "Criado por: José Silva"
echo "Data: 16 de agosto de 2022"
```

## Recursos técnicos utilizados

<p>Alguns dos recursos técnicos, serviços da AWS e outras ferramentas que foi utilizado no projeto</p>

<div align="center">
    <img src="https://skillicons.dev/icons?i=git,github,bash,aws,ubuntu,docker,kubernetes,terraform,html"/>
    <div align="center">
        <img src="../../../assets/aws/VPC.png" alt="AWS Virtual Private Cloud">
        <img src="../../../assets/aws/EC2.png" alt="AWS Elastic Compute Cloud">
        <img src="../../../assets/aws/ECR.png" alt="AWS Elastic Container Registry">
        <img src="../../../assets/aws/EKS.png" alt="AWS Elastic Kubernetes Service">
        <img src="../../../assets/aws/CodeBuild.png" alt="AWS CodeBuild">
        <img src="../../../assets/aws/CodePipeline.png" alt="AWS CodePipeline">
        <img src="../../../assets/aws/IAM.png" alt="AWS Identity and Access Management">
    </div>
</div>

## Storytelling (Sobre o projeto)

<p>O Gabriel, arquiteto de nuvem, trabalha em uma concessionária vendendo carros da Hyundai, tipo o Hyundai HB20. O seu chefe pediu para que ele criasse uma infraestrutura para hospedar o site da concessionária e solicitou alguns requisitos técnicos:</p>

- Escalabilidade
- Disponibilidade
- Segurança (AWS Secrets Manager)
- Eficiência utilizando Docker (site web será implementado em um container)
- Automatização utilizando:
    - AWS CodeBuild
    - AWS CodePipeline
    - Terraform
    - GitHub (repositório de código)
- Kubernetes (AWS EKS)
    - Kubernetes Horizontal Pod Autoscaler (HPA)
    - Kubernetes replicaSet
    - ReadinessProbe & LivenessProbe

## Requisitos

<p>Atente-se para alguns requisitos antes da execução:</p>

* Conta no Dockerhub
* Conta no GitHub
* Conta da AWS
* Região: us-east-1 (Norte da Virgínia)
* Permissão nos seguintes serviços:
    * AWS IAM
    * AWS VPC
    * AWS EKS
    * AWS ECR
    * AWS CodeBuild & AWS CodePipeline
    * AWS Secrets Manager
* AWS CLI
* AWS EKSCTL
* Kubectl

## Execução

### Step 01 - Ambiente AWS

</p>01 - Na AWS, vá para o serviço IAM e crie um usuário novo com as permissões:</p>

* Acesso ao AWS CLI
* Acesso Administrador (Recomendação: Crie permissões baseada em least privilege)
* Chaves de acesso (salve-as em algum lugar):
    * AWS Access Key
    * AWS Secret Access Key

<p>02 - Ao criar a conta, acesse ela pela AWS.</p>
<p>03 - Crie uma instância EC2 Ubuntu</p>
<p>04 - Acesse a instância EC2 Ubuntu via SSH</p>

```bash
# O Comando abaixo é necessário uma chave PEM da instância
ssh -i chave.pem ubuntu@<PUBLIC_IP>
```
<p>(OPCIONAL) Caso a instância EC2 não tenha AWS CLI instalado, execute: </p>

```bash
sudo apt-get update -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
<p>05 - Crie um arquivo chamado: EKS-Cluster.yaml</p>
<p>06 - Abra o arquivo e cole o conteúdo abaixo:</p>

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: hyundai-cluster
  region: us-east-1

managedNodeGroups:
  - name: workerNode-01
    instanceType: t3.small
    desiredCapacity: 2
```
> O arquivo acima cria um cluster EKS com o nome *hyundai-cluster* na *região us-east-1*, com 2 nodes do *tipo t3.small*

<p>07 - Utilizando as credenciais (AWS Access Key & Secret Access Key), autentique-se na AWS dentro da instância</p>

```bash
aws configure
```

<p>08 - Instale o EKSCTL & Kubectl</p>

```bash
# EKSCTL
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin

# Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Teste ambas CLI
eksctl
kubectl version --client

```

<p>09 - Com o EKSCTL instalado, crie o cluster</p>

```bash
eksctl create cluster -f EKS-Cluster.yaml
```

<p>10 - Aguarde até o cluster EKS ser criado.</p>

### Step 02 - Repositórios GitHub

<p>Seguindo os princípios do Gitflow e GitOps, na parte dos repositórios estruture da seguinte maneira:</p>
<p>01 - Crie um repositório de código chamado: hyundai-project</p>
<p>03 - Crie um repositório para o ambiente de homologação: hyundai-project-hml</p>
<p>05 - No repositório de código crie o arquivo: buildspec.yaml com o seguinte conteúdo:</p>

```yaml
version: 0.2
env:
  secrets-manager: 
    DOCKER_PASSWD: DOCKER_CREDENTIALS:DOCKER_PASSWD
    DOCKER_USR: DOCKER_CREDENTIALS:DOCKER_USR
    GITHUBTOKEN: GHP_TOKEN:GITHUB_CREDENTIAL

phases:
  install:
    run-as: root
    on-failure: ABORT
    commands:
      - echo Installing the system packages
      - echo y | apt-get update
      - echo y | apt-get install figlet
      - echo y | apt-get install git
      - echo y | apt-get install docker.io
      # Instalando AWS CLI
      - echo Configuring Environment Variables
      - echo Checking the Branch
      - export COMMIT_ID=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-5) # COMMIT_ID
      - export PROJECT_NAME=$(echo $CODEBUILD_INITIATOR | cut -d"/" -f2) # PROJECT NAME
      - export ACCOUNT_ID=$(echo $CODEBUILD_BUILD_ARN | cut -d":" -f5) # ACCOUNT ID 
      # Pegando a BRANCH
      - export BRANCH_NAME=$(aws codepipeline get-pipeline --name $PROJECT_NAME | grep "Branch" | cut -d":" -f2 | cut -d'"' -f2) # BRANCH NAME
      - echo "BRANCH :" | figlet
      - echo $BRANCH_NAME | figlet
      - case $BRANCH_NAME in
        main | master | head | HEAD) export BUILD_ENV="-prd" ;;
        hml | homolog) export BUILD_ENV="-hml" ;;
        dev | develop | desenvolvimento) export BUILD_ENV="-dev" ;;
        esac
      - export GIT_REPO="$PROJECT_NAME$BUILD_ENV"
      - git --version
      - docker --version
      # Pegando o DOCKER REPO
      - export DCK_REPO=$(echo $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$PROJECT_NAME)
      # Printando as variaveis que pegou
      - echo "Variables in Cache:"
      - echo "==> Project Name $PROJECT_NAME"
      - echo "==> Commit ID $COMMIT_ID"
      - echo "==> BRANCH Name $BRANCH_NAME"
      - echo "==> Account ID $ACCOUNT_ID"
      - echo "==> Docker REPO $DCK_REPO"
      - echo "==> Region $AWS_DEFAULT_REGION "
      - echo "==> BUILD ENV $BUILD_ENV"
      - echo "==> GIT REPO $GIT_REPO"
  pre_build:
    run-as: root
    on-failure: ABORT
    commands:
      # Construindo a imagem Docker
      - echo DOCKER BUILD | figlet
      - echo $DOCKER_PASSWD > docker_password.txt
      - cat docker_password.txt | docker login --username $DOCKER_USR --password-stdin
      - docker build -t $PROJECT_NAME . -f Dockerfile
      - docker images
      # Jogando a imagem no AWS ECR
      - echo DOCKER PUSH ECR | figlet
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - docker tag $PROJECT_NAME:latest $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$PROJECT_NAME:$COMMIT_ID
      - docker images
      - docker push $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$PROJECT_NAME:$COMMIT_ID
      # DOCKER SCAN STEP
      - echo USING ECR SCAN | figlet
      - status=$(aws ecr describe-image-scan-findings --repository-name $PROJECT_NAME --image-id imageTag=$COMMIT_ID | grep "status" | cut -d'"' -f4)
      - echo $status
      - sleep 10
      - status=$(aws ecr describe-image-scan-findings --repository-name $PROJECT_NAME --image-id imageTag=$COMMIT_ID | grep "status" | cut -d'"' -f4)
      - echo $status
      - while [ $status != "COMPLETE" ]; do echo "SCANNING THE IMAGE $status"; sleep 10; done
      - aws ecr describe-image-scan-findings --repository-name $PROJECT_NAME --image-id imageTag=$COMMIT_ID > vulnerabilities.txt
      - echo VULNERABILITIES | figlet
      - cat vulnerabilities.txt | grep -A 5 -e "HIGH" -e "CRITICAL"
      # TESTANDO SE O CONTAINER DA RESULT 200
      - echo TESTING CONTAINER | figlet
      - docker run -d -p 80:80 --name web-container $PROJECT_NAME
      - sleep 3
      # Verificando status code do web container
      - export status_code=$(docker exec -i web-container curl -I localhost | grep "200" | cut -d" "  -f2)
      - echo $status_code
      - sleep 5
      # Verificando status code do web container se o status for diferente de 200 inicia rollback do push
      - if [ $status_code -eq 200 ]; then 

          echo "STATUS OK = $status_code" | figlet

          docker stop web-container && docker rm web-container && exit 0

        else

          echo "STATUS NOT OK = $status_code" | figlet
          
          echo "ROLLBACK IMAGE PUSH" | figlet

          docker stop web-container && docker rm web-container

          previous_image=$(docker history $PROJECT_NAME | head -n 3 | tail -n 1 | cut -d" " -f1)

          docker tag $previous_image $PROJECT_NAME

          docker push $ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$PROJECT_NAME:$previous_image && exit 1

        fi
      - echo Proceed | figlet
  build:
    run-as: root
    on-failure: ABORT
    commands:
    # STEP DO KUBECTL (instalar)
      - curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      - sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      - kubectl version --client
    # Conectando-se ao CLUSTER:
      - export CLUSTER=$(echo $PROJECT_NAME | cut -d"-" -f1)
      - export CLUSTER_NAME=$CLUSTER-cluster
      - echo $CLUSTER_NAME
      - aws eks update-kubeconfig --name $CLUSTER_NAME
      - kubectl get nodes
    # Verificar se a branch for HML e se for pegar o repo de HML, senao for tentar criar um script de pull request da dev para a main/master/prd
      - if [[ $BRACH_NAME = "master" ]]; then

          echo $BRANCH_NAME | figlet 
    
        else

          echo $BRANCH_NAME | figlet

          git clone https://oauth2:$GITHUBTOKEN@github.com/<git-user>/$GIT_REPO

          cd $GIT_REPO

          echo OLD DEPLOYMENT | figlet

          echo && cat *-dp.yaml

          echo "Criando NAMESPACE"

          namespace=$(cat *-dp.yaml | grep "namespace.*" | cut -d":" -f2)

          echo $namespace

          kubectl create ns $namespace

          cat *-dp.yaml | grep "/" | grep "image" |  sed -i "s|\/$PROJECT_NAME:.*|\/$PROJECT_NAME:$COMMIT_ID|g" *-dp.yaml

          echo NEW DEPLOYMENT | figlet

          echo && cat *-dp.yaml

          git config --global user.email $ACCOUNT_ID

          git config --global user.name "AWS_ACCOUNT"

          git commit -a -m "UPDATE THE IMAGE TO $COMMIT_ID, CodeBuild ID $CODEBUILD_BUILD_ID"

          git push
 
        fi
      - echo Proceed | figlet
  post_build:
    commands:
```

> A Pipeline vai monitorar os commits feitos nas branchs: hml, prd e dev, porém todo o projeto roda apenas na hml. Depois disso vai pegar algumas variáveis importantes como o Commit ID, nome da Branch, repositorio do ECR e outros. Depois desse processo, vai executar algumas etapas de CI onde verifica a imagem utilizando o ECR SCAN, e testa o container para ver se o status da página é 200, caso não for, ele vai tentar executar um Rollback para uma versão anterior. Por fim, a etapa de CD verifica se o repositório é hml e inicia uma alteração da hash do commit na imagem de deployment do EKS e executa um novo commit.

<p>06 - Ainda no repositório de código, crie um arquivo chamado: Dockerfile, com o seguinte conteúdo</p>

```docker
FROM nginx
COPY web/* /usr/share/nginx/html/
RUN mkdir /usr/share/nginx/html/Hyundai
COPY Hyundai/* /usr/share/nginx/html/Hyundai
EXPOSE 80
```

<p>07 - No repositório de código crie um diretório chamado: web</p>
<p>08 - Dentro do diretório web crie um arquivo chamado: index.html, com o seguinte conteúdo </p>

```html
<!DOCTYPE html>
<head>
    <title>Hyundai Project</title>
</head>
<body>
    <h1>HPA Project - 2</h1>
    <a><img src="https://formulanimal.com.br/wp-content/uploads/2024/06/pexels-chevonrossouw-2558605-3-850x394.jpg" width="200"></a>
</body>
```

<p>09 - Não esqueça de verificar se todos os arquivos anteriores estão dentro do repositório no GitHub</p>

<p>02 - Agora, no repositório de código, crie uma outra branch chamada hml</p>

### Step 03 - AWS CodeBuild

01 - Vá para o serviço AWS CodeBuild

02 - Crie um novo projeto:

* Nome: hyundai-project
* Source:
    * Selecione: GitHub
    * Conecte utilizando OAuth
    * Copie a URL do repositório de código na branch de homolog
* Ambiente:
    * Imagem gerenciada: Ubuntu
    * Runtime: Standard
    * Image: aws/codebuild/standard:<latest>
    * Marque a opção: Privilegiado/Privileged
    * Service Role: New Service Role
* Buildspec:
    * Selecione: "Use a buildspec file"
    * Buildspec name: buildspec.yaml
* Logs:
    * Marque a caixa: Cloudwatch logs - optional
    * Group name: hyundai-project
    * Stream name: hpa-
* Crie o projeto do CodeBuild
        
> OBS: Verifique se a Role do AWS CodeBuild tenha acesso ao AWS EKS + AWS Secrets Manager.

### Step 04 - AWS ECR

01 - Crie um AWS Elastic Container Registry

* Visibilidade: Private
* Nome: hyundai-project
* Ative: Scan on Push

### Step 05 - AWS Secrets Manager

> Nesta etapa, troque os valores da secrets para o seu!

01 - Crie as seguintes secrets:

* Secret 01:
    * KEY: DOCKER_PASSWD
    * VALUE: your_docker_hub_password
    * KEY: DOCKER_USR
    * VALUE: your_docker_hub_user
    * Secret Name: DOCKER_CREDENTIALS

* Secret 02:
    * KEY: GITHUB_CREDENTIAL
    * VALUE: your_github_token
    * Secret Name: GHP_TOKEN
    > Caso não tenha criado um acesse: [Como criar um token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

> OBS: Desabilite o Secret Rotation para todas elas.

### Step 06 - AWS IAM

01 - Vá para o IAM
02 - Procure pela role do AWS CodeBuild (que o nosso projeto recem criado utiliza)
03 - Adicione as permissões abaixo

* AWSCodePipelineReadOnlyAccess
* AmazonEC2ContainerRegistryFullAccess
* SecretsManagerReadWrite

04 - Crie uma politica em linha com o seguinte json:

```json
{
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
}
```

### Step 07 - Manifestos Kubernetes

01 - Antes de prosseguir, no repositório: hyundai-project-hml, crie os seguintes arquivos e com seus respectivos conteúdos:

* hyundai-dp.yml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hyundai-project-dp
  namespace: hyundai-project
spec:
  selector:
    matchLabels:
      app: hyundai-project
  replicas: 1
  revisionHistoryLimit: 0
  template:
    metadata:
      labels:
        app: hyundai-project
    spec:
      containers:
        - name: hyundai-project-container
          image: <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/hyundai-project:12345
          imagePullPolicy: Always
          readinessProbe:
              tcpSocket:
                port: 80
              initialDelaySeconds: 30
              periodSeconds: 10
          livenessProbe:
              tcpSocket:
                port: 80
              initialDelaySeconds: 15
              periodSeconds: 20
      imagePullSecrets:
        - name: ecr-registry
```

<br>

* hyundai-svc.yml
```
apiVersion: v1
kind: Service
metadata:
  name: hyundai-project-svc
  namespace: hyundai-project
spec:
  ports:
  - port: 80
  selector:
    app: hyundai-project
```

<br>

* hyundai-in.yml
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hyundai-project-in
  namespace: hyundai-project
  annotations:
  # use the shared ingress-nginx
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: ingress.ddns.net
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hyundai-project-svc
            port:
              number: 80
```

> Substitua os itens entre "<>" com o seu respectivo valor

### Step 08 - AWS CodePipeline

01 - Crie uma pipeline no AWS CodePipeline com as seguintes configurações:

* Pipeline Name: hyundai-project
* Service Role: New Service Role
* Add source stage:
    * Source Provide: Github
    * Conecte no Github
    * Repository: hyundai-project
    * Branch: hml ou homolog
    * Detection Options: AWS CodePipeline
* Add build stage:
    * Build provider: AWS CodeBuild
    * Project Name: hyundai-project
* Pule o Deploy stage/provider

### Step 09 - Configure o ConfigMap do EKS Cluster

01 - Na instancia EC2 que está pré-configurada com o aws configure, eksctl e kubectl, execute o seguinte comando:
```bash
aws eks update-kubeconfig --name hyundai-cluster --region us-east-1
```

02 - Agora edite o configmap do aws-auth, execute:
```
kubectl edit -n kube-system cm aws-auth
``` 

03 - Com muito cuidado, na seção MapRoles, adicione:
```yaml
- groups:
      - system:masters
      rolearn: arn:aws:iam::<account-id>:role/<codebuild-role-name>
      username: <codebuild-role-name>
```
> Substitua pelo os campos "<>" seus respectivos valores.

> Essa permissão faz com que o AWS CodeBuild execute solicitações via kubectl CLI dentro do cluster, como por exemplo: criar namespaces.

### Step 10 - Crie a Docker Secret para o EKS

01 - Ainda na instância EC2, execute:
```bash
aws ecr get-login-password --region <aws-region> | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com
```
> Esse comando se autentica no AWS ECR que você criou, não se esqueça de substituir os conteúdos entre "<>" pelo seus respectivos valores.

> Talvez esse comando só funcione com o usuário root!

02 - No diretório do usuário autenticado no AWS ECR, execute:
```bash
cat .docker/config.json 
```

03 - Copie o valor de auth no comando anterior e execute:
```bash
  kubectl create secret docker-registry ecr-registry --docker-server=https://<account-id>.dkr.ecr.<aws-region>.amazonaws.com --docker-username=AWS --docker-password=<auth-value> -n <namespace>
```

> Substitua os campos entre "<>" pelo seus respectivos valores!

### Step 11 - Atribua uma permissão aos Nodes EKS

01 - No serviço AWS EKS, procure pela permissão que o seus worker nodes estão utilizando

02 - Edite a permissão colocando uma política em linha com o seguinte conteúdo:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": "arn:aws:ecr:*:<account-id>:repository/*"
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
}
```
> Substitua os campos entre "<>" pelo seus respectivos valores!

### Step 12 - Aplique os manifestos e o HPA

01 - No cluster, crie o seguinte namespace:
```
kubectl create ns -n hyundai-project
```

02 - Aplique todos os manifestos do Kubernetes. Para isto, copie os manifestos (arquivos yml) que você criou no repositório "hyundai-project-hml" e aplique-os no cluster executando o seguinte comando:
```bash
kubectl apply -f <nome-do-arquivo>.yml
```

03 - Após aplicar todos os arquivos, aplique o Horizontal Pod Autoscaler (HPA), execute:
```bash
kubectl autoscale deployment -n hyundai-project hyundai-project-dp --cpu-percent=50 --min=1 --max=10
```

## Download do Terraform

Abaixo, disponibilizo um link para você baixar ou copiar o conteúdo do script do Terraform

[Clique aqui para visualizar o Terraform](https://raw.githubusercontent.com/cl0uD-C1SC0/PersonalBlog/refs/heads/main/docs/assets/projects_files/hyundai_hpa/tf-architecture.tf)

## Conclusão

Todo o projeto foi seguindo as práticas de GitOps e Gitflow, não todas é claro. A ideia principal do projeto é criar o HPA, porém como requisito foi necessário criar uma automação utilizando o AWS CodeBuild e o AWS CodePipeline. 

O arquivo de configuração do AWS CodeBuild (buildspec.yml) ele é simples e não faz muita coisa não, ele só atende a branch de homolog/hml, mas mesmo de forma simples, ele cumpre o que faz. 

O Script do Terraform faz algumas coisas:

* Cria uma VPC completa
* Cria a política do EKS no IAM
* Cria um cluster EKS
* Cria uma política do IAM para as Worker Nodes
* Cria um grupo de Nodes
* Cria as secrets do Secret Manager
* Cria o IAM do EKS Describre para o AWS CodeBuild + política do AWS CodeBuild
* Configura o AWS CodeBuild
* Cria o AWS ECR

> Importante ressaltar que: É necessário ver todo o script do Terraform e substituir os valores entre "<>" para o seu valor que você deseja. 


