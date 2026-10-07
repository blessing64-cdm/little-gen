class MemoryGameManager {
    constructor() {
        this.categories = {
            animals: ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🐔', '🐧', '🐦', '🦆', '🦉'],
            fruits: ['🍎', '🍏', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🍈', '🍒', '🍑', '🍍', '🥥', '🥝', '🍅', '🥑', '🍆', '🥔', '🥕'],
            shapes: ['🔴', '🔵', '🟢', '🟡', '🟣', '🟠', '⬛', '⬜', '🔶', '🔷', '🔺', '🔻', '💠', '🔘', '🔲', '🔳', '⭐', '🌙', '🌀', '💎' ]
        };
        
        this.difficultySettings = {
            easy: { rows: 2, cols: 3, pairs: 3 },
            medium: { rows: 3, cols: 4, pairs: 6 },
            hard: { rows: 4, cols: 5, pairs: 10 }
        };

        this.currentCategory = 'animals';
        this.currentDifficulty = 'easy';
        this.cards = [];
        this.flippedCards = [];
        this.matchedPairs = 0;
        this.isProcessing = false;
    }

    init() {
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Category selection
        const catBtns = document.querySelectorAll('.memory-cat-btn');
        catBtns.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const target = e.currentTarget;
                catBtns.forEach(b => b.classList.remove('active'));
                target.classList.add('active');
                this.currentCategory = target.dataset.category;
                
                // Visual feedback
                target.style.transform = 'scale(0.9)';
                setTimeout(() => target.style.transform = '', 150);
                
                if (typeof audio !== 'undefined') {
                    audio.init();
                    audio.playClickSound();
                }
            });
        });

        // Difficulty selection
        const diffBtns = document.querySelectorAll('.difficulty-btn');
        diffBtns.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const target = e.currentTarget;
                diffBtns.forEach(b => b.classList.remove('active'));
                target.classList.add('active');
                this.currentDifficulty = target.dataset.diff;
                
                target.style.transform = 'scale(0.9)';
                setTimeout(() => target.style.transform = '', 150);

                if (typeof audio !== 'undefined') {
                    audio.init();
                    audio.playClickSound();
                }
            });
        });

        // Start button
        const startBtn = document.getElementById('btn-start-memory');
        if (startBtn) {
            startBtn.addEventListener('click', () => {
                if (typeof audio !== 'undefined') {
                    audio.init();
                    audio.playClickSound();
                }
                this.startGame();
            });
        }

        // Back button to library
        const backBtn = document.getElementById('btn-back-from-memory');
        if (backBtn) {
            backBtn.addEventListener('click', () => {
                if (typeof ui !== 'undefined') ui.showLibrary();
                if (typeof window.adManager !== 'undefined') window.adManager.showInterstitial();
            });
        }
    }

    showSelection() {
        document.getElementById('memory-selection-view').classList.remove('hidden');
        document.getElementById('memory-board-view').classList.add('hidden');
    }

    startGame() {
        const settings = this.difficultySettings[this.currentDifficulty];
        const categoryItems = [...this.categories[this.currentCategory]];
        
        // Pick random unique items for pairs
        const selectedItems = this.shuffle(categoryItems).slice(0, settings.pairs);
        // Duplicate into pairs
        this.cards = this.shuffle([...selectedItems, ...selectedItems]);
        
        this.flippedCards = [];
        this.matchedPairs = 0;
        this.isProcessing = false;

        this.renderBoard(settings);
    }

    renderBoard(settings) {
        const board = document.getElementById('memory-board');
        if(!board) return;

        board.innerHTML = '';
        board.className = `grid-${this.currentDifficulty}`;
        
        // Dynamic scaling based on rows/cols to prevent vertical overflow
        const gap = 10;
        board.style.gridTemplateColumns = `repeat(${settings.cols}, 1fr)`;
        board.style.gap = `${gap}px`;
        
        // Calculate dynamic font size for emojis based on card count
        let fontSize = '3.5rem';
        if (settings.cols > 4) fontSize = '2rem';
        else if (settings.cols > 3) fontSize = '2.8rem';

        this.cards.forEach((item, index) => {
            const card = document.createElement('div');
            card.className = 'memory-card';
            card.dataset.item = item;
            card.dataset.index = index;
            card.style.width = '100%'; // Let grid control width

            card.innerHTML = `
                <div class="memory-card-face memory-card-front" style="font-size: ${fontSize}">${item}</div>
                <div class="memory-card-face memory-card-back" style="font-size: calc(${fontSize} * 0.7)">?</div>
            `;

            card.addEventListener('click', () => this.handleCardClick(card));
            board.appendChild(card);
        });

        document.getElementById('memory-selection-view').classList.add('hidden');
        document.getElementById('memory-board-view').classList.remove('hidden');
        
        if (typeof audio !== 'undefined') audio.speak("Find the matching pairs!");
    }

    handleCardClick(card) {
        if (this.isProcessing || card.classList.contains('flipped') || this.flippedCards.length >= 2) return;

        card.classList.add('flipped');
        this.flippedCards.push(card);
        audio.playTone(400, 'sine', 0.05);

        if (this.flippedCards.length === 2) {
            this.checkMatch();
        }
    }

    checkMatch() {
        this.isProcessing = true;
        const [card1, card2] = this.flippedCards;
        const item = card1.dataset.item;

        if (card1.dataset.item === card2.dataset.item) {
            // Match found
            this.matchedPairs++;
            audio.playCorrectSound();
            
            // Speak the matched item
            setTimeout(() => {
                this.pronounceItem(item);
            }, 300);

            this.flippedCards = [];
            this.isProcessing = false;

            if (this.matchedPairs === this.difficultySettings[this.currentDifficulty].pairs) {
                this.handleWin();
            }
        } else {
            // No match
            setTimeout(() => {
                card1.classList.remove('flipped');
                card2.classList.remove('flipped');
                this.flippedCards = [];
                this.isProcessing = false;
            }, 1000);
        }
    }

    pronounceItem(item) {
        // Maps emojis to words for speech
        const namingMap = {
            '🐶': 'Dog', '🐱': 'Cat', '🐭': 'Mouse', '🐹': 'Hamster', '🐰': 'Rabbit',
            '🦊': 'Fox', '🐻': 'Bear', '🐼': 'Panda', '🐨': 'Koala', '🐯': 'Tiger',
            '🦁': 'Lion', '🐮': 'Cow', '🐷': 'Pig', '🐸': 'Frog', '🐵': 'Monkey',
            '🐔': 'Chicken', '🐧': 'Penguin', '🐦': 'Bird', '🦆': 'Duck', '🦉': 'Owl',
            '🍎': 'Apple', '🍏': 'Green Apple', '🍐': 'Pear', '🍊': 'Orange', '🍋': 'Lemon',
            '🍌': 'Banana', '🍉': 'Watermelon', '🍇': 'Grapes', '🍓': 'Strawberry', '🍈': 'Melon',
            '🔴': 'Red Circle', '🔵': 'Blue Circle', '🟢': 'Green Circle', '🟡': 'Yellow Circle',
            '🟣': 'Purple Circle', '🟠': 'Orange Circle', '⬛': 'Black Square', '⬜': 'White Square',
            '⭐': 'Star', '🌙': 'Moon', '💎': 'Diamond'
        };
        const name = namingMap[item] || "Great Match!";
        audio.speak(name);
    }

    handleWin() {
        if (window.stats) {
            const icons = { 'animals': '🦁', 'fruits': '🍎', 'shapes': '📐' };
            window.stats.recordMastery('memory', icons[this.currentCategory] || '🎯');
        }

        setTimeout(() => {
            audio.speak("Fantastic! You have a great memory!");
            this.showWinCelebration();
        }, 800);
    }

    showWinCelebration() {
        // Use existing reward overlay if possible or just simplified pop
        const container = document.getElementById('memory-board-view');
        const overlay = document.createElement('div');
        overlay.className = 'reward-container';
        overlay.innerHTML = '<div class="anim-pop-in" style="font-size: 5rem;">🏆⭐🎉</div>';
        container.appendChild(overlay);

        setTimeout(() => {
            overlay.remove();
            this.showSelection();
        }, 3000);
    }

    shuffle(array) {
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
        return array;
    }
}

const memoryGame = new MemoryGameManager();
window.memoryGame = memoryGame;
