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
];

const neonColors = [
    '#00FFCC', '#FF66CC', '#CCFF00', '#00FFFF', '#FF9966', '#CC99FF', '#66FF99'
];

// Helper for HTML onClick (fixes Hero Banner click)
function openGame(id) {
    const game = gamesDB.find(g => g.id === id);
    if (game) {
        openModal(game);
    } else {
        console.error("Game not found: " + id);
    }
}

function initGames() {
    const grid = document.getElementById('game-grid-container');
    if (!grid) return;

    grid.innerHTML = '';
    
    // 生成足够多的卡片
    const allGames = [...gamesDB, ...gamesDB, ...gamesDB]; 

    allGames.forEach((game) => {
        const card = document.createElement('div');
        card.className = 'game-card';
        card.onclick = () => openModal(game);
        
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
    console.log("Games initialized: " + allGames.length);
}

// 详情页模态框逻辑
function openModal(game) {
    // 填充数据
    document.getElementById('modal-img').style.backgroundImage = `url('${game.img}')`;
    document.getElementById('modal-title').innerText = game.name;
    
    const tagsContainer = document.getElementById('modal-tags');
    tagsContainer.innerHTML = '';
    game.tags.forEach(tag => {
        const tagEl = document.createElement('div');
        tagEl.className = 'neon-tag';
        tagEl.innerText = tag;
        // 随机霓虹色
        const color = neonColors[Math.floor(Math.random() * neonColors.length)];
        tagEl.style.backgroundColor = color;
        tagEl.style.boxShadow = `0 2px 8px ${color}66`; // 40% opacity hex
        tagsContainer.appendChild(tagEl);
    });

    // 显示模态框
    const modal = document.getElementById('game-detail-modal');
    modal.classList.add('open');
}

function closeModal() {
    const modal = document.getElementById('game-detail-modal');
    modal.classList.remove('open');
}

// 页面加载初始化
document.addEventListener('DOMContentLoaded', () => {
    initGames();
    
    // Tab 切换逻辑
    document.querySelectorAll('.nav-item').forEach((item, index) => {
        item.addEventListener('click', function() {
            document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
            this.classList.add('active');

            const pages = ['page-games', 'page-lobby', 'page-profile'];
            const targetPageId = pages[index];

            // 切换页面显隐
            document.querySelectorAll('.page-content').forEach(page => {
                if (page.id === targetPageId) {
                    page.classList.add('active-page');
                    page.classList.remove('hidden-page');
                } else {
                    page.classList.remove('active-page');
                    page.classList.add('hidden-page');
                }
            });

            // 切换顶部 App Bar 显隐 (个人中心和大厅通常有自己的头图)
            const appBar = document.getElementById('main-app-bar');
            if (targetPageId === 'page-games') {
                appBar.style.display = 'flex';
            } else {
                appBar.style.display = 'none'; // 大厅和个人中心全屏
            }
        });
    });
});
