class ColoringStudio {
    constructor() {
        this.canvas = document.getElementById('coloring-canvas');
        this.ctx = this.canvas.getContext('2d');
        this.currentAnimal = null;
        this.currentColor = '#EF476F';
        this.mode = 'tap-fill'; // or 'brush'
        this.history = [];
        this.isDrawing = false;
        
        this.colors = [
            '#EF476F', // Red
            '#118AB2', // Blue
            '#06D6A0', // Green
            '#FFD166', // Yellow
            '#000000', // Black
            '#F77F00', // Orange
            '#8338EC'  // Purple
        ];
        
        this.init();
    }

    init() {
        this.setupPalette();
        this.setupTools();
        this.setupCanvasEvents();
    }

    setupPalette() {
        const p = document.getElementById('studio-palette');
        p.innerHTML = '';
        this.colors.forEach(c => {
            const btn = document.createElement('div');
            btn.className = 'btn-palette-color';
            btn.style.backgroundColor = c;
            if (c === this.currentColor) btn.classList.add('active');
            
            btn.onclick = () => {
                this.currentColor = c;
                document.querySelectorAll('.btn-palette-color').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                
                // Audio feedback
                const colorNames = {
                    '#EF476F': 'Red', '#118AB2': 'Blue', '#06D6A0': 'Green',
                    '#FFD166': 'Yellow', '#000000': 'Black', '#F77F00': 'Orange', '#8338EC': 'Purple'
                };
                audio.speak(`${colorNames[c]} color`);
            };
            p.appendChild(btn);
        });
    }

    setupTools() {
        document.getElementById('tool-tap-fill').onclick = (e) => this.switchMode('tap-fill', e.target);
        document.getElementById('tool-brush').onclick = (e) => this.switchMode('brush', e.target);
        
        document.getElementById('btn-undo').onclick = () => this.undo();
        document.getElementById('btn-clear-canvas').onclick = () => this.clearCanvas();
        document.getElementById('btn-save-art').onclick = () => this.saveArt();
        document.getElementById('btn-magic-color').onclick = () => this.magicColor();
    }

    switchMode(newMode, btn) {
        this.mode = newMode;
        document.querySelectorAll('.btn-tool').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        audio.playClickSound();
    }

    setupCanvasEvents() {
        // Handle both Mouse and Touch
        const start = (e) => {
            e.preventDefault();
            this.saveState();
            const pos = this.getEventPos(e);
            
            if (this.mode === 'tap-fill') {
                this.floodFill(pos.x, pos.y);
            } else {
                this.isDrawing = true;
                this.ctx.beginPath();
                this.ctx.moveTo(pos.x, pos.y);
            }
        };

        const move = (e) => {
            if (!this.isDrawing || this.mode !== 'brush') return;
            e.preventDefault();
            const pos = this.getEventPos(e);
            
            this.ctx.lineTo(pos.x, pos.y);
            this.ctx.strokeStyle = this.currentColor;
            this.ctx.lineWidth = 15;
            this.ctx.lineCap = 'round';
            this.ctx.lineJoin = 'round';
            this.ctx.stroke();
        };

        const stop = () => {
            if (this.isDrawing) {
                this.isDrawing = false;
                this.redrawOutline(); // Keep the outline on top
            }
        };

        this.canvas.addEventListener('mousedown', start);
        this.canvas.addEventListener('mousemove', move);
        this.canvas.addEventListener('mouseup', stop);
        this.canvas.addEventListener('touchstart', start);
        this.canvas.addEventListener('touchmove', move);
        this.canvas.addEventListener('touchend', stop);
    }

    getEventPos(e) {
        const rect = this.canvas.getBoundingClientRect();
        const clientX = e.touches ? e.touches[0].clientX : e.clientX;
        const clientY = e.touches ? e.touches[0].clientY : e.clientY;
        
        // Scale to logical canvas coordinates
        const x = (clientX - rect.left) * (this.canvas.width / rect.width);
        const y = (clientY - rect.top) * (this.canvas.height / rect.height);
        return { x: Math.floor(x), y: Math.floor(y) };
    }

