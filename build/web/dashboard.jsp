<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.User, model.Product, model.Stock" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard | SmartInv</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
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
        --shadow-md: 0 6px 20px rgba(30,60,114,0.10);
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
        background: var(--bg-body);
        color: var(--text-dark);
        min-height: 100vh;
        display: flex;
        transition: background 0.3s;
        overflow-x: hidden;
    }

    /* ============ ANIMATED BACKGROUND ============ */
    .bg-animation { position: fixed; inset: 0; overflow: hidden; z-index: 0; pointer-events: none; }
    .bg-animation::after {
        content: ''; position: absolute; inset: 0;
        background: radial-gradient(ellipse at center, transparent 35%, rgba(0,0,0,0.3) 100%);
    }
    .orb { position: absolute; border-radius: 50%; filter: blur(80px); opacity: 0.35; will-change: transform; }
    body.dark .orb { opacity: 0.45; }
    .orb-1 { width: 500px; height: 500px; background: radial-gradient(circle, #4361ee, transparent 70%); top: -150px; left: -100px; animation: f1 18s ease-in-out infinite; }
    .orb-2 { width: 420px; height: 420px; background: radial-gradient(circle, #4cc9f0, transparent 70%); bottom: -120px; right: -80px; animation: f2 22s ease-in-out infinite; }
    .orb-3 { width: 380px; height: 380px; background: radial-gradient(circle, #b5179e, transparent 70%); top: 45%; left: 42%; animation: f3 25s ease-in-out infinite; opacity: 0.22; }
    .orb-4 { width: 320px; height: 320px; background: radial-gradient(circle, #06d6a0, transparent 70%); top: 10%; right: 12%; animation: f4 20s ease-in-out infinite; opacity: 0.25; }
    @keyframes f1 { 0%,100%{transform:translate(0,0);} 50%{transform:translate(80px,60px)scale(1.1);} }
    @keyframes f2 { 0%,100%{transform:translate(0,0);} 50%{transform:translate(-100px,-80px)scale(1.15);} }
    @keyframes f3 { 0%,100%{transform:translate(-50%,-50%);} 50%{transform:translate(-30%,-60%)scale(1.1);} }
    @keyframes f4 { 0%,100%{transform:translate(0,0);} 50%{transform:translate(-90px,90px)scale(1.1);} }

    .bg-grid {
        position: absolute; inset: 0;
        background-image:
            linear-gradient(rgba(67,97,238,0.04) 1px, transparent 1px),
            linear-gradient(90deg, rgba(67,97,238,0.04) 1px, transparent 1px);
        background-size: 45px 45px;
        animation: gm 30s linear infinite;
    }
    body.dark .bg-grid {
        background-image:
            linear-gradient(rgba(76,201,240,0.05) 1px, transparent 1px),
            linear-gradient(90deg, rgba(76,201,240,0.05) 1px, transparent 1px);
    }
    @keyframes gm { 0%{background-position:0 0;} 100%{background-position:45px 45px;} }

    .particle {
        position: absolute; background: rgba(67,97,238,0.4);
        border-radius: 50%; box-shadow: 0 0 6px rgba(76,201,240,0.6);
        animation: rise linear infinite;
    }
    body.dark .particle { background: rgba(255,255,255,0.7); }
    @keyframes rise {
        0% { transform: translateY(100vh) scale(.5); opacity: 0; }
        10%,90% { opacity: 1; }
        100% { transform: translateY(-100px) scale(1); opacity: 0; }
    }
    @media (prefers-reduced-motion: reduce) { .orb,.particle,.bg-grid { animation: none !important; } }

    /* ============ SIDEBAR ============ */
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
        background: linear-gradient(90deg, rgba(76,201,240,0.25), rgba(67,97,238,0.25));
        color: #fff; box-shadow: inset 3px 0 0 #4cc9f0;
    }
    .nav-item.active::after {
        content: ''; position: absolute; right: 14px;
        width: 6px; height: 6px; background: #4cc9f0;
        border-radius: 50%; box-shadow: 0 0 10px #4cc9f0;
    }
    .sidebar-footer {
        margin-top: auto; padding-top: 20px;
        border-top: 1px solid rgba(255,255,255,0.1);
        font-size: 11px; color: #7b8db5; text-align: center;
    }

    /* ============ MAIN ============ */
    .main {
        margin-left: 250px; flex: 1;
        padding: 24px 32px 40px;
        min-height: 100vh; width: calc(100% - 250px);
        position: relative; z-index: 1;
    }

    /* ============ TOPBAR ============ */
    .topbar {
        background: var(--bg-card); padding: 16px 24px;
        border-radius: var(--radius); box-shadow: var(--shadow-sm);
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 24px; border: 1px solid var(--border);
    }
    .topbar-left h1 { font-size: 22px; color: var(--text-dark); font-weight: 700; letter-spacing: -0.3px; }
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
        border: 1px solid var(--border); transition: var(--transition);
    }
    .user-chip:hover { box-shadow: var(--shadow-md); transform: translateY(-1px); }
    .user-chip .avatar {
        width: 32px; height: 32px; border-radius: 50%;
        background: linear-gradient(135deg, #4361ee, #4cc9f0);
        color: #fff; display: flex; align-items: center; justify-content: center;
        font-weight: 700; font-size: 13px;
    }
    .user-chip .u-name { font-size: 13px; font-weight: 600; color: var(--text-dark); line-height: 1.2; }
    .user-chip .u-role { font-size: 10px; color: var(--text-light); text-transform: uppercase; letter-spacing: 0.5px; }

    /* ============ STATS ============ */
    .stats-grid {
        display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 20px; margin-bottom: 28px;
    }
    .stat-card {
        background: var(--bg-card); padding: 22px;
        border-radius: var(--radius); box-shadow: var(--shadow-sm);
        border: 1px solid var(--border);
        position: relative; overflow: hidden;
        transition: var(--transition); cursor: pointer;
    }
    .stat-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-lg); }
    .stat-card::before {
        content: ''; position: absolute;
        top: 0; left: 0; width: 4px; height: 100%;
        background: var(--accent, var(--primary));
    }
    .stat-card .stat-icon {
        width: 46px; height: 46px; border-radius: 12px;
        display: flex; align-items: center; justify-content: center;
        font-size: 22px; margin-bottom: 14px;
        background: var(--accent-bg, rgba(67,97,238,0.1));
        color: var(--accent, var(--primary));
    }
    .stat-card h3 {
        font-size: 12px; color: var(--text-light);
        text-transform: uppercase; letter-spacing: 0.8px;
        margin-bottom: 6px; font-weight: 600;
    }
    .stat-card .value {
        font-size: 32px; font-weight: 800; color: var(--text-dark);
        line-height: 1; letter-spacing: -1px;
    }
    .stat-card .trend {
        font-size: 12px; color: var(--text-light);
        margin-top: 8px; display: flex; align-items: center; gap: 4px;
    }
    .stat-card.primary { --accent: #4361ee; --accent-bg: rgba(67,97,238,0.1); }
    .stat-card.success { --accent: #06d6a0; --accent-bg: rgba(6,214,160,0.1); }
    .stat-card.warning { --accent: #ffb703; --accent-bg: rgba(255,183,3,0.12); }
    .stat-card.danger  { --accent: #ef476f; --accent-bg: rgba(239,71,111,0.1); }

    /* ============ SECTION ============ */
    .section-head {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 16px;
    }
    .section-title {
        font-size: 17px; font-weight: 700; color: var(--text-dark);
        display: flex; align-items: center; gap: 8px;
    }
    .section-title .bar {
        width: 4px; height: 18px;
        background: linear-gradient(180deg, #4cc9f0, #4361ee);
        border-radius: 2px;
    }
    .section-link {
        font-size: 13px; color: var(--primary);
        text-decoration: none; font-weight: 600;
        transition: var(--transition);
    }
    .section-link:hover { color: var(--primary-dark); }

    /* ============ ACTIONS ============ */
    .actions-grid {
        display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
        gap: 16px; margin-bottom: 28px;
    }
    .action-tile {
        background: var(--bg-card); padding: 22px 16px;
        border-radius: var(--radius); border: 1px solid var(--border);
        text-decoration: none; text-align: center;
        transition: var(--transition);
        display: flex; flex-direction: column; align-items: center;
        gap: 10px; cursor: pointer; box-shadow: var(--shadow-sm);
    }
    .action-tile:hover {
        transform: translateY(-5px); box-shadow: var(--shadow-lg);
        border-color: var(--primary);
    }
    .action-tile .a-icon {
        width: 50px; height: 50px; border-radius: 14px;
        display: flex; align-items: center; justify-content: center;
        font-size: 22px; background: var(--primary-light);
        transition: var(--transition);
    }
    .action-tile:hover .a-icon {
        background: linear-gradient(135deg, #4361ee, #4cc9f0);
        color: #fff; transform: rotate(-6deg) scale(1.05);
    }
    .action-tile .a-label { font-size: 13px; font-weight: 600; color: var(--text-dark); }

    /* ============ CHART PANELS ============ */
    .charts-grid {
        display: grid;
        grid-template-columns: 1.2fr 1fr;
        gap: 20px;
        margin-bottom: 20px;
    }
    @media (max-width: 992px) { .charts-grid { grid-template-columns: 1fr; } }

    .chart-panel {
        background: var(--bg-card);
        border-radius: var(--radius);
        border: 1px solid var(--border);
        box-shadow: var(--shadow-sm);
        overflow: hidden;
        padding: 22px;
    }
    .chart-panel-head {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 18px;
    }
    .chart-panel-head h3 {
        font-size: 15px; font-weight: 700; color: var(--text-dark);
        display: flex; align-items: center; gap: 8px;
    }
    .chart-panel-head .badge {
        font-size: 11px; font-weight: 700;
        padding: 4px 10px; border-radius: 20px;
        background: var(--primary-light); color: var(--primary);
        text-transform: uppercase; letter-spacing: 0.5px;
    }
    .chart-panel-head .badge.green { background: rgba(6,214,160,0.15); color: #06d6a0; }
    .chart-panel-head .badge.purple { background: rgba(181,23,158,0.15); color: #b5179e; }

    .chart-wrap {
        position: relative;
        height: 300px;
        width: 100%;
    }

    /* ============ DOUGHNUT LAYOUT ============ */
    .donut-panel {
        background: var(--bg-card);
        border-radius: var(--radius);
        border: 1px solid var(--border);
        box-shadow: var(--shadow-sm);
        padding: 22px;
    }
    .donut-layout {
        display: grid;
        grid-template-columns: 300px 1fr;
        gap: 40px;
        align-items: center;
        padding: 10px 0;
    }
    @media (max-width: 992px) {
        .donut-layout { grid-template-columns: 1fr; gap: 24px; }
    }

    .donut-canvas-wrap {
        position: relative;
        height: 300px;
        width: 300px;
        margin: 0 auto;
    }
    @media (max-width: 400px) {
        .donut-canvas-wrap { width: 260px; height: 260px; }
    }

    .donut-legend {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px 24px;
        max-height: 320px;
        overflow-y: auto;
        padding-right: 8px;
    }
    @media (max-width: 992px) {
        .donut-legend { grid-template-columns: 1fr 1fr; }
    }
    @media (max-width: 480px) {
        .donut-legend { grid-template-columns: 1fr; }
    }

    .donut-legend::-webkit-scrollbar { width: 6px; }
    .donut-legend::-webkit-scrollbar-thumb {
        background: var(--border); border-radius: 3px;
    }

    .legend-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 8px 10px;
        border-radius: 8px;
        font-size: 13px;
        font-weight: 500;
        color: var(--text-dark);
        transition: background 0.2s;
    }
    .legend-item:hover {
        background: var(--primary-light);
    }

    .legend-dot {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        flex-shrink: 0;
        box-shadow: 0 0 0 3px rgba(67,97,238,0.08);
    }

    .legend-label {
        flex: 1;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .legend-value {
        font-weight: 700;
        color: var(--text-mid);
        font-variant-numeric: tabular-nums;
        font-size: 12px;
        white-space: nowrap;
    }

    /* ============ PANELS (Recent / Alerts) ============ */
    .panels-grid { display: grid; grid-template-columns: 1.5fr 1fr; gap: 20px; }
    @media (max-width: 992px) { .panels-grid { grid-template-columns: 1fr; } }

    .panel {
        background: var(--bg-card);
        border-radius: var(--radius); border: 1px solid var(--border);
        box-shadow: var(--shadow-sm); overflow: hidden;
    }
    .panel-head {
        padding: 18px 22px; border-bottom: 1px solid var(--border);
        display: flex; justify-content: space-between; align-items: center;
    }
    .panel-head h3 { font-size: 15px; font-weight: 700; color: var(--text-dark); }
    .panel-body { padding: 8px 0; max-height: 340px; overflow-y: auto; }

    .activity-item {
        display: flex; align-items: center; gap: 14px;
        padding: 12px 22px; transition: var(--transition);
        border-left: 3px solid transparent;
    }
    .activity-item:hover { background: var(--primary-light); border-left-color: var(--primary); }
    .activity-item .a-dot {
        width: 38px; height: 38px; border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        font-size: 16px; flex-shrink: 0;
    }
    .activity-item.in  .a-dot { background: rgba(6,214,160,0.12); color: #06d6a0; }
    .activity-item.out .a-dot { background: rgba(239,71,111,0.12); color: #ef476f; }
    .activity-item .a-info { flex: 1; min-width: 0; }
    .activity-item .a-title {
        font-size: 13.5px; font-weight: 600; color: var(--text-dark);
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .activity-item .a-meta { font-size: 11.5px; color: var(--text-light); margin-top: 2px; }
    .activity-item .a-qty { font-size: 13px; font-weight: 700; padding: 4px 10px; border-radius: 8px; }
    .activity-item.in  .a-qty { background: rgba(6,214,160,0.12); color: #06d6a0; }
    .activity-item.out .a-qty { background: rgba(239,71,111,0.12); color: #ef476f; }

    .alert-item {
        display: flex; align-items: center; gap: 12px;
        padding: 14px 22px; border-bottom: 1px solid var(--border);
    }
    .alert-item:last-child { border-bottom: none; }
    .alert-item .warn-icon {
        width: 34px; height: 34px; border-radius: 10px;
        background: rgba(255,183,3,0.15); color: #ffb703;
        display: flex; align-items: center; justify-content: center;
        font-size: 16px; flex-shrink: 0;
    }
    .alert-item.danger .warn-icon { background: rgba(239,71,111,0.15); color: #ef476f; }
    .alert-item .alert-info { flex: 1; min-width: 0; }
    .alert-item .alert-title {
        font-size: 13px; font-weight: 600; color: var(--text-dark);
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .alert-item .alert-sub { font-size: 11.5px; color: var(--text-light); margin-top: 2px; }

    .empty-state { text-align: center; padding: 30px 20px; color: var(--text-light); font-size: 13px; }
    .empty-state .em-icon { font-size: 32px; margin-bottom: 8px; display: block; opacity: 0.5; }

    /* ============ MOBILE ============ */
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
        .topbar { padding: 14px 16px; }
        .topbar-left h1 { font-size: 18px; }
        .user-chip .u-name, .user-chip .u-role { display: none; }
        .chart-wrap { height: 240px; }
    }

    @keyframes fadeUp {
        from { opacity: 0; transform: translateY(16px); }
        to   { opacity: 1; transform: translateY(0); }
    }
    .stat-card, .action-tile, .chart-panel, .donut-panel { animation: fadeUp 0.5s ease both; }
    .stat-card:nth-child(1) { animation-delay: 0.05s; }
    .stat-card:nth-child(2) { animation-delay: 0.10s; }
    .stat-card:nth-child(3) { animation-delay: 0.15s; }
    .stat-card:nth-child(4) { animation-delay: 0.20s; }
</style>
</head>
<body>

<!-- ANIMATED BACKGROUND -->
<div class="bg-animation" aria-hidden="true">
    <div class="bg-grid"></div>
    <div class="orb orb-1"></div>
    <div class="orb orb-2"></div>
    <div class="orb orb-3"></div>
    <div class="orb orb-4"></div>
</div>

<!-- SIDEBAR -->
<aside class="sidebar" id="sidebar">
    <div class="brand">
        <div class="brand-icon">&#128230;</div>
        <div class="brand-text">
            <h2>SmartInv</h2>
            <p>Inventory System</p>
        </div>
    </div>

    <div class="nav-section-title">Main</div>
    <a href="<%= ctx %>/dashboard" class="nav-item active"><span class="icon">&#127968;</span> Dashboard</a>
    <a href="<%= ctx %>/product?action=list" class="nav-item"><span class="icon">&#128230;</span> Products</a>
    <a href="<%= ctx %>/inventory?action=list" class="nav-item"><span class="icon">&#128260;</span> Inventory</a>

    <div class="nav-section-title">Operations</div>
    <a href="<%= ctx %>/inventory?action=stockInPage" class="nav-item"><span class="icon">&#10133;</span> Stock In</a>
    <a href="<%= ctx %>/inventory?action=stockOutPage" class="nav-item"><span class="icon">&#10134;</span> Stock Out</a>

    <div class="nav-section-title">Reports</div>
    <a href="<%= ctx %>/report?action=stockReport" class="nav-item"><span class="icon">&#128202;</span> Stock Report</a>
    <a href="<%= ctx %>/report?action=lowStock" class="nav-item"><span class="icon">&#9888;</span> Low Stock Alerts</a>

    <div class="nav-section-title">Account</div>
    <a href="<%= ctx %>/logout" class="nav-item"><span class="icon">&#128682;</span> Logout</a>

    <div class="sidebar-footer">&copy; 2026 SmartInv<br>v1.0</div>
</aside>

<!-- MAIN -->
<main class="main">

    <div class="topbar">
        <div class="topbar-left">
            <h1>Welcome back, <%= loggedUser.getFullName() %></h1>
            <p>Here's what's happening in your inventory today.</p>
        </div>
        <div class="topbar-right">
            <button class="icon-btn" id="themeToggle" title="Toggle theme">&#127769;</button>
            <div class="user-chip">
                <div class="avatar"><%= loggedUser.getFullName().substring(0, 1).toUpperCase() %></div>
                <div>
                    <div class="u-name"><%= loggedUser.getFullName() %></div>
                    <div class="u-role"><%= loggedUser.getRole() %></div>
                </div>
            </div>
        </div>
    </div>

    <!-- STATS -->
    <div class="stats-grid">
        <div class="stat-card primary">
            <div class="stat-icon">&#128230;</div>
            <h3>Total Products</h3>
            <div class="value">${totalProducts != null ? totalProducts : 0}</div>
            <div class="trend">&#128200; Active items in catalog</div>
        </div>
        <div class="stat-card success">
            <div class="stat-icon">&#9989;</div>
            <h3>Total Stock Units</h3>
            <div class="value">${totalStock != null ? totalStock : 0}</div>
            <div class="trend">&#128230; Units in inventory</div>
        </div>
        <div class="stat-card warning">
            <div class="stat-icon">&#9888;</div>
            <h3>Low Stock Items</h3>
            <div class="value">${lowStockCount != null ? lowStockCount : 0}</div>
            <div class="trend">&#128276; Need restocking soon</div>
        </div>
        <div class="stat-card danger">
            <div class="stat-icon">&#128683;</div>
            <h3>Out of Stock</h3>
            <div class="value">${outOfStockCount != null ? outOfStockCount : 0}</div>
            <div class="trend">&#10071; Urgent attention needed</div>
        </div>
    </div>

    <!-- QUICK ACTIONS -->
    <div class="section-head">
        <div class="section-title"><span class="bar"></span> Quick Actions</div>
    </div>
    <div class="actions-grid">
        <a href="<%= ctx %>/product?action=new" class="action-tile">
            <div class="a-icon">&#10133;</div>
            <div class="a-label">Add Product</div>
        </a>
        <a href="<%= ctx %>/inventory?action=stockInPage" class="action-tile">
            <div class="a-icon">&#128229;</div>
            <div class="a-label">Stock In</div>
        </a>
        <a href="<%= ctx %>/inventory?action=stockOutPage" class="action-tile">
            <div class="a-icon">&#128228;</div>
            <div class="a-label">Stock Out</div>
        </a>
        <a href="<%= ctx %>/report?action=stockReport" class="action-tile">
            <div class="a-icon">&#128202;</div>
            <div class="a-label">View Reports</div>
        </a>
        <a href="<%= ctx %>/report?action=lowStock" class="action-tile">
            <div class="a-icon">&#9888;</div>
            <div class="a-label">Low Stock</div>
        </a>
        <a href="<%= ctx %>/product?action=list" class="action-tile">
            <div class="a-icon">&#128203;</div>
            <div class="a-label">All Products</div>
        </a>
    </div>

    <!-- CHARTS SECTION -->
    <div class="section-head">
        <div class="section-title"><span class="bar"></span> Analytics Overview</div>
    </div>

    <!-- Row 1: Bar + Line -->
    <div class="charts-grid">
        <div class="chart-panel">
            <div class="chart-panel-head">
                <h3>&#128202; Top 10 Products by Stock</h3>
                <span class="badge">Bar Chart</span>
            </div>
            <div class="chart-wrap">
                <canvas id="barChart"></canvas>
            </div>
        </div>

        <div class="chart-panel">
            <div class="chart-panel-head">
                <h3>&#128200; Stock Movements (7 Days)</h3>
                <span class="badge green">Line Chart</span>
            </div>
            <div class="chart-wrap">
                <canvas id="lineChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Row 2: Doughnut -->
    <div class="donut-panel">
        <div class="chart-panel-head">
            <h3>&#127849; Product Distribution by Category</h3>
            <span class="badge purple">Doughnut Chart</span>
        </div>
        <div class="donut-layout">
            <div class="donut-canvas-wrap">
                <canvas id="pieChart"></canvas>
            </div>
            <div class="donut-legend" id="donutLegend"></div>
        </div>
    </div>

    <!-- Row 3: Recent Transactions + Low Stock -->
    <div class="section-head" style="margin-top: 28px;">
        <div class="section-title"><span class="bar"></span> Activity Overview</div>
    </div>
    <div class="panels-grid">

        <div class="panel">
            <div class="panel-head">
                <h3>&#128340; Recent Transactions</h3>
                <a href="<%= ctx %>/inventory?action=list" class="section-link">View all &rarr;</a>
            </div>
            <div class="panel-body">
<%
    List<Stock> recent = (List<Stock>) request.getAttribute("recentTransactions");
    if (recent != null && !recent.isEmpty()) {
        for (Stock s : recent) {
            boolean isIn = "IN".equalsIgnoreCase(s.getTransactionType());
%>
                <div class="activity-item <%= isIn ? "in" : "out" %>">
                    <div class="a-dot"><%= isIn ? "&#128229;" : "&#128228;" %></div>
                    <div class="a-info">
                        <div class="a-title"><%= s.getProductName() %></div>
                        <div class="a-meta">
                            by <%= s.getUsername() != null ? s.getUsername() : "system" %>
                            &middot; <%= s.getTransactionDate() %>
                        </div>
                    </div>
                    <div class="a-qty"><%= isIn ? "+" : "-" %><%= s.getQuantity() %></div>
                </div>
<%
        }
    } else {
%>
                <div class="empty-state">
                    <span class="em-icon">&#128229;</span>
                    No transactions yet
                </div>
<%
    }
%>
            </div>
        </div>

        <div class="panel">
            <div class="panel-head">
                <h3>&#9888; Low Stock Alerts</h3>
                <a href="<%= ctx %>/report?action=lowStock" class="section-link">View all &rarr;</a>
            </div>
            <div class="panel-body">
<%
    List<Product> low = (List<Product>) request.getAttribute("lowStockProducts");
    if (low != null && !low.isEmpty()) {
        int shown = 0;
        for (Product p : low) {
            if (shown >= 5) break;
            shown++;
            boolean isOut = (p.getQuantity() == 0);
%>
                <div class="alert-item <%= isOut ? "danger" : "" %>">
                    <div class="warn-icon"><%= isOut ? "&#128683;" : "&#9888;" %></div>
                    <div class="alert-info">
                        <div class="alert-title"><%= p.getProductName() %></div>
                        <div class="alert-sub">
                            <%= isOut ? "Out of stock" : "Only " + p.getQuantity() + " left" %>
                            &middot; Reorder at <%= p.getReorderLevel() %>
                        </div>
                    </div>
                </div>
<%
        }
    } else {
%>
                <div class="empty-state">
                    <span class="em-icon">&#9989;</span>
                    All products well-stocked
                </div>
<%
    }
%>
            </div>
        </div>

    </div>

</main>

<button class="menu-toggle" id="menuToggle" title="Menu">&#9776;</button>

<script>
    // ============================================================
    //  THEME TOGGLE
    // ============================================================
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
        updateChartColors();
    });

    // ============================================================
    //  MOBILE MENU
    // ============================================================
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

    // ============================================================
    //  ANIMATED COUNTERS
    // ============================================================
    document.querySelectorAll('.stat-card .value').forEach(function (el) {
        var text = el.textContent.trim();
        var target = parseInt(text, 10);
        if (isNaN(target) || target === 0) return;
        el.textContent = '0';
        var step = Math.max(1, Math.ceil(target / 30));
        var current = 0;
        var timer = setInterval(function () {
            current += step;
            if (current >= target) {
                el.textContent = target;
                clearInterval(timer);
            } else {
                el.textContent = current;
            }
        }, 25);
    });

    // ============================================================
    //  PARTICLES
    // ============================================================
    (function () {
        var c = document.querySelector('.bg-animation');
        if (!c) return;
        for (var i = 0; i < 20; i++) {
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

    // ============================================================
    //  GREETING
    // ============================================================
    (function () {
        var hour = new Date().getHours();
        var greet = 'Welcome';
        if (hour < 12) greet = 'Good morning';
        else if (hour < 17) greet = 'Good afternoon';
        else greet = 'Good evening';
        var h1 = document.querySelector('.topbar-left h1');
        if (h1) h1.textContent = h1.textContent.replace(/^Welcome back,/, greet + ',');
    })();

    // ============================================================
    //  BUILD CHART DATA FROM JSP
    // ============================================================
    <%
        List<Product> productsForChart = (List<Product>) request.getAttribute("productsForChart");
        StringBuilder barLabels = new StringBuilder("[");
        StringBuilder barData   = new StringBuilder("[");
        if (productsForChart != null) {
            int limit = Math.min(10, productsForChart.size());
            for (int i = 0; i < limit; i++) {
                Product p = productsForChart.get(i);
                String name = p.getProductName() != null ? p.getProductName() : "";
                if (name.length() > 18) name = name.substring(0, 18) + "…";
                barLabels.append("\"").append(name.replace("\"", "\\\"")).append("\"");
                barData.append(p.getQuantity());
                if (i < limit - 1) { barLabels.append(","); barData.append(","); }
            }
        }
        barLabels.append("]");
        barData.append("]");
    %>
    var barLabels = <%= barLabels.toString() %>;
    var barValues = <%= barData.toString() %>;
    if (barLabels.length === 2) {
        barLabels = ["No Data"];
        barValues = [0];
    }

    var pieLabels = ["Electronics","Stationery","Furniture","Groceries","Clothing","Others",
                     "Home Appliances","Sports & Outdoors","Books & Media","Toys & Games",
                     "Health & Beauty","Automotive","Garden & Tools","Pet Supplies","Baby Products"];
    var pieValues = [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100];

    <%
        int[] categoryStats = (int[]) request.getAttribute("categoryStats");
        if (categoryStats != null) {
    %>
    pieValues = [
        <%= categoryStats[0] %>, <%= categoryStats[1] %>, <%= categoryStats[2] %>,
        <%= categoryStats[3] %>, <%= categoryStats[4] %>, <%= categoryStats[5] %>,
        <%= categoryStats[6] %>, <%= categoryStats[7] %>, <%= categoryStats[8] %>,
        <%= categoryStats[9] %>, <%= categoryStats[10] %>, <%= categoryStats[11] %>,
        <%= categoryStats[12] %>, <%= categoryStats[13] %>, <%= categoryStats[14] %>
    ];
    <%
        }
    %>

    // Line chart labels + data
    var lineLabels = [];
    (function () {
        var today = new Date();
        for (var i = 6; i >= 0; i--) {
            var d = new Date(today);
            d.setDate(today.getDate() - i);
            lineLabels.push(d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }));
        }
    })();
    var lineIn  = [12, 19, 8, 25, 17, 22, 14];
    var lineOut = [7, 11, 15, 9, 20, 13, 8];

    // ============================================================
    //  CHART.js DEFAULTS
    // ============================================================
    Chart.defaults.font.family = "'Segoe UI', sans-serif";
    Chart.defaults.font.size = 11;
    Chart.defaults.color = body.classList.contains('dark') ? '#a0aec0' : '#8898aa';

    // ============================================================
    //  BAR CHART
    // ============================================================
    var barCtx = document.getElementById('barChart').getContext('2d');
    var barGradient = barCtx.createLinearGradient(0, 0, 0, 300);
    barGradient.addColorStop(0, 'rgba(67, 97, 238, 0.95)');
    barGradient.addColorStop(1, 'rgba(76, 201, 240, 0.55)');

    var barChart = new Chart(barCtx, {
        type: 'bar',
        data: {
            labels: barLabels,
            datasets: [{
                label: 'Stock Quantity',
                data: barValues,
                backgroundColor: barGradient,
                borderColor: '#4361ee',
                borderWidth: 1.5,
                borderRadius: 8,
                borderSkipped: false,
                hoverBackgroundColor: 'rgba(58, 12, 163, 0.95)'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: 'rgba(26, 31, 54, 0.95)',
                    padding: 12,
                    cornerRadius: 8,
                    callbacks: {
                        label: function (ctx) { return 'Quantity: ' + ctx.parsed.y + ' units'; }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: body.classList.contains('dark') ? 'rgba(255,255,255,0.06)' : 'rgba(136,152,170,0.12)', drawBorder: false },
                    ticks: { font: { size: 11 } }
                },
                x: {
                    grid: { display: false },
                    ticks: { font: { size: 10 }, maxRotation: 40, minRotation: 0 }
                }
            },
            animation: { duration: 1200, easing: 'easeOutQuart' }
        }
    });

    // ============================================================
    //  LINE CHART
    // ============================================================
    var lineCtx = document.getElementById('lineChart').getContext('2d');
    var inGradient = lineCtx.createLinearGradient(0, 0, 0, 300);
    inGradient.addColorStop(0, 'rgba(6, 214, 160, 0.35)');
    inGradient.addColorStop(1, 'rgba(6, 214, 160, 0.02)');
    var outGradient = lineCtx.createLinearGradient(0, 0, 0, 300);
    outGradient.addColorStop(0, 'rgba(239, 71, 111, 0.30)');
    outGradient.addColorStop(1, 'rgba(239, 71, 111, 0.02)');

    var lineChart = new Chart(lineCtx, {
        type: 'line',
        data: {
            labels: lineLabels,
            datasets: [
                {
                    label: 'Stock In',
                    data: lineIn,
                    borderColor: '#06d6a0',
                    backgroundColor: inGradient,
                    borderWidth: 2.5,
                    tension: 0.4,
                    fill: true,
                    pointRadius: 4,
                    pointHoverRadius: 6,
                    pointBackgroundColor: '#06d6a0',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2
                },
                {
                    label: 'Stock Out',
                    data: lineOut,
                    borderColor: '#ef476f',
                    backgroundColor: outGradient,
                    borderWidth: 2.5,
                    tension: 0.4,
                    fill: true,
                    pointRadius: 4,
                    pointHoverRadius: 6,
                    pointBackgroundColor: '#ef476f',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { mode: 'index', intersect: false },
            plugins: {
                legend: {
                    display: true, position: 'top', align: 'end',
                    labels: { boxWidth: 10, boxHeight: 10, usePointStyle: true, pointStyle: 'circle', padding: 12, font: { size: 11, weight: '600' } }
                },
                tooltip: {
                    backgroundColor: 'rgba(26, 31, 54, 0.95)',
                    padding: 12,
                    cornerRadius: 8
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: body.classList.contains('dark') ? 'rgba(255,255,255,0.06)' : 'rgba(136,152,170,0.12)', drawBorder: false },
                    ticks: { font: { size: 11 } }
                },
                x: { grid: { display: false }, ticks: { font: { size: 11 } } }
            },
            animation: { duration: 1200, easing: 'easeOutQuart' }
        }
    });

    // ============================================================
    //  DOUGHNUT CHART (custom HTML legend)
    // ============================================================
    var pieCtx = document.getElementById('pieChart').getContext('2d');
    var pieColors = [
        '#4361ee', '#4cc9f0', '#7209b7', '#f72585', '#06d6a0',
        '#ffb703', '#fb8500', '#e63946', '#3a0ca3', '#2a9d8f',
        '#e76f51', '#8338ec', '#ff006e', '#118ab2', '#f4a261'
    ];

    var pieChart = new Chart(pieCtx, {
        type: 'doughnut',
        data: {
            labels: pieLabels,
            datasets: [{
                data: pieValues,
                backgroundColor: pieColors,
                borderColor: body.classList.contains('dark') ? '#1a2238' : '#ffffff',
                borderWidth: 3,
                hoverOffset: 10,
                hoverBorderWidth: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '60%',
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: 'rgba(26, 31, 54, 0.95)',
                    padding: 12,
                    cornerRadius: 8,
                    callbacks: {
                        label: function (ctx) {
                            var total = ctx.dataset.data.reduce(function (a, b) { return a + b; }, 0);
                            var pct = total > 0 ? ((ctx.parsed / total) * 100).toFixed(1) : '0';
                            return '  ' + ctx.label + ': ' + ctx.parsed + ' products (' + pct + '%)';
                        }
                    }
                }
            },
            animation: {
                animateRotate: true,
                animateScale: true,
                duration: 1200,
                easing: 'easeOutQuart'
            }
        }
    });

    // Custom HTML legend
    (function buildLegend() {
        var legendEl = document.getElementById('donutLegend');
        if (!legendEl) return;
        legendEl.innerHTML = '';

        var total = pieValues.reduce(function (a, b) { return a + b; }, 0);

        for (var i = 0; i < pieLabels.length; i++) {
            var count = pieValues[i];
            var pct = total > 0 ? ((count / total) * 100).toFixed(1) : '0';

            var item = document.createElement('div');
            item.className = 'legend-item';
            item.innerHTML =
                '<span class="legend-dot" style="background:' + pieColors[i] + '"></span>' +
                '<span class="legend-label">' + pieLabels[i] + '</span>' +
                '<span class="legend-value">' + count + ' (' + pct + '%)</span>';
            legendEl.appendChild(item);
        }
    })();

    // ============================================================
    //  THEME COLOR UPDATE
    // ============================================================
    function updateChartColors() {
        var isDark = body.classList.contains('dark');
        var gridColor = isDark ? 'rgba(255,255,255,0.06)' : 'rgba(136,152,170,0.12)';
        var textColor = isDark ? '#a0aec0' : '#8898aa';

        barChart.options.scales.y.grid.color = gridColor;
        barChart.options.scales.y.ticks.color = textColor;
        barChart.options.scales.x.ticks.color = textColor;
        barChart.update();

        lineChart.options.scales.y.grid.color = gridColor;
        lineChart.options.scales.y.ticks.color = textColor;
        lineChart.options.scales.x.ticks.color = textColor;
        lineChart.options.plugins.legend.labels.color = textColor;
        lineChart.update();

        pieChart.data.datasets[0].borderColor = isDark ? '#1a2238' : '#ffffff';
        pieChart.update();
    }
</script>

</body>
</html>