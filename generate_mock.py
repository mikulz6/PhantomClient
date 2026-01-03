import json
import random

# 读取已有的真实数据
with open("assets/json/steam_games_data.json", "r") as f:
    base_data = json.load(f)

expanded_data = []
categories = ["RPG", "FPS/TPS", "动作冒险", "竞速狂飙", "独立佳作", "策略模拟"]

# 扩充到 1000
for i in range(1000):
    # 随机取一个模板
    template = random.choice(base_data)
    
    # 深度拷贝
    new_game = template.copy()
    
    # 修改 ID 防止重复 (key冲突)
    new_game["id"] = i + 100000 
    
    # 随机分配一个分类 (如果模板没有 category 字段)
    if "category" not in new_game or new_game["category"] == "其他":
        new_game["category"] = random.choice(categories)
        
    # 为了演示，稍微改个名
    # new_game["name"] = f"{template['name']} ({i})" 
    
    expanded_data.append(new_game)

# 写入
with open("assets/json/steam_games_data_mock.json", "w") as f:
    json.dump(expanded_data, f, ensure_ascii=False, indent=2)

print("生成了 1000 条测试数据 assets/json/steam_games_data_mock.json")
