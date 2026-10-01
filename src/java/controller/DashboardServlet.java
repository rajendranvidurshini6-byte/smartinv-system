package controller;

import dao.ProductDAO;
import dao.StockDAO;
import model.Product;
import model.Stock;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private ProductDAO productDAO;
    private StockDAO stockDAO;

    @Override
    public void init() throws ServletException {
        System.out.println("[DashboardServlet] init() called");
        productDAO = new ProductDAO();
        stockDAO = new StockDAO();
    }

    private ProductDAO getProductDAO() {
        if (productDAO == null) productDAO = new ProductDAO();
        return productDAO;
    }

    private StockDAO getStockDAO() {
        if (stockDAO == null) stockDAO = new StockDAO();
        return stockDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        System.out.println("===== DASHBOARD LOAD =====");
        System.out.println("  User: " + user.getUsername());

        // ---------- STATS ----------
        try {
            int totalProducts = getProductDAO().getTotalProductCount();
            request.setAttribute("totalProducts", totalProducts);
            System.out.println("  totalProducts = " + totalProducts);
        } catch (Exception e) {
            System.out.println("  ✘ getTotalProductCount failed");
            e.printStackTrace();
            request.setAttribute("totalProducts", 0);
        }

        try {
            int totalStock = getProductDAO().getTotalStockUnits();
            request.setAttribute("totalStock", totalStock);
            System.out.println("  totalStock = " + totalStock);
        } catch (Exception e) {
            System.out.println("  ✘ getTotalStockUnits failed");
            e.printStackTrace();
            request.setAttribute("totalStock", 0);
        }

        try {
            int lowStockCount = getProductDAO().getLowStockCount();
            request.setAttribute("lowStockCount", lowStockCount);
            System.out.println("  lowStockCount = " + lowStockCount);
        } catch (Exception e) {
            System.out.println("  ✘ getLowStockCount failed");
            e.printStackTrace();
            request.setAttribute("lowStockCount", 0);
        }

        try {
            int outOfStock = getProductDAO().getOutOfStockCount();
            request.setAttribute("outOfStockCount", outOfStock);
            System.out.println("  outOfStockCount = " + outOfStock);
        } catch (Exception e) {
            System.out.println("  ✘ getOutOfStockCount failed");
            e.printStackTrace();
            request.setAttribute("outOfStockCount", 0);
        }

        // ---------- TOP 10 PRODUCTS FOR BAR CHART ----------
        try {
            List<Product> allProducts = getProductDAO().getAllProducts();
            if (allProducts != null) {
                allProducts.sort((a, b) -> Integer.compare(b.getQuantity(), a.getQuantity()));
            }
            request.setAttribute("productsForChart", allProducts);
            System.out.println("  productsForChart set: "
                + (allProducts == null ? "null" : allProducts.size() + " rows"));
        } catch (Exception e) {
            System.out.println("  ✘ productsForChart failed");
            e.printStackTrace();
        }

        // ---------- CATEGORY STATS FOR DOUGHNUT CHART ----------
        try {
            int[] categoryStats = new int[15];
            String sql = "SELECT c.category_name, COUNT(p.product_id) AS cnt " +
                         "FROM categories c " +
                         "LEFT JOIN products p ON c.category_id = p.category_id " +
                         "GROUP BY c.category_name " +
                         "ORDER BY c.category_id";

            try (Connection conn = util.DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                int idx = 0;
                while (rs.next() && idx < 15) {
                    categoryStats[idx++] = rs.getInt("cnt");
                }
            }
            request.setAttribute("categoryStats", categoryStats);
            System.out.println("  categoryStats set");
        } catch (Exception e) {
            System.out.println("  ✘ categoryStats failed");
            e.printStackTrace();
        }

        // ---------- RECENT TRANSACTIONS ----------
        try {
            List<Stock> recent = getStockDAO().getAllTransactions();
            System.out.println("  getAllTransactions: "
                + (recent == null ? "null" : recent.size() + " rows"));
            if (recent != null && recent.size() > 5) {
                recent = recent.subList(0, 5);
            }
            request.setAttribute("recentTransactions", recent);
        } catch (Exception e) {
            System.out.println("  ✘ getAllTransactions failed");
            e.printStackTrace();
            request.setAttribute("recentTransactions", null);
        }

        // ---------- LOW STOCK PRODUCTS ----------
        try {
            List<Product> low = getProductDAO().getLowStockProducts();
            System.out.println("  getLowStockProducts: "
                + (low == null ? "null" : low.size() + " rows"));
            if (low != null && low.size() > 5) {
                low = low.subList(0, 5);
            }
            request.setAttribute("lowStockProducts", low);
        } catch (Exception e) {
            System.out.println("  ✘ getLowStockProducts failed");
            e.printStackTrace();
            request.setAttribute("lowStockProducts", null);
        }

        System.out.println("==========================");
        request.setAttribute("loggedUser", user);
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }
}