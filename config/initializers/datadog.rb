Datadog.configure do |c|
  c.tracer env: Rails.env
  c.tracer enabled: ENV["DD_API_KEY"].present?
  c.tracer partial_flush: true

  # Multiple Redis integrations to split Redis usage per-instance to
  # accommodate having a different Redis instance for each use case.
  c.use :redis, service_name: "redis-rpush", describes: { url: ENV["REDIS_RPUSH_URL"] }
  c.use :redis, service_name: "redis-sessions", describes: { url: ENV["REDIS_SESSIONS_URL"] }

  # Sidekiq jobs that spin up thousands of other jobs end up consuming a
  # *lot* of memory on instrumentation alone. This env var allows us to
  # enable it only when needed.
  if ENV["DD_ENABLE_REDIS_SIDEKIQ"] == "true"
    c.use :redis, service_name: "redis-sidekiq", describes: { url: ENV["REDIS_SIDEKIQ_URL"] }
  end

  # Generic REDIS_URL comes last, allowing it to overwrite any of the
  # above when multiple Redis use cases are backed by the same Redis URL.
  c.use :redis, service_name: "redis", describes: { url: ENV["REDIS_URL"] }
end

ForemStatsClient = Datadog::Statsd.new
