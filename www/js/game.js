
class GameManager {
    constructor() {
        this.currentCategory = null;
        this.currentQuestions = [];
        this.currentIndex = 0;
        this.currentAnswer = null;
        this.isAnimating = false;
        this.gamePhase = null; // 'learn' or 'quiz'
        
        // Progress tracking
        this.stats = {
            lessonsPlayed: parseInt(localStorage.getItem('lg_lessons_played') || '0')
        };
        
        // Timer tracking
        this.activeIntervals = [];
        this.countInterval = null;
    }

    reset() {
        this.currentCategory = null;
        this.gamePhase = null;
        this.isAnimating = false;
        
        if (this.countInterval) {
            clearInterval(this.countInterval);
            this.countInterval = null;
        }

        // Cancel all recorded intervals
        while (this.activeIntervals.length > 0) {
            clearInterval(this.activeIntervals.pop());
        }
    }

    startCategory(categoryKey) {
        if (categoryKey === 'numbers') {
            ui.showLevelSelection();
            return;
        }
        
        if (categoryKey === 'animals') {
            ui.showAnimalCategorySelection();
            return;
        }

        if (!gameData[categoryKey]) return;
        
        this.currentCategory = categoryKey;
        this.currentSubCategory = null; 
        this.currentQuestions = []; // Reset list
        this.isAnimating = false;

        this.stats.lessonsPlayed++;
        localStorage.setItem('lg_lessons_played', this.stats.lessonsPlayed.toString());

        if (categoryKey === 'abc' || categoryKey === 'colors' 
            || categoryKey === 'shapes' || categoryKey === 'phonics'
            || categoryKey === 'animals' || categoryKey === 'fruits'
            || categoryKey === 'vegetables') {
            this.startAutoLearningMode();
        } else {
            this.startQuizPhase();
        }
    }

    startCountingWorld(min, max) {
        ui.hideLevelSelection();
        this.currentCategory = 'numbers';
        this.currentQuestions = []; // MUST reset list to prevent stale data
        this.isAnimating = false;

        // Generate the dynamic range for this lesson
        gameData.numbers = generateNumberRange(min, max);
        
        this.stats.lessonsPlayed++;
        localStorage.setItem('lg_lessons_played', this.stats.lessonsPlayed.toString());

        ui.showGameplay();
        this.startAutoLearningMode();
    }

    startAnimalWorld(subCategory) {
        ui.hideAnimalCategorySelection();
        this.currentCategory = 'animals';
        this.currentSubCategory = subCategory; // pets, farm, or wild
        this.currentQuestions = []; // Reset first
        this.isAnimating = false;

        // Load the specific group from gameData.animals (now an object of arrays)
        this.currentQuestions = [...gameData.animals[subCategory]];
        
        this.stats.lessonsPlayed++;
        localStorage.setItem('lg_lessons_played', this.stats.lessonsPlayed.toString());

        ui.showGameplay();
        this.startAutoLearningMode();
    }

    async speakGuidedRepetition(mainText, repeatText) {
        if (this.gamePhase !== 'learn') return;
        
        // 1. Initial Presentation
        await audio.speak(mainText);
        await new Promise(r => setTimeout(r, 800));
        
        if (this.gamePhase !== 'learn') return;

        // 2. Visual Prompt in UI
        const promptEl = document.getElementById('game-prompt');
        const originalText = promptEl.textContent;
        promptEl.textContent = "Your turn! 🎤";
        promptEl.classList.add('anim-pulse');

        // 3. Guided Request
        const prompts = ["Can you say", "Say it with me", "Say"];
        const randomPrompt = prompts[Math.floor(Math.random() * prompts.length)];
        await audio.speak(`${randomPrompt}: ${repeatText}`);
        
        // 4. Wait for child
        await new Promise(r => setTimeout(r, 2000));
        
        // 5. Restore UI
        if (promptEl) {
            promptEl.textContent = originalText;
            promptEl.classList.remove('anim-pulse');
        }
    }

