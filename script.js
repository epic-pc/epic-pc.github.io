// ===== Particle System =====
class ParticleSystem {
    constructor(container) {
        this.container = container;
        this.particles = [];
        this.particleCount = 40;
        this.init();
    }

    init() {
        for (let i = 0; i < this.particleCount; i++) {
            this.createParticle();
        }
    }

    createParticle() {
        const particle = document.createElement('div');
        particle.className = 'particle';

        // Random properties
        const size = 3 + Math.random() * 8;
        const startX = Math.random() * 100;
        const duration = 15 + Math.random() * 20;
        const delay = Math.random() * 10;

        particle.style.width = `${size}px`;
        particle.style.height = `${size}px`;
        particle.style.left = `${startX}%`;
        particle.style.animationDuration = `${duration}s`;
        particle.style.animationDelay = `${delay}s`;

        this.container.appendChild(particle);
        this.particles.push(particle);
    }
}

// ===== Cursor Trail Effect =====
class CursorTrail {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.particles = [];
        this.hue = 0;

        this.resize();
        window.addEventListener('resize', () => this.resize());
        document.addEventListener('mousemove', (e) => this.addParticle(e));

        this.animate();
    }

    resize() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
    }

    addParticle(e) {
        const particle = {
            x: e.clientX,
            y: e.clientY,
            size: Math.random() * 3 + 1,
            speedX: (Math.random() - 0.5) * 2,
            speedY: (Math.random() - 0.5) * 2,
            life: 1
        };
        this.particles.push(particle);

        // Limit particles
        if (this.particles.length > 50) {
            this.particles.shift();
        }
    }

    animate() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        this.hue += 0.5;
        if (this.hue > 360) this.hue = 0;

        for (let i = this.particles.length - 1; i >= 0; i--) {
            const p = this.particles[i];

            p.x += p.speedX;
            p.y += p.speedY;
            p.life -= 0.02;
            p.size *= 0.98;

            if (p.life <= 0 || p.size < 0.5) {
                this.particles.splice(i, 1);
                continue;
            }

            this.ctx.fillStyle = `hsla(${this.hue}, 100%, 60%, ${p.life * 0.5})`;
            this.ctx.beginPath();
            this.ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
            this.ctx.fill();
        }

        requestAnimationFrame(() => this.animate());
    }
}

// ===== 3D Card Tilt Effect =====
class CardTilt {
    constructor(card) {
        this.card = card;
        this.card.addEventListener('mousemove', (e) => this.handleMove(e));
        this.card.addEventListener('mouseleave', () => this.handleLeave());
    }

