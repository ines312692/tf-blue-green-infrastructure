[
  {
    "name": "${container_name}",
    "image": "${container_image}",
    "cpu": 0,
    "portMappings": [
      {
        "name": "${container_name}-${container_port}-tcp",
        "containerPort": ${container_port},
        "hostPort": ${container_port},
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "environment": [
      {
        "name": "ENVIRONMENT",
        "value": "${environment_name}"
      },
      {
        "name": "PORT",
        "value": "${container_port}"
      }
    ],
    "environmentFiles": [],
    "mountPoints": [],
    "volumesFrom": [],
    "ulimits": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${log_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -f http://localhost:${container_port}/health || exit 1"
      ],
      "interval": 30,
      "timeout": 5,
      "retries": 3,
      "startPeriod": 60
    }
  }
]