package main

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

func main() {
	r := gin.Default()

	// 开启自动运维看门狗
	StartWatchdog()

	// API: 获取状态
	r.GET("/status", func(c *gin.Context) {
		status, _ := GetSystemStatus()
		c.JSON(http.StatusOK, status)
	})

	// API: 手动重启 Sunshine
	r.POST("/restart", func(c *gin.Context) {
		err := RestartSunshine()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"message": "Sunshine restarted successfully"})
	})

    // 监听 19000 端口 (避免和 Sunshine 的 47989 冲突)
	r.Run(":19000") 
}
