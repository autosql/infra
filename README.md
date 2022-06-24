# Autosql 인프라

**dev 환경 구조**

<img width="500" src="https://user-images.githubusercontent.com/96629089/175305838-6918904a-684a-42fb-8ba9-65977bb293c1.png">

- [프론트엔드 - 렌딩 페이지 HTML 및 리엑트 앱](https://github.com/autosql/frontend)
- [백엔드 API 서버](https://github.com/autosql/backend)

**네트워크 및 보안 구조**

<img width="400" src="https://user-images.githubusercontent.com/96629089/175305863-6e28b082-b9b2-40c0-82b0-060414faf8e6.png">

## 테라폼 모듈

### 프로젝트 변수
|Name| Type     | Default        |Description|
|----|----------|----------------|-----------|
|app| `string` | autosql        | 어플리케이션 명  |
|domain| `string` | autosql.co.kr  |어플리케이션 최상위 도메인|
|region| `string`   | ap-northeast-2 |AWS Region|

<br><br>

### VPC
<hr>

#### Resources
|Name| Type     |
|----|----------|
|aws_vpc| resource |
|aws_subnet| resource |
|aws_internet_gateway| resource |
|aws_route_table| resource |
|aws_route_table_association| resource |

#### Inputs
| Name | Description | Type | Default | Required |
|------|----------|------|-------|:--------:|
|app|어플리케이션 명|`string`|autosql|yes|
|env|배포 환경|`string`|terraform.workspace|yes|
|vpc_cidr|vpc의 cidr|`string`|10.0.0.0/16|no|
|public_subnets|가용영역 a와 b의 서브넷 cidr|`list(string)`|["10.0.1.0/24", "10.0.2.0/24"]|no|

#### Outputs
|Name|Description|
|----|-----------|
|vpc_id|배포된 vpc id|
|public_subnet_ids|ap-northeast-2a와 ap-northeast-2b에 배포된 서브넷 아이디의 리스트|

<br><br>

### Frontend
<hr>

#### Resources
`bucket.tf`

|Name| Type               |
|----|--------------------|
|aws_s3_bucket| resource(for_each) |
|aws_s3_bucket_website_configuration| resource(for_each) |
|aws_iam_policy_document|resource(for_each)|
|aws_s3_bucket_policy|resource(for_each)|
|aws_s3_bucket_acl|resource(for_each)|

`proxy_instance.tf`

|Name|Type|
|----|----|
|aws_security_group|resource|
|aws_eip|resource|
|aws_instance|resource|

`ssm_parameter.tf`

|Name| Type               |
|----|--------------------|
|aws_ssm_parameter|resource(for_each)|

`route53.tf`

|Name|Type|
|----|----|
|aws_route53_zone|resource|
|aws_route53_record|resource|


#### Inputs
| Name | Description             | Type     | Default                  | Required |
|------|-------------------------|----------|--------------------------|:-----:|
|app| 어플리케이션 명                | `string` | autosql                  |   yes |
|env| 배포 환경                   | `string` | terraform.workspace      |   yes |
|domain| 어플리케이션 최상위 도메인          | `string`  | autosql.co.kr            |   yes |
|region| Region                  |`string`| ap-northeast-2           |   yes |
|vpc_id| 개발환경의 vpc id            |`string`| `terraform_remote_state` |   yes |
|public_subnet_ids| 개발환경 vpc 내의 subnet의 리스트 |`list(string)`| `terraform_remote_state` |   yes |
|bucket_names|랜딩페이지 버킷과 리엑트 앱 버킷|`list(string)`|["landing", "erd"]|   yes |
|bucket_acl|버킷의 acl|`string`|"public-read"|yes|


#### Outputs

| Name              |Description|
|-------------------|-----------|
| website_endpoints |생성된 버킷들의 website endpoints|

<br><br>

### Backend
<hr>

#### Resources

`loadbalancer.tf`

|Name| Type     |
|----|----------|
|aws_security_group|resource|
|aws_lb|resource|
|aws_lb_listener|resource|
|aws_lb_listener_rule|resource|
|aws_lb_target_group|resource|

`elastic-container-registry.tf`

|Name| Type     |
|----|----------|
|aws_ecr_repository|resource|
|aws_ecr_lifecycle_policy|resource|

`elastic-container-service.tf`

|Name| Type     |
|----|----------|
|aws_security_group|resource|
|aws_iam_policy_document|data|
|aws_iam_role|resource|
|aws_iam_role_policy|resource|
|aws_iam_role_policy_attachment|resource|
|template_file|data|
|aws_ecs_task_definition|resource|
|aws_ecs_cluster|resource|
|aws_ecs_service|resource|

`autoscaling.tf`

|Name| Type     |
|----|----------|
|aws_appautoscaling_target|resource|
|aws_appautoscaling_policy|resource(for_each)|

`ssm_parameter.tf`

|Name| Type     |
|----|----------|
|aws_ssm_parameter|resource|

`route53.tf`

|Name| Type     |
|----|----------|
|aws_route53_zone|resource|
|aws_route53_record|resource|
|aws_acm_certificate|resource|
|aws_acm_certificate_validation|resource|

`codecommit.tf`

|Name| Type     |
|----|----------|
|aws_caller_identity|data|
|template_file|data|
|aws_codecommit_repository|resource|

`codedeploy.tf`

|Name| Type     |
|----|----------|
|aws_iam_policy_document|data|
|aws_iam_role|resource|
|aws_iam_role_policy|resource|
|aws_iam_role_policy_attachment|resource|
|aws_codedeploy_app|resource|
|aws_codedeploy_deployment_group|resource|

`codepipeline.tf`

|Name| Type     |
|----|----------|
|aws_s3_bucket|resource|
|aws_iam_policy_document|data|
|aws_iam_role|resource|
|aws_iam_role_policy|resource|
|aws_codepipeline|resource|

#### Inputs

| Name | Description                                       | Type | Default                  | Required |
|------|---------------------------------------------------|------|--------------------------|:--------:|
|app| 어플리케이션 명                                          | `string` | autosql                  |   yes |
|env| 배포 환경                                             | `string` | terraform.workspace      |   yes |
|domain| 어플리케이션 최상위 도메인                                    | `string`  | autosql.co.kr            |   yes |
|region| Region                                            |`string`| ap-northeast-2           |   yes |
|vpc_id| 개발환경의 vpc id                                      |`string`| `terraform_remote_state` |   yes |
|public_subnet_ids| 개발환경 vpc 내의 subnet의 리스트                           |`list(string)`| `terraform_remote_state` |   yes |
|desired_count| ecs FARGATE 서비스 Desired 갯수                        |`number`| 1                        |yes|
|min_capacity| 어플리케이션 오토스케일링 - ecs FARGATE 서비스 최소값               |`number`| 1                        |yes|
|max_capacity| 어플리케이션 오토스케일링 - ecs FARGATE 서비스 최대값               |`number`| 3                        |yes|
|scale_policy| 어플리케이션 오토스케일링 정책                                  |`map(number)`|                          |yes|
|scale_policy.ECSServiceAverageCPUUtilization| CPU 사용량 퍼센트                                       |`number`| 60                       |yes|
|scale_policy.ECSServiceAverageMemoryUtilization| Memory 사용량 퍼센트                                    |`number`| 80                       |yes|
|host_port| ecs 서비스 작업의 호스트 포트                                |`number`| 80                       |yes|
|container_port| ecs 서비스 작업의 컨테이너 포트                               |`number`| 3000                     |yes|
|container_spec_path| data.template_file 의 템플릿 파일 경로                    |`string`| backend.config.json.tpl  |yes|
|MYSQL_USERNAME| data.template_file 의 변수 - 데이터베이스 사용자              |`string`| admin                    |yes|
|MYSQL_DATABASE| data.template_file 의 변수 - 데이터베이스 명                |`string`|autosql|yes|
|taskdef_path| codecommit - data.template_file 의 작업정의 파일 경로      |`string`|taskdef.json|yes|
|appspec_path| codecommit - data.template_file 의 앱스펙 파일 경로|`string`|appspec.yaml|yes|

#### Outputs

|Name| Description   |
|----|---------------|
|repository_url| ecr 레포지토리 url |
|api_domain_name|acm 이 적용된 loadbalancer 의 A 레코드|

<br><br>

### Database
<hr>

#### Resources

`rds.tf`

|Name| Type     |
|----|----------|
|aws_db_subnet_group|resource|
|aws_db_instance|resource|
|aws_security_group|resource|

`ssm_parameter.tf`

|Name| Type     |
|----|----------|
|aws_ssm_parameter|resource|

#### Inputs

| Name | Description | Type | Default | Required |
|------|----------|------|-------|:--------:|
|app| 어플리케이션 명| `string` | autosql                  |   yes |
|env| 배포 환경| `string` | terraform.workspace      |   yes |
|domain| 어플리케이션 최상위 도메인| `string`  | autosql.co.kr            |   yes |
|region| Region|`string`| ap-northeast-2           |   yes |
|vpc_id| 개발환경의 vpc id|`string`| `terraform_remote_state` |   yes |
|public_subnet_ids| 개발환경 vpc 내의 subnet의 리스트 |`list(string)`| `terraform_remote_state` |   yes |
|instance_type|RDS mysql의 인스턴스 타입|`string`|db.t2.micro|yes|
|database_port|RDS mysql의 데이터베이스 포트|`number`|3306|yes|
|MYSQL_USER|데이터베이스 사용자명|`string`|admin|yes|
|MYSQL_PASSWORD|데이터베이스 사용자 암호|`string`|TF_VAR_MYSQL_PASSWORD|yes|

#### Outputs

|Name| Description   |
|----|---------------|
|address|데이터베이스 웹 endpoint|

<br><br>

## 이슈
- 현재 개발 환경의 Cloudfront 대신 프론트엔드 버킷에 proxy를 위한 nginx 서버 인스턴스를 사용 중
- RDS는 VPC 내에서 접근 가능하므로 Bastion Host 를 통해 RDS mysql 접속하여 데이터 Restore