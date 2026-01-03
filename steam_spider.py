import requests
import json
import time
import random
import os

# 配置
# 抓取数量：为了演示，默认抓取前 20 个。实际使用时可以改为 1000。
TARGET_COUNT = 20 
OUTPUT_FILE = "steam_games_data.json"

# Steam 接口参数
# cc=cn: 中国区价格/货币
# l=schinese: 简体中文
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

def get_top_sellers_ids(count=100):
    """
    获取热销榜的 App ID 列表
    """
    print(f"正在获取 Steam 热销榜前 {count} 名...")
    app_ids = []
    base_url = "https://store.steampowered.com/search/results/"
    
    # Steam 搜索每页默认 50 个，需要分页
    pages = (count // 50) + 1
    
    for page in range(pages):
        try:
            params = {
                "query": "",
                "start": page * 50,
                "count": 50,
                "dynamic_data": "",
                "sort_by": "_ASC",
                "snr": "1_7_7_7000_7",
                "filter": "topsellers",
                "infinite": 1,
                "cc": "cn",
                "l": "schinese"
            }
            
            response = requests.get(base_url, params=params, headers=HEADERS, timeout=10)
            if response.status_code == 200:
                data = response.json()
                # 解析 HTML (简单方式，或者使用 BeautifulSoup)
                # 这里 Steam 返回的 json 中包含 html 片段，我们简单提取 appid
                results_html = data.get("results_html", "")
                
                # 简单的字符串处理提取 data-ds-appid="12345"
                import re
                ids = re.findall(r'data-ds-appid="(\d+)"', results_html)
                
                # 去重并添加
                for app_id in ids:
                    if app_id not in app_ids:
                        app_ids.append(app_id)
                        
                print(f"  - 已获取 {len(app_ids)} 个 ID")
                if len(app_ids) >= count:
                    break
            
            # 礼貌爬虫，暂停一下
            time.sleep(1)
            
        except Exception as e:
            print(f"获取列表失败: {e}")
            
    return app_ids[:count]

def get_game_details(app_id):
    """
    根据 App ID 获取详细信息（图片、视频、简介）
    """
    url = "https://store.steampowered.com/api/appdetails"
    params = {
        "appids": app_id,
        "cc": "cn",
        "l": "schinese"
    }
    
    try:
        response = requests.get(url, params=params, headers=HEADERS, timeout=10)
        data = response.json()
        
        if data and str(app_id) in data and data[str(app_id)]["success"]:
            game_data = data[str(app_id)]["data"]
            
            # 提取我们需要的数据
            
            # 1. 视频 (取第一个宣传片的 mp4)
            video_url = ""
            if "movies" in game_data and len(game_data["movies"]) > 0:
                # 优先取 480p 或 max 避免流量过大，实际可用 max
                video_url = game_data["movies"][0].get("mp4", {}).get("480", "")
            
            # 2. 标签/分类 (Steam API 的 categories 或 genres)
            tags = []
            if "genres" in game_data:
                tags = [g["description"] for g in game_data["genres"]][:3] # 只取前3个
                
            # 3. 清洗数据结构
            clean_data = {
                "id": game_data["steam_appid"],
                "name": game_data["name"],
                "short_description": game_data["short_description"],
                "header_image": game_data["header_image"], # 横图
                # 尝试构造竖图封面 (library_600x900)，官方 API 不一定直接给，但 URL 规律通常如下
                "poster_image": f"https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/{app_id}/library_600x900.jpg",
                "video_url": video_url,
                "tags": tags,
                "price_text": game_data.get("price_overview", {}).get("final_formatted", "免费"),
                "release_date": game_data.get("release_date", {}).get("date", "")
            }
            return clean_data
            
    except Exception as e:
        print(f"获取 {app_id} 详情失败: {e}")
        
    return None

def main():
    # 1. 获取 ID 列表
    app_ids = get_top_sellers_ids(TARGET_COUNT)
    print(f"最终待抓取列表: {app_ids}")
    
    final_games = []
    
    # 2. 遍历获取详情
    print("开始抓取详情...")
    for index, app_id in enumerate(app_ids):
        print(f"[{index+1}/{len(app_ids)}] 正在处理 AppID: {app_id}")
        
        details = get_game_details(app_id)
        if details:
            final_games.append(details)
            print(f"  -> 成功: {details['name']}")
        else:
            print(f"  -> 失败或跳过")
            
        # 防止触发 Steam 速率限制 (Rate Limit)
        # 商业项目建议使用代理池
        time.sleep(random.uniform(1.0, 2.0))
        
    # 3. 保存结果
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(final_games, f, ensure_ascii=False, indent=2)
        
    print(f"\n抓取完成！数据已保存至 {OUTPUT_FILE}")
    print(f"共获取 {len(final_games)} 个游戏信息。")

if __name__ == "__main__":
    main()
