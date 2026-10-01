<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.User, model.Category" %>
<%
    User loggedUser = (User) session.getAttribute("user");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add Product | SmartInv</title>
<style>
    :root {
        --primary: #4361ee;
        --primary-dark: #3a0ca3;
        --primary-light: #eef1ff;
        --success: #06d6a0;
        --warning: #ffb703;
        --danger: #ef476f;

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
        background: var(--bg-body); color: var(--text-dark);
        min-height: 100vh; display: flex; transition: background 0.3s;
    }

    /* BACKGROUND */
    .bg-animation { position: fixed; inset: 0; overflow: hidden; z-index: 0; pointer-events: none; }
    .bg-animation::after {
        content: ''; position: absolute; inset: 0;
        background: radial-gradient(ellipse at center, transparent 35%, rgba(0,0,0,0.35) 100%);
    }
    .orb { position: absolute; border-radius: 50%; filter: blur(80px); opacity: 0.35; }
    body.dark .orb { opacity: 0.45; }
    .orb-1 { width: 500px; height: 500px; background: radial-gradient(circle, #4361ee, transparent 70%); top: -150px; left: -100px; animation: f1 18s ease-in-out infinite; }
    .orb-2 { width: 420px; height: 420px; background: radial-gradient(circle, #4cc9f0, transparent 70%); bottom: -120px; right: -80px; animation: f2 22s ease-in-out infinite; }
    .orb-3 { width: 380px; height: 380px; background: radial-gradient(circle, #b5179e, transparent 70%); top: 45%; left: 42%; animation: f3 25s ease-in-out infinite; opacity: 0.22; }
    @keyframes f1 { 0%,100%{transform:translate(0,0);} 50%{transform:translate(80px,60px)scale(1.1);} }
    @keyframes f2 { 0%,100%{transform:translate(0,0);} 50%{transform:translate(-100px,-80px)scale(1.15);} }
    @keyframes f3 { 0%,100%{transform:translate(-50%,-50%);} 50%{transform:translate(-30%,-60%)scale(1.1);} }

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

    @media (prefers-reduced-motion: reduce) { .orb,.bg-grid { animation: none !important; } }

    /* SIDEBAR (same as list) */
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
        font-size: 20px;
    }
    .brand-text h2 { font-size: 18px; font-weight: 700; }
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
    .icon-btn:hover { background: var(--primary); color: #fff; transform: translateY(-2px); }

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

    /* FORM */
    .form-card {
        background: var(--bg-card); padding: 32px;
        border-radius: var(--radius); box-shadow: var(--shadow-sm);
        border: 1px solid var(--border); max-width: 720px;
        backdrop-filter: blur(8px);
        animation: fadeUp 0.5s ease both;
    }
    @keyframes fadeUp { from { opacity: 0; transform: translateY(16px);} to { opacity: 1; transform: translateY(0);} }

    .form-header {
        display: flex; align-items: center; gap: 14px;
        margin-bottom: 26px; padding-bottom: 18px;
        border-bottom: 1px solid var(--border);
    }
    .form-header .icon-circle {
        width: 46px; height: 46px; border-radius: 14px;
        background: linear-gradient(135deg, #4361ee, #4cc9f0);
        color: #fff; display: flex; align-items: center; justify-content: center;
        font-size: 22px;
        box-shadow: 0 6px 18px rgba(67,97,238,0.3);
    }
    .form-header h1 { font-size: 20px; color: var(--text-dark); font-weight: 700; }
    .form-header p { font-size: 13px; color: var(--text-light); margin-top: 2px; }

    .error-box {
        background: linear-gradient(135deg, #fdecea, #fadbd8);
        color: #922b21; padding: 12px 16px;
        border-radius: var(--radius-sm); font-size: 13px;
        margin-bottom: 20px; border-left: 4px solid var(--danger);
    }
    body.dark .error-box { background: rgba(239,71,111,0.15); color: #ff8095; }

    .form-row {
        display: grid; grid-template-columns: 1fr 1fr; gap: 18px;
    }
    @media (max-width: 600px) { .form-row { grid-template-columns: 1fr; } }

    .form-group { margin-bottom: 18px; }
    .form-group label {
        display: block; font-size: 13px; color: var(--text-dark);
        margin-bottom: 7px; font-weight: 600;
    }
    .form-group label .req { color: var(--danger); margin-left: 2px; }
    .form-group input, .form-group select, .form-group textarea {
        width: 100%; padding: 12px 14px;
        border: 1.5px solid var(--border); border-radius: var(--radius-sm);
        font-size: 14px; color: var(--text-dark);
        background: #fafbfd; transition: var(--transition);
        font-family: inherit;
    }
    body.dark .form-group input,
    body.dark .form-group select,
    body.dark .form-group textarea { background: #0f1729; color: var(--text-dark); }

    .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
        outline: none; border-color: var(--primary);
        background: var(--bg-card);
        box-shadow: 0 0 0 4px rgba(67,97,238,0.1);
    }
    .form-group small {
        display: block; font-size: 11.5px;
        color: var(--text-light); margin-top: 5px;
    }

    .btn-row {
        display: flex; gap: 12px; margin-top: 8px;
        padding-top: 20px; border-top: 1px solid var(--border);
    }
    .btn {
        padding: 12px 22px; border-radius: var(--radius-sm);
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
    .btn-secondary {
        background: var(--primary-light); color: var(--text-mid);
        border: 1px solid var(--border);
    }
    .btn-secondary:hover {
        background: var(--border); transform: translateY(-2px);
    }

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
        .user-chip .u-name, .user-chip .u-role { display: none; }
        .form-card { padding: 22px 18px; }
    }
</style>
</head>
<body>

<div class="bg-animation" aria-hidden="true">
    <div class="bg-grid"></div>
    <div class="orb orb-1"></div>
    <div class="orb orb-2"></div>
    <div class="orb orb-3"></div>
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

<main class="main">
    <div class="topbar">
        <div class="topbar-left">
            <h1>Add Product</h1>
            <p>Create a new product in the catalog</p>
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

    <div class="form-card">
        <div class="form-header">
            <div class="icon-circle">&#10133;</div>
            <div>
                <h1>New Product Details</h1>
                <p>Fill in the fields below to add a product</p>
            </div>
        </div>

        <% if (error != null) { %>
            <div class="error-box"><%= error %></div>
        <% } %>

        <form action="<%= ctx %>/product" method="post" onsubmit="return validateForm()" id="productForm">
            <input type="hidden" name="action" value="add">

            <div class="form-group">
                <label for="productName">Product Name <span class="req">*</span></label>
                <input type="text" id="productName" name="productName"
                       placeholder="e.g., Laptop HP 15, A4 Paper Ream"
                       required maxlength="150" autofocus>
                <small>Max 150 characters</small>
            </div>

            <div class="form-group">
                <label for="categoryId">Category <span class="req">*</span></label>
                <select id="categoryId" name="categoryId" required>
                    <option value="">-- Select a category --</option>
                    <%
                        if (categories != null && !categories.isEmpty()) {
                            for (Category c : categories) {
                    %>
                        <option value="<%= c.getCategoryId() %>"><%= c.getCategoryName() %></option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="price">Price (Rs.) <span class="req">*</span></label>
                    <input type="number" id="price" name="price"
                           step="0.01" min="0.01" placeholder="0.00" required>
                </div>
                <div class="form-group">
                    <label for="quantity">Initial Quantity <span class="req">*</span></label>
                    <input type="number" id="quantity" name="quantity"
                           min="0" value="0" required>
                </div>
            </div>

            <div class="form-group">
                <label for="reorderLevel">Reorder Level <span class="req">*</span></label>
                <input type="number" id="reorderLevel" name="reorderLevel"
                       min="1" value="10" required>
                <small>You'll be alerted when stock drops to this level</small>
            </div>

            <div class="btn-row">
                <button type="submit" class="btn btn-primary">&#128190; Save Product</button>
                <a href="<%= ctx %>/product?action=list" class="btn btn-secondary">&#10006; Cancel</a>
            </div>
        </form>
    </div>
</main>

<button class="menu-toggle" id="menuToggle" title="Menu">&#9776;</button>

<script>
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

    function validateForm() {
        var name = document.getElementById('productName').value.trim();
        var cat = document.getElementById('categoryId').value;
        var price = parseFloat(document.getElementById('price').value);
        var qty = parseInt(document.getElementById('quantity').value);
        var reorder = parseInt(document.getElementById('reorderLevel').value);

        if (name === '') { alert('Product name is required.'); return false; }
        if (cat === '') { alert('Please select a category.'); return false; }
        if (isNaN(price) || price <= 0) { alert('Price must be a positive number.'); return false; }
        if (isNaN(qty) || qty < 0) { alert('Quantity cannot be negative.'); return false; }
        if (isNaN(reorder) || reorder < 1) { alert('Reorder level must be at least 1.'); return false; }
        return true;
    }
</script>

</body>
</html>