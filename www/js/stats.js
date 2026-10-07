class StatsManager {
    constructor() {
        this.storageKey = 'lg_mastery_data';
        this.streakKey = 'lg_streak_data';
        
        this.data = JSON.parse(localStorage.getItem(this.storageKey) || '{}');
        /* Data structure example:
           {
              "abc": ["A", "B"],
              "numbers": ["1", "5"],
              "animals": ["Lion"]
           }
        */

        this.streakData = JSON.parse(localStorage.getItem(this.streakKey) || '{"count": 0, "lastDate": null}');
        
        this.updateStreak();
    }

    recordMastery(category, item) {
        if (!this.data[category]) {
            this.data[category] = [];
        }
        
        if (!this.data[category].includes(item)) {
            this.data[category].push(item);
            this.save();
            
            // Also update total lessons count if needed
            let total = parseInt(localStorage.getItem('lg_lessons_played') || '0');
            localStorage.setItem('lg_lessons_played', (total + 1).toString());
        }
    }

    save() {
        localStorage.setItem(this.storageKey, JSON.stringify(this.data));
    }

    getCategoryProgress(category) {
        const counts = {
            'abc': 26,
            'numbers': 100,
            'colors': 12,
            'animals': 25,
            'shapes': 15,
            'fruits': 15,
            'tracing': 36, // A-Z + 0-9
            'stories': 5,  // Just as a placeholder for read stories
            'memory': 20
        };
        
        const learned = (this.data[category] || []).length;
        const total = counts[category] || 20;
        
        return Math.min(100, Math.floor((learned / total) * 100));
    }

    updateStreak() {
        const now = new Date();
        const today = now.toISOString().split('T')[0];
        
        if (this.streakData.lastDate === today) return; // Already updated today
        
        const last = this.streakData.lastDate ? new Date(this.streakData.lastDate) : null;
        
        if (last) {
            const diffTime = Math.abs(now - last);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            
            if (diffDays === 1) {
                // Consecutive day!
                this.streakData.count++;
            } else if (diffDays > 1) {
                // Streak broken
                this.streakData.count = 1;
            }
        } else {
            // First time
            this.streakData.count = 1;
        }
        
        this.streakData.lastDate = today;
        localStorage.setItem(this.streakKey, JSON.stringify(this.streakData));
    }

    resetAll() {
        this.data = {};
        this.streakData = { count: 0, lastDate: null };
        this.save();
        localStorage.setItem(this.streakKey, JSON.stringify(this.streakData));
        localStorage.setItem('lg_lessons_played', '0');
        
        // Notify UI
        if(window.ui) window.ui.updateParentsDashboard();
    }

    getRecentAchievements() {
        let all = [];
        for (const cat in this.data) {
            this.data[cat].forEach(item => {
                all.push({ cat, item });
            });
        }
        // Return last 10
        return all.slice(-10).reverse();
    }
}

const stats = new StatsManager();
window.stats = stats;
