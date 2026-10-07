class BodyExplorerManager {
    constructor() {
        this.parts = [
            { id: 'body-head', name: 'Head', image: 'assets/body/head.png', hotspots: [{ x: 50, y: 18, w: 22, h: 22 }] },
            { id: 'body-hair', name: 'Hair', image: 'assets/body/hair.png', hotspots: [{ x: 50, y: 10, w: 20, h: 10 }] },
            { id: 'body-eyes', name: 'Eyes', image: 'assets/body/eyes.png', hotspots: [
                { x: 44, y: 17, w: 8, h: 8 },
                { x: 56, y: 17, w: 8, h: 8 }
            ], isPlural: true },
            { id: 'body-nose', name: 'Nose', image: 'assets/body/nose.png', hotspots: [{ x: 50, y: 22, w: 8, h: 8 }] },
            { id: 'body-mouth', name: 'Mouth', image: 'assets/body/mouth.png', hotspots: [{ x: 50, y: 28, w: 12, h: 6 }] },
            { id: 'body-ears', name: 'Ears', image: 'assets/body/ears.png', hotspots: [
                { x: 35, y: 20, w: 8, h: 10 },
                { x: 65, y: 20, w: 8, h: 10 }
            ], isPlural: true },
            { id: 'body-neck', name: 'Neck', image: 'assets/body/neck.png', hotspots: [{ x: 50, y: 35, w: 12, h: 10 }] },
            { id: 'body-shoulders', name: 'Shoulders', image: 'assets/body/shoulders.png', hotspots: [
                { x: 38, y: 42, w: 18, h: 12 },
                { x: 62, y: 42, w: 18, h: 12 }
            ], isPlural: true },
            { id: 'body-chest', name: 'Chest', image: 'assets/body/chest.png', hotspots: [{ x: 50, y: 50, w: 30, h: 18 }] },
            { id: 'body-stomach', name: 'Stomach', image: 'assets/body/stomach.png', hotspots: [{ x: 50, y: 65, w: 25, h: 18 }] },
            { id: 'body-arms', name: 'Arms', image: 'assets/body/arms.png', hotspots: [
                { x: 26, y: 55, w: 15, h: 35 },
                { x: 74, y: 55, w: 15, h: 35 }
            ], isPlural: true },
            { id: 'body-hands', name: 'Hands', image: 'assets/body/hands.png', hotspots: [
                { x: 18, y: 75, w: 15, h: 15 },
                { x: 82, y: 75, w: 15, h: 15 }
            ], isPlural: true },
            { id: 'body-fingers', name: 'Fingers', image: 'assets/body/fingers.png', hotspots: [
                { x: 18, y: 85, w: 12, h: 12 },
                { x: 82, y: 85, w: 12, h: 12 }
            ], isPlural: true },
            { id: 'body-legs', name: 'Legs', image: 'assets/body/legs.png', hotspots: [
                { x: 42, y: 85, w: 15, h: 35 },
                { x: 58, y: 85, w: 15, h: 35 }
            ], isPlural: true },
            { id: 'body-knees', name: 'Knees', image: 'assets/body/knees.png', hotspots: [
                { x: 42, y: 92, w: 12, h: 10 },
                { x: 58, y: 92, w: 12, h: 10 }
            ], isPlural: true },
            { id: 'body-feet', name: 'Feet', image: 'assets/body/feet.png', hotspots: [
                { x: 42, y: 98, w: 15, h: 10 },
                { x: 58, y: 98, w: 15, h: 10 }
            ], isPlural: true }
        ];
        
        this.currentStage = null;
        this.guidedIndex = 0;
        this.isPlaying = false;
        this.activeTarget = null;
        this.timeoutIds = [];
        this.speechRecognition = null;
        
        this.promptText = document.getElementById('body-prompt-text');
        this.hotspotLayer = document.getElementById('body-hotspots-layer');
        this.detailImg = document.getElementById('body-part-detail-img');
        this.detailWrapper = document.getElementById('body-detail-wrapper');
        this.container = document.getElementById('body-explorer-container');

        this.initSpeechRecognition();
        this.initHotspots();
    }

    initSpeechRecognition() {
        const SpeechRec = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (SpeechRec) {
            this.speechRecognition = new SpeechRec();
            this.speechRecognition.continuous = false;
            this.speechRecognition.interimResults = false;
            this.speechRecognition.lang = 'en-US';
            
            this.speechRecognition.onresult = (event) => {
                const speechResult = event.results[0][0].transcript.toLowerCase();
                this.handleSpeechResult(speechResult);
            };
            this.speechRecognition.onerror = (event) => {
                console.log("Speech recognition error:", event.error);
                this.simulateSpeechSuccess();
            };
        }
    }

    initHotspots() {
        if (!this.hotspotLayer) return;
        this.hotspotLayer.innerHTML = '';
        
        this.parts.forEach(part => {
            part.hotspots.forEach(config => {
                const hs = document.createElement('div');
                hs.className = 'body-hotspot';
                hs.dataset.partId = part.id;
                hs.style.left = `${config.x - (config.w / 2)}%`;
                hs.style.top = `${config.y - (config.h / 2)}%`;
                hs.style.width = `${config.w}%`;
                hs.style.height = `${config.h}%`;
                
                hs.onclick = () => this.handlePartClick(part);
                this.hotspotLayer.appendChild(hs);
            });
        });
    }

    reset() {
        this.stop();
        this.promptText.textContent = "Select a mode above!";
        this.clearHighlights();
    }

    stop() {
        this.isPlaying = false;
        this.timeoutIds.forEach(id => clearTimeout(id));
        this.timeoutIds = [];
        if (this.speechRecognition) {
            try { this.speechRecognition.stop(); } catch(e) {}
        }
        this.clearHighlights();
    }

    delay(ms) {
        return new Promise(resolve => {
            const id = setTimeout(resolve, ms);
            this.timeoutIds.push(id);
        });
    }

    clearHighlights() {
        if (this.hotspotLayer) {
            this.hotspotLayer.querySelectorAll('.body-hotspot').forEach(hs => hs.classList.remove('active'));
        }
        const svg = document.getElementById('body-anatomy-svg');
        if (svg) {
            svg.querySelectorAll('.svg-part').forEach(part => part.classList.remove('active'));
        }
        if (this.detailWrapper) {
            this.detailWrapper.classList.add('hidden');
        }
        if (this.container) {
            this.container.classList.remove('detail-mode');
        }
    }

    highlightPart(id) {
        this.clearHighlights();
        
        const part = this.parts.find(p => p.id === id);
        if (!part) return;

        // Show Detail View if available
        if (this.detailWrapper && part.image) {
            this.detailImg.src = part.image;
            this.detailWrapper.classList.remove('hidden');
            if (this.container) {
                this.container.classList.add('detail-mode');
            }
        }

        // Highlight Hotspots
        const hotspots = this.hotspotLayer.querySelectorAll(`.body-hotspot[data-part-id="${id}"]`);
        hotspots.forEach(hs => {
            hs.classList.add('active');
        });

        // Highlight SVG Part
        const svgPart = document.getElementById(id);
        if (svgPart) {
            svgPart.classList.add('active');
        }
    }

    async startStage(stageName) {
        this.stop();
        this.currentStage = stageName;
        this.isPlaying = true;
        
        if (stageName === 'guided') {
            this.guidedIndex = 0;
            this.playGuidedSequence();
        } else if (stageName === 'repeat') {
            this.playRepeatMode();
        } else if (stageName === 'song') {
            this.playSongMode();
        }
    }

    async playGuidedSequence() {
        if (!this.isPlaying || this.currentStage !== 'guided') return;
        
        if (this.guidedIndex >= this.parts.length) {
            this.promptText.textContent = "Great job finishing the body explorer!";
            audio.speak("Great job! You learned all the body parts!", 1.0, 1.3);
            this.clearHighlights();
            return;
        }

        const part = this.parts[this.guidedIndex];
        this.highlightPart(part.id);
        this.promptText.textContent = part.name;
        
        audio.playClickSound();
        audio.speak(part.name, 0.9, 1.2);
        
        await this.delay(2000);
        if (!this.isPlaying || this.currentStage !== 'guided') return;
        
        const sentence = part.isPlural ? `These are the ${part.name}` : `This is the ${part.name}`;
        audio.speak(sentence, 1.0, 1.1);
        
        await this.delay(3500);
        if (!this.isPlaying || this.currentStage !== 'guided') return;
        
        this.guidedIndex++;
        this.playGuidedSequence();
    }

    async handlePartClick(part) {
        if (!this.isPlaying) return;

        if (this.currentStage === 'guided') {
            audio.speak(part.name, 1.0, 1.3);
            this.promptText.textContent = part.name;
            this.highlightPart(part.id);
        }
    }

    async playRepeatMode() {
        if (!this.isPlaying || this.currentStage !== 'repeat') return;
        this.clearHighlights();
        
        this.activeTarget = this.parts[Math.floor(Math.random() * this.parts.length)];
        this.highlightPart(this.activeTarget.id);
        
        this.promptText.textContent = `Say: "${this.activeTarget.name}"`;
        audio.speak(`Say... ${this.activeTarget.name}`, 0.9, 1.2);
        
        await this.delay(2000);
        if (!this.isPlaying || this.currentStage !== 'repeat') return;

        if (this.speechRecognition) {
            try {
                this.promptText.textContent = `🎙️ Listening... Say "${this.activeTarget.name}"`;
                this.speechRecognition.start();
            } catch (e) {
                this.simulateSpeechSuccess();
            }
        } else {
            this.simulateSpeechSuccess();
        }
    }

    async handleSpeechResult(transcript) {
        if (!this.isPlaying || this.currentStage !== 'repeat') return;
        
        if (transcript.includes(this.activeTarget.name.toLowerCase())) {
            this.correctSpeech();
        } else {
            audio.playIncorrectSound();
            this.promptText.textContent = "Hmm, try again!";
            audio.speak("Try again. Say " + this.activeTarget.name, 1.0, 1.1);
            await this.delay(3000);
            if (this.isPlaying) this.playRepeatMode();
        }
    }

    async simulateSpeechSuccess() {
        this.promptText.textContent = `⏱️ Say "${this.activeTarget.name}" out loud!`;
        await this.delay(3000);
        if (!this.isPlaying || this.currentStage !== 'repeat') return;
        this.correctSpeech();
    }

    async correctSpeech() {
        audio.playCorrectSound();
        this.promptText.textContent = "Great! 🌟";
        audio.speak("Great!", 1.0, 1.4);
        await this.delay(2000);
        if (this.isPlaying) this.playRepeatMode();
    }

    async playSongMode() {
        if (!this.isPlaying || this.currentStage !== 'song') return;
        
        const sequence = [
            { id: 'body-head', word: 'Head,' },
            { id: 'body-shoulders', word: 'Shoulders,' },
            { id: 'body-knees', word: 'Knees, and' },
            { id: 'body-feet', word: 'Feet!' }, 
            { id: 'body-knees', word: 'Knees, and' },
            { id: 'body-feet', word: 'Feet!' },
            
            { id: 'body-eyes', word: 'And Eyes, and' },
            { id: 'body-ears', word: 'Ears, and' },
            { id: 'body-mouth', word: 'Mouth, and' },
            { id: 'body-nose', word: 'Nose!' },
            
            { id: 'body-head', word: 'Head,' },
            { id: 'body-shoulders', word: 'Shoulders,' },
            { id: 'body-knees', word: 'Knees, and' },
            { id: 'body-feet', word: 'Feet!' }
        ];

        this.promptText.textContent = "Body Song Time! 🎵";
        audio.speak("Let's sing the body song!", 1.0, 1.1);
        await this.delay(2000);
        
        const tempo = 1400; 

        for (let i = 0; i < sequence.length; i++) {
            if (!this.isPlaying || this.currentStage !== 'song') return;
            const item = sequence[i];
            this.highlightPart(item.id);
            this.promptText.textContent = item.word;
            audio.speak(item.word, 1.1, 1.4);
            
            await this.delay(tempo);
        }
        
        if (this.isPlaying && this.currentStage === 'song') {
            await this.delay(2000);
            this.playSongMode(); 
        }
    }
}

const bodyExplorer = new BodyExplorerManager();
window.bodyExplorer = bodyExplorer;
