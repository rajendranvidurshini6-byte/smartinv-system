<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.User, model.Product" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    List<Product> products = (List<Product>) request.getAttribute("products");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Products | SmartInv</title>
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

    /* ============ BACKGROUND ============ */
    .bg-animation {
        position: fixed; inset: 0;
        overflow: hidden; z-index: 0; pointer-events: none;
    }
    .bg-animation::after {
        content: ''; position: absolute; inset: 0;
        background: radial-gradient(ellipse at center, transparent 35%, rgba(0,0,0,0.35) 100%);
    }
    .orb {
        position: absolute; border-radius: 50%;
        filter: blur(80px); opacity: 0.4; will-change: transform;
    }
    body.dark .orb { opacity: 0.5; }
    .orb-1 { width: 500px; height: 500px; background: radial-gradient(circle, #4361ee, transparent 70%); top: -150px; left: -100px; animation: floatOrb1 18s ease-in-out infinite; }
    .orb-2 { width: 420px; height: 420px; background: radial-gradient(circle, #4cc9f0, transparent 70%); bottom: -120px; right: -80px; animation: floatOrb2 22s ease-in-out infinite; }
    .orb-3 { width: 380px; height: 380px; background: radial-gradient(circle, #b5179e, transparent 70%); top: 45%; left: 42%; animation: floatOrb3 25s ease-in-out infinite; opacity: 0.25; }
    .orb-4 { width: 320px; height: 320px; background: radial-gradient(circle, #06d6a0, transparent 70%); top: 10%; right: 15%; animation: floatOrb4 20s ease-in-out infinite; opacity: 0.28; }

    @keyframes floatOrb1 { 0%,100%{transform:translate(0,0)scale(1);} 33%{transform:translate(80px,60px)scale(1.1);} 66%{transform:translate(-40px,100px)scale(.95);} }
    @keyframes floatOrb2 { 0%,100%{transform:translate(0,0)scale(1);} 50%{transform:translate(-100px,-80px)scale(1.15);} }
    @keyframes floatOrb3 { 0%,100%{transform:translate(-50%,-50%)scale(1);} 50%{transform:translate(-30%,-60%)scale(1.15);} }
    @keyframes floatOrb4 { 0%,100%{transform:translate(0,0)scale(1);} 50%{transform:translate(-90px,90px)scale(1.1);} }

    .bg-grid {
        position: absolute; inset: 0;
        background-image:
            linear-gradient(rgba(67,97,238,0.04) 1px, transparent 1px),
            linear-gradient(90deg, rgba(67,97,238,0.04) 1px, transparent 1px);
        background-size: 45px 45px;
        animation: gridMove 30s linear infinite;
    }
    body.dark .bg-grid {
        background-image:
            linear-gradient(rgba(76,201,240,0.05) 1px, transparent 1px),
            linear-gradient(90deg, rgba(76,201,240,0.05) 1px, transparent 1px);
    }
    @keyframes gridMove { 0%{background-position:0 0;} 100%{background-position:45px 45px;} }

    .particle {
        position: absolute; background: rgba(67,97,238,0.4);
        border-radius: 50%; box-shadow: 0 0 6px rgba(76,201,240,0.6);
        animation: rise linear infinite;
    }
    body.dark .particle {
        background: rgba(255,255,255,0.7);
        box-shadow: 0 0 8px rgba(76,201,240,0.8);
    }
    @keyframes rise {
        0% { transform: translateY(100vh) scale(.5); opacity: 0; }
        10%,90% { opacity: 1; }
        100% { transform: translateY(-100px) scale(1); opacity: 0; }
    }
    @media (prefers-reduced-motion: reduce) { .orb,.particle,.bg-grid { animation: none !important; } }

    /* ============ SIDEBAR ============ */
    .sidebar {
        width: 250px;
        background: var(--bg-sidebar);
        color: #fff;
        padding: 24px 16px;
        position: fixed;
        height: 100vh;
        overflow-y: auto;
        transition: transform 0.3s;
        z-index: 100;
        display: flex;
        flex-direction: column;
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
    .brand-text h2 { font-size: 18px; letter-spacing: 0.5px; font-weight: 700; }
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
        background: var(--bg-card);
        padding: 16px 24px;
        border-radius: var(--radius);
        box-shadow: var(--shadow-sm);
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 24px;
        border: 1px solid var(--border);
        backdrop-filter: blur(10px);
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
    .icon-btn:hover {
        background: var(--primary); color: #fff;
        transform: translateY(-2px); box-shadow: 0 6px 16px rgba(67,97,238,0.3);
    }

    .user-chip {
        display: flex; align-items: center; gap: 10px;
        padding: 6px 14px 6px 6px;
        background: var(--primary-light); border-radius: 40px;
        border: 1px solid var(--border); transition: var(--transition);
    }
    .user-chip .avatar {
        width: 32px; height: 32px; border-radius: 50%;
        background: linear-gradient(135deg, #4361ee, #4cc9f0);
        color: #fff; display: flex; align-items: center; justify-content: center;
        font-weight: 700; font-size: 13px;
    }
    .user-chip .u-name { font-size: 13px; font-weight: 600; color: var(--text-dark); line-height: 1.2; }
    .user-chip .u-role { font-size: 10px; color: var(--text-light); text-transform: uppercase; letter-spacing: 0.5px; }

    /* ============ ACTION BAR ============ */
    .action-bar {
        display: flex; justify-content: space-between; align-items: center;
        margin-bottom: 20px; gap: 12px; flex-wrap: wrap;
    }
    .search-box {
        position: relative; flex: 1; max-width: 380px;
    }
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

    .btn {
        padding: 11px 20px; border-radius: var(--radius-sm);
        font-size: 14px; font-weight: 600;
        text-decoration: none; cursor: pointer;
        border: none; transition: var(--transition);
        display: inline-flex; align-items: center; gap: 6px;
        font-family: inherit;
    }
    .btn-primary {
        background: linear-gradient(135deg, #4361ee, #3a0ca3);
        color: #fff; box-shadow: 0 4px 14px rgba(67,97,238,0.3);
    }
    .btn-primary:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 22px rgba(67,97,238,0.45);
    }
    .btn-sm {
        padding: 6px 12px; font-size: 12px; border-radius: 8px;
    }
    .btn-edit { background: rgba(255,183,3,0.15); color: #d68910; }
    .btn-edit:hover { background: #ffb703; color: #fff; }
    .btn-delete { background: rgba(239,71,111,0.15); color: #c0392b; }
    .btn-delete:hover { background: #ef476f; color: #fff; }

    body.dark .btn-edit { color: #ffb703; }
    body.dark .btn-delete { color: #ef476f; }

    /* ============ TABLE ============ */
    .table-card {
        background: var(--bg-card);
        border-radius: var(--radius);
        box-shadow: var(--shadow-sm);
        border: 1px solid var(--border);
        overflow: hidden;
        backdrop-filter: blur(8px);
    }
    table {
        width: 100%; border-collapse: collapse;
    }
    thead {
        background: linear-gradient(90deg, rgba(67,97,238,0.08), rgba(76,201,240,0.08));
    }
    thead th {
        padding: 14px 16px; text-align: left;
        font-size: 12px; text-transform: uppercase;
        letter-spacing: 0.6px; color: var(--text-mid);
        font-weight: 700;
    }
    tbody tr {
        border-bottom: 1px solid var(--border);
        transition: var(--transition);
    }
    tbody tr:last-child { border-bottom: none; }
    tbody tr:hover { background: rgba(67,97,238,0.04); }
    body.dark tbody tr:hover { background: rgba(76,201,240,0.06); }

    tbody td {
        padding: 14px 16px; font-size: 14px;
        color: var(--text-dark);
    }
    .product-cell {
        display: flex; align-items: center; gap: 12px;
    }
    .product-avatar {
        width: 38px; height: 38px; border-radius: 10px;
        background: linear-gradient(135deg, #4361ee, #4cc9f0);
        color: #fff; display: flex; align-items: center; justify-content: center;
        font-weight: 700; font-size: 15px;
        flex-shrink: 0;
    }
    .product-name { font-weight: 600; color: var(--text-dark); }
    .product-id { font-size: 11px; color: var(--text-light); margin-top: 2px; }

    .badge {
        display: inline-block; padding: 5px 11px;
        border-radius: 20px; font-size: 11.5px;
        font-weight: 700; letter-spacing: 0.3px;
    }
    .badge-ok { background: rgba(6,214,160,0.15); color: #06d6a0; }
    .badge-low { background: rgba(255,183,3,0.15); color: #d68910; }
    .badge-out { background: rgba(239,71,111,0.15); color: #c0392b; }
    body.dark .badge-low { color: #ffb703; }
    body.dark .badge-out { color: #ef476f; }

    .empty-state {
        text-align: center; padding: 60px 30px;
        color: var(--text-light);
    }
    .empty-state .em-icon {
        font-size: 48px; display: block; margin-bottom: 12px; opacity: 0.5;
    }
    .empty-state h3 {
        font-size: 16px; color: var(--text-mid); margin-bottom: 6px;
    }
    .empty-state p {
        font-size: 13px; color: var(--text-light);
    }

    /* ============ MOBILE ============ */
    .menu-toggle {
        display: none; position: fixed;
        bottom: 20px; right: 20px;
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
        thead th:nth-child(3), tbody td:nth-child(3),
        thead th:nth-child(6), tbody td:nth-child(6) { display: none; }
        .action-bar { flex-direction: column; align-items: stretch; }
        .search-box { max-width: 100%; }
    }

    @keyframes fadeUp {
        from { opacity: 0; transform: translateY(16px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .topbar, .action-bar, .table-card { animation: fadeUp 0.5s ease both; }
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
    <a href="<%= ctx %>/dashboard" class="nav-item"><span class="icon">&#127968;</span> Dashboard</a>
    <a href="<%= ctx %>/product?action=list" class="nav-item active"><span class="icon">&#128230;</span> Products</a>
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
            <h1>Products</h1>
            <p>Manage your inventory product catalog</p>
        </div>
        <div class="topbar-right">
            <button class="icon-btn" id="themeToggle" title="Toggle theme">&#127769;</button>
            <div class="user-chip">
                <div class="avatar"><%= loggedUser.getFullName().substring(0,1).toUpperCase() %></div>
                <div>
                    <div class="u-name"><%= loggedUser.getFullName() %></div>
                    <div class="u-role"><%= loggedUser.getRole() %></div>
                </div>
            </div>
        </div>
    </div>

    <div class="action-bar">
        <div class="search-box">
            <input type="text" id="searchInput" placeholder="Search products by name, category..." onkeyup="filterTable()">
        </div>
        <a href="<%= ctx %>/product?action=new" class="btn btn-primary">&#10133; Add Product</a>
    </div>

    <div class="table-card">
        <table id="productTable">
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Category</th>
                    <th>Price (Rs.)</th>
                    <th>Quantity</th>
                    <th>Reorder Level</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                if (products != null && !products.isEmpty()) {
                    for (Product p : products) {
                        String badgeClass = "badge-ok";
                        String badgeText = "In Stock";
                        if (p.getQuantity() == 0) {
                            badgeClass = "badge-out"; badgeText = "Out of Stock";
                        } else if (p.getQuantity() <= p.getReorderLevel()) {
                            badgeClass = "badge-low"; badgeText = "Low Stock";
                        }
                        String initial = p.getProductName() != null && p.getProductName().length() > 0
                            ? p.getProductName().substring(0,1).toUpperCase() : "?";
            %>
                <tr>
                    <td>
                        <div class="product-cell">
                            <div class="product-avatar"><%= initial %></div>
                            <div>
                                <div class="product-name"><%= p.getProductName() %></div>
                                <div class="product-id">ID: #<%= p.getProductId() %></div>
                            </div>
                        </div>
                    </td>
                    <td><%= p.getCategoryName() != null ? p.getCategoryName() : "-" %></td>
                    <td><%= String.format("%,.2f", p.getPrice()) %></td>
                    <td><%= p.getQuantity() %></td>
                    <td><%= p.getReorderLevel() %></td>
                    <td><span class="badge <%= badgeClass %>"><%= badgeText %></span></td>
                    <td>
                        <a href="<%= ctx %>/product?action=edit&id=<%= p.getProductId() %>" class="btn btn-edit btn-sm">&#9998; Edit</a>
                        <a href="<%= ctx %>/product?action=delete&id=<%= p.getProductId() %>"
                           class="btn btn-delete btn-sm"
                           onclick="return confirm('Delete product: <%= p.getProductName() %>?');">&#128465; Delete</a>
                    </td>
                </tr>
            <%
                    }
                } else {
            %>
                <tr>
                    <td colspan="7">
                        <div class="empty-state">
                            <span class="em-icon">&#128230;</span>
                            <h3>No products found</h3>
                            <p>Click "Add Product" to create your first product.</p>
                        </div>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</main>

<button class="menu-toggle" id="menuToggle" title="Menu">&#9776;</button>

<script>
    // ===== THEME =====
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

    // ===== MOBILE MENU =====
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

    // ===== SEARCH FILTER =====
    function filterTable() {
        var input = document.getElementById('searchInput').value.toLowerCase();
        var rows = document.querySelectorAll('#productTable tbody tr');
        rows.forEach(function (row) {
            if (row.querySelector('.empty-state')) return;
            var text = row.innerText.toLowerCase();
            row.style.display = text.indexOf(input) > -1 ? '' : 'none';
        });
    }

    // ===== PARTICLES =====
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
</script>

</body>
</html>