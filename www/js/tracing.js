class TracingManager {
    constructor() {
        this.letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split('');
        this.numbers = "0123456789".split('');
        
        this.currentMode = 'letters';
        this.currentChar = null;
        
        this.canvas = document.getElementById('tracing-canvas');
        this.ctx = this.canvas ? this.canvas.getContext('2d', { willReadFrequently: true }) : null;
        
        this.currentColor = '#EF476F';
        this.isDrawing = false;
        
        this.basePixelCount = 0;
        this.hasWon = false;
        
        this.setupButtons();
        if(this.canvas) {
            this.setupCanvasEvents();
            // Handle resize
            window.addEventListener('resize', () => {
                if(!document.getElementById('tracing-studio-view').classList.contains('hidden')) {
                    this.initCanvasForReview();
                }
            });
        }
    }

    setupButtons() {
        // Selection buttons
        const btnLetters = document.getElementById('btn-trace-letters');
        const btnNumbers = document.getElementById('btn-trace-numbers');
        
        if (btnLetters) {
            btnLetters.addEventListener('click', () => {
                this.currentMode = 'letters';
                this.generateGrid();
            });
        }
        
        if (btnNumbers) {
            btnNumbers.addEventListener('click', () => {
                this.currentMode = 'numbers';
                this.generateGrid();
            });
        }

        // Tool buttons
        document.querySelectorAll('.tracing-color-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                document.querySelectorAll('.tracing-color-btn').forEach(b => b.classList.remove('active'));
                e.target.classList.add('active');
                this.currentColor = e.target.dataset.color;
                audio.playClickSound();
            });
        });

        const btnClear = document.getElementById('btn-trace-clear');
        if (btnClear) {
            btnClear.addEventListener('click', () => {
                audio.playTone(300, 'triangle', 0.1);
                this.resetCanvas();
            });
        }
    }

    showSelection() {
        this.generateGrid();
        document.getElementById('tracing-selection-view').classList.remove('hidden');
        document.getElementById('tracing-studio-view').classList.add('hidden');
    }

    generateGrid() {
        const grid = document.getElementById('tracing-item-grid');
        if(!grid) return;
        
        grid.innerHTML = '';
        const items = this.currentMode === 'letters' ? this.letters : this.numbers;
        
        items.forEach(item => {
            const btn = document.createElement('div');
            btn.className = 'btn-trace-item anim-pop-in';
            btn.textContent = item;
            
            btn.onclick = () => {
                audio.playClickSound();
                if(this.currentMode === 'letters') {
                    audio.speak("Trace the letter " + item);
                } else {
                    audio.speak("Trace the number " + item);
                }
                this.startTracing(item);
            };
            
            grid.appendChild(btn);
        });
    }

    startTracing(char) {
        this.currentChar = char;
        this.hasWon = false;
        
        document.getElementById('tracing-char-name').textContent = char;
        document.getElementById('tracing-reward').classList.add('hidden');
        document.getElementById('tracing-selection-view').classList.add('hidden');
        document.getElementById('tracing-studio-view').classList.remove('hidden');
        
        // Give UI a moment to layout before sizing canvas
        setTimeout(() => {
            this.initCanvasForReview();
        }, 100);
    }

    initCanvasForReview() {
        const wrapper = document.getElementById('tracing-canvas-wrapper');
        this.canvas.width = wrapper.clientWidth;
        this.canvas.height = wrapper.clientHeight;
        
        this.resetCanvas();
    }

    resetCanvas() {
        if(!this.ctx || !this.currentChar) return;
        this.hasWon = false;
        
        const w = this.canvas.width;
        const h = this.canvas.height;
        
        // Clear full canvas
        this.ctx.clearRect(0, 0, w, h);
        
        // --- 1. Draw the Base Shape ---
        this.ctx.globalCompositeOperation = 'source-over';
        
        // Choose font size based on canvas height
        const fontSize = Math.min(w, h) * 0.8;
        this.ctx.font = `900 ${fontSize}px Nunito, sans-serif`;
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';
        
        // Draw Light Gray base
        this.ctx.fillStyle = '#e0e0e0';
        // Add a slight dark border/stroke for high contrast base
        this.ctx.strokeStyle = '#ccc';
        this.ctx.lineWidth = 10;
        this.ctx.lineJoin = 'round';
        
        const x = w / 2;
        const y = h / 2;
        this.ctx.strokeText(this.currentChar, x, y);
        this.ctx.fillText(this.currentChar, x, y);
        
        // --- 2. Calculate Base Pixels for Win Condition ---
        this.calculateBasePixels();
        
        // --- 3. Set Masking Mode for user drawing ---
        // 'source-atop' means new drawing only exists where the base shape already is.
        this.ctx.globalCompositeOperation = 'source-atop';
        
        // Add dotted line effect down the middle for tracing guidance
        this.ctx.globalCompositeOperation = 'source-over';
        this.ctx.fillStyle = 'rgba(255,255,255,0.4)';
        // Draw inner guided tracking lines by masking a thinner version of text
        this.ctx.globalCompositeOperation = 'source-atop';
    }

    calculateBasePixels() {
        const imgData = this.ctx.getImageData(0, 0, this.canvas.width, this.canvas.height);
        const data = imgData.data;
        let count = 0;
        
        // Check Alpha channel (every 4th byte)
        for(let i = 3; i < data.length; i += 4) {
            if(data[i] > 50) { // If pixel is significantly opaque
                count++;
            }
        }
        this.basePixelCount = count;
    }

    setupCanvasEvents() {
        const getTouchPos = (e) => {
            const rect = this.canvas.getBoundingClientRect();
            let clientX, clientY;
            if (e.touches && e.touches.length > 0) {
                clientX = e.touches[0].clientX;
                clientY = e.touches[0].clientY;
            } else {
                clientX = e.clientX;
                clientY = e.clientY;
            }
            return {
                x: clientX - rect.left,
                y: clientY - rect.top
            };
        };

        const startDraw = (e) => {
            if(this.hasWon) return; // Stop drawing if already won
            e.preventDefault();
            this.isDrawing = true;
            const pos = getTouchPos(e);
            
            this.ctx.globalCompositeOperation = 'source-atop'; // Restrict to base letter shape
            this.ctx.lineCap = 'round';
            this.ctx.lineJoin = 'round';
            
            // Age 2-6 needs a thick forgiving brush!
            this.ctx.lineWidth = Math.min(this.canvas.width, this.canvas.height) * 0.15; 
            
            this.ctx.strokeStyle = this.currentColor;
            
            this.ctx.beginPath();
            this.ctx.moveTo(pos.x, pos.y);
            this.ctx.lineTo(pos.x, pos.y);
            this.ctx.stroke();
        };

        const draw = (e) => {
            if (!this.isDrawing || this.hasWon) return;
            e.preventDefault();
            const pos = getTouchPos(e);
            
            this.ctx.lineTo(pos.x, pos.y);
            this.ctx.stroke();
        };

        const stopDraw = (e) => {
            if(this.isDrawing) {
                this.ctx.closePath();
                this.isDrawing = false;
                if(!this.hasWon) {
                    this.checkCompletion();
                }
            }
        };

        // Mouse Events
        this.canvas.addEventListener('mousedown', startDraw);
        this.canvas.addEventListener('mousemove', draw);
        this.canvas.addEventListener('mouseup', stopDraw);
        this.canvas.addEventListener('mouseout', stopDraw);

        // Touch Events
        this.canvas.addEventListener('touchstart', startDraw, { passive: false });
        this.canvas.addEventListener('touchmove', draw, { passive: false });
        this.canvas.addEventListener('touchend', stopDraw, { passive: false });
        this.canvas.addEventListener('touchcancel', stopDraw, { passive: false });
    }

    checkCompletion() {
        // Read canvas to see how much of the gray shape is now colored
        const imgData = this.ctx.getImageData(0, 0, this.canvas.width, this.canvas.height);
        const data = imgData.data;
        
        let coloredPixels = 0;
        
        // Loop through pixels. A base gray pixel has R, G, B roughly around 224 (0xe0)
        // A colored pixel will diverge significantly from grayscale.
        for(let i = 0; i < data.length; i += 4) {
            const r = data[i];
            const g = data[i+1];
            const b = data[i+2];
            const a = data[i+3];
            
            if (a > 50) {
                // If it's NOT the base gray color (or border gray), it's a colored pixel
                // Gray #e0e0e0 = 224,224,224. Gray #ccc = 204,204,204
                if (Math.abs(r - g) > 20 || Math.abs(g - b) > 20 || r < 190) {
                    coloredPixels++;
                }
            }
        }
        
        const percentage = coloredPixels / this.basePixelCount;
        
        // If they fill 80% of the shape, they win!
        if (percentage > 0.80) {
            this.triggerWin();
        }
    }

    triggerWin() {
        this.hasWon = true;

        if (window.stats) {
            window.stats.recordMastery('tracing', this.currentChar);
        }

        audio.playCorrectSound();
        audio.speak("Great job! " + this.currentChar, 1.0, 1.3);
        
        // Completely fill in any missing bits of the letter as a reward
        this.ctx.globalCompositeOperation = 'source-over';
        const fontSize = Math.min(this.canvas.width, this.canvas.height) * 0.8;
        this.ctx.font = `900 ${fontSize}px Nunito, sans-serif`;
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';
        this.ctx.fillStyle = this.currentColor;
        this.ctx.fillText(this.currentChar, this.canvas.width / 2, this.canvas.height / 2);
        
        // Pop animation
        this.canvas.classList.add('tracing-complete-anim');
        setTimeout(() => this.canvas.classList.remove('tracing-complete-anim'), 1000);
        
        // Show fireworks/reward
        const reward = document.getElementById('tracing-reward');
        reward.innerHTML = '🌟✨🎉';
        reward.classList.remove('hidden');
    }
}

const tracingStudio = new TracingManager();
window.tracingStudio = tracingStudio;