    // --- Phase 1: Auto Learning Mode ---
    startAutoLearningMode() {
        this.gamePhase = 'learn';
        
        // --- LOGIC FIX: Don't overwrite if sub-category already set currentQuestions ---
        if (!this.currentQuestions || this.currentQuestions.length === 0) {
            const data = gameData[this.currentCategory];
            if (Array.isArray(data)) {
                this.currentQuestions = [...data];
            } else {
                // FALLBACK: Category might be an object (Animals sub-categorized)
                // If we get here, it means we entered from a flat button but data is nested
                console.warn(`Category ${this.currentCategory} has nested data. Expected array.`);
            }
        }
        
        this.currentIndex = 0;
        
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        optionsContainer.innerHTML = '';
        
        if (this.currentCategory === 'abc') {
            promptEl.textContent = "Sing with me!";
            audio.speak("Sing with me!");
        } else if (this.currentCategory === 'numbers') {
            promptEl.textContent = "Count with me!";
            audio.speak("Count with me!");
        } else if (this.currentCategory === 'colors') {
            promptEl.textContent = "Learn Colors!";
            audio.speak("Let's learn colors!");
        } else if (this.currentCategory === 'shapes') {
            promptEl.textContent = "Learn Shapes!";
            audio.speak("Let's learn shapes!");
        } else if (this.currentCategory === 'phonics') {
            promptEl.textContent = "Letter Sounds!";
            audio.speak("Let's learn our sounds!");
        }

        setTimeout(() => {
            this.playNextLearningItem();
        }, 1500);
    }

    playNextLearningItem() {
        if (this.gamePhase !== 'learn' || !this.currentCategory) return; // Cancel if exited
        
        if (this.currentIndex >= this.currentQuestions.length) {
            // Done learning, assignment time!
            this.startQuizPhase();
            return;
        }

        if (this.currentCategory === 'abc') {
            this.playABCLearningItem();
        } else if (this.currentCategory === 'numbers') {
            this.playNumberLearningItem();
        } else if (this.currentCategory === 'colors') {
            this.playColorLearningItem();
        } else if (this.currentCategory === 'shapes') {
            this.playShapeLearningItem();
        } else if (this.currentCategory === 'phonics') {
            this.playPhonicLearningItem();
        } else if (this.currentCategory === 'animals') {
            this.playAnimalLearningItem();
        } else if (this.currentCategory === 'fruits') {
            this.playFruitLearningItem();
        } else if (this.currentCategory === 'vegetables') {
            this.playVegetableLearningItem();
        }
    }

    async playABCLearningItem() {
        const letterData = this.currentQuestions[this.currentIndex];
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        
        // Use the large centered layout
        optionsContainer.className = 'options-container learning-layout-centered';
        promptEl.className = `game-prompt anim-pop-in ${letterData.colorClass}`; 
        promptEl.textContent = letterData.value; 
        optionsContainer.innerHTML = '';

        // Create the HUGE bouncing letter
        const letterCard = document.createElement('div');
        letterCard.className = `option-card ${letterData.colorClass} card-huge anim-roll-in anim-rainbow-pulse`;
        letterCard.textContent = letterData.value;
        optionsContainer.appendChild(letterCard);

        audio.playTone(400, 'sine', 0.2);
        letterCard.classList.add('anim-glow', 'anim-bounce');
        
        // --- UPGRADED: Guided Repetition ---
        await this.speakGuidedRepetition(letterData.shortName, letterData.shortName);

        if (this.gamePhase !== 'learn' || this.currentCategory !== 'abc') return;
        
        // Show the text name below the object
        promptEl.className = 'game-prompt anim-pop-in';
        promptEl.textContent = letterData.name; 

        // Switch card to Object
        letterCard.className = `option-card card-huge anim-zoom-in-bounce`;
        letterCard.style.borderColor = '#eee';
        letterCard.textContent = letterData.objectEmoji || "✨";
        
        audio.playCorrectSound();
        
        // --- UPGRADED: Second Repetition for the Object ---
        const objectName = letterData.name.split(' ').pop(); // Get "Apple" from "A is for Apple"
        await this.speakGuidedRepetition(letterData.name, objectName);

        if (this.gamePhase !== 'learn' || this.currentCategory !== 'abc') return;
        this.currentIndex++;
        this.playNextLearningItem();
    }
    