    loadAnimal(animalData) {
        this.currentAnimal = animalData;
        document.getElementById('coloring-studio-view').classList.remove('hidden');
        document.getElementById('coloring-selection-view').classList.add('hidden');
        document.getElementById('coloring-animal-name').textContent = animalData.name;
        
        audio.speak(`This is a ${animalData.name}. Let's color the ${animalData.name}!`);
        
        this.history = [];
        this.canvas.width = 1000;
        this.canvas.height = 1000;
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.ctx.fillStyle = "#ffffff";
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        
        this.animalImg = new Image();
        this.outlineCanvas = null; // Clear cached outline for new animal
        this.animalImg.onload = () => {
            this.redrawOutline();
        };
        this.animalImg.src = animalData.image;
    }

    redrawOutline() {
        if (!this.animalImg) return;
        
        // Generate a true black & white coloring outline dynamically
        if (!this.outlineCanvas) {
            this.outlineCanvas = document.createElement('canvas');
            this.outlineCanvas.width = this.canvas.width;
            this.outlineCanvas.height = this.canvas.height;
            const ctxO = this.outlineCanvas.getContext('2d');
            
            // Step 1: Draw a solid white background so transparent images don't flood
            ctxO.fillStyle = 'white';
            ctxO.fillRect(0, 0, this.outlineCanvas.width, this.outlineCanvas.height);
            
            // Step 2: Use extreme contrast and grayscale to mathematically strip
            // colors and leave only the darkest outlines as 'black lines'.
            // High brightness pushes middle colors (yellows/browns) up into pure white.
            ctxO.filter = 'grayscale(100%) brightness(170%) contrast(1000%)';
            
            // Draw maintaining an internal margin
            ctxO.drawImage(this.animalImg, 100, 100, this.canvas.width - 200, this.canvas.height - 200);
            ctxO.filter = 'none';

            // Step 3: Strict Binary Threshold
            // Mathematically forces all anti-aliased gray pixels onto 0 (black) or 255 (white).
            // Without this, multiplying gray pixels onto the canvas after each fill 
            // iteratively darkens the white boundaries until the fill tool "cracks" and stops working.
            const imgData = ctxO.getImageData(0, 0, this.outlineCanvas.width, this.outlineCanvas.height);
            const data = imgData.data;
            for (let i = 0; i < data.length; i += 4) {
                // Determine luminosity
                const avg = (data[i] + data[i+1] + data[i+2]) / 3;
                // Strict pivot: lighter pixels go to PURE white, darker to PURE black
                const val = avg > 200 ? 255 : 0;
                
                data[i] = val;     // R
                data[i+1] = val;   // G
                data[i+2] = val;   // B
                data[i+3] = 255;   // Force absolute opacity
            }
            ctxO.putImageData(imgData, 0, 0);
        }
        
        // Multiply the mathematical outline over whatever child has colored
        this.ctx.globalCompositeOperation = 'multiply';
        this.ctx.drawImage(this.outlineCanvas, 0, 0);
        this.ctx.globalCompositeOperation = 'source-over';
    }

    // Flood Fill (Tap-to-fill)
    floodFill(startX, startY) {
        const targetColor = this.ctx.getImageData(startX, startY, 1, 1).data;
        const fillColor = this.hexToRgb(this.currentColor);
        
        // Don't fill if same color or if it's the BLACK border
        if (targetColor[0] < 50 && targetColor[1] < 50 && targetColor[2] < 50) return; 
        if (this.colorsMatch(targetColor, [fillColor.r, fillColor.g, fillColor.b, 255])) return;

        const imageData = this.ctx.getImageData(0, 0, this.canvas.width, this.canvas.height);
        const pixels = imageData.data;
        
        const stack = [[startX, startY]];
        const width = this.canvas.width;
        const height = this.canvas.height;
        
        const targetR = targetColor[0];
        const targetG = targetColor[1];
        const targetB = targetColor[2];
        const targetA = targetColor[3];

        while (stack.length > 0) {
            let [x, y] = stack.pop();
            const pos = (y * width + x) * 4;

            if (this.colorsMatch([pixels[pos], pixels[pos+1], pixels[pos+2], pixels[pos+3]], [targetR, targetG, targetB, targetA])) {
                pixels[pos] = fillColor.r;
                pixels[pos+1] = fillColor.g;
                pixels[pos+2] = fillColor.b;
                pixels[pos+3] = 255;

                if (x > 0) stack.push([x - 1, y]);
                if (x < width - 1) stack.push([x + 1, y]);
                if (y > 0) stack.push([x, y - 1]);
                if (y < height - 1) stack.push([x, y + 1]);
            }
        }
        
        this.ctx.putImageData(imageData, 0, 0);
        this.redrawOutline();
        audio.playTone(600, 'sine', 0.1);
    }

