# Ello.Stream

Returns post streams for category and following by querying our Roshi backed
stream service.

Queries `ello-stream` service while handling minimum page sizes and proper
nsfw/nudity/blocked filtering.

Uses and depends on Ello.Core to filter and retrieve authoritative post data.

Check out our Roshi backed Go
[Ello Stream Service](https://github.com/ello/streams) to learn more.

## Configuration

Ello.Core expects the following environmental variables in production
(like) environments:

- `STREAM_SERVICE_URL` – URL to stream service, defaults to docker dev URL
- `STREAM_SERVICE_USER` – username to stream service, defaults to docker dev’s
  `ello`
- `STREAM_SERVICE_PASSWORD` – password for stream service, defaults to docker
  dev’s `password`
