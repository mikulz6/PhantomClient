package main

import (
	"fmt"
	"runtime"
	"time"

	"github.com/shirou/gopsutil/v3/cpu"
	"github.com/shirou/gopsutil/v3/mem"
	"github.com/shirou/gopsutil/v3/process"
)

type SystemStatus struct {
	CPUUsage    float64 `json:"cpu_usage"`
	MemUsage    float64 `json:"mem_usage"`
	MemTotal    uint64  `json:"mem_total"`
	MemUsed     uint64  `json:"mem_used"`
	OS          string  `json:"os"`
	Arch        string  `json:"arch"`
	SunshinePID int32   `json:"sunshine_pid"`
	IsRunning   bool    `json:"sunshine_running"`
}

func GetSystemStatus() (*SystemStatus, error) {
	v, _ := mem.VirtualMemory()
	c, _ := cpu.Percent(time.Second, false)

	status := &SystemStatus{
		MemUsage: v.UsedPercent,
		MemTotal: v.Total,
		MemUsed:  v.Used,
		OS:       runtime.GOOS,
		Arch:     runtime.GOARCH,
	}

	if len(c) > 0 {
		status.CPUUsage = c[0]
	}

	// 检查 Sunshine 进程
	procs, _ := process.Processes()
	for _, p := range procs {
		name, err := p.Name()
		if err == nil && (name == "sunshine" || name == "sunshine.exe") {
			status.SunshinePID = p.Pid
			status.IsRunning = true
			break
		}
	}

	return status, nil
}

// 模拟获取 Nvidia 显卡信息 (真实环境需要调用 nvidia-smi)
func GetGPUStatus() string {
    // TODO: 实现 exec.Command("nvidia-smi", ...)
    return "Nvidia GPU Monitor Pending"
}
