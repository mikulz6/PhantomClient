import json
import random

# 读取已有的真实数据
try:
    with open("assets/json/steam_games_data.json", "r") as f:
        base_data = json.load(f)
except:
    # 如果没有真实数据，就用空列表防止报错
    base_data = []

# 如果真实数据太少，或者没有，我们需要一些硬编码的模板来启动
if len(base_data) < 5:
    base_data = [
        {"id": 1, "name": "Cyberpunk 2077", "header_image": "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg", "poster_image": "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1091500/library_600x900.jpg", "tags": ["RPG", "开放世界"], "categories": ["开放世界", "赛博朋克", "CDPR"]},
        {"id": 2, "name": "Elden Ring", "header_image": "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1245620/header.jpg", "poster_image": "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1245620/library_600x900.jpg", "tags": ["魂类", "RPG"], "categories": ["魂与类魂", "开放世界", "万代"]},
    ]

expanded_data = []
# 扩展后的分类池
categories_pool = [
    "JRPG", "ARPG", "开放世界", "射击游戏", "恐怖惊悚", 
    "肉鸽莱克", "策略模拟", "格斗竞技", "双人合作", "赛博朋克", 
    "二次元", "魂与类魂", "运动竞速", "独立佳作", "网游"
]

studios_pool = [
    "索尼", "微软", "任天堂", "Rockstar", "CDPR", "EA", "育碧", 
    "动视暴雪", "SE", "Sega", "卡普空", "科乐美", "万代", "Larian", "米哈游", "Valve"
]

# 扩充到 1000
for i in range(1000):
    template = random.choice(base_data)
    new_game = template.copy()
    new_game["id"] = i + 100000 
    
    # 随机分配 1-2 个玩法分类 + 0-1 个厂商分类
    num_cats = random.randint(1, 2);
    my_cats = random.sample(categories_pool, num_cats)
    
    if random.random() > 0.7: # 30% 概率有大厂标签
        my_cats.append(random.choice(studios_pool))
        
    new_game["categories"] = my_cats
    
    expanded_data.append(new_game)

with open("assets/json/steam_games_data_mock.json", "w") as f:
    json.dump(expanded_data, f, ensure_ascii=False, indent=2)

print("生成了 1000 条包含新分类的测试数据")
