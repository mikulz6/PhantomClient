// 真实游戏数据
const gamesDB = [
    { id: '1', name: "Elden Ring", img: "https://cdn.akamai.steamstatic.com/steam/apps/1245620/header.jpg", tags: ["魂类", "开放世界"] },
    { id: '2', name: "Red Dead Redemption 2", img: "https://cdn.akamai.steamstatic.com/steam/apps/1174180/header.jpg", tags: ["剧情", "西部"] },
    { id: '3', name: "Baldur's Gate 3", img: "https://cdn.akamai.steamstatic.com/steam/apps/1086940/header.jpg", tags: ["CRPG", "策略"] },
    { id: '4', name: "Cyberpunk 2077", img: "https://cdn.akamai.steamstatic.com/steam/apps/1091500/header.jpg", tags: ["赛博朋克", "科幻"] },
    { id: '5', name: "God of War", img: "https://cdn.akamai.steamstatic.com/steam/apps/1593500/header.jpg", tags: ["动作", "神话"] },
    { id: '6', name: "GTA V", img: "https://cdn.akamai.steamstatic.com/steam/apps/271590/header.jpg", tags: ["开放世界", "犯罪"] },
    { id: '7', name: "The Witcher 3", img: "https://cdn.akamai.steamstatic.com/steam/apps/292030/header.jpg", tags: ["RPG", "剧情"] },
    { id: '8', name: "Sekiro", img: "https://cdn.akamai.steamstatic.com/steam/apps/814380/header.jpg", tags: ["动作", "高难"] },
    { id: '9', name: "Hogwarts Legacy", img: "https://cdn.akamai.steamstatic.com/steam/apps/990080/header.jpg", tags: ["魔法", "开放世界"] },
    { id: '10', name: "Spider-Man", img: "https://cdn.akamai.steamstatic.com/steam/apps/1817070/header.jpg", tags: ["超级英雄", "动作"] },
    { id: '11', name: "Resident Evil 4", img: "https://cdn.akamai.steamstatic.com/steam/apps/2050650/header.jpg", tags: ["恐怖", "射击"] },
    { id: '12', name: "Monster Hunter World", img: "https://cdn.akamai.steamstatic.com/steam/apps/582010/header.jpg", tags: ["共斗", "动作"] },
    { id: '13', name: "Forza Horizon 5", img: "https://cdn.akamai.steamstatic.com/steam/apps/1551360/header.jpg", tags: ["赛车", "模拟"] },
    { id: '14', name: "Assassin's Creed Valhalla", img: "https://cdn.akamai.steamstatic.com/steam/apps/2208920/header.jpg", tags: ["历史", "RPG"] },
    { id: '15', name: "Final Fantasy VII", img: "https://cdn.akamai.steamstatic.com/steam/apps/1462040/header.jpg", tags: ["JRPG", "经典"] },
    { id: '16', name: "Persona 5 Royal", img: "https://cdn.akamai.steamstatic.com/steam/apps/1687950/header.jpg", tags: ["JRPG", "回合制"] },
    { id: '17', name: "Apex Legends", img: "https://cdn.akamai.steamstatic.com/steam/apps/1172470/header.jpg", tags: ["FPS", "大逃杀"] },
    { id: '18', name: "Destiny 2", img: "https://cdn.akamai.steamstatic.com/steam/apps/1085660/header.jpg", tags: ["FPS", "MMO"] },
    { id: '19', name: "Dota 2", img: "https://cdn.akamai.steamstatic.com/steam/apps/570/header.jpg", tags: ["MOBA", "竞技"] },
    { id: '20', name: "Counter-Strike 2", img: "https://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg", tags: ["FPS", "竞技"] },
];

function initGames() {
    const grid = document.getElementById('game-grid-container');
    if (!grid) return;

    // 清空现有内容
    grid.innerHTML = '';

    // 生成大量卡片 (重复几次数组以模拟很多游戏)
    const allGames = [...gamesDB, ...gamesDB, ...gamesDB]; // 60个游戏

    allGames.forEach((game, index) => {
        const card = document.createElement('div');
        card.className = 'game-card';
        card.onclick = () => openGame(game.id);
        
        // 延迟加载图片机制（简单模拟）
        const tagsHtml = game.tags.map(tag => `<span>${tag}</span>`).join('');
        
        card.innerHTML = `
            <div class="card-img" style="background-image: url('${game.img}');"></div>
            <div class="card-info">
                <h4>${game.name}</h4>
                <div class="tags">${tagsHtml}</div>
            </div>
        `;
        grid.appendChild(card);
    });
}

function openGame(id) {
    console.log("Open game: " + id);
    // 简单的点击反馈动画
    const card = event.currentTarget;
    card.style.transform = "scale(0.95)";
    setTimeout(() => {
        card.style.transform = "scale(1)";
    }, 150);
}

// 页面加载初始化
document.addEventListener('DOMContentLoaded', () => {
    initGames();
    
    // Tab 切换逻辑
    document.querySelectorAll('.nav-item').forEach((item, index) => {
        item.addEventListener('click', function() {
            // 1. Update Tab State
            document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
            this.classList.add('active');

            // 2. Switch Page Content
            const pages = ['page-games', 'page-lobby', 'page-profile'];
            const targetPageId = pages[index];

            document.querySelectorAll('.page-content').forEach(page => {
                if (page.id === targetPageId) {
                    page.classList.add('active-page');
                    // 注意：不需要处理 hidden-page 类，因为 css 中非 active-page 默认就是 display: none
                } else {
                    page.classList.remove('active-page');
                }
            });
        });
    });
});
