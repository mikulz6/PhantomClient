import requests
import json
import time
import random
import os

# 配置
TARGET_COUNT = 1000 
OUTPUT_FILE = "assets/json/steam_games_data.json"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

# 1. 玩法分类 (大幅拓宽)
GENRE_MAPPING = {
    "JRPG": ["JRPG", "日系角色扮演"],
    "ARPG": ["动作角色扮演", "ARPG", "砍杀"],
    "开放世界": ["开放世界", "Open World"],
    "射击游戏": ["射击", "FPS", "TPS", "第一人称射击"],
    "恐怖惊悚": ["恐怖", "惊悚", "生存恐怖", "丧尸"],
    "肉鸽莱克": ["Roguelike", "Roguelite", "类Rogue"],
    "策略模拟": ["策略", "模拟", "RTS", "大战略", "城市营造"],
    "格斗竞技": ["格斗", "Fighting", "格斗游戏"],
    "双人合作": ["合作", "在线合作", "本地合作", "分屏"],
    "赛博朋克": ["赛博朋克", "Cyberpunk", "科幻"],
    "二次元": ["动漫", "Anime", "二次元", "视觉小说"],
    "魂与类魂": ["类魂", "困难", "黑暗奇幻"],
    "运动竞速": ["体育", "竞速", "足球", "篮球", "赛车"],
    "独立佳作": ["独立", "像素", "2D"],
    "网游": ["大型多人在线", "MMORPG", "多人"],
    "免费游戏": ["免费开玩", "免费"]
}

# 2. 厂商分类 (补全大厂)
PUBLISHER_KEYWORDS = {
    "索尼": ["PlayStation", "Sony"],
    "微软": ["Xbox", "Microsoft", "Bethesda", "Mojang"],
    "任天堂": ["Nintendo"], # 也可以加上，虽然主要是主机
    "Rockstar": ["Rockstar"], # R星独立
    "CDPR": ["CD PROJEKT RED"], # 波兰蠢驴
    "EA": ["Electronic Arts", "EA Sports"],
    "育碧": ["Ubisoft"],
    "动视暴雪": ["Blizzard", "Activision"],
    "TakeTwo": ["Take-Two", "2K"],
    "SE": ["Square Enix"],
    "Sega": ["SEGA", "ATLUS"],
    "卡普空": ["CAPCOM"],
    "科乐美": ["KONAMI"],
    "万代": ["Bandai Namco", "FromSoftware"],
    "Larian": ["Larian"],
    "米哈游": ["miHoYo", "Hoyoverse"],
    "Valve": ["Valve"]
}

def determine_categories(tags, developers, publishers):
    cats = []
    # 玩法
    for tag in tags:
        for cat_name, keywords in GENRE_MAPPING.items():
            if tag in keywords and cat_name not in cats:
                cats.append(cat_name)
    # 厂商
    dev_text = " ".join(developers + publishers)
    for pub_name, keywords in PUBLISHER_KEYWORDS.items():
        for kw in keywords:
            if kw.lower() in dev_text.lower() and pub_name not in cats:
                cats.append(pub_name)
                break
    return cats

def get_game_details(app_id):
    url = "https://store.steampowered.com/api/appdetails"
    params = {"appids": app_id, "cc": "cn", "l": "schinese"}
    try:
        response = requests.get(url, params=params, headers=HEADERS, timeout=10)
        data = response.json()
        if data and str(app_id) in data and data[str(app_id)]["success"]:
            game_data = data[str(app_id)]["data"]
            if "header_image" not in game_data or "name" not in game_data: return None
            
            video_url = ""
            if "movies" in game_data and len(game_data["movies"]) > 0:
                video_url = game_data["movies"][0].get("mp4", {}).get("480", "")
            
            tags = []
            if "genres" in game_data: tags = [g["description"] for g in game_data["genres"]]
            
            price_text = "免费"
            if "price_overview" in game_data: price_text = game_data["price_overview"].get("final_formatted", "免费")
            elif game_data.get("is_free", False): price_text = "免费"

            cats = determine_categories(tags, game_data.get("developers", []), game_data.get("publishers", []))

            return {
                "id": game_data["steam_appid"],
                "name": game_data["name"],
                "short_description": game_data.get("short_description", ""),
                "header_image": game_data["header_image"],
                "poster_image": f"https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/{app_id}/library_600x900.jpg",
                "video_url": video_url,
                "tags": tags[:5], 
                "price_text": price_text,
                "release_date": game_data.get("release_date", {}).get("date", ""),
                "categories": cats,
                "developers": game_data.get("developers", [])
            }
    except Exception as e:
        print(f"Error fetching {app_id}: {e}")
    return None

def get_top_sellers_ids(count=1000):
    print(f"Fetching top {count} games...")
    app_ids = []
    base_url = "https://store.steampowered.com/search/results/"
    batch_size = 50
    pages = (count // batch_size) + 2
    
    for page in range(pages):
        if len(app_ids) >= count: break
        try:
            params = {"start": page * batch_size, "count": batch_size, "filter": "topsellers", "infinite": 1, "cc": "cn", "l": "schinese"}
            response = requests.get(base_url, params=params, headers=HEADERS, timeout=15)
            if response.status_code == 200:
                import re
                ids = re.findall(r'data-ds-appid="(\d+)"', response.json().get("results_html", ""))
                for app_id in ids:
                    if app_id not in app_ids: app_ids.append(app_id)
            time.sleep(1.5)
        except Exception as e:
            print(f"Error fetching list: {e}")
    return app_ids[:count]

def main():
    app_ids = get_top_sellers_ids(TARGET_COUNT)
    final_games = []
    for index, app_id in enumerate(app_ids):
        if index % 20 == 0: print(f"Progress: {index}/{len(app_ids)}")
        details = get_game_details(app_id)
        if details: final_games.append(details)
        if len(final_games) > 0 and len(final_games) % 50 == 0:
             with open(OUTPUT_FILE, "w", encoding="utf-8") as f: json.dump(final_games, f, ensure_ascii=False, indent=2)
        time.sleep(random.uniform(0.5, 1.0))
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f: json.dump(final_games, f, ensure_ascii=False, indent=2)
    print("Done.")

if __name__ == "__main__":
    main()
