
## Autosql 인프라 구조

![infra-Infra drawio](https://user-images.githubusercontent.com/96629089/174983580-66bc6cb5-c70a-4f79-8086-d7195b02c8d3.png)

### 이슈
- 현재 개발 환경의 Cloudfront 를 내리고 각 Bucket 으로 proxy 를 위한 nginx 서버를 둠
- RDS는 VPC 내에서 접근 가능하므로 Bastion Host 를 통해 RDS mysql 접속 및 데이터 Restore


## Autosql 인프라 네트워크 및 보안 구조

![infra-Network drawio](https://user-images.githubusercontent.com/96629089/174983627-883cfb63-bf84-4a4d-ae44-c0d46973b519.png)
