function openGame(id) {
    console.log("Open game: " + id);
    // Add touch feedback
}

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
                page.classList.remove('hidden-page');
                page.classList.add('active-page');
            } else {
                page.classList.remove('active-page');
                page.classList.add('hidden-page');
            }
        });
        
        // 3. Scroll to top
        document.getElementById('main-container').scrollTo(0, 0);
    });
});