    colorsMatch(c1, c2) {
        // Tolerance for anti-aliasing
        return Math.abs(c1[0] - c2[0]) < 10 && 
               Math.abs(c1[1] - c2[1]) < 10 && 
               Math.abs(c1[2] - c2[2]) < 10;
    }

    hexToRgb(hex) {
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : null;
    }

    saveState() {
        if (this.history.length > 10) this.history.shift();
        this.history.push(this.canvas.toDataURL());
    }

    undo() {
        if (this.history.length === 0) return;
        const prevState = new Image();
        prevState.onload = () => {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
            this.ctx.drawImage(prevState, 0, 0);
        };
        prevState.src = this.history.pop();
        audio.playClickSound();
    }

    clearCanvas() {
        if (!confirm("Start over?")) return;
        this.loadAnimal(this.currentAnimal);
    }

    async saveArt() {
        audio.speak("Look Mommy! I colored the " + this.currentAnimal.name);

        if (typeof Capacitor !== 'undefined' && Capacitor.isNativePlatform()) {
            try {
                const { Filesystem, Directory } = Capacitor.Plugins;
                const { Media } = Capacitor.Plugins;

                const base64Data = this.canvas.toDataURL('image/png').split(',')[1];
                const filename = `my-${this.currentAnimal.name}-${Date.now()}.png`;

                // 1. Save temporarily to Cache
                const writeResult = await Filesystem.writeFile({
                    path: filename,
                    data: base64Data,
                    directory: Directory.Cache
                });

                // 2. Export immediately to public Photo Gallery
                if (Media) {
                    await Media.savePhoto({ path: writeResult.uri, album: 'Little Gen' });
                    audio.playCorrectSound();
                    setTimeout(() => alert("Masterpiece automatically saved to your Phone Gallery! 🖼️"), 500);
                } else {
                    alert("Media plugin not fully loaded. Try rebuilding.");
                }

            } catch (err) {
                console.error("Save to Gallery Error:", err);
                alert("Could not save picture. Please check if Little Gen has Photo/Storage permissions!");
                audio.playIncorrectSound();
            }
        } else {
            // Web fallback
            const link = document.createElement('a');
            link.download = `my-${this.currentAnimal.name}.png`;
            link.href = this.canvas.toDataURL();
            link.click();
        }
    }

    magicColor() {
        audio.speak("Alakazam! Magic colors!");
        audio.playTone(800, 'sine', 0.5);
        
        // Simple magic: Fill random regions with primary colors
        // For now, let's just use a preset "solved" filter or just fill the major regions.
        for(let i=0; i<30; i++) {
           const rx = Math.floor(Math.random() * this.canvas.width);
           const ry = Math.floor(Math.random() * this.canvas.height);
           this.currentColor = this.colors[Math.floor(Math.random() * this.colors.length)];
           this.floodFill(rx, ry);
        }
    }

    showSelection() {
        document.getElementById('coloring-studio-view').classList.add('hidden');
        document.getElementById('coloring-selection-view').classList.remove('hidden');
        
        const grid = document.getElementById('coloring-animal-grid');
        if (grid.children.length === 0) this.renderAnimalPicker();
    }

    renderAnimalPicker() {
        const grid = document.getElementById('coloring-animal-grid');
        grid.innerHTML = '';
        gameData.coloringAnimals.forEach(animal => {
            const btn = document.createElement('button');
            btn.className = 'btn-grid-mode color-white';
            btn.innerHTML = `
                <img src="${animal.image}" style="width: 80px; filter: grayscale(1);">
                <span class="label">${animal.name}</span>
            `;
            btn.onclick = () => this.loadAnimal(animal);
            grid.appendChild(btn);
        });
    }
}

const coloringStudio = new ColoringStudio();
