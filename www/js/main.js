class App {
    constructor() {}

    updateNavPill(activeId) {
        document.querySelectorAll('.nav-pill-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        const activeBtn = document.getElementById(activeId);
        if (activeBtn) activeBtn.classList.add('active');
    }

    async init() {
        // --- 0. INTERNET CONNECTION ENFORCEMENT ---
        this.checkConnection();
        
        // Listen for network changes
        if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Network) {
            window.Capacitor.Plugins.Network.addListener('networkStatusChange', status => {
                if (!status.connected) {
                    this.showNoInternetScreen();
                } else {
                    this.checkConnection();
                }
            });
        } else {
            window.addEventListener('online', () => this.checkConnection());
            window.addEventListener('offline', () => this.showNoInternetScreen());
        }

        // --- 1. SET PREMIUM IF ADMIN ---
        const isAdmin = typeof auth !== 'undefined' && auth && auth.currentUser && auth.currentUser.email === 'queennkere@gmail.com';
        if (isAdmin) {
            localStorage.setItem('lg_premium', 'true');
            localStorage.setItem('lg_premium_user_email', auth.currentUser.email);
        } else {
            // Verify real active subscription
            if (window.Capacitor && window.Capacitor.isNativePlatform()) {
                try {
                    if (window.AMAZON_BUILD) {
                        // Amazon: restore purchases via our native AmazonIapPlugin
                        const AmazonIap = window.Capacitor?.Plugins?.AmazonIap;
                        if (AmazonIap) {
                            await AmazonIap.restorePurchases();
                            // The restore is async; trust localStorage set by a prior successful purchase
                            // lg_premium_paid was already set on success; just honour it here
                            if (localStorage.getItem('lg_premium_paid') === 'true') {
                                localStorage.setItem('lg_premium', 'true');
                            }
                        }
                    } else if (window.Capacitor?.Plugins?.Purchases) {
                        // Google Play: use RevenueCat
                        const Purchases = window.Capacitor.Plugins.Purchases;
                        const rcKey = "goog_YOUR_PUBLIC_REVENUECAT_KEY_HERE";
                        if (rcKey && !rcKey.includes("YOUR_PUBLIC")) {
                            await Purchases.configure({ apiKey: rcKey });
                            const customerInfo = await Purchases.getCustomerInfo();
                            if (customerInfo?.entitlements?.active['PremiumAccess']) {
                                localStorage.setItem('lg_premium', 'true');
                            } else if (localStorage.getItem('lg_premium_paid') !== 'true') {
                                localStorage.removeItem('lg_premium');
                            }
                        } else {
                            console.log("RevenueCat key is placeholder. Skipping remote verification.");
                        }
                    }
                } catch (e) {
                    console.log("Could not verify subscription: ", e);
                }
            } else if (localStorage.getItem('lg_premium_user_email') !== (typeof auth !== 'undefined' && auth && auth.currentUser ? auth.currentUser.email : '')) {
                // If the user changed and they aren't admin, reset premium unless they are a paid user
                if (localStorage.getItem('lg_premium_paid') !== 'true' && !window.AMAZON_BUILD) {
                    localStorage.removeItem('lg_premium');
                }
            }
        }

        ui.init();
        this.preloadAssets();
        
        // Initialize Theme
        const isDarkMode = localStorage.getItem('lg_theme') === 'dark';
        if (isDarkMode) {
            document.body.classList.add('dark-mode');
            const themeBtn = document.getElementById('btn-menu-theme');
            if(themeBtn) themeBtn.textContent = '☀️ Bright Mode';
        }

        // Initialize Premium UI
        const isPremium = localStorage.getItem('lg_premium') === 'true';
        if (isPremium) {
            document.querySelectorAll('.lock-icon').forEach(icon => icon.style.display = 'none');
            const premiumBtn = document.getElementById('btn-upgrade-premium');
            if(premiumBtn) {
                premiumBtn.innerHTML = "✓ Premium Unlocked";
                premiumBtn.style.background = "var(--accent-green)";
                premiumBtn.style.boxShadow = "none";
            }
        }

        ui.showSplashScreen();
        
        setTimeout(() => {
            ui.showLibrary();
            
            // Initialize specific features
            if (window.memoryGame) window.memoryGame.init();
            
            // --- PERSONALIZED GREETING ---
            const childName = localStorage.getItem('lg_profile_name');
            const nameDisplay = document.getElementById('user-name-display');
            if (nameDisplay) {
                nameDisplay.textContent = childName || "Friend";
            }
        }, 3000); // Show splash for 3 seconds


        this.setupButtons();
        
        // Expose function for the game manager to return to library
        window.goBackToCategories = () => {
            this.returnToLibrary(); 
        };

        // --- SMART Native Android Back Button Support ---
        if (typeof Capacitor !== 'undefined' && Capacitor.isNativePlatform() && Capacitor.Plugins.App) {
            Capacitor.Plugins.App.addListener('backButton', ({ canGoBack }) => {
                // Determine current view state for intelligent navigation
                const libView = document.getElementById('category-selection-view');
                const coloringStudio = document.getElementById('coloring-studio-view');
                const coloringSelection = document.getElementById('coloring-selection-view');
                const bodyExplorer = document.getElementById('body-explorer-view');
                const gameplay = document.getElementById('gameplay-interface');
                const animalsOverlay = document.getElementById('animal-category-overlay');
                const levelOverlay = document.getElementById('level-selection-overlay');

                if (libView && !libView.classList.contains('hidden')) {
                    // We are at the root menu - Exit the app
                    Capacitor.Plugins.App.exitApp();
                } else if (coloringStudio && !coloringStudio.classList.contains('hidden')) {
                    // In a coloring project - Go back to selection
                    if (window.coloringStudio) window.coloringStudio.showSelection();
                } else if (document.getElementById('tracing-studio-view') && !document.getElementById('tracing-studio-view').classList.contains('hidden')) {
                    // In the tracing studio - back to ABC/123 grid
                    if (window.tracingStudio) window.tracingStudio.showSelection();
                } else if (document.getElementById('storybook-reading-view') && !document.getElementById('storybook-reading-view').classList.contains('hidden')) {
                    // In a storybook - back to library
                    if (window.storybookStudio) window.storybookStudio.showSelection();
                } else if (document.getElementById('memory-board-view') && !document.getElementById('memory-board-view').classList.contains('hidden')) {
                    // In the memory game - back to selection grid
                    if (window.memoryGame) window.memoryGame.showSelection();
                } else if (animalsOverlay && !animalsOverlay.classList.contains('hidden')) {
                    ui.cancelAnimalCategorySelection();
                } else if (levelOverlay && !levelOverlay.classList.contains('hidden')) {
                    ui.cancelLevelSelection();
                } else {
                    // Everywhere else - return to main library
                    this.returnToLibrary();
                }
            });
        }
    }

    async checkConnection() {
        let isConnected = true;
        if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.Network) {
            const status = await window.Capacitor.Plugins.Network.getStatus();
            isConnected = status.connected;
        } else {
            isConnected = navigator.onLine;
        }

        if (!isConnected) {
            this.showNoInternetScreen();
            return;
        }

        // We have a network connection, now check for actual data access
        // Retry logic for unstable mobile networks
        let hasData = false;
        for (let i = 0; i < 3; i++) {
            try {
                const controller = new AbortController();
                const timeoutId = setTimeout(() => controller.abort(), 4000); // 4s timeout per ping
                
                const url = 'https://dns.google/resolve?name=google.com&_=' + new Date().getTime();
                const response = await fetch(url, { 
                    mode: 'cors', 
                    cache: 'no-store',
                    signal: controller.signal
                });
                
                clearTimeout(timeoutId);

                if (response.ok) {
                    hasData = true;
                    break;
                }
            } catch (error) {
                // Ignore transient errors and retry
            }
        }

        if (hasData) {
            this.hideNoInternetScreen();
            
            // Re-trigger ad preparation if ads failed previously
            if (window.adManager) {
                if (!window.adManager.isPrepared) {
                    window.adManager.prepareInterstitial();
                }
                // Re-trigger banner if it failed to load originally
                if (!document.body.classList.contains('ad-visible')) {
                    window.adManager.showBanner();
                }
            }
        } else {
            this.showNoInternetScreen();
        }
    }

    showNoInternetScreen() {
        const noInternetView = document.getElementById('no-internet-view');
        if (noInternetView) noInternetView.classList.remove('hidden');
    }

    hideNoInternetScreen() {
        const noInternetView = document.getElementById('no-internet-view');
        if (noInternetView) noInternetView.classList.add('hidden');
    }

    setupButtons() {
        // Global button click sound
        document.addEventListener('click', (e) => {
            const isButtonLike = e.target.tagName === 'BUTTON' || 
                               e.target.closest('.btn') || 
                               e.target.closest('.btn-icon') || 
                               e.target.closest('.btn-mode') || 
                               e.target.closest('.menu-item') || 
                               e.target.closest('.option-card');
                               
            if (isButtonLike && e.target.id !== 'btn-settings-toggle') {
                audio.init(); // unlock audio context if not already
                audio.playClickSound();
            } else if (e.target.id === 'btn-settings-toggle') {
                audio.init();
                audio.playTone(800, 'triangle', 0.1); // distinct sound for menu
            }
        });

        // Global Settings Menu
        const settingsMenu = document.getElementById('settings-menu');
        const settingsBackdrop = document.getElementById('settings-backdrop');
        
        const closeSettings = () => {
            settingsMenu.classList.add('hidden');
            settingsBackdrop.classList.add('hidden');
        };

        document.getElementById('btn-settings-toggle').addEventListener('click', () => {
            const isHidden = settingsMenu.classList.contains('hidden');
            if (isHidden) {
                settingsMenu.classList.remove('hidden');
                settingsBackdrop.classList.remove('hidden');
            } else {
                closeSettings();
            }
        });

        // Hide menu if clicked outside
        document.addEventListener('click', (e) => {
            if (!e.target.closest('#settings-menu') && !e.target.closest('#btn-settings-toggle')) {
                closeSettings();
            }
        });

        document.getElementById('btn-menu-sound').addEventListener('click', (e) => {
            const isMuted = audio.toggleMute();
            e.target.textContent = isMuted ? '🔇 Sound Off' : '🔊 Sound On';
            closeSettings();
        });

        document.getElementById('btn-menu-parents').addEventListener('click', () => {
            closeSettings();
            this.showParentsScreen();
        });

        // Profile Overlay Logic
        const profileModal = document.getElementById('profile-overlay');
        const nameInput = document.getElementById('profile-name');
        const ageInput = document.getElementById('profile-age');

        document.getElementById('btn-menu-profile').addEventListener('click', () => {
            closeSettings();
            
            // Load existing data
            nameInput.value = localStorage.getItem('lg_profile_name') || '';
            ageInput.value = localStorage.getItem('lg_profile_age') || '';
            
            profileModal.classList.remove('hidden');
        });

        document.getElementById('btn-profile-cancel').addEventListener('click', () => {
            profileModal.classList.add('hidden');
            if (window.adManager) window.adManager.showInterstitial();
        });

        document.getElementById('btn-profile-save').addEventListener('click', () => {
            const childName = nameInput.value.trim();
            localStorage.setItem('lg_profile_name', childName);
            localStorage.setItem('lg_profile_age', ageInput.value.trim());
            
            profileModal.classList.add('hidden');
            if(childName) {
                audio.speak(`Profile saved for ${childName}!`);
            }
        });

        document.getElementById('btn-menu-theme').addEventListener('click', (e) => {
            const isDark = document.body.classList.toggle('dark-mode');
            if (isDark) {
                localStorage.setItem('lg_theme', 'dark');
                e.target.textContent = '☀️ Bright Mode';
            } else {
                localStorage.setItem('lg_theme', 'light');
                e.target.textContent = '🌙 Dark Mode';
            }
            closeSettings();
        });

        // Landing Screen Buttons
        document.getElementById('btn-start').addEventListener('click', () => {
            const hasAudio = typeof audio !== 'undefined';
            if (hasAudio) audio.init(); 
            
            const childName = localStorage.getItem('lg_profile_name');
            const greeting = childName ? `Let's play, ${childName}!` : "Welcome Little Gen! What should we play today?";
            if (hasAudio) audio.speak(greeting, 1.0, 1.2);
            
            ui.showMainGameUI();
        });

        document.getElementById('btn-parents').addEventListener('click', () => {
            this.showParentsScreen();
        });

        const libParents = document.getElementById('btn-library-parents');
        if (libParents) libParents.addEventListener('click', () => this.showParentsScreen());

        const libSettings = document.getElementById('btn-library-settings');
        if (libSettings) libSettings.addEventListener('click', () => this.toggleSettings());

        document.getElementById('btn-close-parents').addEventListener('click', () => {
            document.getElementById('parents-overlay').classList.add('hidden');
            if (window.adManager) window.adManager.showInterstitial();
        });

        document.getElementById('btn-parents-reset').addEventListener('click', () => {
            if(confirm("Are you sure you want to reset all progress?")) {
                localStorage.removeItem('lg_lessons_played');
                document.getElementById('stat-lessons').textContent = '0';
                audio.speak("Progress reset.");
            }
        });

        document.getElementById('btn-parents-profile').addEventListener('click', () => {
            document.getElementById('parents-overlay').classList.add('hidden');
            document.getElementById('btn-menu-profile').click();
        });

        document.getElementById('btn-parents-support').addEventListener('click', () => {
            const subject = encodeURIComponent("Little Gen App Support");
            const body = encodeURIComponent("Hello,\n\nI need some help with the app...\n\n");
            window.location.href = `mailto:queennkere@gmail.com?subject=${subject}&body=${body}`;
        });



        document.getElementById('btn-upgrade-premium').addEventListener('click', async () => {
            if (localStorage.getItem('lg_premium') === 'true') return;

            if (typeof audio !== 'undefined' && audio.init) {
                audio.init();
                audio.playClickSound();
            }

            // Check user authentication safely (bypassed on Amazon build)
            let user = null;
            if (window.AMAZON_BUILD === true) {
                // Amazon Fire OS build - guest parent user session
                user = { email: "guest@littlegen.app" };
            } else if (typeof auth !== 'undefined' && auth && auth.currentUser) {
                user = auth.currentUser;
            } else if (typeof firebase !== 'undefined' && firebase.auth && firebase.auth().currentUser) {
                user = firebase.auth().currentUser;
            }

            if (!user) {
                const authView = document.getElementById('auth-view');
                if (authView && typeof ui !== 'undefined') {
                    ui.showScreen(authView);
                }
                return;
            }
            
            try {
                // Native Checkout (Capacitor Native Platform)
                if (window.Capacitor && window.Capacitor.isNativePlatform()) {
                    if (window.AMAZON_BUILD) {
                        // --- Amazon Appstore: Direct Native IAP ---
                        const AmazonIap = window.Capacitor?.Plugins?.AmazonIap;
                        if (!AmazonIap) {
                            throw new Error("AmazonIap plugin not available.");
                        }
                        const result = await AmazonIap.purchase({ sku: 'little_gen_premium_v1' });
                        if (!result || !result.success) {
                            throw new Error("Amazon purchase did not succeed.");
                        }
                        // result.alreadyPurchased is also a success case
                    } else {
                        // --- Google Play: RevenueCat ---
                        const Purchases = window.Capacitor?.Plugins?.Purchases;
                        const rcKey = "goog_YOUR_PUBLIC_REVENUECAT_KEY_HERE";
                        if (Purchases && rcKey && !rcKey.includes("YOUR_PUBLIC")) {
                            await Purchases.configure({ apiKey: rcKey });
                            const result = await Purchases.purchaseProduct({ 
                                productIdentifier: 'little_gen_premium_monthly' 
                            });
                            if (!result?.customerInfo?.entitlements?.active['PremiumAccess']) {
                                throw new Error("Purchase could not be verified.");
                            }
                        } else {
                            // Web/Debug Math Gate Fallback
                            const a = Math.floor(Math.random() * 5) + 1;
                            const b = Math.floor(Math.random() * 5) + 1;
                            const ans = prompt(`Parent Verification: What is ${a} + ${b}? (Enter ${a + b} to unlock Premium)`);
                            if (ans !== (a + b).toString()) {
                                if (typeof audio !== 'undefined' && audio.playIncorrectSound) audio.playIncorrectSound();
                                return;
                            }
                        }
                    }
                } else {
                    // Web Test Fallback (Math Gate)
                    const a = Math.floor(Math.random() * 5) + 1;
                    const b = Math.floor(Math.random() * 5) + 1;
                    const ans = prompt(`Parent Web Test: What is ${a} + ${b}? (Type ${a + b})`);
                    if (ans !== (a + b).toString()) {
                        if (typeof audio !== 'undefined' && audio.playIncorrectSound) audio.playIncorrectSound();
                        return;
                    }
                }

                // Purchase / Unlock Success!
                localStorage.setItem('lg_premium', 'true');
                localStorage.setItem('lg_premium_paid', 'true');
                if (window.adManager) window.adManager.hideBanner();
                
                const btn = document.getElementById('btn-upgrade-premium');
                if (btn) {
                    btn.innerHTML = "✓ Premium Unlocked";
                    btn.style.background = "#06D6A0";
                    btn.style.boxShadow = "none";
                }
                
                document.querySelectorAll('.lock-icon').forEach(icon => icon.style.display = 'none');
                
                if (typeof audio !== 'undefined') {
                    if (audio.playCorrectSound) audio.playCorrectSound();
                    if (audio.speak) audio.speak("Premium Unlocked! Thank you!", 1.0, 1.2);
                }
                
            } catch(e) {
                if (!e?.userCancelled) {
                    alert("Purchase Notice: " + (e?.message || "Unable to complete purchase at this time."));
                }
                if (typeof audio !== 'undefined' && audio.playIncorrectSound) audio.playIncorrectSound();
            }
        });

        document.getElementById('btn-auth-back').addEventListener('click', () => {
            document.getElementById('auth-view').classList.add('hidden');
        });

        // Master Back-to-Library Handlers
        const backToLibraryBtns = [
            'btn-back-to-library', 
            'btn-back-from-coloring', 
            'btn-body-back',
            'btn-back-from-tracing',
            'btn-back-from-stories',
            'btn-back-from-memory'
        ];
        backToLibraryBtns.forEach(id => {
            const btn = document.getElementById(id);
            if (btn) {
                btn.onclick = () => {
                    if (typeof audio !== 'undefined') {
                        audio.init();
                        audio.playTone(400, 'sine', 0.1);
                    }
                    this.returnToLibrary();
                };
            }
        });

        // Specific sub-menu back buttons
        const btnBackToAnimals = document.getElementById('btn-back-to-animals');
        if (btnBackToAnimals) {
            btnBackToAnimals.onclick = () => {
                if (typeof coloringStudio !== 'undefined') {
                    coloringStudio.showSelection();
                }
                if (typeof audio !== 'undefined') {
                    audio.playTone(400, 'sine', 0.1);
                }
                if (typeof window.adManager !== 'undefined') {
                    window.adManager.showInterstitial();
                }
            };
        }

        const btnBackToTracingSel = document.getElementById('btn-back-to-tracing-sel');
        if (btnBackToTracingSel) {
            btnBackToTracingSel.onclick = () => {
                if (typeof tracingStudio !== 'undefined') {
                    tracingStudio.showSelection();
                }
                if (typeof audio !== 'undefined') {
                    audio.playTone(400, 'sine', 0.1);
                }
                if (typeof window.adManager !== 'undefined') {
                    window.adManager.showInterstitial();
                }
            };
        }

        // Category Grid Buttons (New V2 Library)
        const gridCategoryBtns = document.querySelectorAll('.category-card-v2');
        gridCategoryBtns.forEach(btn => {
            btn.addEventListener('click', (e) => {
                audio.init(); 

                const targetBtn = e.target.closest('.category-card-v2');
                if (!targetBtn) return;
                
                const category = targetBtn.dataset.category;
                
                // --- PREMIUM CHECK ---
                const isPremium = localStorage.getItem('lg_premium') === 'true';
                const premiumCategories = ['coloring', 'tracing', 'body', 'shapes', 'animals', 'music'];
                if (premiumCategories.includes(category) && !isPremium) {
                    audio.playTone(300, 'sine', 0.2); // Denied sound
                    this.showParentsScreen(); // Show upgrade dashboard
                    return;
                }

                if (category === 'coloring') {
                    ui.showColoringWorld();
                    coloringStudio.showSelection();
                } else if (category === 'tracing') {
                    ui.showTracingWorld();
                    tracingStudio.showSelection();
                } else if (category === 'stories') {
                    ui.showStorybookWorld();
                    storybookStudio.showSelection();
                } else if (category === 'memory') {
                    ui.showMemoryGame();
                    memoryGame.showSelection();
                } else if (category === 'body') {
                    ui.showBodyExplorer();
                } else if (category === 'music') {
                    // Fallback to memory game or a placeholder if music isn't ready
                    // For now, let's treat it as a coming soon or reuse another mode
                    ui.showMemoryGame(); 
                    memoryGame.showSelection();
                } else {
                    this.startGameScreen(category);
                }
            });
        });

        // Bottom Nav Pill Logic
        const navHome = document.getElementById('nav-home');
        const navStories = document.getElementById('nav-stories');
        const navProfile = document.getElementById('nav-profile');

        if (navHome) navHome.onclick = () => {
            this.returnToLibrary();
            this.updateNavPill('nav-home');
        };
        if (navStories) navStories.onclick = () => {
            ui.showStorybookWorld();
            if (window.storybookStudio) window.storybookStudio.showSelection();
            this.updateNavPill('nav-stories');
        };
        if (navProfile) navProfile.onclick = () => {
            this.toggleSettings();
            // Optional: specifically open profile tab if settings has one
            document.getElementById('btn-menu-profile').click();
            this.updateNavPill('nav-profile');
        };

        // Retry Connection Button
        const btnRetry = document.getElementById('btn-retry-connection');
        if (btnRetry) {
            btnRetry.addEventListener('click', async () => {
                const originalText = btnRetry.textContent;
                btnRetry.textContent = "Checking...";
                btnRetry.disabled = true;
                await this.checkConnection();
                btnRetry.textContent = originalText;
                btnRetry.disabled = false;
            });
        }

        this.setupParentListeners();
    }

    showParentsScreen() {
        // 1. ADMIN BYPASS
        const loggedInEmail = auth && auth.currentUser ? auth.currentUser.email : null;
        if (loggedInEmail === 'queennkere@gmail.com') {
            ui.showParentsScreen();
            return;
        }

        // Simple parent gate
        const a = Math.floor(Math.random() * 5) + 1;
        const b = Math.floor(Math.random() * 5) + 1;
        const ans = prompt(`Parents Only! What is ${a} + ${b}?`);
        
        if (parseInt(ans) === (a + b)) {
            ui.showParentsScreen();
        } else if (ans !== null) {
            audio.playIncorrectSound();
            alert("Oops! That is not correct.");
        }
    }

    setupParentListeners() {
        // Reset Progress
        const btnReset = document.getElementById('btn-parents-reset');
        if (btnReset) {
            btnReset.onclick = () => {
                if (confirm("Are you sure you want to reset ALL progress? This cannot be undone.")) {
                    if (window.stats) window.stats.resetAll();
                    audio.playTone(300, 'triangle', 0.2);
                    alert("Progress reset successfully!");
                }
            };
        }

        // Close dashboard
        const btnClose = document.getElementById('btn-close-parents');
        if (btnClose) {
            btnClose.onclick = () => {
                document.getElementById('parents-overlay').classList.add('hidden');
                audio.playClickSound();
            };
        }

        // Logout
        const btnLogout = document.getElementById('btn-parents-logout');
        if (btnLogout) {
            btnLogout.onclick = () => {
                if (confirm("Log out from Little Gen?")) {
                    if (typeof authManager !== 'undefined') {
                        authManager.logout();
                    } else {
                        // Fallback if authManager isn't available
                        localStorage.setItem('lg_logged_out', 'true');
                        localStorage.removeItem('lg_user_id');
                        localStorage.removeItem('lg_premium');
                        location.reload();
                    }
                }
            };
        }
    }

    returnToLibrary() {
        try {
            // Reset game state and abruptly stop any background audio queues
            if (typeof game !== 'undefined' && game.reset) {
                game.reset();
            } else if (typeof game !== 'undefined') {
                game.currentCategory = null;
                game.gamePhase = null;
            }

            // Stop all module background tasks explicitly
            if (typeof bodyExplorer !== 'undefined' && bodyExplorer.stop) bodyExplorer.stop();
            if (typeof memoryGame !== 'undefined' && memoryGame.stop) memoryGame.stop();
            if (typeof coloringStudio !== 'undefined' && coloringStudio.stop) coloringStudio.stop();
            if (typeof tracingStudio !== 'undefined' && tracingStudio.stop) tracingStudio.stop();
            if (typeof storybookStudio !== 'undefined' && storybookStudio.stop) storybookStudio.stop();

            if (typeof audio !== 'undefined') {
                if (audio.synth) audio.synth.cancel();
                if (window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.TextToSpeech && typeof window.Capacitor.Plugins.TextToSpeech.stop === 'function') {
                    window.Capacitor.Plugins.TextToSpeech.stop().catch(e => {});
                }
            }
            
            // Show library first so the UI state is 'safe' for ads
            ui.showLibrary();

            if (window.adManager) window.adManager.showInterstitial();
        } catch (e) {
            console.error("Error during returnToLibrary state cleanup:", e);
            ui.showLibrary();
        }
    }

    startGameScreen(category) {
        ui.showGameplay();
        
        const titles = {
            'numbers': '123 Numbers',
            'abc': 'Sing & Learn ABCs',
            'colors': 'Find the Color',
            'animals': 'Animal Sounds',
            'shapes': 'Learn Shapes',
            'phonics': 'First Phonics',
            'fruits': 'Real Fruits',
            'vegetables': 'Real Veggies'
        };
        
        // Start specific game mode logic
        game.startCategory(category);
    }

    preloadAssets() {
        if (!gameData) return;
        
        const assetsToLoad = [];
        
        // Collect all images from Animals, Fruits, Vegetables
        ['animals', 'fruits', 'vegetables'].forEach(cat => {
            const data = gameData[cat];
            if (!data) return;
            
            if (Array.isArray(data)) {
                data.forEach(item => {
                    if (item.image) assetsToLoad.push(item.image);
                });
            } else if (typeof data === 'object') {
                // For nested animals (pets, farm, wild)
                Object.values(data).forEach(subArr => {
                    if (Array.isArray(subArr)) {
                        subArr.forEach(item => {
                            if (item.image) assetsToLoad.push(item.image);
                        });
                    }
                });
            }
        });

        // Unique set
        const uniqueAssets = [...new Set(assetsToLoad)];
        console.log(`Preloading ${uniqueAssets.length} assets...`);

        uniqueAssets.forEach(src => {
            const img = new Image();
            img.src = src;
            img.onerror = () => console.warn(`Failed to preload: ${src}`);
        });
    }
}

// Bootstrap
document.addEventListener('DOMContentLoaded', () => {
    const app = new App();
    let appStarted = false;

    const forceStart = () => {
        if (appStarted) return;
        appStarted = true;
        
        app.init();
    }

    try {
        if (typeof authManager !== 'undefined') {
            
            // Watchdog: If Firebase hangs, force open the app.
            const watchdog = setTimeout(() => {
                if (!appStarted) {
                    console.warn("Firebase watchdog triggered, forcing start...");
                    
                    // Show login screen manually if stuck
                    const authView = document.getElementById('auth-view');
                    if (authView) authView.classList.remove('hidden');
                }
            }, 2000);

            authManager.init(() => {
                clearTimeout(watchdog);
                forceStart();
            });
        } else {
            forceStart();
        }
    } catch (e) {
        console.error("Critical Auth Error, forcing fallback: ", e);
        forceStart();
    }
});
