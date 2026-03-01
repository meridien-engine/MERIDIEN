package cache

import (
	"context"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

const blacklistPrefix = "token:blacklist:"

// TokenBlacklist manages revoked JWT tokens in Redis.
type TokenBlacklist struct {
	client *redis.Client
}

// NewTokenBlacklist creates a new TokenBlacklist backed by the given Redis client.
func NewTokenBlacklist(client *redis.Client) *TokenBlacklist {
	return &TokenBlacklist{client: client}
}

// Add inserts a JTI into the blacklist with the given TTL (should match remaining token lifetime).
func (b *TokenBlacklist) Add(jti string, ttl time.Duration) error {
	if ttl <= 0 {
		// Token already expired; no need to store.
		return nil
	}
	ctx := context.Background()
	key := fmt.Sprintf("%s%s", blacklistPrefix, jti)
	return b.client.Set(ctx, key, "1", ttl).Err()
}

// IsBlacklisted reports whether the given JTI has been revoked.
func (b *TokenBlacklist) IsBlacklisted(jti string) (bool, error) {
	ctx := context.Background()
	key := fmt.Sprintf("%s%s", blacklistPrefix, jti)
	n, err := b.client.Exists(ctx, key).Result()
	if err != nil {
		return false, err
	}
	return n > 0, nil
}
