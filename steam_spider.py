import requests
import json
import time
import random
import os

# 配置
TARGET_COUNT = 1000 
OUTPUT_FILE = "assets/json/steam_games_data.json" # 直接写入 assets
BATCH_SIZE = 50

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

# 我们的客户端标准分类映射
CATEGORY_MAPPING = {
    "RPG": ["角色扮演", "RPG", "JRPG", "ARPG", "剧情丰富"],
    "FPS/TPS": ["射击", "FPS", "第一人称射击", "第三人称射击", "狙击"],
    "动作冒险": ["动作", "冒险", "开放世界", "类魂", "砍杀"],
    "竞速狂飙": ["竞速", "驾驶", "赛车", "体育", "模拟"],
    "独立佳作": ["独立", "像素", "2D", "横向卷轴", "解谜"],
    "策略模拟": ["策略", "模拟", "建造", "回合制", "卡牌"]
}

def determine_category(tags, name):
    """根据 Steam 标签归纳为我们的主分类"""
    # 1. 优先匹配硬核类型
    for tag in tags:
        for main_cat, keywords in CATEGORY_MAPPING.items():
            if tag in keywords:
                return main_cat
    # 2. 默认分类
    return "热门精选"

def get_top_sellers_ids(count=1000):
    print(f"正在获取 Steam 热销榜前 {count} 名...")
    app_ids = []
    base_url = "https://store.steampowered.com/search/results/"
    
    # Steam 每次最多给 100，但建议 50 比较稳
    batch_size = 50
    pages = (count // batch_size) + 2
    
    for page in range(pages):
        if len(app_ids) >= count:
            break
            
        try:
            print(f"  正在获取第 {page+1} 页索引...")
            params = {
                "query": "",
                "start": page * batch_size,
                "count": batch_size,
                "dynamic_data": "",
                "sort_by": "_ASC",
                "snr": "1_7_7_7000_7",
                "filter": "topsellers",
                "infinite": 1,
                "cc": "cn",
                "l": "schinese"
            }
            
            response = requests.get(base_url, params=params, headers=HEADERS, timeout=15)
            if response.status_code == 200:
                data = response.json()
                results_html = data.get("results_html", "")
                
                import re
                ids = re.findall(r'data-ds-appid="(\d+)"', results_html)
                
                new_ids = 0
                for app_id in ids:
                    if app_id not in app_ids:
                        app_ids.append(app_id)
                        new_ids += 1
                
                print(f"    -> 本页新增 {new_ids} 个, 总计 {len(app_ids)}")
                
                if new_ids == 0:
                    print("    -> 警告：本页无新数据，可能已达上限")
            
            time.sleep(random.uniform(1.5, 3.0))
            
        except Exception as e:
            print(f"获取列表页失败: {e}")
            time.sleep(5) # 出错多歇会儿
            
    return app_ids[:count]

def get_game_details(app_id):
    url = "https://store.steampowered.com/api/appdetails"
    params = {"appids": app_id, "cc": "cn", "l": "schinese"}
    
    try:
        response = requests.get(url, params=params, headers=HEADERS, timeout=10)
        data = response.json()
        
        if data and str(app_id) in data and data[str(app_id)]["success"]:
            game_data = data[str(app_id)]["data"]
            
            # 必须要有图和名字
            if "header_image" not in game_data or "name" not in game_data:
                return None

            # 视频
            video_url = ""
            if "movies" in game_data and len(game_data["movies"]) > 0:
                video_url = game_data["movies"][0].get("mp4", {}).get("480", "")
            
            # 标签
            tags = []
            if "genres" in game_data:
                tags = [g["description"] for g in game_data["genres"]] # 取全部
            
            # 价格
            price_text = "免费"
            if "price_overview" in game_data:
                price_text = game_data["price_overview"].get("final_formatted", "免费")
            elif game_data.get("is_free", False):
                price_text = "免费"

            # 归类
            my_category = determine_category(tags, game_data["name"])

            clean_data = {
                "id": game_data["steam_appid"],
                "name": game_data["name"],
                "short_description": game_data.get("short_description", ""),
                "header_image": game_data["header_image"],
                "poster_image": f"https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/{app_id}/library_600x900.jpg",
                "video_url": video_url,
                "tags": tags[:4], # 只存前4个展示用
                "price_text": price_text,
                "release_date": game_data.get("release_date", {}).get("date", ""),
                "category": my_category # 直接存好分类
            }
            return clean_data
            
    except Exception as e:
        print(f"获取 {app_id} 详情失败: {e}")
        
    return None

def main():
    # 0. 检查已有数据，支持增量更新（暂略，直接覆盖）
    
    # 1. 获取 ID
    app_ids = get_top_sellers_ids(TARGET_COUNT)
    print(f"准备抓取 {len(app_ids)} 个游戏详情...")
    
    final_games = []
    
    # 2. 遍历
    for index, app_id in enumerate(app_ids):
        # 简单进度条
        if index % 10 == 0:
            print(f"进度: {index}/{len(app_ids)} (已成功: {len(final_games)})")
            
        details = get_game_details(app_id)
        if details:
            final_games.append(details)
        
        # 3. 定期保存 (防止中间崩溃全白跑)
        if len(final_games) > 0 and len(final_games) % 50 == 0:
            print(f"  -> 自动保存 {len(final_games)} 条数据...")
            with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
                json.dump(final_games, f, ensure_ascii=False, indent=2)

        time.sleep(random.uniform(0.5, 1.2)) # 稍微快一点，1000个要跑很久
        
    # 最终保存
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(final_games, f, ensure_ascii=False, indent=2)
        
    print(f"全部完成！共 {len(final_games)} 条数据已存入 {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