    async playNumberLearningItem() {
        const itemData = this.currentQuestions[this.currentIndex];
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        const countingView = document.getElementById('counting-world-view');
        const countingDisplay = document.getElementById('counting-display');
        
        // Setup layout
        optionsContainer.className = 'options-container learning-layout-centered';
        promptEl.className = 'game-prompt anim-pop-in ' + itemData.colorClass;
        promptEl.textContent = itemData.value;
        optionsContainer.innerHTML = '';
        countingView.classList.remove('hidden');
        countingDisplay.innerHTML = '';

        // Adjust grid based on count
        if (itemData.value > 50) {
            countingDisplay.className = 'counting-grid large-count';
        } else if (itemData.value > 20) {
            countingDisplay.className = 'counting-grid medium-count';
        } else {
            countingDisplay.className = 'counting-grid';
        }

        // Add the objects
        for (let i = 0; i < itemData.value; i++) {
            const obj = document.createElement('div');
            obj.className = 'counting-object anim-zoom-in-bounce anim-jump';
            obj.style.animationDelay = `${i * 0.05}s`;
            obj.textContent = itemData.objectEmoji;
            countingDisplay.appendChild(obj);
        }

        audio.playTone(400, 'sine', 0.1);
        
        // --- UPGRADED: Guided Repetition ---
        const plural = itemData.value > 1 ? 's' : '';
        const numberLabel = itemData.value.toString();
        await this.speakGuidedRepetition(`${itemData.value} ${itemData.objectName}${plural}`, numberLabel);

        if (this.gamePhase !== 'learn' || this.currentCategory !== 'numbers') return;
        this.currentIndex++;
        this.playNextLearningItem();
    }

    async playColorLearningItem() {
        const itemData = this.currentQuestions[this.currentIndex];
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        
        promptEl.textContent = "Look!";
        promptEl.className = `game-prompt anim-pop-in ${itemData.colorClass}`;
        optionsContainer.innerHTML = '';

        const wrapper = document.createElement('div');
        wrapper.style.display = 'flex';
        wrapper.style.flexDirection = 'column';
        wrapper.style.alignItems = 'center';
        wrapper.style.gap = '1rem';

        const card = document.createElement('div');
        card.className = `option-card ${itemData.colorClass} anim-pop-in`;
        card.style.width = '150px';
        card.style.height = '150px';
        
        const label = document.createElement('div');
        label.textContent = itemData.value;
        label.style.fontSize = '3rem';
        label.style.fontWeight = '900';
        label.className = `anim-pop-in delay-1 ${itemData.colorClass}`;

        wrapper.appendChild(card);
        wrapper.appendChild(label);
        optionsContainer.appendChild(wrapper);

        audio.playTone(400, 'sine', 0.1);
        card.classList.add('anim-glow', 'anim-bounce');
        
        // --- UPGRADED: Guided Repetition ---
        await this.speakGuidedRepetition(itemData.name, itemData.name);

        if (this.gamePhase !== 'learn' || this.currentCategory !== 'colors') return;
        this.currentIndex++;
        promptEl.className = 'game-prompt';
        this.playNextLearningItem();
    }

    async playShapeLearningItem() {
        const itemData = this.currentQuestions[this.currentIndex];
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        
        promptEl.textContent = "Learn Shapes!";
        promptEl.className = `game-prompt anim-pop-in ${itemData.colorClass}`;
        optionsContainer.innerHTML = '';

        const wrapper = document.createElement('div');
        wrapper.style.display = 'flex';
        wrapper.style.alignItems = 'center';
        wrapper.style.justifyContent = 'center';
        wrapper.style.gap = '2vw';
        wrapper.className = 'anim-pop-in';

        const labelEl = document.createElement('div');
        labelEl.textContent = itemData.name; 
        labelEl.style.fontSize = 'min(4rem, 10vw)';
        labelEl.style.fontWeight = '900';
        labelEl.style.color = 'var(--text-dark)';

        const card = document.createElement('div');
        card.className = `option-card anim-bounce delay-1`;
        card.style.width = 'min(150px, 20vw)';
        card.style.height = 'min(150px, 20vw)';
        card.style.fontSize = 'min(8rem, 20vw)';
        card.style.border = 'none';
        card.style.background = 'transparent';
        card.style.boxShadow = 'none';
        card.textContent = itemData.value;
        
        wrapper.appendChild(labelEl);
        wrapper.appendChild(card);
        optionsContainer.appendChild(wrapper);

        audio.playTone(400, 'sine', 0.1);
        
        // --- UPGRADED: Guided Repetition ---
        await this.speakGuidedRepetition(itemData.name, itemData.name);

        if (this.gamePhase !== 'learn' || this.currentCategory !== 'shapes') return;
        this.currentIndex++;
        promptEl.className = 'game-prompt';
        this.playNextLearningItem();
    }

