package cache

import (
	"context"
	"fmt"

	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/config"
	"github.com/redis/go-redis/v9"
)

// Client is the global Redis client. It may be nil if Redis is unavailable.
var Client *redis.Client

// Connect initialises the Redis client and verifies connectivity.
func Connect(cfg *config.RedisConfig) error {
	Client = redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("%s:%s", cfg.Host, cfg.Port),
		Password: cfg.Password,
		DB:       cfg.DB,
	})

	ctx := context.Background()
	if _, err := Client.Ping(ctx).Result(); err != nil {
		Client = nil
		return fmt.Errorf("failed to connect to Redis: %w", err)
	}

	return nil
}

// Close closes the Redis connection.
func Close() error {
	if Client != nil {
		return Client.Close()
	}
	return nil
}
