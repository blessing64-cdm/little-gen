class StoryManager {
    constructor() {
        this.stories = [
            {
                id: 'lion-mouse',
                title: 'The Lion and the Mouse',
                cover: 'assets/stories/lion_cover.png',
                pages: [
                    { text: "Once upon a time, a mighty lion was sleeping in the forest.", image: "assets/stories/lion_cover.png" },
                    { text: "He was dreaming of being the king of the jungle.", image: "" },
                    { text: "A little mouse ran across the lion's nose and woke him up!", image: "" },
                    { text: "The lion roared and caught the mouse with his big paw.", image: "" },
                    { text: "The mouse was scared. “Please let me go,” he begged.", image: "" },
                    { text: "“Maybe one day I can help you too!” the mouse said.", image: "" },
                    { text: "The lion laughed. “How could a small mouse help a big lion?”", image: "" },
                    { text: "But the lion was kind and let the little mouse go.", image: "" },
                    { text: "Many days later, the lion was caught in a hunter's net.", image: "" },
                    { text: "He struggled and roared, but he could not escape.", image: "" },
                    { text: "The little mouse heard the lion and came to help.", image: "" },
                    { text: "He used his sharp teeth to chew the ropes of the net.", image: "" },
                    { text: "Soon, the ropes broke and the mighty lion was free!", image: "" },
                    { text: "“Thank you, little friend,” said the lion. “You are truly brave.”", image: "" }
                ]
            },
            {
                id: 'hungry-caterpillar',
                title: 'The Hungry Caterpillar',
                cover: 'assets/stories/cat_cover.png',
                pages: [
                    { text: "In the light of the moon, a little egg lay on a leaf.", image: "assets/stories/cat_cover.png" },
                    { text: "On Sunday morning, a tiny caterpillar popped out of the egg.", image: "" },
                    { text: "He was very hungry and started looking for some food.", image: "" },
                    { text: "On Monday, he ate through one big red apple.", image: "" },
                    { text: "On Tuesday, he ate through two yellow pears.", image: "" },
                    { text: "On Wednesday, he ate through three juicy blue plums.", image: "" },
                    { text: "On Thursday, he ate through four red strawberries.", image: "" },
                    { text: "On Friday, he ate through five bright oranges.", image: "" },
                    { text: "On Saturday, he ate so much food he had a stomach ache!", image: "" },
                    { text: "The next day, he ate a green leaf and felt much better.", image: "" },
                    { text: "He was not a tiny caterpillar anymore. He was a big, fat caterpillar!", image: "" },
                    { text: "He built a small house called a cocoon around himself.", image: "" },
                    { text: "He stayed inside for more than two weeks.", image: "" },
                    { text: "Then he nibbled a hole and pushed his way out.", image: "" },
                    { text: "He was a beautiful butterfly! 🎉", image: "" }
                ]
            },
            {
                id: 'ellie-elephant',
                title: 'Ellie’s Dream',
                cover: 'assets/stories/ellie_cover.png',
                pages: [
                    { text: "Once upon a time, in a quiet green forest, there was a little elephant named Ellie.", image: "assets/stories/ellie_cover.png" },
                    { text: "Ellie loved to play all day—she splashed in the river, chased butterflies, and walked with her mommy.", image: "assets/stories/ellie_cover.png" },
                    { text: "But one night, Ellie couldn’t sleep.", image: "assets/stories/ellie_cover.png" },
                    { text: "She rolled left… she rolled right…", image: "assets/stories/ellie_cover.png" },
                    { text: "“Mama,” Ellie whispered, “I can’t sleep.”", image: "assets/stories/ellie_cover.png" },
                    { text: "Her mommy smiled softly. “Close your eyes, little one,” she said. “Let’s count the stars together.”", image: "assets/stories/ellie_cover.png" },
                    { text: "Ellie looked up at the sky.", image: "assets/stories/ellie_cover.png" },
                    { text: "“One star…” “Two stars…” “Three shiny stars…”", image: "assets/stories/ellie_cover.png" },
                    { text: "Soon, the stars began to twinkle softly.", image: "assets/stories/ellie_cover.png" },
                    { text: "Ellie yawned. Her eyes felt heavy.", image: "assets/stories/ellie_cover.png" },
                    { text: "She snuggled close to her mommy.", image: "assets/stories/ellie_cover.png" },
                    { text: "As she counted… four… five… six…", image: "assets/stories/ellie_cover.png" },
                    { text: "Ellie slowly drifted into a sweet, quiet sleep.", image: "assets/stories/ellie_cover.png" },
                    { text: "And in her dream, she danced with the stars. ✨", image: "assets/stories/ellie_cover.png" },
                    { text: "🌙 Good night, sleep tight.", image: "assets/stories/ellie_cover.png" }
                ]
            },
            {
                id: 'benny-bunny',
                title: 'Benny Bunny',
                cover: 'assets/stories/benny_cover.png',
                pages: [
                    { text: "Benny the bunny loved to hop and play.", image: "assets/stories/benny_cover.png" },
                    { text: "He hopped in the grass, He hopped by the trees, He even hopped with the bees! 🐝", image: "assets/stories/benny_cover.png" },
                    { text: "But when the moon came out, it was time for bed.", image: "assets/stories/benny_cover.png" },
                    { text: "“Just one more hop!” Benny said.", image: "assets/stories/benny_cover.png" },
                    { text: "Hop… hop… hop…", image: "assets/stories/benny_cover.png" },
                    { text: "Soon, his hops became slower… Hop… …hop…", image: "assets/stories/benny_cover.png" },
                    { text: "His mommy bunny smiled. “Come here, little one.”", image: "assets/stories/benny_cover.png" },
                    { text: "She tucked him into a soft, warm bed of leaves.", image: "assets/stories/benny_cover.png" },
                    { text: "“Close your eyes,” she whispered.", image: "assets/stories/benny_cover.png" },
                    { text: "Benny yawned a big yawn. 😴 His ears flopped down gently.", image: "assets/stories/benny_cover.png" },
                    { text: "And before he could say another hop…", image: "assets/stories/benny_cover.png" },
                    { text: "He was fast asleep, dreaming of soft green fields. 🌿", image: "assets/stories/benny_cover.png" }
                ]
            },
            {
                id: 'milo-bear',
                title: 'Milo the Bear',
                cover: 'assets/stories/milo_cover.png',
                pages: [
                    { text: "Milo the little bear loved honey.", image: "assets/stories/milo_cover.png" },
                    { text: "One evening, he ate a little too much. 🍯 “Mmm… yummy,” he said.", image: "assets/stories/milo_cover.png" },
                    { text: "But soon… He felt very sleepy.", image: "assets/stories/milo_cover.png" },
                    { text: "Milo waddled to his cozy cave.", image: "assets/stories/milo_cover.png" },
                    { text: "The night was quiet. The stars were shining.", image: "assets/stories/milo_cover.png" },
                    { text: "His mama bear hugged him tight. “Time to sleep, Milo,” she said softly.", image: "assets/stories/milo_cover.png" },
                    { text: "Milo closed his eyes.", image: "assets/stories/milo_cover.png" },
                    { text: "He dreamed of golden honey, buzzing bees, and warm sunshine.", image: "assets/stories/milo_cover.png" },
                    { text: "His little tummy was full… His heart was happy…", image: "assets/stories/milo_cover.png" },
                    { text: "And Milo slept all night long. 🌙", image: "assets/stories/milo_cover.png" },
                    { text: "🌟 Sweet dreams.", image: "assets/stories/milo_cover.png" }
                ]
            }
        ];
        
        this.currentStory = null;
        this.currentPageIndex = 0;
        this.isPlaying = false;
        
        // Highlighting and Autoplay logic timeouts
        this.highlightTimeouts = [];
        this.autoplayTimeout = null;
        this.wordSpans = [];
        
        // UI Elements
        this.selectionView = document.getElementById('storybook-selection-view');
        this.readingView = document.getElementById('storybook-reading-view');
        this.grid = document.getElementById('storybook-grid');
        this.headerTitle = document.getElementById('storybook-title-display');
        this.pageImage = document.getElementById('story-page-image');
        this.pageTextContainer = document.getElementById('story-page-text');
        
        this.btnPrev = document.getElementById('btn-story-prev');
        this.btnNext = document.getElementById('btn-story-next');
        this.btnReplay = document.getElementById('btn-story-replay');
        this.btnBack = document.getElementById('btn-story-back');

        this.setupButtons();
    }

    setupButtons() {
        if(this.btnPrev) {
            this.btnPrev.addEventListener('click', () => {
                if(this.btnPrev.classList.contains('disabled')) return;
                this.stopAudioAndHighlights();
                audio.playClickSound();
                this.turnPage(-1);
            });
        }
        
        if(this.btnNext) {
            this.btnNext.addEventListener('click', () => {
                if(this.btnNext.classList.contains('disabled')) return;
                this.stopAudioAndHighlights();
                audio.playClickSound();
                this.turnPage(1);
            });
        }
        
        if(this.btnReplay) {
            this.btnReplay.addEventListener('click', () => {
                this.stopAudioAndHighlights();
                audio.playClickSound();
                this.playCurrentPage();
            });
        }
        
        if(this.btnBack) {
            this.btnBack.addEventListener('click', () => {
                this.stopAudioAndHighlights();
                this.showSelection();
                if (window.adManager) window.adManager.showInterstitial();
            });
        }
    }

    clearAutoplay() {
        if(this.autoplayTimeout) {
            clearTimeout(this.autoplayTimeout);
            this.autoplayTimeout = null;
        }
    }

    showSelection() {
        this.stopAudioAndHighlights();
        this.generateGrid();
        if(this.selectionView) this.selectionView.classList.remove('hidden');
        if(this.readingView) this.readingView.classList.add('hidden');
    }

    generateGrid() {
        if(!this.grid) return;
        this.grid.innerHTML = '';
        
        this.stories.forEach(story => {
            const card = document.createElement('div');
            card.className = 'story-card anim-pop-in';
            
            // Note: Since assets/stories might not exist yet, use fallback or missing image handler.
            card.innerHTML = `
                <img src="${story.cover}" class="story-cover-img" onerror="this.src='assets/body/pixar_boy_anatomy.png'" alt="${story.title}">
                <div class="story-title-banner">
                    <h3>${story.title}</h3>
                </div>
            `;
            
            card.addEventListener('click', () => {
                audio.playClickSound();
                this.openStory(story);
            });
            
            this.grid.appendChild(card);
        });
    }

    openStory(story) {
        this.currentStory = story;
        this.currentPageIndex = 0;
        
        if(this.headerTitle) this.headerTitle.textContent = story.title;
        
        if(this.selectionView) this.selectionView.classList.add('hidden');
        if(this.readingView) this.readingView.classList.remove('hidden');
        
        this.renderPage();
    }

    turnPage(direction) {
        this.clearAutoplay();
        this.currentPageIndex += direction;
        
        // Bounds checking
        if(this.currentPageIndex < 0) this.currentPageIndex = 0;
        if(this.currentPageIndex >= this.currentStory.pages.length) {
            this.currentPageIndex = this.currentStory.pages.length - 1;
            // End of story - maybe show reward or just stay
            return;
        }
        
        this.renderPage();
    }

    renderPage() {
        const page = this.currentStory.pages[this.currentPageIndex];
        
        // Set Image (fallback to story cover, then to placeholder)
        if(this.pageImage) {
            this.pageImage.src = page.image || this.currentStory.cover;
            this.pageImage.onerror = () => { this.pageImage.src = 'assets/body/pixar_boy_anatomy.png'; };
        }
        
        // Set Text by splitting into span words
        if(this.pageTextContainer) {
            this.wordSpans = [];
            this.pageTextContainer.innerHTML = '';
            
            const words = page.text.split(' ');
            words.forEach(word => {
                const span = document.createElement('span');
                span.className = 'story-word';
                // Remove punctuation for the data attribute for clean pronunciation
                const cleanWord = word.replace(/[^\w\s]|_/g, "");
                span.textContent = word + ' ';
                span.dataset.cleanWord = cleanWord;
                
                // Tap-to-Speak specific word logic!
                span.addEventListener('click', () => {
                    this.stopAudioAndHighlights();
                    
                    // Reset all
                    this.wordSpans.forEach(s => s.classList.remove('highlight'));
                    
                    // Highlight tapped
                    span.classList.add('highlight');
                    audio.speak(cleanWord, 1.0, 1.1);
                    
                    // Remove highlight shortly after
                    setTimeout(() => { span.classList.remove('highlight'); }, 800);
                });
                
                this.wordSpans.push(span);
                this.pageTextContainer.appendChild(span);
            });
        }
        
        // Update nav buttons state
        if(this.btnPrev) {
            if(this.currentPageIndex === 0) this.btnPrev.classList.add('disabled');
            else this.btnPrev.classList.remove('disabled');
        }
        if(this.btnNext) {
            if(this.currentPageIndex === this.currentStory.pages.length - 1) this.btnNext.classList.add('disabled');
            else this.btnNext.classList.remove('disabled');
        }
        
        // Auto-play the text
        // Add tiny delay for transition to complete
        setTimeout(() => this.playCurrentPage(), 500);
    }

    playCurrentPage() {
        this.stopAudioAndHighlights();
        
        const page = this.currentStory.pages[this.currentPageIndex];
        
        // Speak full phrase
        audio.speak(page.text, 0.9, 1.1);
        
        // Simulate Word-by-Word highlighting synced to 0.9 speech rate
        let cumulativeDelay = 0;
        
        this.wordSpans.forEach((span, index) => {
            const cleanWord = span.dataset.cleanWord;
            const wordLength = cleanWord.length;
            const rawWord = span.textContent.trim();
            
            const timeToHighlight = cumulativeDelay;
            
            // Base duration tailored for TTS rate of 0.9
            let duration = 150 + (wordLength * 55); 
            
            // Add natural pauses for punctuation
            if (rawWord.endsWith('.') || rawWord.endsWith('!') || rawWord.endsWith('?')) {
                duration += 400; // End of sentence pause
            } else if (rawWord.endsWith(',')) {
                duration += 250; // Comma pause
            } else if (rawWord.endsWith('”') || rawWord.endsWith('“') || rawWord.endsWith('—')) {
                duration += 100; // Minor punctuation pause
            }
            
            // Add highlighting timeout
            const t1 = setTimeout(() => {
                // Clear previous highlights
                this.wordSpans.forEach(s => s.classList.remove('highlight'));
                // Add to current
                span.classList.add('highlight');
            }, timeToHighlight);
            
            this.highlightTimeouts.push(t1);
            
            cumulativeDelay += duration;
        });
        
        // Final timeout to clear all highlights AND trigger autoplay
        const tEnd = setTimeout(() => {
            this.wordSpans.forEach(s => s.classList.remove('highlight'));
            
            // AUTOPLAY: If not on last page, schedule turn
            if (this.currentPageIndex < this.currentStory.pages.length - 1) {
                this.autoplayTimeout = setTimeout(() => {
                    this.turnPage(1);
                }, 1200); // Wait 1.2 seconds before turning
            }
        }, cumulativeDelay);
        this.highlightTimeouts.push(tEnd);
    }

    stopAudioAndHighlights() {
        // Clear all running timeouts
        this.highlightTimeouts.forEach(t => clearTimeout(t));
        this.highlightTimeouts = [];
        this.clearAutoplay();
        
        // Remove visual highlights
        this.wordSpans.forEach(s => s.classList.remove('highlight'));
        
        // Attempt to stop Text-to-Speech immediately if available natively
        if (typeof audio !== 'undefined') {
            if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.TextToSpeech) {
                window.Capacitor.Plugins.TextToSpeech.stop().catch(e => {});
            } else if ('speechSynthesis' in window) {
                window.speechSynthesis.cancel();
            }
        }
    }
}

const storybookStudio = new StoryManager();
window.storybookStudio = storybookStudio;
