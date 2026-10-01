<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.User, model.Product" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    List<Product> lowStockProducts = (List<Product>) request.getAttribute("lowStockProducts");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Low Stock Alerts | SmartInv</title>
<style>
    :root {
        --primary: #4361ee;
        --primary-dark: #3a0ca3;
        --primary-light: #eef1ff;
        --success: #06d6a0;
        --warning: #ffb703;
        --danger: #ef476f;
        --info: #4cc9f0;

        --bg-body: #f5f7fb;
        --bg-card: #ffffff;
        --bg-sidebar: linear-gradient(180deg, #1e3c72 0%, #2a5298 100%);

        --text-dark: #1a1f36;
        --text-mid: #4a5568;
        --text-light: #8898aa;

        --border: #e6ecf5;
        --shadow-sm: 0 2px 8px rgba(30,60,114,0.06);
        --shadow-lg: 0 15px 40px rgba(30,60,114,0.15);

        --radius: 14px;
        --radius-sm: 10px;
        --transition: 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    }

    body.dark {
        --bg-body: #0f1729;
        --bg-card: #1a2238;
        --text-dark: #f0f4f8;
        --text-mid: #a0aec0;
        --text-light: #718096;
        --border: #2d3748;
        --primary-light: #1a2540;
        --bg-sidebar: linear-gradient(180deg, #0a0f1e 0%, #162447 100%);
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
        font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif;
        background: var(--bg-body); color: var(--text-dark);
        min-height: 100vh; display: flex; transition: background 0.3s;
        overflow-x: hidden;
    }

    /* BACKGROUND */
    .bg-animation { position: fixed; inset: 0; overflow: hidden; z-index: 0; pointer-events: none; }
    .bg-animation::after {
        content: ''; position: absolute; inset: 0;
        background: radial-gradient(ellipse at center, transparent 35%, rgba(0,0,0,0.35) 100%);
    }
    .orb { position: absolute; border-radius: 50%; filter: blur(80px); opacity: 0.35; will-change: transform; }
    body.dark .orb { opacity: 0.45; }
    .orb-1 { width: 500px; height: 500px; background: radial-gradient(circle, #ef476f, transparent 70%); top: -150px; left: -100px; animation: f1 18s ease-in-out infinite; }
    .orb-2 { width: 420px; height: 420px; background: radial-gradient(circle, #ffb703, transparent 70%); bottom: -120px; right: -80px; animation: f2 22s ease-in-out infinite; }
    .orb-3 { width: 380px; height: 380px; background: radial-gradient(circle, #b5179e, transparent 70%); top: 45%; left: 42%; animation: f3 25s ease-in-out infinite; opacity: 0.22; }
    .orb-4 { width: 320px; height: 320px; background: radial-gradient(circle, #ff006e, transparent 70%); top: 10%; right: 12%; animation: f4 20s ease-in-out infinite; opacity: 0.22; }
    @keyframes f1 { 0%,100%{transform:translate(0,0);} 50%{transform:translate(80px,60px)scale(1.1);} }
    @keyframes f2 { 0%,100%{transform:translate(0,0);} 50%{transform:translate(-100px,-80px)scale(1.15);} }
    @keyframes f3 { 0%,100%{transform:translate(-50%,-50%);} 50%{transform:translate(-30%,-60%)scale(1.1);} }
    @keyframes f4 { 0%,100%{transform:translate(0,0);} 50%{transform:translate(-90px,90px)scale(1.1);} }

    .bg-grid {
        position: absolute; inset: 0;
        background-image:
            linear-gradient(rgba(239,71,111,0.04) 1px, transparent 1px),
            linear-gradient(90deg, rgba(239,71,111,0.04) 1px, transparent 1px);
        background-size: 45px 45px;
        animation: gm 30s linear infinite;
    }
    body.dark .bg-grid {
        background-image:
            linear-gradient(rgba(239,71,111,0.06) 1px, transparent 1px),
            linear-gradient(90deg, rgba(239,71,111,0.06) 1px, transparent 1px);
    }
    @keyframes gm { 0%{background-position:0 0;} 100%{background-position:45px 45px;} }

    .particle {
        position: absolute; background: rgba(239,71,111,0.5);
        border-radius: 50%; box-shadow: 0 0 6px rgba(255,183,3,0.6);
        animation: rise linear infinite;
    }
    body.dark .particle { background: rgba(255,183,3,0.6); }
    @keyframes rise {
        0% { transform: translateY(100vh) scale(.5); opacity: 0; }
        10%,90% { opacity: 1; }
        100% { transform: translateY(-100px) scale(1); opacity: 0; }
    }
    @media (prefers-reduced-motion: reduce) { .orb,.particle,.bg-grid { animation: none !important; } }

    /* SIDEBAR */
    .sidebar {
        width: 250px; background: var(--bg-sidebar); color: #fff;
        padding: 24px 16px; position: fixed; height: 100vh;
        overflow-y: auto; transition: transform 0.3s; z-index: 100;
        display: flex; flex-direction: column;
    }
    .sidebar::-webkit-scrollbar { width: 6px; }
    .sidebar::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.2); border-radius: 3px; }

    .brand {
        display: flex; align-items: center; gap: 10px;
        padding: 0 8px 24px; border-bottom: 1px solid rgba(255,255,255,0.1);
        margin-bottom: 20px;
    }
    .brand-icon {
        width: 38px; height: 38px;
        background: linear-gradient(135deg, #4cc9f0, #4361ee);
        border-radius: 10px; display: flex; align-items: center; justify-content: center;
        font-size: 20px; box-shadow: 0 4px 12px rgba(76,201,240,0.4);
    }
    .brand-text h2 { font-size: 18px; font-weight: 700; letter-spacing: 0.5px; }
    .brand-text p { font-size: 10px; color: #a0b4d6; text-transform: uppercase; letter-spacing: 1.5px; }
    .nav-section-title {
        font-size: 10px; color: #7b8db5; text-transform: uppercase;
        letter-spacing: 1.2px; padding: 12px 12px 8px; font-weight: 600;
    }
    .nav-item {
        display: flex; align-items: center; gap: 12px;
        padding: 11px 14px; color: #cdd8ee; text-decoration: none;
        border-radius: var(--radius-sm); font-size: 14px; font-weight: 500;
        margin-bottom: 3px; transition: var(--transition); position: relative;
    }
    .nav-item .icon { font-size: 17px; width: 20px; text-align: center; }
    .nav-item:hover { background: rgba(255,255,255,0.08); color: #fff; transform: translateX(4px); }
    .nav-item.active {
        background: linear-gradient(90deg, rgba(239,71,111,0.3), rgba(181,23,158,0.25));
        color: #fff; box-shadow: inset 3px 0 0 #ef476f;
    }
    .nav-item.active::after {
        content: ''; position: absolute; right: 14px;
        width: 6px; height: 6px; background: #ef476f;
        border-radius: 50%; box-shadow: 0 0 10px #ef476f;
    }
    .sidebar-footer {
        margin-top: auto; padding-top: 20px;
        border-top: 1px solid rgba(255,255,255,0.1);
        font-size: 11px; color: #7b8db5; text-align: center;
    }

    /* MAIN */
    .main {
        margin-left: 250px; flex: 1;
        padding: 24px 32px 40px;
        min-height: 100vh; width: calc(100% - 250px);
        position: relative; z-index: 1;
    }

    .topbar {
        background: var(--bg-card); padding: 16px 24px;
        border-radius: var(--radius); box-shadow: var(--shadow-sm);
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 24px; border: 1px solid var(--border);
    }
    .topbar-left h1 { font-size: 22px; color: var(--text-dark); font-weight: 700; }
    .topbar-left p { font-size: 13px; color: var(--text-light); margin-top: 2px; }
    .topbar-right { display: flex; align-items: center; gap: 14px; }

    .icon-btn {
        width: 40px; height: 40px; border-radius: 10px;
        background: var(--primary-light); border: 1px solid var(--border);
        color: var(--text-mid); cursor: pointer; font-size: 17px;
        display: flex; align-items: center; justify-content: center;
        transition: var(--transition);
    }
    .icon-btn:hover { background: var(--primary); color: #fff; transform: translateY(-2px); box-shadow: 0 6px 16px rgba(67,97,238,0.3); }

    .user-chip {
        display: flex; align-items: center; gap: 10px;
        padding: 6px 14px 6px 6px;
        background: var(--primary-light); border-radius: 40px;
        border: 1px solid var(--border);
    }
    .user-chip .avatar {
        width: 32px; height: 32px; border-radius: 50%;
        background: linear-gradient(135deg, #4361ee, #4cc9f0);
        color: #fff; display: flex; align-items: center; justify-content: center;
        font-weight: 700; font-size: 13px;
    }
    .user-chip .u-name { font-size: 13px; font-weight: 600; color: var(--text-dark); line-height: 1.2; }
    .user-chip .u-role { font-size: 10px; color: var(--text-light); text-transform: uppercase; letter-spacing: 0.5px; }

    /* ALERT BANNER */
    .alert-banner {
        background: linear-gradient(135deg, rgba(239,71,111,0.12), rgba(255,183,3,0.12));
        border: 1px solid rgba(239,71,111,0.3);
        border-left: 4px solid var(--danger);
        border-radius: var(--radius);
        padding: 16px 22px;
        margin-bottom: 22px;
        display: flex; align-items: center; gap: 14px;
    }
    .alert-banner.ok {
        background: linear-gradient(135deg, rgba(6,214,160,0.12), rgba(6,214,160,0.05));
        border-color: rgba(6,214,160,0.3);
        border-left-color: var(--success);
    }
    .alert-banner .ab-icon {
        width: 46px; height: 46px; border-radius: 12px;
        background: rgba(239,71,111,0.18); color: var(--danger);
        display: flex; align-items: center; justify-content: center;
        font-size: 22px; flex-shrink: 0;
    }
    .alert-banner.ok .ab-icon { background: rgba(6,214,160,0.18); color: var(--success); }
    .alert-banner .ab-text h3 {
        font-size: 15px; font-weight: 700; color: var(--text-dark);
        margin-bottom: 3px;
    }
    .alert-banner .ab-text p {
        font-size: 13px; color: var(--text-mid);
    }
    .alert-banner .ab-text p b { color: var(--danger); font-weight: 800; }
    .alert-banner.ok .ab-text p b { color: var(--success); }

    /* SUMMARY CARDS */
    .summary-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 16px; margin-bottom: 22px;
    }
    .summary-card {
        background: var(--bg-card); padding: 18px 20px;
        border-radius: var(--radius); border: 1px solid var(--border);
        box-shadow: var(--shadow-sm);
        display: flex; align-items: center; gap: 14px;
        transition: var(--transition);
    }
    .summary-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-lg); }
    .summary-card .s-icon {
        width: 46px; height: 46px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        font-size: 20px; flex-shrink: 0;
    }
    .summary-card .s-icon.red { background: rgba(239,71,111,0.15); color: #ef476f; }
    .summary-card .s-icon.amber { background: rgba(255,183,3,0.15); color: #d68910; }
    body.dark .summary-card .s-icon.amber { color: #ffb703; }
    .summary-card .s-icon.green { background: rgba(6,214,160,0.15); color: #06d6a0; }
    .summary-card .s-icon.blue { background: rgba(67,97,238,0.12); color: #4361ee; }

    .summary-card .s-info h4 {
        font-size: 11px; color: var(--text-light);
        text-transform: uppercase; letter-spacing: 0.6px;
        margin-bottom: 4px; font-weight: 600;
    }
    .summary-card .s-info .s-val {
        font-size: 22px; font-weight: 800; color: var(--text-dark);
        letter-spacing: -0.5px;
    }

    /* ACTION BAR */
    .action-bar {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 20px; gap: 12px; flex-wrap: wrap;
    }
    .search-box { position: relative; flex: 1; max-width: 340px; }
    .search-box input {
        width: 100%; padding: 11px 16px 11px 42px;
        border: 1px solid var(--border); border-radius: var(--radius-sm);
        background: var(--bg-card); color: var(--text-dark);
        font-size: 14px; transition: var(--transition);
        font-family: inherit;
    }
    .search-box input:focus {
        outline: none; border-color: var(--primary);
        box-shadow: 0 0 0 4px rgba(67,97,238,0.1);
    }
    .search-box::before {
        content: '\1F50D'; position: absolute;
        left: 14px; top: 50%; transform: translateY(-50%);
        font-size: 14px; color: var(--text-light);
    }

    .filter-tabs {
        display: flex; gap: 8px; background: var(--bg-card);
        padding: 5px; border-radius: var(--radius-sm);
        border: 1px solid var(--border);
    }
    .filter-tab {
        padding: 7px 14px; border-radius: 8px;
        font-size: 12.5px; font-weight: 600;
        cursor: pointer; border: none;
        background: transparent; color: var(--text-light);
        transition: var(--transition); font-family: inherit;
    }
    .filter-tab:hover { color: var(--text-dark); }
    .filter-tab.active {
        background: linear-gradient(135deg, #ef476f, #b5179e);
        color: #fff; box-shadow: 0 3px 10px rgba(239,71,111,0.3);
    }

    /* ALERT CARDS GRID */
    .alerts-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
        gap: 16px;
    }
    @media (max-width: 480px) { .alerts-grid { grid-template-columns: 1fr; } }

    .alert-card {
        background: var(--bg-card);
        border-radius: var(--radius);
        border: 1px solid var(--border);
        border-left: 4px solid var(--warning);
        padding: 20px;
        box-shadow: var(--shadow-sm);
        transition: var(--transition);
        position: relative;
        overflow: hidden;
    }
    .alert-card:hover { transform: translateY(-4px); box-shadow: var(--shadow-lg); }
    .alert-card.danger {
        border-left-color: var(--danger);
        background: linear-gradient(135deg, rgba(239,71,111,0.04), transparent 60%);
    }
    .alert-card.warning {
        border-left-color: var(--warning);
        background: linear-gradient(135deg, rgba(255,183,3,0.04), transparent 60%);
    }

    .ac-header {
        display: flex; justify-content: space-between; align-items: flex-start;
        margin-bottom: 14px; gap: 12px;
    }
    .ac-title-block { flex: 1; min-width: 0; }
    .ac-title {
        font-size: 15px; font-weight: 700; color: var(--text-dark);
        margin-bottom: 4px;
        overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
    }
    .ac-sub {
        font-size: 11.5px; color: var(--text-light);
        display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
    }
    .ac-cat-badge {
        display: inline-block; padding: 2px 8px;
        border-radius: 10px; font-size: 10.5px;
        font-weight: 600;
        background: var(--primary-light); color: var(--primary);
    }
    .ac-severity-badge {
        display: inline-flex; align-items: center; gap: 4px;
        padding: 5px 11px; border-radius: 20px;
        font-size: 11px; font-weight: 700;
        letter-spacing: 0.3px;
        white-space: nowrap;
    }
    .ac-severity-badge.out { background: rgba(239,71,111,0.15); color: #ef476f; }
    .ac-severity-badge.low { background: rgba(255,183,3,0.15); color: #d68910; }
    body.dark .ac-severity-badge.low { color: #ffb703; }

    .ac-bar-wrap { margin: 14px 0 12px; }
    .ac-bar-labels {
        display: flex; justify-content: space-between;
        font-size: 11px; color: var(--text-light);
        margin-bottom: 6px; font-weight: 600;
    }
    .ac-bar {
        height: 8px; border-radius: 4px;
        background: rgba(136,152,170,0.15);
        overflow: hidden; position: relative;
    }
    .ac-bar-fill {
        height: 100%; border-radius: 4px;
        transition: width 0.6s ease;
    }
    .ac-bar-fill.out { background: linear-gradient(90deg, #ef476f, #b5179e); }
    .ac-bar-fill.low { background: linear-gradient(90deg, #ffb703, #f39c12); }

    .ac-numbers {
        display: grid; grid-template-columns: 1fr 1fr;
        gap: 10px; margin-bottom: 14px;
    }
    .ac-num-box {
        background: var(--primary-light);
        border-radius: 10px; padding: 10px 14px;
    }
    body.dark .ac-num-box { background: rgba(76,201,240,0.06); }
    .ac-num-label {
        font-size: 10.5px; color: var(--text-light);
        text-transform: uppercase; letter-spacing: 0.5px;
        font-weight: 600; margin-bottom: 3px;
    }
    .ac-num-value {
        font-size: 18px; font-weight: 800; color: var(--text-dark);
        letter-spacing: -0.5px;
    }
    .ac-num-value.red { color: #ef476f; }
    .ac-num-value.amber { color: #d68910; }
    body.dark .ac-num-value.amber { color: #ffb703; }

    .ac-actions { display: flex; gap: 8px; }
    .btn-restock {
        flex: 1;
        padding: 10px 14px;
        border-radius: 10px;
        border: none;
        font-size: 13px;
        font-weight: 700;
        cursor: pointer;
        text-decoration: none;
        text-align: center;
        transition: var(--transition);
        display: inline-flex; align-items: center; justify-content: center;
        gap: 6px;
        background: linear-gradient(135deg, #06d6a0, #059669);
        color: #fff;
        box-shadow: 0 4px 14px rgba(6,214,160,0.3);
        font-family: inherit;
    }
    .btn-restock:hover { transform: translateY(-2px); box-shadow: 0 8px 22px rgba(6,214,160,0.45); }
    .btn-restock.danger {
        background: linear-gradient(135deg, #ef476f, #b5179e);
        box-shadow: 0 4px 14px rgba(239,71,111,0.35);
    }
    .btn-restock.danger:hover { box-shadow: 0 8px 22px rgba(239,71,111,0.5); }

    .empty-panel {
        background: var(--bg-card);
        border-radius: var(--radius);
        border: 1px solid var(--border);
        box-shadow: var(--shadow-sm);
        padding: 70px 30px;
        text-align: center;
    }
    .empty-panel .em-icon {
        font-size: 64px; margin-bottom: 16px;
        display: inline-block;
        animation: bounce 2s ease-in-out infinite;
    }
    @keyframes bounce {
        0%, 100% { transform: translateY(0); }
        50%      { transform: translateY(-10px); }
    }
    .empty-panel h3 { font-size: 18px; color: var(--text-dark); margin-bottom: 8px; }
    .empty-panel p { font-size: 13.5px; color: var(--text-light); max-width: 460px; margin: 0 auto; }

    /* PRINT */
    @media print {
        .sidebar, .topbar-right, .action-bar, .bg-animation, .menu-toggle,
        .icon-btn, .user-chip, .ac-actions { display: none !important; }
        .main { margin-left: 0; width: 100%; padding: 0; }
        body { background: #fff !important; color: #000 !important; }
        .alert-card, .summary-card, .alert-banner, .topbar {
            box-shadow: none; border: 1px solid #ccc;
            page-break-inside: avoid;
        }
    }

    /* MOBILE */
    .menu-toggle {
        display: none; position: fixed; bottom: 20px; right: 20px;
        width: 52px; height: 52px; border-radius: 50%;
        background: linear-gradient(135deg, #4361ee, #3a0ca3);
        color: #fff; border: none; font-size: 22px;
        cursor: pointer; box-shadow: 0 8px 24px rgba(67,97,238,0.4);
        z-index: 200;
    }
    @media (max-width: 768px) {
        .sidebar { transform: translateX(-100%); }
        .sidebar.open { transform: translateX(0); }
        .main { margin-left: 0; width: 100%; padding: 20px 16px 80px; }
        .menu-toggle { display: flex; align-items: center; justify-content: center; }
        .topbar { padding: 14px 16px; flex-wrap: wrap; gap: 10px; }
        .topbar-left h1 { font-size: 18px; }
        .user-chip .u-name, .user-chip .u-role { display: none; }
        .action-bar { flex-direction: column; align-items: stretch; }
        .search-box { max-width: 100%; }
    }
</style>
</head>
<body>

<div class="bg-animation" aria-hidden="true">
    <div class="bg-grid"></div>
    <div class="orb orb-1"></div>
    <div class="orb orb-2"></div>
    <div class="orb orb-3"></div>
    <div class="orb orb-4"></div>
</div>

<aside class="sidebar" id="sidebar">
    <div class="brand">
        <div class="brand-icon">&#128230;</div>
        <div class="brand-text">
            <h2>SmartInv</h2>
            <p>Inventory System</p>
        </div>
    </div>
    <div class="nav-section-title">Main</div>
    <a href="<%= ctx %>/dashboard" class="nav-item"><span class="icon">&#127968;</span> Dashboard</a>
    <a href="<%= ctx %>/product?action=list" class="nav-item"><span class="icon">&#128230;</span> Products</a>
    <a href="<%= ctx %>/inventory?action=list" class="nav-item"><span class="icon">&#128260;</span> Inventory</a>
    <div class="nav-section-title">Operations</div>
    <a href="<%= ctx %>/inventory?action=stockInPage" class="nav-item"><span class="icon">&#10133;</span> Stock In</a>
    <a href="<%= ctx %>/inventory?action=stockOutPage" class="nav-item"><span class="icon">&#10134;</span> Stock Out</a>
    <div class="nav-section-title">Reports</div>
    <a href="<%= ctx %>/report?action=stockReport" class="nav-item"><span class="icon">&#128202;</span> Stock Report</a>
    <a href="<%= ctx %>/report?action=lowStock" class="nav-item active"><span class="icon">&#9888;</span> Low Stock Alerts</a>
    <div class="nav-section-title">Account</div>
    <a href="<%= ctx %>/logout" class="nav-item"><span class="icon">&#128682;</span> Logout</a>
    <div class="sidebar-footer">&copy; 2026 SmartInv<br>v1.0</div>
</aside>

<main class="main">
    <div class="topbar">
        <div class="topbar-left">
            <h1>Low Stock Alerts</h1>
            <p>Products that need immediate restocking</p>
        </div>
        <div class="topbar-right">
            <button class="icon-btn" id="themeToggle" title="Toggle theme">&#127769;</button>
            <button class="icon-btn" onclick="window.print()" title="Print alerts">&#128424;</button>
            <div class="user-chip">
                <div class="avatar"><%= loggedUser.getFullName().substring(0,1).toUpperCase() %></div>
                <div>
                    <div class="u-name"><%= loggedUser.getFullName() %></div>
                    <div class="u-role"><%= loggedUser.getRole() %></div>
                </div>
            </div>
        </div>
    </div>

<%
    int totalAlerts = (lowStockProducts != null) ? lowStockProducts.size() : 0;
    int outCount = 0;
    int lowCount = 0;
    if (lowStockProducts != null) {
        for (Product p : lowStockProducts) {
            if (p.getQuantity() == 0) outCount++;
            else lowCount++;
        }
    }
    int totalProducts = 1000;
    int healthyCount = Math.max(0, totalProducts - totalAlerts);
    double safePct = totalProducts > 0 ? (healthyCount * 100.0 / totalProducts) : 100.0;
%>

    <% if (totalAlerts > 0) { %>
        <div class="alert-banner">
            <div class="ab-icon">&#9888;</div>
            <div class="ab-text">
                <h3>Attention Required</h3>
                <p>
                    <b><%= totalAlerts %></b> product<%= totalAlerts != 1 ? "s" : "" %> at or below reorder level —
                    <b><%= outCount %></b> out of stock, <b><%= lowCount %></b> running low.
                </p>
            </div>
        </div>
    <% } else { %>
        <div class="alert-banner ok">
            <div class="ab-icon">&#9989;</div>
            <div class="ab-text">
                <h3>All Clear</h3>
                <p>Every product is <b>sufficiently stocked</b>. No restocking needed right now.</p>
            </div>
        </div>
    <% } %>

    <div class="summary-grid">
        <div class="summary-card">
            <div class="s-icon red">&#128683;</div>
            <div class="s-info">
                <h4>Out of Stock</h4>
                <div class="s-val"><%= outCount %></div>
            </div>
        </div>
        <div class="summary-card">
            <div class="s-icon amber">&#9888;</div>
            <div class="s-info">
                <h4>Low Stock</h4>
                <div class="s-val"><%= lowCount %></div>
            </div>
        </div>
        <div class="summary-card">
            <div class="s-icon green">&#9989;</div>
            <div class="s-info">
                <h4>Healthy Products</h4>
                <div class="s-val"><%= healthyCount %></div>
            </div>
        </div>
        <div class="summary-card">
            <div class="s-icon blue">&#128202;</div>
            <div class="s-info">
                <h4>Stock Health</h4>
                <div class="s-val"><%= String.format("%.0f%%", safePct) %></div>
            </div>
        </div>
    </div>

    <div class="action-bar">
        <div class="search-box">
            <input type="text" id="searchInput" placeholder="Search alerts by product or category..."
                   onkeyup="filterCards()">
        </div>
        <div class="filter-tabs">
            <button class="filter-tab active" data-filter="all" onclick="setFilter(this, 'all')">All</button>
            <button class="filter-tab" data-filter="out" onclick="setFilter(this, 'out')">Out of Stock</button>
            <button class="filter-tab" data-filter="low" onclick="setFilter(this, 'low')">Low Stock</button>
        </div>
    </div>

    <div class="alerts-grid" id="alertsGrid">
    <%
        if (lowStockProducts != null && !lowStockProducts.isEmpty()) {
            for (Product p : lowStockProducts) {
                boolean isOut = (p.getQuantity() == 0);
                int qty = p.getQuantity();
                int reorder = p.getReorderLevel();
                int pct = reorder > 0 ? Math.min(100, (int)(qty * 100.0 / reorder)) : 0;
    %>
        <div class="alert-card <%= isOut ? "danger" : "warning" %>"
             data-type="<%= isOut ? "out" : "low" %>">
            <div class="ac-header">
                <div class="ac-title-block">
                    <div class="ac-title"><%= p.getProductName() %></div>
                    <div class="ac-sub">
                        <span class="ac-cat-badge">
                            <%= p.getCategoryName() != null ? p.getCategoryName() : "Uncategorized" %>
                        </span>
                        <span>ID: #<%= p.getProductId() %></span>
                    </div>
                </div>
                <span class="ac-severity-badge <%= isOut ? "out" : "low" %>">
                    <%= isOut ? "&#128683; OUT" : "&#9888; LOW" %>
                </span>
            </div>

            <div class="ac-bar-wrap">
                <div class="ac-bar-labels">
                    <span>Stock Level</span>
                    <span><%= qty %> / <%= reorder %></span>
                </div>
                <div class="ac-bar">
                    <div class="ac-bar-fill <%= isOut ? "out" : "low" %>" style="width: <%= pct %>%;"></div>
                </div>
            </div>

            <div class="ac-numbers">
                <div class="ac-num-box">
                    <div class="ac-num-label">Current Stock</div>
                    <div class="ac-num-value <%= isOut ? "red" : "amber" %>"><%= qty %></div>
                </div>
                <div class="ac-num-box">
                    <div class="ac-num-label">Reorder Level</div>
                    <div class="ac-num-value"><%= reorder %></div>
                </div>
            </div>

            <div class="ac-actions">
                <a href="<%= ctx %>/inventory?action=stockInPage"
                   class="btn-restock <%= isOut ? "danger" : "" %>">
                    <%= isOut ? "&#128229; Restock Now" : "&#10133; Add Stock" %>
                </a>
            </div>
        </div>
    <%
            }
        }
    %>
    </div>

    <% if (lowStockProducts == null || lowStockProducts.isEmpty()) { %>
        <div class="empty-panel">
            <div class="em-icon">&#127881;</div>
            <h3>No Alerts!</h3>
            <p>All products are well-stocked. You'll see alerts here when any item reaches its reorder level.</p>
        </div>
    <% } %>

</main>

<button class="menu-toggle" id="menuToggle" title="Menu">&#9776;</button>

<script>
    // THEME
    var themeBtn = document.getElementById('themeToggle');
    var body = document.body;
    if (localStorage.getItem('smartinv-theme') === 'dark') {
        body.classList.add('dark');
        themeBtn.innerHTML = '&#9728;';
    }
    themeBtn.addEventListener('click', function () {
        body.classList.toggle('dark');
        var isDark = body.classList.contains('dark');
        themeBtn.innerHTML = isDark ? '&#9728;' : '&#127769;';
        localStorage.setItem('smartinv-theme', isDark ? 'dark' : 'light');
    });

    // MOBILE MENU
    var menuBtn = document.getElementById('menuToggle');
    var sidebar = document.getElementById('sidebar');
    menuBtn.addEventListener('click', function (e) {
        e.stopPropagation();
        sidebar.classList.toggle('open');
    });
    document.addEventListener('click', function (e) {
        if (window.innerWidth <= 768 && sidebar.classList.contains('open')
                && !sidebar.contains(e.target) && e.target !== menuBtn) {
            sidebar.classList.remove('open');
        }
    });

    // FILTER + SEARCH
    var currentFilter = 'all';
    function setFilter(btn, filter) {
        document.querySelectorAll('.filter-tab').forEach(function (t) { t.classList.remove('active'); });
        btn.classList.add('active');
        currentFilter = filter;
        applyFilters();
    }
    function filterCards() { applyFilters(); }
    function applyFilters() {
        var input = document.getElementById('searchInput').value.toLowerCase();
        var cards = document.querySelectorAll('#alertsGrid .alert-card');
        cards.forEach(function (card) {
            var text = card.innerText.toLowerCase();
            var type = card.getAttribute('data-type');
            var matchSearch = text.indexOf(input) > -1;
            var matchType = (currentFilter === 'all') || (type === currentFilter);
            card.style.display = (matchSearch && matchType) ? '' : 'none';
        });
    }

    // PARTICLES
    (function () {
        var c = document.querySelector('.bg-animation');
        if (!c) return;
        for (var i = 0; i < 25; i++) {
            var p = document.createElement('span');
            p.className = 'particle';
            var size = Math.random() * 3 + 1.5;
            p.style.width = size + 'px';
            p.style.height = size + 'px';
            p.style.left = (Math.random() * 100) + '%';
            p.style.bottom = '-10px';
            p.style.animationDuration = (Math.random() * 15 + 10) + 's';
            p.style.animationDelay = (Math.random() * 10) + 's';
            c.appendChild(p);
        }
    })();
</script>

</body>
</html>