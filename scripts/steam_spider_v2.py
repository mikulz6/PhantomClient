import requests
import json
import time
import random
import os
import re

# 配置
TARGET_COUNT = 1000 
OUTPUT_FILE = "assets/json/steam_games_data.json"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8"
}

# 1. 玩法分类 (多对多)
GENRE_MAPPING = {
    "JRPG": ["JRPG", "日系角色扮演"],
    "ARPG": ["动作角色扮演", "ARPG", "砍杀"],
    "魂与类魂": ["类魂", "困难", "黑暗奇幻"],
    "射击游戏": ["射击", "FPS", "TPS", "第一人称射击", "第三人称射击"],
    "运动类游戏": ["体育", "竞速", "足球", "篮球"],
    "独立佳作": ["独立", "像素", "2D"],
    "网游": ["大型多人在线", "MMORPG", "多人"],
    "免费游戏": ["免费开玩", "免费"]
}

# 2. 厂商分类 (根据 publisher/developer 字段，需要 API 返回更多信息)
PUBLISHER_KEYWORDS = {
    "索尼": ["PlayStation", "Sony"],
    "微软": ["Xbox", "Microsoft", "Bethesda", "Mojang"],
    "SE": ["Square Enix"],
    "Sega": ["SEGA", "ATLUS"],
    "卡普空": ["CAPCOM"],
    "科乐美": ["KONAMI"],
    "育碧": ["Ubisoft"],
    "Valve": ["Valve"],
    "TakeTwo": ["Take-Two", "Rockstar", "2K"],
    "万代": ["Bandai Namco", "FromSoftware"]
}

def determine_categories(tags, developers, publishers):
    """返回游戏所属的所有分类列表"""
    cats = []
    
    # 玩法匹配
    for tag in tags:
        for cat_name, keywords in GENRE_MAPPING.items():
            if tag in keywords and cat_name not in cats:
                cats.append(cat_name)
    
    # 厂商匹配
    dev_text = " ".join(developers + publishers)
    for pub_name, keywords in PUBLISHER_KEYWORDS.items():
        for kw in keywords:
            if kw.lower() in dev_text.lower() and pub_name not in cats:
                cats.append(pub_name)
                
    # 兜底
    if not cats:
        cats.append("其他")
        
    return cats

def get_game_details(app_id):
    url = "https://store.steampowered.com/api/appdetails"
    params = {"appids": app_id, "cc": "cn", "l": "schinese"}
    
    try:
        response = requests.get(url, params=params, headers=HEADERS, timeout=10)
        data = response.json()
        
        if data and str(app_id) in data and data[str(app_id)]["success"]:
            game_data = data[str(app_id)]["data"]
            
            if "header_image" not in game_data or "name" not in game_data:
                return None

            video_url = ""
            if "movies" in game_data and len(game_data["movies"]) > 0:
                video_url = game_data["movies"][0].get("mp4", {}).get("480", "")
            
            tags = []
            if "genres" in game_data:
                tags = [g["description"] for g in game_data["genres"]]
                
            developers = game_data.get("developers", [])
            publishers = game_data.get("publishers", [])
            
            price_text = "免费"
            if "price_overview" in game_data:
                price_text = game_data["price_overview"].get("final_formatted", "免费")
            elif game_data.get("is_free", False):
                price_text = "免费"

            # 计算多重分类
            my_categories = determine_categories(tags, developers, publishers)

            clean_data = {
                "id": game_data["steam_appid"],
                "name": game_data["name"],
                "short_description": game_data.get("short_description", ""),
                "header_image": game_data["header_image"],
                "poster_image": f"https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/{app_id}/library_600x900.jpg",
                "video_url": video_url,
                "tags": tags[:5], 
                "price_text": price_text,
                "release_date": game_data.get("release_date", {}).get("date", ""),
                "categories": my_categories, # 注意这里变成 List
                "developers": developers
            }
            return clean_data
            
    except Exception as e:
        print(f"获取 {app_id} 详情失败: {e}")
        
    return None

def get_top_sellers_ids(count=1000):
    print(f"Fetching top {count} games...")
    app_ids = []
    # 使用 search/results 接口，它是 HTML 解析，比较稳定且无需复杂签名
    base_url = "https://store.steampowered.com/search/results/"
    batch_size = 50
    pages = (count // batch_size) + 5 # 多抓几页防止去重后不够
    
    for page in range(pages):
        if len(app_ids) >= count: break
        try:
            params = {
                "start": page * batch_size, 
                "count": batch_size, 
                "filter": "topsellers", 
                "infinite": 1, 
                "cc": "cn", 
                "l": "schinese"
            }
            response = requests.get(base_url, params=params, headers=HEADERS, timeout=15)
            if response.status_code == 200:
                data = response.json()
                html = data.get("results_html", "")
                
                # 正则提取 appid
                ids = re.findall(r'data-ds-appid="(\d+)"', html)
                
                new_ids = 0
                for app_id in ids:
                    if app_id not in app_ids: 
                        app_ids.append(app_id)
                        new_ids += 1
                
                print(f"Page {page}: Found {new_ids} new games (Total: {len(app_ids)})")
                
                if new_ids == 0 and len(ids) > 0:
                    print("No new games found in this batch, might have reached the end.")
                    # 可以在这里增加 break，但为了稳妥继续翻两页
                    
            time.sleep(2) # 增加延时防止被 Ban
        except Exception as e:
            print(f"Error fetching list page {page}: {e}")
            time.sleep(5)
            
    return app_ids[:count]

def main():
    app_ids = get_top_sellers_ids(TARGET_COUNT)
    final_games = []
    
    # 确保输出目录存在
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    
    print(f"Starting detailed info fetch for {len(app_ids)} games...")
    
    for index, app_id in enumerate(app_ids):
        if index % 10 == 0: 
            print(f"Progress: {index}/{len(app_ids)} ({len(final_games)} valid)")
            
        details = get_game_details(app_id)
        if details: 
            final_games.append(details)
            
        # 每抓取 50 个保存一次，防止程序中断全白跑
        if len(final_games) > 0 and len(final_games) % 50 == 0:
             with open(OUTPUT_FILE, "w", encoding="utf-8") as f: 
                json.dump(final_games, f, ensure_ascii=False, indent=2)
                
        # 随机延时模拟人类行为
        time.sleep(random.uniform(1.0, 2.0))

    # 最终保存
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f: 
        json.dump(final_games, f, ensure_ascii=False, indent=2)
    print("Done. Saved to assets/json/steam_games_data.json")

if __name__ == "__main__":
    main()
