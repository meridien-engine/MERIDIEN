package middleware

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/mu7ammad-3li/MERIDIEN/backend/internal/utils"
	"github.com/redis/go-redis/v9"
)

// RateLimiter is a fixed-window rate limiter backed by Redis.
type RateLimiter struct {
	client *redis.Client
	limit  int
	window time.Duration
}

// NewRateLimiter creates a RateLimiter that allows at most limit requests per window per IP.
func NewRateLimiter(client *redis.Client, limit int, window time.Duration) *RateLimiter {
	return &RateLimiter{client: client, limit: limit, window: window}
}

// Middleware returns a Gin handler that enforces the rate limit.
// On Redis errors it fails open (allows the request through).
func (rl *RateLimiter) Middleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		ip := c.ClientIP()
		// Window key bucketed by truncated Unix timestamp so windows are aligned.
		bucket := time.Now().Truncate(rl.window).Unix()
		key := fmt.Sprintf("rate:%s:%s:%d", c.FullPath(), ip, bucket)

		ctx := context.Background()

		count, err := rl.client.Incr(ctx, key).Result()
		if err != nil {
			// Redis unavailable — fail open.
			c.Next()
			return
		}

		// Set TTL on first increment.
		if count == 1 {
			rl.client.Expire(ctx, key, rl.window)
		}

		if count > int64(rl.limit) {
			utils.ErrorResponse(c, http.StatusTooManyRequests, "Too many requests, please try again later")
			c.Abort()
			return
		}

		c.Next()
	}
}
