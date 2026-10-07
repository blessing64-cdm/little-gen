// Firebase Configuration (Compat Version for Vanilla JS)
const firebaseConfig = {
  apiKey: "AIzaSyBFjRrq2QuB3636n3Jg8vq4TU3PlrwscME",
  authDomain: "little-gen.firebaseapp.com",
  projectId: "little-gen",
  storageBucket: "little-gen.firebasestorage.app",
  messagingSenderId: "905477293704",
  appId: "1:905477293704:web:2c17f195a04828e8e3c13d",
  measurementId: "G-12B6FECG4X"
};

// Mock auth object used for Amazon builds and offline fallback.
// On Amazon, Firebase/GMS is not available — the guest session
// auto-logs the user in so the app works without an internet connection.
const mockAuth = {
    onAuthStateChanged: (cb) => {
        // Respect the logout flag so we don't auto-login after a manual logout
        const isLoggedOut = localStorage.getItem('lg_logged_out') === 'true';
        if (isLoggedOut) {
            setTimeout(() => cb(null), 500);
        } else {
            // Automatically log in a guest user if offline and not explicitly logged out
            setTimeout(() => cb({ email: "guest@littlegen.app" }), 1000);
        }
    },
    signOut: () => {
        localStorage.setItem('lg_logged_out', 'true');
        return Promise.resolve();
    },
    signInWithEmailAndPassword: (email, password) => {
        localStorage.removeItem('lg_logged_out');
        return Promise.resolve();
    },
    createUserWithEmailAndPassword: (email, password) => {
        localStorage.removeItem('lg_logged_out');
        return Promise.resolve();
    }
};

// Initialize Firebase if available AND not an Amazon build.
// Amazon Fire OS does not include Google Play Services (GMS),
// so Firebase Auth would crash or hang. Use mock auth instead.
if (window.AMAZON_BUILD === true) {
    var auth = mockAuth;
    console.log("Auth: Amazon build detected. Using guest session (no Firebase). 🔥🚫");
} else if (typeof firebase !== 'undefined') {
    firebase.initializeApp(firebaseConfig);
    var auth = firebase.auth();
} else {
    // Fallback mock for offline web testing
    var auth = mockAuth;
    console.warn("Firebase not loaded. Using offline mock.");
}

class AuthManager {
    constructor() {}

    init(onSuccessCallback) {
        this.onSuccessCallback = onSuccessCallback;
        
        this.authView = document.getElementById('auth-view');
        this.splashView = document.getElementById('splash-view');
        
        this.emailInput = document.getElementById('auth-email');
        this.passwordInput = document.getElementById('auth-password');
        
        this.btnSignup = document.getElementById('btn-auth-signup');
        this.btnLogin = document.getElementById('btn-auth-login');
        
        this.setupListeners();
        this.listenForAuthState();
    }

    setupListeners() {
        this.btnSignup.addEventListener('click', async () => {
            const email = this.emailInput.value.trim();
            const password = this.passwordInput.value.trim();
            
            if (!email || !password) {
                alert("Please enter a valid email and password.");
                return;
            }

            try {
                this.btnSignup.textContent = "Loading...";
                localStorage.removeItem('lg_logged_out'); // Clear flag on signup
                await auth.createUserWithEmailAndPassword(email, password);
                // The onAuthStateChanged listener will automatically take over here
            } catch (error) {
                alert(error.message);
                this.btnSignup.textContent = "Create Account";
            }
        });

        this.btnLogin.addEventListener('click', async () => {
            const email = this.emailInput.value.trim();
            const password = this.passwordInput.value.trim();
            
            if (!email || !password) {
                alert("Please enter a valid email and password.");
                return;
            }

            try {
                this.btnLogin.textContent = "Loading...";
                localStorage.removeItem('lg_logged_out'); // Clear flag on login
                await auth.signInWithEmailAndPassword(email, password);
                // The onAuthStateChanged listener will automatically take over here
            } catch (error) {
                alert(error.message);
                this.btnLogin.textContent = "Log In";
            }
        });
    }

    listenForAuthState() {
        auth.onAuthStateChanged((user) => {
            if (user) {
                // SUCCESS - User is logged in!
                console.log("Logged in as:", user.email);
                
                // Save email for "no login required again" logic
                localStorage.setItem('lg_user_email', user.email);
                
                // Hide Auth View if it's currently open
                if (!this.authView.classList.contains('hidden')) {
                    this.authView.classList.add('hidden');
                    
                    // If they were in the middle of a purchase, they can click again 
                    // or we could auto-trigger, but simpler to let them click again.
                }
                
                // Trigger the main application load ONLY if it hasn't started yet
                if (this.onSuccessCallback) {
                    const callback = this.onSuccessCallback;
                    this.onSuccessCallback = null; // Ensure it only runs once
                    callback();
                }
            } else {
                // NOT LOGGED IN - Just log it, don't force UI change on start
                console.log("User is signed out.");
                
                // Reset buttons
                this.btnSignup.textContent = "Create Account";
                this.btnLogin.textContent = "Log In";
            }
        });
    }
    
    // Helper to allow parents to logout from settings later
    async logout() {
        try {
            localStorage.setItem('lg_logged_out', 'true'); // Set logout flag
            localStorage.removeItem('lg_premium');
            localStorage.removeItem('lg_premium_paid');
            localStorage.removeItem('lg_premium_user_email');
            localStorage.removeItem('lg_user_id');
            
            await auth.signOut();
            window.location.reload(); // Hard refresh back to Auth Screen
        } catch (error) {
            console.error("Logout Error", error);
            // Fallback reload if signOut fails
            window.location.reload();
        }
    }
}

const authManager = new AuthManager();
window.authManager = authManager;