    async playPhonicLearningItem() {
        const itemData = this.currentQuestions[this.currentIndex];
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        
        optionsContainer.className = 'options-container learning-layout-centered';
        promptEl.className = `game-prompt anim-pop-in ${itemData.colorClass}`;
        promptEl.textContent = itemData.value;
        optionsContainer.innerHTML = '';

        const card = document.createElement('div');
        card.className = `option-card ${itemData.colorClass} card-huge anim-roll-in anim-rainbow-pulse`;
        card.textContent = itemData.value;
        optionsContainer.appendChild(card);

        audio.playTone(400, 'sine', 0.2);
        card.classList.add('anim-glow', 'anim-bounce');
        
        // --- UPGRADED: Guided Repetition for Phonetic Sound ---
        await this.speakGuidedRepetition(`The letter ${itemData.value} makes the sound: ${itemData.name}.`, itemData.name);

        if (this.gamePhase !== 'learn' || this.currentCategory !== 'phonics') return;
        
        promptEl.className = 'game-prompt anim-pop-in';
        promptEl.textContent = `${itemData.name} is for ${itemData.objectEmoji}`;
        
        card.className = `option-card card-huge anim-pop-in`;
        card.style.borderColor = '#eee';
        card.textContent = itemData.objectEmoji;
        
        audio.playCorrectSound();
        
        // --- UPGRADED: Second Repetition for the Phonic Object ---
        await this.speakGuidedRepetition(`${itemData.name} is for... ${itemData.objectEmoji}!`, itemData.name);

        if (this.gamePhase !== 'learn' || this.currentCategory !== 'phonics') return;
        this.currentIndex++;
        this.playNextLearningItem();
    }

    // --- Phase 2: Interactive Quiz / Assignment ---
    startQuizPhase() {
        this.gamePhase = 'quiz';
        
        // --- LOGIC FIX: Handle nested Animal categories ---
        let allItems = [];
        if (this.currentCategory === 'animals' && this.currentSubCategory) {
            allItems = [...gameData.animals[this.currentSubCategory]];
        } else {
            const data = gameData[this.currentCategory];
            allItems = Array.isArray(data) ? [...data] : [];
        }

        this.shuffleArray(allItems);
        this.currentQuestions = allItems.slice(0, 5); 
        this.currentIndex = 0;
        
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        optionsContainer.innerHTML = '';
        
        promptEl.textContent = "Your turn!";
        promptEl.className = 'game-prompt anim-pop-in';
        audio.speak("Great job! Now it's your turn.", 1.0, 1.2);
        audio.playTone(600, 'triangle', 0.1);

        setTimeout(() => {
            if (this.gamePhase !== 'quiz') return;
            this.nextQuestion();
        }, 2500);
    }

    // --- Interactive Mode ---
    nextQuestion() {
        if (this.currentIndex >= this.currentQuestions.length) {
            this.finishCategory();
            return;
        }

        this.isAnimating = false;
        this.currentAnswer = this.currentQuestions[this.currentIndex];
        
        // --- LOGIC FIX: Get other options from correctly mapped category/subcategory ---
        let pool = [];
        if (this.currentCategory === 'animals' && this.currentSubCategory) {
            pool = gameData.animals[this.currentSubCategory];
        } else {
            pool = gameData[this.currentCategory];
        }

        const otherOptions = pool.filter(item => item.id !== this.currentAnswer.id);
        this.shuffleArray(otherOptions);
        const options = [this.currentAnswer, otherOptions[0], otherOptions[1]];
        this.shuffleArray(options);

        this.renderQuestion(options);
    }

