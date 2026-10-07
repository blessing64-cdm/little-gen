/**
 * AdManager 🎟️
 * Google AdMob Integration for Little Gen
 */
window.adManager = {
    // Production IDs
    prodAdUnitId: 'ca-app-pub-1353958726197171/2579402811',
    prodBannerAdUnitId: 'ca-app-pub-1353958726197171/9625220524',

    // Google Test IDs (Always work during development)
    testAdUnitId: 'ca-app-pub-3940256099942544/1033173712',
    testBannerAdUnitId: 'ca-app-pub-3940256099942544/6300978111',

    // Configuration
    useTestAds: false, // SET TO FALSE FOR PRODUCTION RELEASE 🚀
    
    isInitialized: false,
    isPrepared: false,

    get currentAdId() {
        return this.useTestAds ? this.testAdUnitId : this.prodAdUnitId;
    },

    get currentBannerId() {
        return this.useTestAds ? this.testBannerAdUnitId : this.prodBannerAdUnitId;
    },

    async init() {
        // Amazon Appstore build: AdMob is not supported on Fire OS.
        // Google Play Services (GMS) is not available on Amazon devices,
        // so all ad functionality is disabled for this build.
        if (window.AMAZON_BUILD === true) {
            console.log("AdMob: Disabled for Amazon Appstore build. 🚫");
            return;
        }

        try {
            // Check if we are on a native platform
            if (typeof Capacitor === 'undefined') {
                console.warn("Capacitor not found. Ads disabled.");
                return;
            }

            if (!Capacitor.isNativePlatform()) {
                console.log("Ads skipped (Web environment) 🌐");
                return;
            }

            const { AdMob } = Capacitor.Plugins;
            if (!AdMob) {
                console.error("AdMob plugin NOT found in Capacitor.Plugins! ❌");
                return;
            }

            console.log("Initializing AdMob... 🎟️");
            await AdMob.initialize({
                requestTrackingAuthorization: true,
                testingDevices: [], // Add your test device ID here if using prod IDs in debug
                initializeForTesting: this.useTestAds
            });

            // --- NEW: UMP CONSENT FLOW (Mandatory for many regions) ---
            try {
                console.log("Checking AdMob Consent Status... 🛡️");
                const consentInfo = await AdMob.requestConsentInfo();
                if (consentInfo.isConsentFormAvailable && consentInfo.status === 'REQUIRED') {
                    console.log("Consent Form Required. Showing now...");
                    await AdMob.showConsentForm();
                }
                console.log("Consent flow completed.");
            } catch (consentError) {
                console.warn("AdMob Consent Info Error (Non-critical):", consentError);
            }

            // Listen for Banner events to adjust layout
            AdMob.addListener('bannerAdLoaded', async () => {
                if (localStorage.getItem('lg_premium') === 'true') {
                     await AdMob.hideBanner();
                     return;
                }
                console.log("Banner loaded, adjusting layout... 📏");
                document.body.classList.add('ad-visible');
            });

            AdMob.addListener('bannerAdFailedToLoad', (info) => {
                console.warn("Banner failed to load! 📏", JSON.stringify(info));
                document.body.classList.remove('ad-visible');
            });

            // Listen for Interstitial events
            AdMob.addListener('interstitialAdFailedToLoad', (info) => {
                console.warn("Interstitial failed to load! 🎟️", JSON.stringify(info));
                this.isPrepared = false;
            });

            this.isInitialized = true;
            console.log("AdMob Initialized ✅ (Mode: " + (this.useTestAds ? "TEST" : "PROD") + ")");
            
            // Preload the first ad
            this.prepareInterstitial();
            
            // Show banner ad
            this.showBanner();
            
            // App Open Ad (Trigger when app resumes)
            const { App } = Capacitor.Plugins;
            if (App) {
                App.addListener('appStateChange', (state) => {
                    if (state.isActive) {
                        console.log("App resumed, showing interstitial... 🎟️");
                        this.showInterstitial();
                    }
                });
            }
        } catch (e) {
            console.error("AdMob Init Error:", e);
        }
    },

    async prepareInterstitial() {
        if (!this.isInitialized) return;
        if (localStorage.getItem('lg_premium') === 'true') return;
        
        try {
            const { AdMob } = Capacitor.Plugins;
            console.log("Preparing Interstitial: " + this.currentAdId);
            await AdMob.prepareInterstitial({
                adId: this.currentAdId,
                isTesting: this.useTestAds
            });
            this.isPrepared = true;
            console.log("Interstitial Prepared 🎟️");
        } catch (e) {
            console.error("AdMob Prepare Error:", e);
        }
    },

    async showInterstitial() {
        if (!this.isInitialized) return;
        if (localStorage.getItem('lg_premium') === 'true') return;

        try {
            const { AdMob } = Capacitor.Plugins;
            
            if (!this.isPrepared) {
                console.log("Ad not ready yet, preloading now...");
                await this.prepareInterstitial();
            }

            // SAFETY CHECK: Only show ads on safe screens (Start Menu or Library)
            // If they are deep inside a learning module, ABORT the ad to prevent interruption!
            const libraryView = document.getElementById('category-selection-view');
            const startView = document.getElementById('start-view');
            const mainGameView = document.getElementById('main-game-view');
            
            // Safe if:
            // 1. The Start Screen is visible
            // 2. The Main Game View is visible AND the Library (Category Selection) is not hidden
            const isStartVisible = startView && !startView.classList.contains('hidden');
            const isLibraryVisible = mainGameView && !mainGameView.classList.contains('hidden') && 
                                   libraryView && !libraryView.classList.contains('hidden');
            
            const isSafe = isStartVisible || isLibraryVisible;
                           
            if (!isSafe) {
                console.log("Ad Safety Check: User is currently engaged in a lesson. Skipping Ad. 🛡️");
                return;
            }

            if (this.isPrepared) {
                await AdMob.showInterstitial();
                this.isPrepared = false; // Reset
                // Reload for next time
                setTimeout(() => this.prepareInterstitial(), 5000);
            }
        } catch (e) {
            console.error("AdMob Show Error:", e);
        }
    },

    async showBanner() {
        if (!this.isInitialized) return;
        if (localStorage.getItem('lg_premium') === 'true') return;
        
        try {
            const { AdMob } = Capacitor.Plugins;
            const options = {
                adId: this.currentBannerId,
                adSize: 'BANNER',
                position: 'BOTTOM_CENTER',
                margin: 0,
                isTesting: this.useTestAds
            };
            console.log("Showing Banner: " + this.currentBannerId);
            await AdMob.showBanner(options);
            console.log("Banner Ad Shown 🎟️");
        } catch (e) {
            console.error("AdMob Banner Error:", e);
        }
    },

    async hideBanner() {
        try {
            const { AdMob } = Capacitor.Plugins;
            if (AdMob) {
                await AdMob.hideBanner();
                document.body.classList.remove('ad-visible');
            }
        } catch (e) {
            console.error("AdMob Hide Banner Error:", e);
        }
    }
};

// Initialize on start
window.addEventListener('load', () => {
    // Wait for Capacitor to be ready
    const checkCapacitor = setInterval(() => {
        if (typeof Capacitor !== 'undefined' && Capacitor.isNativePlatform()) {
            clearInterval(checkCapacitor);
            window.adManager.init();
        } else if (typeof Capacitor !== 'undefined' && !Capacitor.isNativePlatform()) {
            clearInterval(checkCapacitor);
            console.log("AdMob: Running in web mode, skipping init.");
        }
    }, 500);
    
    // Safety timeout
    setTimeout(() => clearInterval(checkCapacitor), 5000);
});
