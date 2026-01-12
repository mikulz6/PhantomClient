import requests
import json
import time
import random
import os

# 配置
TARGET_COUNT = 1000 
OUTPUT_FILE = "assets/json/steam_games_data.json" # 保持输出文件名不变，方便直接替换

# 小黑盒 API (Web 端或 App 端抓包地址)
# 这里使用一个公开的 Web 接口路径作为示例，实际可能需要根据抓包结果调整
# 小黑盒热销榜通常在 game/get_game_list 这类接口
BASE_URL = "https://api.xiaoheihe.cn/game/get_game_list_v3"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Referer": "https://www.xiaoheihe.cn/",
    "Origin": "https://www.xiaoheihe.cn"
}

# 模拟数据加工逻辑
def process_heybox_data(item):
    """将小黑盒数据转换为我们 App 需要的格式"""
    try:
        # 提取字段 (根据小黑盒常见字段结构)
        # 注意：实际字段名需根据 API 返回调整，这里假设通用字段
        game_name = item.get("name_en", "") or item.get("name_cn", "")
        if not game_name: return None
        
        steam_appid = item.get("appid", 0) # 小黑盒通常会带 steam appid
        
        # 图片处理
        # 小黑盒图片通常由 CDN 托管
        img_url = item.get("img_url", "")
        # 尝试构造竖版和横版图
        # 如果只有一张图，我们尽量复用
        header_image = img_url
        poster_image = img_url 
        
        # 视频 (小黑盒列表可能不直接返回视频，先置空或用通用占位)
        video_url = item.get("video_url", "")
        
        # 标签
        tags = item.get("tags", [])
        
        # 价格
        price_info = item.get("price", {})
        price_text = "免费"
        if price_info:
            current = price_info.get("current", 0)
            if current > 0:
                price_text = f"¥{current}"
            elif price_info.get("is_free", False):
                 price_text = "免费"
        
        # 厂商
        developers = [] # 小黑盒列表可能没有详细厂商信息
        
        # 构造分类
        # 这里复用之前的分类逻辑，或者根据小黑盒的 tags 映射
        categories = ["热销"] # 默认
        if tags:
             categories.extend(tags)
             
        return {
            "id": steam_appid,
            "name": item.get("name_cn", game_name), # 优先用中文名
            "short_description": item.get("desc", ""), # 简介
            "header_image": header_image,
            "poster_image": poster_image,
            "video_url": video_url,
            "tags": tags[:5],
            "price_text": price_text,
            "release_date": item.get("release_date", ""),
            "categories": categories,
            "developers": developers
        }
        
    except Exception as e:
        print(f"Error processing item: {e}")
        return None

def fetch_heybox_games(count=1000):
    print(f"Starting fetch from HeyBox (Target: {count})...")
    games = []
    offset = 0
    limit = 30 # 每页数量
    
    while len(games) < count:
        try:
            # 构造参数
            params = {
                "limit": limit,
                "offset": offset,
                "sort": "rank", # 按热度/排名
                "filter": "steam", # 筛选 Steam 游戏
                "os_type": "web"
            }
            
            # 发起请求
            # 注意：如果 API 需要签名 (heybox_id/nonce/signature)，这里会失败
            # 这种情况下，我们可能需要硬编码一些抓包拿到的固定参数
            response = requests.get(BASE_URL, params=params, headers=HEADERS, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if data.get("status") == "ok":
                    items = data.get("result", {}).get("list", [])
                    if not items:
                        print("No more items found.")
                        break
                        
                    for item in items:
                        processed = process_heybox_data(item)
                        if processed:
                            games.append(processed)
                            
                    offset += limit
                    print(f"Progress: {len(games)}/{count}")
                    time.sleep(1) # 礼貌延时
                else:
                    print(f"API Error: {data.get('msg')}")
                    break
            else:
                print(f"HTTP Error: {response.status_code}")
                break
                
        except Exception as e:
            print(f"Request failed: {e}")
            break
            
    return games[:count]

def main():
    final_games = fetch_heybox_games(TARGET_COUNT)
    
    if final_games:
        print(f"Successfully fetched {len(final_games)} games.")
        # 写入文件
        # 确保目录存在
        os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
        
        with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
            json.dump(final_games, f, ensure_ascii=False, indent=2)
        print(f"Saved to {OUTPUT_FILE}")
    else:
        print("Failed to fetch any games.")

if __name__ == "__main__":
    main()
