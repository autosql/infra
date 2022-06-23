
## Autosql 인프라 구조

![infra-Infra drawio](https://user-images.githubusercontent.com/96629089/175305838-6918904a-684a-42fb-8ba9-65977bb293c1.png)

### 이슈
- 현재 개발 환경의 Cloudfront 를 내리고 각 Bucket 으로 proxy 를 위한 nginx 서버를 둠
- RDS는 VPC 내에서 접근 가능하므로 Bastion Host 를 통해 RDS mysql 접속 및 데이터 Restore


## Autosql 인프라 네트워크 및 보안 구조

![infra-Network drawio](https://user-images.githubusercontent.com/96629089/175305863-6e28b082-b9b2-40c0-82b0-060414faf8e6.png)
