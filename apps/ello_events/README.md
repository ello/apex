# Ello.Events

Responsible for tasks that need to be processed in the background.  The public
API is `Ello.Events.publish(%Event{})`, where `%Event{}` implements the
`Ello.Event` behavior.  In this way, we can support multiple background queueing
mechanisms, e.g. Sidekiq or a simple Elixir `Task`.

# Creating New Events

Take a look at `Ello.Events.CountPostView` and `Ello.Events.Sidekiq`.  This is
an example of implementing an event that is pushed to the redis/sidekiq event
queue.  If you create another event handler, just implement a suitable `publish`
function and start your background process/queueing there.

# Events

### `CountPostView`

```elixir
Ello.Events.publish(%CountPostView{
  post_ids: [1, 2, 3],
  user_id: 666,
  stream_kind: "following",
  stream_id: nil,
})
```
