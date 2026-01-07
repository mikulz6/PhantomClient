package main

import (
	"fmt"
	"log"
	"os/exec"
	"runtime"
	"time"
)

// Watchdog 负责监控 Sunshine 进程
func StartWatchdog() {
	ticker := time.NewTicker(10 * time.Second)
	go func() {
		for range ticker.C {
			checkAndHeal()
		}
	}()
}

func checkAndHeal() {
	status, err := GetSystemStatus()
	if err != nil {
		log.Println("Error getting system status:", err)
		return
	}

	// 1. 进程存活检查
	if !status.IsRunning {
		log.Println("⚠️ Sunshine is NOT running! Attempting restart...")
		RestartSunshine()
	}

	// 2. 内存泄漏检查 (如果内存占用超过 90%)
	if status.MemUsage > 90.0 {
		log.Printf("⚠️ Memory usage critical (%.2f%%)! Restarting Sunshine to free resources...\n", status.MemUsage)
		RestartSunshine()
	}
}

func RestartSunshine() error {
	log.Println("🔄 Executing RestartSunshine...")
	
	// 1. 杀进程
	killCmd := "pkill sunshine"
	if runtime.GOOS == "windows" {
		killCmd = "taskkill /F /IM sunshine.exe"
	}
	exec.Command("sh", "-c", killCmd).Run() // Windows 下可能需要调整 shell
    if runtime.GOOS == "windows" {
        exec.Command("cmd", "/C", killCmd).Run()
    }

	// 2. 等待释放
	time.Sleep(2 * time.Second)

	// 3. 启动进程
	// 注意：这里需要替换为 Sunshine 的真实安装路径
    var startCmd *exec.Cmd
    if runtime.GOOS == "windows" {
        startCmd = exec.Command("C:\\Program Files\\Sunshine\\sunshine.exe") // 假设路径
    } else {
        startCmd = exec.Command("sunshine")
    }
	
	err := startCmd.Start()
	if err != nil {
		log.Println("❌ Failed to start Sunshine:", err)
		return err
	}
	log.Println("✅ Sunshine started successfully!")
	return nil
}
