#pragma once

#ifdef _WIN32
#include <windows.h>
#include <string>
#include <iostream>

namespace sunshine {
namespace virt_display {

    // 简单的日志宏，实际应对接 Sunshine 的日志系统
    #define LOG_INFO(msg) std::cout << "[VirtualDisplay] " << msg << std::endl

    inline void SetResolution(int width, int height, int refreshRate) {
        LOG_INFO("Attempting to set resolution to " << width << "x" << height << "@" << refreshRate);

        DEVMODE dm;
        ZeroMemory(&dm, sizeof(dm));
        dm.dmSize = sizeof(dm);

        // 获取当前设置作为基底
        if (!EnumDisplaySettings(NULL, ENUM_CURRENT_SETTINGS, &dm)) {
            LOG_INFO("Failed to enumerate current display settings.");
            return;
        }

        // 设置目标参数
        dm.dmPelsWidth = width;
        dm.dmPelsHeight = height;
        dm.dmDisplayFrequency = refreshRate;
        
        // 标记我们要修改的字段
        dm.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT | DM_DISPLAYFREQUENCY;

        // 尝试 1: 完整修改 (分辨率 + 刷新率)
        LONG result = ChangeDisplaySettingsEx(NULL, &dm, NULL, CDS_UPDATEREGISTRY | CDS_GLOBAL, NULL);
        
        if (result == DISP_CHANGE_SUCCESSFUL) {
            LOG_INFO("Successfully changed resolution and refresh rate.");
            return;
        }

        // 尝试 2: 如果失败，尝试只修改分辨率 (忽略刷新率，有些虚拟驱动对刷新率不敏感)
        LOG_INFO("Failed to set refresh rate, trying resolution only...");
        dm.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT;
        result = ChangeDisplaySettingsEx(NULL, &dm, NULL, CDS_UPDATEREGISTRY | CDS_GLOBAL, NULL);

        if (result == DISP_CHANGE_SUCCESSFUL) {
            LOG_INFO("Successfully changed resolution only.");
        } else {
            LOG_INFO("Failed to change resolution. Error code: " << result);
            // 这里可以添加更高级的 CCD API (SetDisplayConfig) 作为 fallback，但这通常足够了
        }
    }
}
}
#endif