    renderQuestion(options) {
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        const countingView = document.getElementById('counting-world-view');
        const countingDisplay = document.getElementById('counting-display');
        
        optionsContainer.innerHTML = '';
        countingDisplay.innerHTML = '';
        
        // Reset container classes
        optionsContainer.className = 'options-container'; 
        
        // Determine Grid Layout based on options count
        if (options.length >= 4) {
            optionsContainer.classList.add('grid-adaptive');
        }
        
        if (this.currentCategory === 'numbers') {
            // Show the objects to count
            promptEl.textContent = `How many ${this.currentAnswer.objectName}s?`;
            countingView.classList.remove('hidden');
            
            // Adjust grid
            if (this.currentAnswer.value > 50) countingDisplay.className = 'counting-grid large-count';
            else if (this.currentAnswer.value > 20) countingDisplay.className = 'counting-grid medium-count';
            else countingDisplay.className = 'counting-grid';

            for (let i = 0; i < this.currentAnswer.value; i++) {
                const obj = document.createElement('div');
                obj.className = 'counting-object anim-pop-in';
                obj.style.animationDelay = `${i * 0.05}s`;
                obj.textContent = this.currentAnswer.objectEmoji;
                obj.id = `count-obj-${i}`;
                countingDisplay.appendChild(obj);
            }

            audio.speak(`How many ${this.currentAnswer.objectName}s are there?`);
        } else if (this.currentCategory === 'animals') {
            // Show real image for matching
            promptEl.textContent = `Where is the ${this.currentAnswer.name}?`;
            countingView.classList.add('hidden');
            audio.speak(`Where is the ${this.currentAnswer.name}?`);
        } else if (this.currentCategory === 'fruits') {
            // Premium Fruit Quiz
            promptEl.textContent = `Find the ${this.currentAnswer.name}`;
            countingView.classList.add('hidden');
            optionsContainer.classList.add('fruit-premium-dark');
            audio.speak(`Can you find the ${this.currentAnswer.name}?`);
        } else if (this.currentCategory === 'vegetables') {
            // Premium Vegetable Quiz
            promptEl.textContent = `Find the ${this.currentAnswer.name}`;
            countingView.classList.add('hidden');
            optionsContainer.classList.add('fruit-premium-dark');
            audio.speak(`Where is the ${this.currentAnswer.name}?`);
        } else {
            // Standard matched mode for other categories
            countingView.classList.add('hidden');
            promptEl.textContent = `Find ${this.currentAnswer.value}`;
            const phrase = this.currentCategory === 'animals' ? `Find the ${this.currentAnswer.name}.` : `Find ${this.currentAnswer.name}.`;
            setTimeout(() => audio.speak(phrase), 500);
        }

        options.forEach((opt, index) => {
            if (this.currentCategory === 'colors') {
                const wrapper = document.createElement('div');
                wrapper.style.display = 'flex';
                wrapper.style.flexDirection = 'column';
                wrapper.style.alignItems = 'center';
                wrapper.style.gap = '0.5rem';
                wrapper.style.cursor = 'pointer';
                
                const btn = document.createElement('div');
                btn.className = `option-card ${opt.colorClass} anim-pop-in delay-${index + 1}`;
                btn.textContent = ''; 
                
                const label = document.createElement('div');
                label.textContent = opt.value;
                label.style.fontSize = '1.8rem';
                label.style.fontWeight = '900';
                label.style.color = 'var(--text-dark)';
                label.className = `anim-pop-in delay-${index + 1}`;
                
                wrapper.appendChild(btn);
                wrapper.appendChild(label);
                
                wrapper.addEventListener('click', () => this.handleOptionClick(btn, opt));
                optionsContainer.appendChild(wrapper);
            } else if (this.currentCategory === 'animals') {
                const btn = document.createElement('div');
                btn.className = `option-card anim-pop-in delay-${index + 1}`;
                btn.style.width = 'min(150px, 20vw)';
                btn.style.height = 'min(150px, 20vw)';
                btn.style.padding = '0';
                btn.style.overflow = 'hidden';
                btn.style.border = '4px solid white';
                
                const img = document.createElement('img');
                img.src = opt.image;
                img.style.width = '100%';
                img.style.height = '100%';
                img.style.objectFit = 'cover';
                btn.appendChild(img);
                
                btn.addEventListener('click', () => this.handleOptionClick(btn, opt));
                optionsContainer.appendChild(btn);
            } else if (this.currentCategory === 'fruits') {
                const btn = document.createElement('div');
                btn.className = `option-card fruit-card-quiz anim-pop-in delay-${index + 1}`;
                
                const img = document.createElement('img');
                img.src = opt.image;
                img.style.width = '100%';
                img.style.height = '100%';
                img.style.objectFit = 'contain';
                btn.appendChild(img);
                
                btn.addEventListener('click', () => this.handleOptionClick(btn, opt));
                optionsContainer.appendChild(btn);
            } else if (this.currentCategory === 'vegetables') {
                const btn = document.createElement('div');
                btn.className = `option-card fruit-card-quiz anim-pop-in delay-${index + 1}`;
                
                const img = document.createElement('img');
                img.src = opt.image;
                img.style.width = '100%';
                img.style.height = '100%';
                img.style.objectFit = 'contain';
                btn.appendChild(img);
                
                btn.addEventListener('click', () => this.handleOptionClick(btn, opt));
                optionsContainer.appendChild(btn);
            } else {
                const btn = document.createElement('div');
                btn.className = `option-card ${opt.colorClass} anim-pop-in delay-${index + 1}`;
                btn.textContent = opt.value;
                
                btn.addEventListener('click', () => this.handleOptionClick(btn, opt));
                optionsContainer.appendChild(btn);
            }
        });
    }

    handleOptionClick(button, optionData) {
        if (this.isAnimating) return; 

        if (optionData.sound) {
            audio.speak(`${optionData.name}. ${optionData.sound}`);
        } else {
            audio.speak(optionData.name);
        }

        if (optionData.id === this.currentAnswer.id) {
            this.isAnimating = true;
            this.handleCorrect(button);
        } else {
            this.handleIncorrect(button);
        }
    }

