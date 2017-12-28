# Ello.Grandstand

Grandstand API Client. Makes authenticated requests to Grandstand API and
returns parsed data.

## Usage:

Currently only daily impressions are supported.

```elixir
# Daily Impressions for a given artist_invite (will use opened_at -> now)
Grandstand.daily_impressions(%{artist_invite: artist_invite})
#> [%Grandstand.Impression{}]

# Total Impressions for a given artist_invite (will use opened_at -> now)
Grandstand.daily_impressions(%{artist_invite: artist_invite})
#> [%Grandstand.Impression{}]
```

## Testing:

During testing a fake client is used by default. Fake data can be added:

```elixir
Grandstand.TestClient.add(%Grandstand.Impression{artist_invite: id, date: date, stream_kind: "following", impressions: 10})
Grandstand.TestClient.reset!
```
