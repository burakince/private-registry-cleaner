# Docker Private Registry Cleaner

## Environment Variables

| Env Variable                   | Description                           | Required | Default |
| ------------------------------ | ------------------------------------- | -------- | ------- |
| PLUGIN_USERNAME                | Docker username                       | Required |         |
| PLUGIN_PASSWORD                | Docker password                       | Required |         |
| PLUGIN_HOST                    | Registry to target                    | Required |         |
| PLUGIN_SCHEMA                  | Registry address schema               | Optional | https   |
| PLUGIN_PORT                    | Registry port                         | Optional | 443     |
| PLUGIN_REPO                    | Repository to target                  | Required |         |
| PLUGIN_MIN                     | Minimum number of tags/images to keep | Optional | 3       |
| PLUGIN_MAX                     | Maximum age of tags/images in days    | Optional | 15      |
| PLUGIN_DEBUG                   | Show verbose information              | Optional | false   |
| PLUGIN_IGNORE_SSL_VERIFICATION | Skip TLS verification                 | Optional | false   |

## CLI Usage

```
PLUGIN_IGNORE_SSL_VERIFICATION=true \
  PLUGIN_USERNAME=myusername \
  PLUGIN_PASSWORD=mypassword \
  PLUGIN_HOST=localhost \
  PLUGIN_SCHEMA=http \
  PLUGIN_PORT=5000 \
  PLUGIN_REPO=myorg/myimage \
  ./run.sh
```

## Image Usage

```
docker run \
  -e PLUGIN_IGNORE_SSL_VERIFICATION=true \
  -e PLUGIN_USERNAME=myusername \
  -e PLUGIN_PASSWORD=mypassword \
  -e PLUGIN_HOST=localhost \
  -e PLUGIN_SCHEMA=http \
  -e PLUGIN_PORT=5000 \
  -e PLUGIN_REPO=myorg/myimage \
  --rm -it burakince/private-registry-cleaner
```

## Drone CI Plugin Usage

```
kind: pipeline
name: default

steps:
- name: registry-clean
  image: burakince/private-registry-cleaner
  settings:
    username: myusername
    password: mypassword
    host: myregistryhost
    repo: myorg/myimage
    ignore_ssl_verification: true
```