    handleCorrect(button) {
        button.classList.add('anim-glow', 'anim-bounce');

        if (window.stats) {
            window.stats.recordMastery(this.currentCategory, this.currentAnswer.value || this.currentAnswer.name);
        }

        audio.playCorrectSound();
        
        const rewardWord = rewards[Math.floor(Math.random() * rewards.length)];
        setTimeout(() => {
            audio.speak(rewardWord, 1.0, 1.4); 
        }, 800); 

        const rewardContainer = document.getElementById('reward-container');
        rewardContainer.classList.remove('hidden');
        ui.createRewardStars(rewardContainer);
        ui.showRewardText(rewardContainer, rewardWord);
        
        setTimeout(() => {
            rewardContainer.classList.add('hidden');
            this.currentIndex++;
            this.nextQuestion();
        }, 2500);
    }

    handleIncorrect(button) {
        if (this.currentCategory === 'numbers') {
            this.guidedCountCorrection();
        } else if (this.currentCategory === 'animals' || this.currentCategory === 'fruits') {
            button.classList.add('anim-wiggle');
            audio.playIncorrectSound();
            
            // Find and highlight correct one
            const options = document.querySelectorAll('.option-card');
            options.forEach(opt => {
                // If it's the correct one, make it glow
                const img = opt.querySelector('img');
                if (img && img.src.includes(this.currentAnswer.image)) {
                    opt.classList.add('highlight-correct');
                    setTimeout(() => opt.classList.remove('highlight-correct'), 2000);
                }
            });

            audio.speak(`This is the ${this.currentAnswer.name}.`);
        } else {
            button.classList.add('anim-wiggle');
            audio.playIncorrectSound();
            
            setTimeout(() => {
                button.classList.remove('anim-wiggle');
            }, 400);

            setTimeout(() => {
                const inc = encouragements[Math.floor(Math.random() * encouragements.length)];
                audio.speak(`${inc} ${this.currentAnswer.name}`);
            }, 500);
        }
    }

    // New "Guided Correction" Mode
    guidedCountCorrection() {
        this.isAnimating = true;
        const count = this.currentAnswer.value;
        
        if (count <= 10) {
            audio.speak("Let's count together!");
            let i = 0;
            this.countInterval = setInterval(() => {
                if (i >= count || this.gamePhase === null) {
                    clearInterval(this.countInterval);
                    this.isAnimating = false;
                    if (this.gamePhase !== null) setTimeout(() => audio.speak(`That's ${count}!`), 500);
                    return;
                }
                
                const obj = document.getElementById(`count-obj-${i}`);
                if (obj) {
                    obj.classList.add('highlight');
                    audio.playTone(500 + (i * 10), 'sine', 0.1);
                    audio.speak((i + 1).toString(), 1.0, 1.3);
                    setTimeout(() => obj.classList.remove('highlight'), 400);
                }
                i++;
            }, 900); // 900ms gives proper time for the TTS engine to finish pronouncing
        } else {
            audio.speak("Wow, that's a lot! Let's count fast!");
            let i = 0;
            this.countInterval = setInterval(() => {
                if (i >= count || this.gamePhase === null) {
                    clearInterval(this.countInterval);
                    this.isAnimating = false;
                    if (this.gamePhase !== null) setTimeout(() => audio.speak(`That's ${count}!`), 500);
                    return;
                }
                
                const obj = document.getElementById(`count-obj-${i}`);
                if (obj) {
                    obj.classList.add('highlight');
                    audio.playTone(600 + ((i % 10) * 15), 'sine', 0.05);
                    setTimeout(() => obj.classList.remove('highlight'), 60);
                }
                i++;
            }, 80); // 80ms interval means 100 items will be counted visually in 8 seconds
        }
    }