    handleMove(e) {
        const rect = this.card.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        const centerX = rect.width / 2;
        const centerY = rect.height / 2;

        const rotateX = (y - centerY) / 10;
        const rotateY = (centerX - x) / 10;

        this.card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`;
    }

    handleLeave() {
        this.card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale3d(1, 1, 1)';
    }
}

// ===== Counter Animation =====
function animateCounter(element) {
    const target = parseInt(element.getAttribute('data-count'));
    const duration = 2000;
    const step = target / (duration / 16);
    let current = 0;

    const timer = setInterval(() => {
        current += step;
        if (current >= target) {
            element.textContent = target;
            clearInterval(timer);
        } else {
            element.textContent = Math.floor(current);
        }
    }, 16);
}

// ===== Intersection Observer for Fade-in Sections =====
function initScrollAnimations() {
    const sections = document.querySelectorAll('.fade-in-section');

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';

                // Animate counters when section is visible
                const counters = entry.target.querySelectorAll('.stat-value');
                counters.forEach(counter => {
                    if (!counter.classList.contains('animated')) {
                        counter.classList.add('animated');
                        animateCounter(counter);
                    }
                });
            }
        });
    }, {
        threshold: 0.2
    });

    sections.forEach(section => {
        observer.observe(section);
    });
}

// ===== Smooth Scroll =====
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// ===== Button Ripple Effect =====
function createRipple(e, button) {
    const ripple = document.createElement('span');
    const rect = button.getBoundingClientRect();
    const size = Math.max(rect.width, rect.height);
    const x = e.clientX - rect.left - size / 2;
    const y = e.clientY - rect.top - size / 2;

    ripple.style.width = ripple.style.height = size + 'px';
    ripple.style.left = x + 'px';
    ripple.style.top = y + 'px';
    ripple.style.position = 'absolute';
    ripple.style.borderRadius = '50%';
    ripple.style.background = 'rgba(255, 255, 255, 0.6)';
    ripple.style.transform = 'scale(0)';
    ripple.style.animation = 'ripple 0.6s ease-out';
    ripple.style.pointerEvents = 'none';

    button.style.position = 'relative';
    button.style.overflow = 'hidden';
    button.appendChild(ripple);

    setTimeout(() => ripple.remove(), 600);
}

// ===== Dynamic Background Color Shift =====
function initBackgroundShift() {
    let hue = 200;
    setInterval(() => {
        hue = (hue + 0.5) % 360;
        const color1 = `hsl(${hue}, 40%, 10%)`;
        const color2 = `hsl(${(hue + 30) % 360}, 35%, 15%)`;
        const color3 = `hsl(${(hue + 60) % 360}, 30%, 12%)`;
        document.body.style.background = `linear-gradient(135deg, ${color1} 0%, ${color2} 50%, ${color3} 100%)`;
    }, 100);
}

// ===== Typing Animation for Features =====
function typeWriter(element, text, speed = 50) {
    let i = 0;
    element.textContent = '';

    function type() {
        if (i < text.length) {
            element.textContent += text.charAt(i);
            i++;
            setTimeout(type, speed);
        }
    }

    type();
}

// ===== Mini Music Player Logic =====
class MusicPlayer {
    constructor() {
        this.audio = document.getElementById('audioPlayer');
        this.playBtn = document.getElementById('playPauseBtn');
        this.playIcon = this.playBtn.querySelector('.play-icon');
        this.pauseIcon = this.playBtn.querySelector('.pause-icon');

        this.volumeSlider = document.getElementById('volumeSlider');
        this.muteBtn = document.getElementById('muteBtn');
        this.visualizer = document.querySelector('.music-visualizer');

        // Progress elements
        this.progressFill = document.getElementById('progressFill');
        this.currentTimeEl = document.getElementById('currentTime');
        this.totalTimeEl = document.getElementById('totalTime');

        this.isPlaying = false;
        this.isMuted = false;

        this.init();
    }

    init() {
        // Play/Pause
        this.playBtn.addEventListener('click', () => this.togglePlay());

        // Volume
        this.volumeSlider.addEventListener('input', (e) => {
            this.audio.volume = e.target.value / 100;
            this.isMuted = false;
        });

        this.muteBtn.addEventListener('click', () => {
            this.isMuted = !this.isMuted;
            this.audio.muted = this.isMuted;
            this.muteBtn.style.opacity = this.isMuted ? '0.5' : '1';
        });

        // Update progress bar and time
        this.audio.addEventListener('timeupdate', () => this.updateProgress());
        this.audio.addEventListener('loadedmetadata', () => this.updateTotalTime());

        // Set initial volume
        this.audio.volume = 0.8;

        // Initialize visualizer state
        this.updateVisualizerState();
    }

    togglePlay() {
        if (this.audio.paused) {
            this.audio.play();
            this.isPlaying = true;
        } else {
            this.audio.pause();
            this.isPlaying = false;
        }
        this.updateUI();
    }

    updateUI() {
        if (this.isPlaying) {
            this.playIcon.classList.add('hidden');
            this.pauseIcon.classList.remove('hidden');
        } else {
            this.playIcon.classList.remove('hidden');
            this.pauseIcon.classList.add('hidden');
        }
        this.updateVisualizerState();
    }

    updateVisualizerState() {
        const bars = this.visualizer.querySelectorAll('span');
        bars.forEach(bar => {
            bar.style.animationPlayState = this.isPlaying ? 'running' : 'paused';
        });
    }

    updateProgress() {
        const percent = (this.audio.currentTime / this.audio.duration) * 100;
        this.progressFill.style.width = `${percent}%`;
        this.currentTimeEl.textContent = this.formatTime(this.audio.currentTime);
    }

    updateTotalTime() {
        this.totalTimeEl.textContent = this.formatTime(this.audio.duration);
    }

    formatTime(seconds) {
        if (isNaN(seconds)) return '0:00';
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    }
}

// ===== Initialize All Effects =====
document.addEventListener('DOMContentLoaded', function () {
    // ===== Loading Screen =====
    const loadingScreen = document.getElementById('loadingScreen');

    // Simple loading timer - wait 2 seconds then fade out
    // Loading Screen Logic with Click-to-Enter for Autoplay
    const clickToEnter = document.getElementById('clickToEnter');
    const spinner = document.querySelector('.loader-spinner');

    // Wait 2 seconds then show "Click to Enter"
    setTimeout(() => {
        spinner.style.display = 'none';
        clickToEnter.style.display = 'block';

        // Trigger reflow
        void clickToEnter.offsetWidth;
        clickToEnter.style.opacity = '1';

        // Add one-time click listener to the entire screen
        const enterHandler = () => {
            loadingScreen.classList.add('fade-out');

            // Play music
            const musicPlayer = window.musicPlayer;
            if (musicPlayer && musicPlayer.audio) {
                musicPlayer.audio.play().then(() => {
                    musicPlayer.isPlaying = true;
                    musicPlayer.updateUI();
                }).catch(err => {
                    console.error('Audio play failed:', err);
                });
            }

            // Remove loading screen
            setTimeout(() => {
                loadingScreen.style.display = 'none';
            }, 1200);

            // Clean up listener
            document.removeEventListener('click', enterHandler);
        };

        document.addEventListener('click', enterHandler);
    }, 2000);

    // Initialize Music Player
    window.musicPlayer = new MusicPlayer();

    // Initialize particle system
    const particlesContainer = document.getElementById('particlesContainer');
    if (particlesContainer) {
        new ParticleSystem(particlesContainer);
    }

    // Initialize cursor trail
    const cursorCanvas = document.getElementById('cursorCanvas');
    if (cursorCanvas) {
        new CursorTrail(cursorCanvas);
    }

    // Initialize card tilt effects (DISABLED - no 3D rotation)
    /*
    const tiltCards = document.querySelectorAll('.tilt-card');
    tiltCards.forEach(card => {
        new CardTilt(card);
    });
    */

    // Initialize scroll animations
    initScrollAnimations();

    // Initialize smooth scroll
    initSmoothScroll();

    // Initialize background shift (optional - can be disabled if too distracting)
    // initBackgroundShift();

    // Add ripple effect to buttons
    const buttons = document.querySelectorAll('.discord-btn, .buy-btn, .download-link');
    buttons.forEach(button => {
        button.addEventListener('click', function (e) {
            createRipple(e, this);
        });
    });

    // Add hover sound effect (optional)
    const cards = document.querySelectorAll('.download-card, .product-card, .tool-card');
    cards.forEach(card => {
        card.addEventListener('mouseenter', function () {
            this.style.transition = 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)';
        });
    });

    // Parallax effect on scroll (DISABLED - profile card stays fixed)
    /*
    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;
        const parallaxElements = document.querySelectorAll('.profile-card');

        parallaxElements.forEach(element => {
            const speed = 0.5;
            element.style.transform = `translateY(${scrolled * speed}px)`;
        });
    });
    */

    // Add glow effect on mouse move for cards
    document.querySelectorAll('.product-card, .download-card').forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            card.style.setProperty('--mouse-x', `${x}px`);
            card.style.setProperty('--mouse-y', `${y}px`);
        });
    });
});

// Add ripple animation CSS
const style = document.createElement('style');
style.textContent = `
    @keyframes ripple {
        to {
            transform: scale(2);
            opacity: 0;
        }
    }
    
    .product-card::before,
    .download-card::before {
        content: '';
        position: absolute;
        width: 200px;
        height: 200px;
        background: radial-gradient(circle, rgba(30, 144, 255, 0.3), transparent 70%);
        left: var(--mouse-x, 50%);
        top: var(--mouse-y, 50%);
        transform: translate(-50%, -50%);
        opacity: 0;
        transition: opacity 0.3s;
        pointer-events: none;
    }
    
    .product-card:hover::before,
    .download-card:hover::before {
        opacity: 1;
    }
`;
document.head.appendChild(style);

// ===== Easter Egg: Konami Code =====
let konamiCode = [];
const konamiSequence = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];

document.addEventListener('keydown', (e) => {
    konamiCode.push(e.key);
    konamiCode = konamiCode.slice(-10);

    if (konamiCode.join(',') === konamiSequence.join(',')) {
        // Activate special effect
        document.body.style.animation = 'rainbow 2s linear infinite';
        setTimeout(() => {
            document.body.style.animation = '';
        }, 5000);
    }
});

const rainbowStyle = document.createElement('style');
rainbowStyle.textContent = `
    @keyframes rainbow {
        0% { filter: hue-rotate(0deg); }
        100% { filter: hue-rotate(360deg); }
    }
`;
document.head.appendChild(rainbowStyle);
