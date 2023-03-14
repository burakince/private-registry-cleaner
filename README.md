# Docker Private Registry Cleaner

## Environment Variables

| Env Variable                   | Description                           | Required | Default |
| ------------------------------ | ------------------------------------- | -------- | ------- |
| PLUGIN_USERNAME                | Docker username                       | Yes      |         |
| PLUGIN_PASSWORD                | Docker password                       | Yes      |         |
| PLUGIN_HOST                    | Registry to target                    | Yes      |         |
| PLUGIN_SCHEMA                  | Registry address schema               | Not      | https   |
| PLUGIN_PORT                    | Registry port                         | Not      | 443     |
| PLUGIN_REPO                    | Repository to target                  | Yes      |         |
| PLUGIN_MIN                     | Minimum number of tags/images to keep | Not      | 3       |
| PLUGIN_MAX                     | Maximum age of tags/images in days    | Not      | 15      |
| PLUGIN_DEBUG                   | Show verbose information              | Not      | false   |
| PLUGIN_IGNORE_SSL_VERIFICATION | Skip TLS verification                 | Not      | false   |

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
    image: burakince/private-registry-cleaner:1.0.0
    pull: if-not-exists
    settings:
      username:
        from_secret: docker_username
      password:
        from_secret: docker_password
      host: myregistryhost
      repo: myorg/myimage
      ignore_ssl_verification: true
```