    async playAnimalLearningItem() {
        if (this.gamePhase !== 'learn' || !this.currentQuestions[this.currentIndex]) return;
        
        const itemData = this.currentQuestions[this.currentIndex];
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        
        optionsContainer.className = 'options-container learning-layout-centered fruit-premium-dark';
        promptEl.className = 'game-prompt anim-pop-in';
        promptEl.textContent = itemData.name;
        optionsContainer.innerHTML = '';

        // Create the Premium Dark Animal Card
        const card = document.createElement('div');
        card.className = `option-card fruit-card-premium anim-pop-in`;
        card.style.flexDirection = 'column';
        card.style.padding = '20px';
        
        const img = new Image();
        img.src = itemData.image; 
        img.style.width = '80%';
        img.style.height = '70%';
        img.style.objectFit = 'contain';
        card.appendChild(img);

        const lbl = document.createElement('div');
        lbl.textContent = itemData.name;
        lbl.style.fontSize = '2.5rem';
        lbl.style.color = 'white';
        lbl.style.fontWeight = '900';
        lbl.style.marginTop = '1rem';
        card.appendChild(lbl);
        
        optionsContainer.appendChild(card);

        audio.playTone(400, 'sine', 0.1);
        
        // --- UPGRADED: Guided Repetition ---
        await this.speakGuidedRepetition(itemData.name, itemData.name);

        if (this.gamePhase !== 'learn' || this.currentCategory !== 'animals') return;
        
        // Play sound and animal sound name
        await audio.speak(itemData.sound);
        
        if (this.gamePhase !== 'learn' || this.currentCategory !== 'animals') return;
        this.currentIndex++;
        this.playNextLearningItem();
    }

    async playFruitLearningItem() {
        if (this.gamePhase !== 'learn' || !this.currentQuestions[this.currentIndex]) return;
        
        const itemData = this.currentQuestions[this.currentIndex];
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        
        optionsContainer.className = 'options-container learning-layout-centered fruit-premium-dark';
        promptEl.className = 'game-prompt anim-pop-in';
        promptEl.textContent = itemData.name;
        optionsContainer.innerHTML = '';

        // Create the Premium Dark Fruit Card
        const card = document.createElement('div');
        card.className = `option-card fruit-card-premium anim-pop-in`;
        card.style.flexDirection = 'column';
        card.style.padding = '20px';
        
        const img = new Image();
        img.src = itemData.image;
        img.style.width = '80%';
        img.style.height = '70%';
        img.style.objectFit = 'contain';
        card.appendChild(img);

        const lbl = document.createElement('div');
        lbl.textContent = itemData.name;
        lbl.style.fontSize = '2.5rem';
        lbl.style.color = 'white';
        lbl.style.fontWeight = '900';
        lbl.style.marginTop = '1rem';
        card.appendChild(lbl);
        
        optionsContainer.appendChild(card);

        audio.playTone(400, 'sine', 0.1);
        
        // --- UPGRADED: Guided Repetition ---
        await this.speakGuidedRepetition(itemData.name, itemData.name);

        if (this.gamePhase !== 'learn' || this.currentCategory !== 'fruits') return;
        
        // Detailed sound/fact about fruit
        await audio.speak(itemData.sound);
        
        if (this.gamePhase !== 'learn' || this.currentCategory !== 'fruits') return;
        this.currentIndex++;
        this.playNextLearningItem();
    }

    async playVegetableLearningItem() {
        if (this.gamePhase !== 'learn' || !this.currentQuestions[this.currentIndex]) return;
        
        const itemData = this.currentQuestions[this.currentIndex];
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        
        optionsContainer.className = 'options-container learning-layout-centered fruit-premium-dark';
        promptEl.className = 'game-prompt anim-pop-in';
        promptEl.textContent = itemData.name;
        optionsContainer.innerHTML = '';

        // Create the Premium Dark Vegetable Card
        const card = document.createElement('div');
        card.className = `option-card fruit-card-premium anim-pop-in`;
        card.style.flexDirection = 'column';
        card.style.padding = '20px';
        
        const img = new Image();
        img.src = itemData.image;
        img.style.width = '80%';
        img.style.height = '70%';
        img.style.objectFit = 'contain';
        card.appendChild(img);

        const lbl = document.createElement('div');
        lbl.textContent = itemData.name;
        lbl.style.fontSize = '2.5rem';
        lbl.style.color = 'white';
        lbl.style.fontWeight = '900';
        lbl.style.marginTop = '1rem';
        card.appendChild(lbl);
        
        optionsContainer.appendChild(card);

        audio.playTone(400, 'sine', 0.1);
        
        // --- UPGRADED: Guided Repetition ---
        await this.speakGuidedRepetition(itemData.name, itemData.name);

        if (this.gamePhase !== 'learn' || this.currentCategory !== 'vegetables') return;
        
        // Detailed sound/fact about vegetable
        await audio.speak(itemData.sound);
        
        if (this.gamePhase !== 'learn' || this.currentCategory !== 'vegetables') return;
        this.currentIndex++;
        this.playNextLearningItem();
    }

