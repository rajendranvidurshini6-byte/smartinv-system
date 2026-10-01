<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login | SmartInv</title>
<style>
    :root {
        --primary: #4361ee;
        --primary-dark: #3a0ca3;
        --primary-light: #eef1ff;
        --success: #06d6a0;
        --warning: #ffb703;
        --danger: #ef476f;
        --info: #4cc9f0;

        --text-dark: #1a1f36;
        --text-mid: #4a5568;
        --text-light: #8898aa;

        --border: #e6ecf5;
        --bg-body: #f5f7fb;
        --shadow-lg: 0 25px 70px rgba(30,60,114,0.18);
        --bg-card: #ffffff;
        --input-bg: #fafbfd;

        --radius: 18px;
        --radius-sm: 10px;
        --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1);

        --accent: #4361ee;
        --accent-dark: #3a0ca3;

        /* Background colors — overridden in dark mode */
        --bg-base-1: #0a0f1e;
        --bg-base-2: #1a0b2e;
        --bg-base-3: #05070f;
        --bg-base-4: #101433;
        --bg-base-5: #0a0a1a;
        --orb-opacity: 0.65;
        --vignette: rgba(0,0,0,0.6);
    }

    body.light {
        --bg-base-1: #eef3ff;
        --bg-base-2: #fde6ff;
        --bg-base-3: #e0e8ff;
        --bg-base-4: #d6e4ff;
        --bg-base-5: #f0f4ff;
        --orb-opacity: 0.55;
        --vignette: rgba(255,255,255,0.4);
        --shadow-lg: 0 25px 70px rgba(30,60,114,0.15);
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }
    html { scroll-behavior: smooth; }
    body {
        font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif;
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        background:
            radial-gradient(ellipse at top left, var(--bg-base-1) 0%, transparent 50%),
            radial-gradient(ellipse at bottom right, var(--bg-base-2) 0%, transparent 50%),
            linear-gradient(135deg,
                var(--bg-base-3) 0%,
                var(--bg-base-1) 40%,
                var(--bg-base-4) 70%,
                var(--bg-base-5) 100%);
        position: relative;
        overflow: hidden;
        padding: 20px;
        transition: background 0.4s ease;
    }

    /* ============================================================
       HIDE BROWSER'S NATIVE PASSWORD REVEAL ICON
       ============================================================ */
    input[type="password"]::-ms-reveal,
    input[type="password"]::-ms-clear {
        display: none !important;
    }

    input[type="password"]::-webkit-credentials-auto-fill-button,
    input[type="password"]::-webkit-strong-password-auto-fill-button,
    input::-webkit-credentials-auto-fill-button {
        visibility: hidden;
        display: none !important;
        pointer-events: none;
        position: absolute;
        right: 0;
    }

    /* ============================================================
       THEME TOGGLE BUTTON (top-right corner)
       ============================================================ */
    .theme-toggle {
        position: fixed;
        top: 20px;
        right: 20px;
        width: 48px;
        height: 48px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.15);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border: 1px solid rgba(255, 255, 255, 0.25);
        color: #fff;
        font-size: 20px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        z-index: 1000;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
    }
    .theme-toggle:hover {
        transform: scale(1.1) rotate(15deg);
        background: rgba(255, 255, 255, 0.25);
        box-shadow: 0 6px 24px rgba(0, 0, 0, 0.3);
    }
    .theme-toggle:active {
        transform: scale(0.95);
    }

    body.light .theme-toggle {
        background: rgba(30, 60, 114, 0.12);
        color: #1a1f36;
        border-color: rgba(30, 60, 114, 0.15);
        box-shadow: 0 4px 20px rgba(30, 60, 114, 0.15);
    }
    body.light .theme-toggle:hover {
        background: rgba(30, 60, 114, 0.2);
        box-shadow: 0 6px 24px rgba(30, 60, 114, 0.25);
    }

    /* ============================================================
       DARK ANIMATED BACKGROUND
       ============================================================ */
    .bg-animation {
        position: fixed; inset: 0;
        overflow: hidden; z-index: 0; pointer-events: none;
    }
    .bg-animation::after {
        content: ''; position: absolute; inset: 0;
        background: radial-gradient(ellipse at center, transparent 30%, var(--vignette) 100%);
        transition: background 0.4s ease;
    }

    .orb {
        position: absolute; border-radius: 50%;
        filter: blur(80px); opacity: var(--orb-opacity); will-change: transform;
        transition: opacity 0.4s ease;
    }
    .orb-1 {
        width: 550px; height: 550px;
        background: radial-gradient(circle, #4cc9f0 0%, #4361ee 40%, transparent 75%);
        top: -180px; left: -120px;
        animation: floatOrb1 16s ease-in-out infinite;
    }
    .orb-2 {
        width: 500px; height: 500px;
        background: radial-gradient(circle, #b5179e 0%, #7209b7 40%, transparent 75%);
        bottom: -150px; right: -100px;
        animation: floatOrb2 20s ease-in-out infinite;
    }
    .orb-3 {
        width: 420px; height: 420px;
        background: radial-gradient(circle, #4361ee 0%, #3a0ca3 50%, transparent 75%);
        top: 45%; left: 40%;
        animation: floatOrb3 24s ease-in-out infinite;
        opacity: calc(var(--orb-opacity) * 0.75);
    }
    .orb-4 {
        width: 380px; height: 380px;
        background: radial-gradient(circle, #06d6a0 0%, #059669 50%, transparent 75%);
        top: 10%; right: 12%;
        animation: floatOrb4 22s ease-in-out infinite;
        opacity: calc(var(--orb-opacity) * 0.7);
    }
    .orb-5 {
        width: 340px; height: 340px;
        background: radial-gradient(circle, #ff006e 0%, #b5179e 50%, transparent 75%);
        bottom: 10%; left: 15%;
        animation: floatOrb5 26s ease-in-out infinite;
        opacity: calc(var(--orb-opacity) * 0.6);
    }

    @keyframes floatOrb1 {
        0%, 100% { transform: translate(0, 0) scale(1); }
        33%      { transform: translate(100px, 80px) scale(1.15); }
        66%      { transform: translate(-50px, 120px) scale(0.92); }
    }
    @keyframes floatOrb2 {
        0%, 100% { transform: translate(0, 0) scale(1); }
        50%      { transform: translate(-120px, -90px) scale(1.2); }
    }
    @keyframes floatOrb3 {
        0%, 100% { transform: translate(-50%, -50%) scale(1); }
        33%      { transform: translate(-30%, -65%) scale(1.25); }
        66%      { transform: translate(-65%, -40%) scale(0.9); }
    }
    @keyframes floatOrb4 {
        0%, 100% { transform: translate(0, 0) scale(1); }
        50%      { transform: translate(-100px, 100px) scale(1.15); }
    }
    @keyframes floatOrb5 {
        0%, 100% { transform: translate(0, 0) scale(1); }
        50%      { transform: translate(80px, -80px) scale(1.2); }
    }

    .bg-grid {
        position: absolute; inset: 0;
        background-image:
            linear-gradient(rgba(76, 201, 240, 0.07) 1px, transparent 1px),
            linear-gradient(90deg, rgba(76, 201, 240, 0.07) 1px, transparent 1px);
        background-size: 50px 50px;
        animation: gridMove 30s linear infinite;
        mask-image: radial-gradient(ellipse at center, black 30%, transparent 80%);
        -webkit-mask-image: radial-gradient(ellipse at center, black 30%, transparent 80%);
    }
    body.light .bg-grid {
        background-image:
            linear-gradient(rgba(67, 97, 238, 0.08) 1px, transparent 1px),
            linear-gradient(90deg, rgba(67, 97, 238, 0.08) 1px, transparent 1px);
    }
    @keyframes gridMove {
        0%   { background-position: 0 0; }
        100% { background-position: 50px 50px; }
    }

    .particle {
        position: absolute;
        background: rgba(255, 255, 255, 0.9);
        border-radius: 50%;
        box-shadow: 0 0 8px rgba(76, 201, 240, 0.9),
                    0 0 16px rgba(76, 201, 240, 0.5);
        animation: rise linear infinite;
    }
    body.light .particle {
        background: rgba(67, 97, 238, 0.55);
        box-shadow: 0 0 6px rgba(67, 97, 238, 0.5);
    }
    @keyframes rise {
        0%   { transform: translateY(100vh) scale(0.4); opacity: 0; }
        10%  { opacity: 1; }
        90%  { opacity: 1; }
        100% { transform: translateY(-120px) scale(1.1); opacity: 0; }
    }

    @media (prefers-reduced-motion: reduce) {
        .orb, .particle, .bg-grid { animation: none !important; }
    }

    /* ============================================================
       LOGIN CARD
       ============================================================ */
    .login-container {
        position: relative; z-index: 1;
        width: 100%; max-width: 440px;
        animation: cardIn 0.7s cubic-bezier(0.34, 1.56, 0.64, 1) both;
    }
    @keyframes cardIn {
        from { opacity: 0; transform: translateY(30px) scale(0.95); }
        to   { opacity: 1; transform: translateY(0) scale(1); }
    }

    .login-card {
        background: rgba(255, 255, 255, 0.98);
        backdrop-filter: blur(24px);
        -webkit-backdrop-filter: blur(24px);
        border-radius: var(--radius);
        box-shadow: var(--shadow-lg),
                    0 0 0 1px rgba(255, 255, 255, 0.08),
                    0 0 80px rgba(67, 97, 238, 0.15);
        padding: 36px 32px 30px;
        border: 1px solid rgba(255, 255, 255, 0.15);
        position: relative;
        overflow: hidden;
        transition: box-shadow 0.4s ease, background 0.4s ease;
    }

    .login-card::before {
        content: '';
        position: absolute;
        top: 0; left: 0;
        width: 100%; height: 4px;
        background: linear-gradient(90deg, var(--accent), var(--accent-dark), #4cc9f0, var(--accent));
        background-size: 300% 100%;
        animation: gradientShift 5s ease infinite;
        transition: background 0.4s ease;
    }
    @keyframes gradientShift {
        0%, 100% { background-position: 0% 50%; }
        50%      { background-position: 100% 50%; }
    }

    .brand-logo {
        display: flex; justify-content: center;
        margin-bottom: 18px;
    }
    .brand-logo .logo-icon {
        width: 60px; height: 60px; border-radius: 18px;
        background: linear-gradient(135deg, #4361ee, #4cc9f0);
        display: flex; align-items: center; justify-content: center;
        font-size: 30px;
        box-shadow: 0 10px 30px rgba(67, 97, 238, 0.4),
                    0 0 40px rgba(76, 201, 240, 0.3);
        animation: logoPulse 3s ease-in-out infinite;
    }
    @keyframes logoPulse {
        0%, 100% { transform: scale(1); }
        50%      { transform: scale(1.06); }
    }

    .login-card h2 {
        text-align: center;
        font-size: 24px; color: var(--text-dark);
        font-weight: 800; letter-spacing: -0.5px;
        margin-bottom: 4px;
    }
    .login-card .subtitle {
        text-align: center; font-size: 12.5px;
        color: var(--text-light); margin-bottom: 22px;
    }

    /* ============================================================
       ROLE TABS
       ============================================================ */
    .role-tabs {
        display: flex; gap: 8px;
        padding: 5px;
        background: #f0f3f9;
        border-radius: 12px;
        margin-bottom: 22px;
        position: relative;
        border: 1px solid var(--border);
        transition: background 0.3s;
    }

    .role-tab {
        flex: 1;
        padding: 11px 14px;
        border-radius: 9px;
        font-size: 13.5px;
        font-weight: 700;
        cursor: pointer;
        border: none;
        background: transparent;
        color: var(--text-light);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        display: flex; align-items: center; justify-content: center;
        gap: 8px;
        font-family: inherit;
        position: relative;
        overflow: hidden;
    }
    .role-tab .role-icon {
        font-size: 16px;
        transition: transform 0.3s ease;
    }
    .role-tab:hover {
        color: var(--text-dark);
    }
    .role-tab:hover .role-icon {
        transform: scale(1.15);
    }
    .role-tab.active {
        background: linear-gradient(135deg, var(--accent), var(--accent-dark));
        color: #fff;
        box-shadow: 0 6px 18px rgba(67, 97, 238, 0.35);
        transform: translateY(-1px);
    }
    .role-tab.active .role-icon {
        transform: scale(1.1);
    }

    .role-tab[data-role="ADMIN"].active {
        background: linear-gradient(135deg, #4361ee, #3a0ca3);
        box-shadow: 0 6px 18px rgba(67, 97, 238, 0.4);
    }
    .role-tab[data-role="STAFF"].active {
        background: linear-gradient(135deg, #06d6a0, #059669);
        box-shadow: 0 6px 18px rgba(6, 214, 160, 0.4);
    }

    /* ============================================================
       FORM
       ============================================================ */
    .error-box {
        background: linear-gradient(135deg, #fdecea, #fadbd8);
        color: #922b21;
        padding: 12px 16px;
        border-radius: var(--radius-sm);
        font-size: 13px;
        margin-bottom: 18px;
        text-align: center;
        border-left: 4px solid var(--danger);
        animation: shake 0.4s ease;
        display: flex;
        align-items: center;
        gap: 8px;
        justify-content: center;
    }
    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        25%      { transform: translateX(-6px); }
        75%      { transform: translateX(6px); }
    }

    .form-group { margin-bottom: 16px; position: relative; }
    .form-group label {
        display: block;
        font-size: 12.5px;
        color: var(--text-dark);
        margin-bottom: 7px;
        font-weight: 600;
        letter-spacing: 0.2px;
    }
    .input-wrap { position: relative; }
    .input-wrap .input-icon {
        position: absolute;
        left: 14px; top: 50%;
        transform: translateY(-50%);
        font-size: 15px;
        color: var(--text-light);
        pointer-events: none;
        transition: var(--transition);
    }
    .form-group input {
        width: 100%;
        padding: 12px 42px 12px 42px;
        border: 1.5px solid var(--border);
        border-radius: var(--radius-sm);
        font-size: 14px;
        color: var(--text-dark);
        background: var(--input-bg);
        transition: var(--transition);
        font-family: inherit;
    }

    .form-group input:focus {
        outline: none;
        border-color: var(--accent);
        background: var(--bg-card);
        box-shadow: 0 0 0 4px rgba(67, 97, 238, 0.1);
    }
    .form-group input:focus ~ .input-icon { color: var(--accent); }

    .toggle-pwd {
        position: absolute;
        right: 12px; top: 50%;
        transform: translateY(-50%);
        background: none;
        border: none;
        cursor: pointer;
        font-size: 16px;
        color: var(--text-light);
        padding: 6px;
        border-radius: 6px;
        transition: var(--transition);
    }
    .toggle-pwd:hover {
        background: var(--primary-light);
        color: var(--accent);
    }

    .btn-login {
        width: 100%;
        padding: 13px;
        background: linear-gradient(135deg, var(--accent) 0%, var(--accent-dark) 100%);
        background-size: 200% 200%;
        color: #fff;
        border: none;
        border-radius: var(--radius-sm);
        font-size: 14.5px;
        font-weight: 700;
        cursor: pointer;
        transition: all 0.3s ease;
        letter-spacing: 0.3px;
        margin-top: 4px;
        position: relative;
        overflow: hidden;
        box-shadow: 0 6px 20px rgba(67, 97, 238, 0.4);
    }
    .btn-login:hover {
        background-position: 100% 0;
        transform: translateY(-2px);
        box-shadow: 0 10px 28px rgba(67, 97, 238, 0.55);
    }
    .btn-login:active { transform: translateY(0); }
    .btn-login:disabled { opacity: 0.7; cursor: not-allowed; transform: none; }

    .spinner {
        display: inline-block;
        width: 14px; height: 14px;
        border: 2px solid rgba(255,255,255,0.4);
        border-top-color: #fff;
        border-radius: 50%;
        animation: spin 0.7s linear infinite;
        margin-right: 6px;
        vertical-align: -2px;
    }
    @keyframes spin { to { transform: rotate(360deg); } }

    .info-box {
        margin-top: 18px;
        padding: 11px 15px;
        background: var(--primary-light);
        border-radius: var(--radius-sm);
        font-size: 11.5px;
        color: var(--text-mid);
        text-align: center;
        line-height: 1.7;
        border: 1px dashed rgba(67, 97, 238, 0.25);
        transition: background 0.3s ease;
    }
    .info-box strong { color: var(--primary-dark); font-weight: 700; }
    .info-box code {
        background: var(--bg-card);
        padding: 2px 7px;
        border-radius: 4px;
        font-size: 11px;
        color: var(--primary-dark);
        font-family: 'Consolas', 'Monaco', monospace;
        border: 1px solid rgba(67, 97, 238, 0.15);
    }

    .footer-note {
        text-align: center;
        font-size: 11px;
        color: var(--text-light);
        margin-top: 16px;
    }

    /* ============================================================
       DARK MODE (body.dark overrides)
       ============================================================ */
    body.dark {
        --text-dark: #f0f4f8;
        --text-mid: #a0aec0;
        --text-light: #718096;
        --border: #2d3748;
        --primary-light: #1a2540;
        --bg-card: #1a2238;
        --input-bg: #0f1729;

        --bg-base-1: #0a0f1e;
        --bg-base-2: #1a0b2e;
        --bg-base-3: #05070f;
        --bg-base-4: #101433;
        --bg-base-5: #0a0a1a;
        --orb-opacity: 0.65;
        --vignette: rgba(0,0,0,0.6);
    }

    body.dark .login-card {
        background: rgba(26, 34, 56, 0.95);
        box-shadow: 0 25px 70px rgba(0,0,0,0.55),
                    0 0 0 1px rgba(255,255,255,0.08),
                    0 0 80px rgba(67, 97, 238, 0.15);
    }
    body.dark .role-tabs {
        background: #0f1729;
        border-color: #2d3748;
    }
    body.dark .form-group input {
        color: #f0f4f8;
    }
    body.dark .form-group input:focus {
        background: #0f1729;
    }
    body.dark .info-box code {
        background: #0f1729;
        color: #4cc9f0;
    }

    @media (max-width: 480px) {
        .login-card { padding: 28px 22px 24px; }
        .login-card h2 { font-size: 21px; }
        .brand-logo .logo-icon { width: 52px; height: 52px; font-size: 26px; }
        .role-tab { font-size: 12.5px; padding: 10px 10px; }
        .theme-toggle { top: 14px; right: 14px; width: 42px; height: 42px; font-size: 17px; }
    }
</style>
</head>
<body class="dark">

<!-- ================= THEME TOGGLE ================= -->
<button class="theme-toggle" id="themeToggle" title="Toggle theme" aria-label="Toggle theme">
    <span id="themeIcon">&#9728;</span>
</button>

<!-- ================= ANIMATED BACKGROUND ================= -->
<div class="bg-animation" aria-hidden="true">
    <div class="bg-grid"></div>
    <div class="orb orb-1"></div>
    <div class="orb orb-2"></div>
    <div class="orb orb-3"></div>
    <div class="orb orb-4"></div>
    <div class="orb orb-5"></div>
</div>

<!-- ================= LOGIN CARD ================= -->
<div class="login-container">
    <div class="login-card" id="loginCard">

        <div class="brand-logo">
            <div class="logo-icon">&#128230;</div>
        </div>

        <h2>SmartInv</h2>
        <p class="subtitle">Inventory Management System</p>

        <% if (error != null) { %>
            <div class="error-box">
                <span>&#9888;</span>
                <span><%= error %></span>
            </div>
        <% } %>

        <!-- ROLE TABS -->
        <div class="role-tabs">
            <button type="button" class="role-tab active" data-role="ADMIN" onclick="selectRole('ADMIN')">
                <span class="role-icon">&#128081;</span>
                Admin
            </button>
            <button type="button" class="role-tab" data-role="STAFF" onclick="selectRole('STAFF')">
                <span class="role-icon">&#128104;&#8205;&#128295;</span>
                Staff
            </button>
        </div>

        <form action="<%= ctx %>/login" method="post" onsubmit="return handleSubmit(event)" id="loginForm">

            <input type="hidden" name="role" id="roleField" value="ADMIN">

            <!-- USERNAME -->
            <div class="form-group">
                <label for="username" id="usernameLabel">Admin Username</label>
                <div class="input-wrap">
                    <input type="text" id="username" name="username"
                           placeholder="Enter your username"
                           autocomplete="username" required autofocus>
                    <span class="input-icon">&#128100;</span>
                </div>
            </div>

            <!-- PASSWORD (lock icon left + eye toggle right) -->
            <div class="form-group">
                <label for="password">Password</label>
                <div class="input-wrap">
                    <input type="password" id="password" name="password"
                           placeholder="Enter your password"
                           autocomplete="current-password" required>
                    <span class="input-icon">&#128274;</span>
                    <button type="button" class="toggle-pwd" id="togglePwd"
                            title="Show password" aria-label="Toggle password visibility">
                        &#128065;
                    </button>
                </div>
            </div>

            <button type="submit" class="btn-login" id="loginBtn">
                <span id="btnText">Login as Admin</span>
            </button>
        </form>

        <div class="info-box" id="infoBox">
            <strong>Admin Access</strong><br>
            Username: <code>admin</code> &nbsp;/&nbsp; Password: <code>admin123</code>
        </div>

        <p class="footer-note">&copy; 2026 SmartInv. All rights reserved.</p>
    </div>
</div>

<script>
    // ============================================================
    // THEME TOGGLE
    // ============================================================
    (function () {
        var themeBtn = document.getElementById('themeToggle');
        var themeIcon = document.getElementById('themeIcon');
        var body = document.body;

        // Load saved theme
        var saved = localStorage.getItem('smartinv-login-theme');

        if (saved === 'light') {
            body.classList.remove('dark');
            body.classList.add('light');
            themeIcon.innerHTML = '&#127769;'; // moon
        } else {
            // default = dark
            body.classList.remove('light');
            body.classList.add('dark');
            themeIcon.innerHTML = '&#9728;'; // sun
        }

        themeBtn.addEventListener('click', function () {
            if (body.classList.contains('dark')) {
                body.classList.remove('dark');
                body.classList.add('light');
                themeIcon.innerHTML = '&#127769;';
                localStorage.setItem('smartinv-login-theme', 'light');
            } else {
                body.classList.remove('light');
                body.classList.add('dark');
                themeIcon.innerHTML = '&#9728;';
                localStorage.setItem('smartinv-login-theme', 'dark');
            }
        });
    })();

    // ============================================================
    // ROLE STATE
    // ============================================================
    var currentRole = 'ADMIN';

    function selectRole(role) {
        currentRole = role;

        document.querySelectorAll('.role-tab').forEach(function (tab) {
            tab.classList.toggle('active', tab.getAttribute('data-role') === role);
        });

        document.getElementById('roleField').value = role;

        var label = document.getElementById('usernameLabel');
        var btnText = document.getElementById('btnText');
        var infoBox = document.getElementById('infoBox');
        var card = document.getElementById('loginCard');

        if (role === 'ADMIN') {
            label.textContent = 'Admin Username';
            btnText.textContent = 'Login as Admin';
            infoBox.innerHTML = '<strong>Admin Access</strong><br>' +
                'Username: <code>admin</code> &nbsp;/&nbsp; Password: <code>admin123</code>';
            card.style.setProperty('--accent', '#4361ee');
            card.style.setProperty('--accent-dark', '#3a0ca3');
        } else {
            label.textContent = 'Staff Username';
            btnText.textContent = 'Login as Staff';
            infoBox.innerHTML = '<strong>Staff Access</strong><br>' +
                'Username: <code>staff</code> &nbsp;/&nbsp; Password: <code>staff123</code>';
            card.style.setProperty('--accent', '#06d6a0');
            card.style.setProperty('--accent-dark', '#059669');
        }

        document.getElementById('password').value = '';
        document.getElementById('username').focus();
    }

    // ============================================================
    // SHOW / HIDE PASSWORD
    // ============================================================
    (function () {
        var toggle = document.getElementById('togglePwd');
        var pwd = document.getElementById('password');
        if (!toggle || !pwd) return;

        toggle.addEventListener('click', function () {
            var isText = pwd.type === 'text';
            pwd.type = isText ? 'password' : 'text';
            toggle.innerHTML = isText ? '&#128065;' : '&#128584;';
            toggle.title = isText ? 'Show password' : 'Hide password';
            pwd.focus();
        });
    })();

    // ============================================================
    // FORM SUBMIT
    // ============================================================
    function handleSubmit(e) {
        var u = document.getElementById('username').value.trim();
        var p = document.getElementById('password').value;

        if (u === '' || p === '') {
            alert('Please fill in both username and password.');
            e.preventDefault();
            return false;
        }

        if (currentRole === 'ADMIN' && u.toLowerCase() === 'staff') {
            alert('You selected Admin, but entered a staff username. Please select Staff instead.');
            e.preventDefault();
            return false;
        }
        if (currentRole === 'STAFF' && u.toLowerCase() === 'admin') {
            alert('You selected Staff, but entered an admin username. Please select Admin instead.');
            e.preventDefault();
            return false;
        }

        var btn = document.getElementById('loginBtn');
        var txt = document.getElementById('btnText');
        btn.disabled = true;
        txt.innerHTML = '<span class="spinner"></span>Signing in...';
        return true;
    }

    // ============================================================
    // FLOATING PARTICLES
    // ============================================================
    (function createParticles() {
        var container = document.querySelector('.bg-animation');
        if (!container) return;
        for (var i = 0; i < 35; i++) {
            var p = document.createElement('span');
            p.className = 'particle';
            var size = Math.random() * 3 + 1.5;
            p.style.width  = size + 'px';
            p.style.height = size + 'px';
            p.style.left   = (Math.random() * 100) + '%';
            p.style.bottom = '-10px';
            p.style.animationDuration = (Math.random() * 18 + 12) + 's';
            p.style.animationDelay   = (Math.random() * 12) + 's';
            container.appendChild(p);
        }
    })();

    // ============================================================
    // AUTOFOCUS
    // ============================================================
    window.addEventListener('load', function () {
        var u = document.getElementById('username');
        if (u) u.focus();
    });
</script>

</body>
</html>