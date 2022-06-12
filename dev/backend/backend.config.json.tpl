[
  {
    "name": "${app_prefix}",
    "image": "${aws_ecr_repository}:${tag}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${container_port},
        "protocol": "tcp"
      }
    ],
    "cpu": 256,
    "memory": 512,
    "environment": [
      {
        "name": "PORT",
        "value": "${container_port}"
      },
      {
        "name": "MYSQL_USERNAME",
        "value": "${MYSQL_USERNAME}"
      },
      {
        "name": "MYSQL_DATABASE",
        "value": "${MYSQL_DATABASE}"
      }
    ]
  }
]