    finishCategory() {
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        const completedCat = this.currentCategory; // Cache before nulling
        this.currentCategory = null; 
        
        promptEl.textContent = "You did it!";
        optionsContainer.innerHTML = '';
        
        audio.playCorrectSound();
        audio.speak("Great job! You finished the lesson!", 1.0, 1.3);

        const rewardContainer = document.getElementById('reward-container');
        rewardContainer.classList.remove('hidden');
        ui.createRewardStars(rewardContainer);
        ui.showRewardText(rewardContainer, "Awesome!");

        setTimeout(() => {
            rewardContainer.classList.add('hidden');
            
            if (completedCat === 'fruits') {
                this.startJuiceMode();
            } else if (completedCat === 'vegetables') {
                this.startKitchenMode();
            } else {
                if (window.adManager) window.adManager.showInterstitial();
                window.goBackToCategories();
            }
        }, 4000);
    }

    startKitchenMode() {
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        
        promptEl.textContent = "Let's Cook Soup!";
        optionsContainer.innerHTML = '';
        optionsContainer.className = 'options-container learning-layout-centered fruit-premium-dark';
        
        audio.speak("Let's make some yummy vegetable soup! Pick three vegetables to put in the pot!");
        
        const selection = gameData.vegetables.slice(0, 6);
        const selected = [];
        
        selection.forEach(veg => {
            const card = document.createElement('div');
            card.className = 'option-card fruit-card-quiz anim-pop-in';
            const img = document.createElement('img');
            img.src = veg.image;
            img.style.width = '100%';
            card.appendChild(img);
            
            card.onclick = () => {
                audio.playTone(600, 'sine', 0.1);
                selected.push(veg);
                card.style.opacity = '0.5';
                card.style.pointerEvents = 'none';
                
                if (selected.length === 3) {
                    this.blendKitchen(selected);
                }
            };
            optionsContainer.appendChild(card);
        });
    }

    blendKitchen(items) {
        const optionsContainer = document.getElementById('options-container');
        optionsContainer.innerHTML = `
            <div class="anim-shake" style="font-size: 8rem; filter: drop-shadow(0 0 30px #aaa);">🍲</div>
            <div style="font-size: 1.8rem; color: white; margin-top: 2rem; font-weight: bold; text-align: center;">
                Yummy! ${items.map(i => i.name).join(' and ')} soup is ready!
            </div>
        `;
        
        audio.playTone(300, 'triangle', 1.0); // Boiling sound
        audio.speak(`Mmm! Your soup with ${items.map(i => i.name).join(' and ')} looks delicious! Good cooking!`, 1.0, 1.2);
        
        setTimeout(() => {
            window.goBackToCategories();
        }, 6000);
    }

    startJuiceMode() {
        const promptEl = document.getElementById('game-prompt');
        const optionsContainer = document.getElementById('options-container');
        
        promptEl.textContent = "Make some juice!";
        optionsContainer.innerHTML = '';
        optionsContainer.className = 'options-container learning-layout-centered fruit-premium-dark';
        
        audio.speak("Let's make some fruit juice! Pick two fruits to blend!");
        
        // Show selection of fruits
        const selection = gameData.fruits.slice(0, 4);
        const selected = [];
        
        selection.forEach(fru => {
            const card = document.createElement('div');
            card.className = 'option-card fruit-card-quiz anim-pop-in';
            const img = document.createElement('img');
            img.src = fru.image;
            img.style.width = '100%';
            card.appendChild(img);
            
            card.onclick = () => {
                audio.playTone(600, 'sine', 0.1);
                selected.push(fru);
                card.style.opacity = '0.5';
                card.style.pointerEvents = 'none';
                
                if (selected.length === 2) {
                    this.blendJuice(selected[0], selected[1]);
                }
            };
            optionsContainer.appendChild(card);
        });
    }

    blendJuice(f1, f2) {
        const optionsContainer = document.getElementById('options-container');
        optionsContainer.innerHTML = `
            <div class="anim-shake" style="font-size: 8rem; filter: drop-shadow(0 0 30px white);">🥤</div>
            <div style="font-size: 2rem; color: white; margin-top: 2rem; font-weight: bold;">
                ${f1.name} + ${f2.name} = Yummy Juice!
            </div>
        `;
        
        audio.playTone(200, 'square', 1.0); // Blender sound
        audio.speak(`${f1.name} plus ${f2.name} makes yummy juice! Delicious!`, 1.0, 1.2);
        
        setTimeout(() => {
            window.goBackToCategories();
        }, 5000);
    }

    shuffleArray(array) {
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
    }
}

const game = new GameManager();
