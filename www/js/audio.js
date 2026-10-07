// Import native plugin if available (Capacitor handles global injection)
// For Vanilla JS, we access it via the Capacitor object
const { TextToSpeech } = Capacitor.Plugins;

class AudioManager {
    constructor() {
        this.synth = window.speechSynthesis;
        this.voice = null;
        this.audioCtx = null;
        this.initialized = false;
        this.isMuted = false;
        
        // Wait for voices to be loaded for browser fallback
        if (this.synth && this.synth.onvoiceschanged !== undefined) {
            this.synth.onvoiceschanged = () => this._loadVoices();
        }
    }

    init() {
        if (this.initialized) return;
        
        try {
            // Browsers require a user interaction to start AudioContext
            if (!this.audioCtx) {
                const AudioContext = window.AudioContext || window.webkitAudioContext;
                if (AudioContext) {
                    this.audioCtx = new AudioContext();
                }
            }
            if (this.audioCtx && this.audioCtx.state === 'suspended') {
                this.audioCtx.resume();
            }

            if (this.synth) {
                this._loadVoices();
                const silent = new SpeechSynthesisUtterance('');
                this.synth.speak(silent);
            }
        } catch (e) {
            console.log("Audio initialization restricted by device: " + e.message);
        }
        
        this.initialized = true;
    }

    _loadVoices() {
        const voices = this.synth.getVoices();
        if (!voices || voices.length === 0) return;
        this.voice = voices.find(v => v.name.includes('Google US English')) ||
                     voices.find(v => v.name.includes('Samantha')) || 
                     voices.find(v => v.lang === 'en-US' && !v.name.includes('Natural') && !v.name.includes('Online')) || 
                     voices[0];
    }

    toggleMute() {
        this.isMuted = !this.isMuted;
        if (this.isMuted) {
            if (this.synth) this.synth.cancel();
            if (TextToSpeech) TextToSpeech.stop();
        }
        return this.isMuted;
    }

    async speak(text, rate = 0.9, pitch = 1.2) {
        if (this.isMuted) return;
        
        try {
            // Priority 1: Native Plugin (loud and reliable on Android)
            if (TextToSpeech) {
                await TextToSpeech.speak({
                    text: text,
                    lang: 'en-US',
                    rate: rate,
                    pitch: pitch,
                    volume: 1.0, // MAX LOUDNESS
                    category: 'ambient'
                });
                return;
            }
        } catch (e) {
            console.warn("Native TTS failed, falling back to browser speech: ", e);
        }

        // Priority 2: Browser Fallback (for testing on computer)
        if (!this.synth) return;
        
        return new Promise((resolve) => {
            this.synth.cancel();
            const utterance = new SpeechSynthesisUtterance(text);
            if (this.voice) utterance.voice = this.voice;
            utterance.rate = Math.max(0.7, rate);
            utterance.pitch = pitch;
            utterance.volume = 1.0; 
            
            utterance.onend = () => {
                resolve();
            };
            
            // Safety timeout in case onend doesn't fire
            setTimeout(resolve, text.length * 100 + 500);
            
            this.synth.speak(utterance);
        });
    }

    playTone(frequency, type = 'sine', duration = 0.3) {
        if (!this.audioCtx || this.isMuted) return;
        const oscillator = this.audioCtx.createOscillator();
        const gainNode = this.audioCtx.createGain();
        oscillator.type = type;
        oscillator.frequency.setValueAtTime(frequency, this.audioCtx.currentTime);
        gainNode.gain.setValueAtTime(0.1, this.audioCtx.currentTime); 
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioCtx.currentTime + duration);
        oscillator.connect(gainNode);
        gainNode.connect(this.audioCtx.destination);
        oscillator.start();
        oscillator.stop(this.audioCtx.currentTime + duration);
    }

    playCorrectSound() {
        this.playTone(523.25, 'triangle', 0.1); 
        setTimeout(() => this.playTone(659.25, 'triangle', 0.2), 100);
        setTimeout(() => this.playTone(783.99, 'triangle', 0.4), 200);
    }

    playIncorrectSound() {
        this.playTone(300, 'sine', 0.3);
        setTimeout(() => this.playTone(250, 'sine', 0.4), 150);
    }

    playClickSound() {
        this.playTone(600, 'sine', 0.05);
    }
}

const audio = new AudioManager();
