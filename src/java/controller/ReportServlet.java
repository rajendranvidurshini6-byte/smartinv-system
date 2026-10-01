package controller;

import dao.ProductDAO;
import dao.StockDAO;
import model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/report")
public class ReportServlet extends HttpServlet {

    private ProductDAO productDAO;
    private StockDAO stockDAO;

    @Override
    public void init() throws ServletException {
        System.out.println("[ReportServlet] init() called");
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

        String action = request.getParameter("action");
        if (action == null) action = "stockReport";

        System.out.println("[ReportServlet] action = " + action);

        try {
            switch (action) {

                case "stockReport":
                    List<Product> allProducts = getProductDAO().getAllProducts();
                    request.setAttribute("products", allProducts);
                    System.out.println("[ReportServlet] forwarding to /reports/stock-report.jsp");
                    request.getRequestDispatcher("/reports/stock-report.jsp")
                           .forward(request, response);
                    break;

                case "lowStock":
                    List<Product> lowStock = getProductDAO().getLowStockProducts();
                    request.setAttribute("lowStockProducts", lowStock);
                    System.out.println("[ReportServlet] forwarding to /reports/low-stock.jsp "
                        + "with " + (lowStock == null ? 0 : lowStock.size()) + " items");
                    request.getRequestDispatcher("/reports/low-stock.jsp")
                           .forward(request, response);
                    break;

                default:
                    System.out.println("[ReportServlet] unknown action → redirect to stockReport");
                    response.sendRedirect(request.getContextPath() + "/report?action=stockReport");
            }
        } catch (Exception e) {
            System.out.println("[ReportServlet] ✘ EXCEPTION:");
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}