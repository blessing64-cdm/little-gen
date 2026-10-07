class UIManager {
    constructor() {
        this.splashView = document.getElementById('splash-view');
        this.startView = document.getElementById('start-view');
        this.parentsView = document.getElementById('parents-overlay');
        this.mainGameView = document.getElementById('main-game-view');
        
        // New two-stage interface elements
        this.libraryView = document.getElementById('category-selection-view');
        this.gameplayInterface = document.getElementById('gameplay-interface');
        this.coloringWorldView = document.getElementById('coloring-world-view');
        this.tracingWorldView = document.getElementById('tracing-world-view');
        this.storybookWorldView = document.getElementById('storybook-world-view');
        this.memoryGameView = document.getElementById('memory-game-view');
        this.bodyExplorerView = document.getElementById('body-explorer-view');
        
        this.gameView = document.getElementById('active-game-view');
        this.countingView = document.getElementById('counting-world-view');
        this.levelView = document.getElementById('level-overlay');
        this.animalCategoryView = document.getElementById('animal-category-overlay');
        
        this.librarySubtitle = document.getElementById('library-subtitle');
        this.gamePrompt = document.getElementById('game-prompt');
        
        this.currentActiveScreen = this.splashView;
    }

    async showScreen(newScreen) {
        if (this.currentActiveScreen === newScreen) return;
        
        // Prepare exit animation
        if (this.currentActiveScreen) {
            this.currentActiveScreen.classList.add('screen-slide-out');
            await new Promise(r => setTimeout(r, 450));
            this.currentActiveScreen.classList.add('hidden');
            this.currentActiveScreen.classList.remove('screen-slide-out');
        }
        
        // Prepare entrance animation
        newScreen.classList.remove('hidden');
        newScreen.classList.add('screen-slide-in');
        this.currentActiveScreen = newScreen;
        
        await new Promise(r => setTimeout(r, 500));
        newScreen.classList.remove('screen-slide-in');
    }

    init() {}

    showSplashScreen() {
        this.splashView.classList.remove('hidden');
        this.currentActiveScreen = this.splashView;
    }

    showLibrary() {
        this.showScreen(this.libraryView);
    }

    showLevelSelection() {
        this.levelView.classList.remove('hidden');
    }

    hideLevelSelection() {
        this.levelView.classList.add('hidden');
    }

    cancelLevelSelection() {
        this.hideLevelSelection();
        if (window.adManager) window.adManager.showInterstitial();
    }

    handleLevelClick(start, end, requiresPremium) {
        if (requiresPremium && localStorage.getItem('lg_premium') !== 'true') {
            if (typeof audio !== 'undefined') audio.playTone(300, 'sine', 0.2); // Denied
            this.hideLevelSelection();
            this.showParentsScreen();
            return;
        }
        
        this.hideLevelSelection();
        if (typeof game !== 'undefined') {
            game.startCountingWorld(start, end);
        }
    }

    showAnimalCategorySelection() {
        this.animalCategoryView.classList.remove('hidden');
    }

    hideAnimalCategorySelection() {
        this.animalCategoryView.classList.add('hidden');
    }

    cancelAnimalCategorySelection() {
        this.hideAnimalCategorySelection();
        if (window.adManager) window.adManager.showInterstitial();
    }

    showSplashScreen() {
        this.showScreen(this.splashView);
    }

    showStartScreen() {
        this.showScreen(this.startView);
    }

    showParentsScreen() {
        this.updateParentsDashboard();
        this.parentsView.classList.remove('hidden');
    }

    updateParentsDashboard() {
        // 1. Update Streak
        const streakEl = document.getElementById('stat-streak');
        if (streakEl && window.stats) {
            streakEl.textContent = `${window.stats.streakData.count} Day${window.stats.streakData.count !== 1 ? 's' : ''}`;
        }

        // 2. Update Lessons Count
        const lessonsEl = document.getElementById('stat-lessons');
        if (lessonsEl) {
            lessonsEl.textContent = localStorage.getItem('lg_lessons_played') || '0';
        }

        // 3. Update Mastery Bars
        const masteryList = document.getElementById('parent-mastery-list');
        if (masteryList && window.stats) {
            masteryList.innerHTML = '';
            const categories = [
                { id: 'abc', name: 'Letters', class: 'fill-abc' },
                { id: 'numbers', name: '123 Numbers', class: 'fill-123' },
                { id: 'colors', name: 'Colors', class: 'fill-colors' },
                { id: 'tracing', name: 'Handwriting', class: 'fill-abc' },
                { id: 'memory', name: 'Memory Puzzles', class: 'fill-colors' }
            ];

            categories.forEach(cat => {
                const percent = window.stats.getCategoryProgress(cat.id);
                const row = document.createElement('div');
                row.className = 'progress-row';
                row.innerHTML = `
                    <div class="progress-label-wrap">
                        <span class="progress-label">${cat.name}</span>
                        <span class="progress-percent">${percent}%</span>
                    </div>
                    <div class="progress-bar-bg">
                        <div class="progress-bar-fill ${cat.class}" style="width: ${percent}%"></div>
                    </div>
                `;
                masteryList.appendChild(row);
            });
        }

        // 4. Update Achievement Bubbles
        const scroll = document.getElementById('parent-achievements-scroll');
        if (scroll && window.stats) {
            scroll.innerHTML = '';
            const recent = window.stats.getRecentAchievements();
            if (recent.length === 0) {
                scroll.innerHTML = '<p style="color:#999; font-size:0.8rem; margin:0;">No items mastered yet. Start playing!</p>';
            } else {
                recent.forEach(ach => {
                    const bubble = document.createElement('div');
                    bubble.className = 'achievement-badge anim-pop-in';
                    bubble.innerHTML = `${ach.item} <span>${ach.cat}</span>`;
                    scroll.appendChild(bubble);
                });
            }
        }
    }

    showMainGameUI() {
        this.showScreen(this.mainGameView);
        this.showLibrary(); 
    }

    showLibrary() {
        this.libraryView.classList.remove('hidden');
        this.gameplayInterface.classList.add('hidden');
        this.coloringWorldView.classList.add('hidden');
        if (this.tracingWorldView) this.tracingWorldView.classList.add('hidden');
        if (this.storybookWorldView) this.storybookWorldView.classList.add('hidden');
        if (this.memoryGameView) this.memoryGameView.classList.add('hidden');
        if (this.bodyExplorerView) this.bodyExplorerView.classList.add('hidden');
        if (this.animalCategoryView) this.animalCategoryView.classList.add('hidden');
        if (this.levelView) this.levelView.classList.add('hidden');
        
        const childName = localStorage.getItem('lg_profile_name');
        if (this.librarySubtitle) {
            this.librarySubtitle.textContent = childName ? `What should we play, ${childName}?` : "Choose a world to explore!";
        }
        
        window.scrollTo(0,0);
    }

    showGameplay() {
        this.libraryView.classList.add('hidden');
        this.coloringWorldView.classList.add('hidden');
        if (this.tracingWorldView) this.tracingWorldView.classList.add('hidden');
        if (this.storybookWorldView) this.storybookWorldView.classList.add('hidden');
        if (this.memoryGameView) this.memoryGameView.classList.add('hidden');
        if (this.bodyExplorerView) this.bodyExplorerView.classList.add('hidden');
        this.gameplayInterface.classList.remove('hidden');
        this.gameView.classList.remove('hidden');
        this.countingView.classList.add('hidden');
    }

    showColoringWorld() {
        this.libraryView.classList.add('hidden');
        this.gameplayInterface.classList.add('hidden');
        if (this.bodyExplorerView) this.bodyExplorerView.classList.add('hidden');
        if (this.tracingWorldView) this.tracingWorldView.classList.add('hidden');
        if (this.storybookWorldView) this.storybookWorldView.classList.add('hidden');
        this.coloringWorldView.classList.remove('hidden');
    }

    hideColoringWorld() {
        this.showLibrary();
    }

    showTracingWorld() {
        this.libraryView.classList.add('hidden');
        this.gameplayInterface.classList.add('hidden');
        if (this.bodyExplorerView) this.bodyExplorerView.classList.add('hidden');
        if (this.coloringWorldView) this.coloringWorldView.classList.add('hidden');
        if (this.storybookWorldView) this.storybookWorldView.classList.add('hidden');
        if (this.memoryGameView) this.memoryGameView.classList.add('hidden');
        this.tracingWorldView.classList.remove('hidden');
    }

    showStorybookWorld() {
        this.libraryView.classList.add('hidden');
        this.gameplayInterface.classList.add('hidden');
        if (this.bodyExplorerView) this.bodyExplorerView.classList.add('hidden');
        if (this.coloringWorldView) this.coloringWorldView.classList.add('hidden');
        if (this.tracingWorldView) this.tracingWorldView.classList.add('hidden');
        if (this.memoryGameView) this.memoryGameView.classList.add('hidden');
        this.storybookWorldView.classList.remove('hidden');
    }

    showMemoryGame() {
        this.libraryView.classList.add('hidden');
        this.gameplayInterface.classList.add('hidden');
        if (this.bodyExplorerView) this.bodyExplorerView.classList.add('hidden');
        if (this.coloringWorldView) this.coloringWorldView.classList.add('hidden');
        if (this.tracingWorldView) this.tracingWorldView.classList.add('hidden');
        if (this.storybookWorldView) this.storybookWorldView.classList.add('hidden');
        this.memoryGameView.classList.remove('hidden');
    }

    showBodyExplorer() {
        this.libraryView.classList.add('hidden');
        this.gameplayInterface.classList.add('hidden');
        this.coloringWorldView.classList.add('hidden');
        if (this.tracingWorldView) this.tracingWorldView.classList.add('hidden');
        if (this.storybookWorldView) this.storybookWorldView.classList.add('hidden');
        if (this.memoryGameView) this.memoryGameView.classList.add('hidden');
        if (this.bodyExplorerView) this.bodyExplorerView.classList.remove('hidden');
        if (window.bodyExplorer) window.bodyExplorer.reset();
    }

    hideBodyExplorer() {
        this.showLibrary();
    }

    setMainTitle(titleText) {
        this.mainTitle.textContent = titleText;
    }

    // Effect: Create stars bursting out for reward
    createRewardStars(container) {
        const starCount = 15;
        const colors = ['#FFD166', '#EF476F', '#06D6A0', '#118AB2'];
        
        for (let i = 0; i < starCount; i++) {
            const star = document.createElement('div');
            star.innerHTML = '⭐';
            star.className = 'anim-reward-star';
            
            // Random positioning around the center
            const angle = Math.random() * Math.PI * 2;
            const distance = Math.random() * 150 + 50;
            const tx = Math.cos(angle) * distance;
            const ty = Math.sin(angle) * distance;
            
            // Random start scale/rotation
            star.style.left = `calc(50% - 20px)`;
            star.style.top = `calc(50% - 20px)`;
            star.style.transform = `scale(0.1)`;
            star.style.setProperty('--tx', `${tx}px`);
            star.style.setProperty('--ty', `${ty}px`);
            
            // Add custom animation directly
            star.animate([
                { transform: `translate(0,0) scale(0.5) rotate(0deg)`, opacity: 1 },
                { transform: `translate(${tx}px, ${ty}px) scale(1.5) rotate(${Math.random()*360}deg)`, opacity: 0 }
            ], {
                duration: 1000 + Math.random() * 500,
                easing: 'cubic-bezier(0.25, 1, 0.5, 1)',
                fill: 'forwards'
            });

            container.appendChild(star);
            
            setTimeout(() => {
                if (star.parentNode) star.parentNode.removeChild(star);
            }, 1500);
        }
    }

    showRewardText(container, text) {
        const rewardText = document.createElement('div');
        rewardText.className = 'reward-overlay anim-bounce-in';
        rewardText.textContent = text;
        container.appendChild(rewardText);

        setTimeout(() => {
            rewardText.style.animation = 'popOutStart 0.5s ease-out forwards';
            setTimeout(() => {
                if(rewardText.parentNode) rewardText.parentNode.removeChild(rewardText);
            }, 500);
        }, 1500);
    }
}

const ui = new UIManager();
