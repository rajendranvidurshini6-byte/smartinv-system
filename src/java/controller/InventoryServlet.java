package controller;

import dao.ProductDAO;
import dao.StockDAO;
import model.Stock;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {

    private StockDAO stockDAO;
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        stockDAO = new StockDAO();
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {

                case "list":
                    List<Stock> transactions = stockDAO.getAllTransactions();
                    request.setAttribute("transactions", transactions);
                    request.getRequestDispatcher("/inventory/stock-list.jsp").forward(request, response);
                    break;

                case "stockInPage":
                    request.setAttribute("products", productDAO.getAllProducts());
                    request.getRequestDispatcher("/inventory/stock-in.jsp").forward(request, response);
                    break;

                case "stockOutPage":
                    request.setAttribute("products", productDAO.getAllProducts());
                    request.getRequestDispatcher("/inventory/stock-out.jsp").forward(request, response);
                    break;

                default:
                    response.sendRedirect(request.getContextPath() + "/inventory?action=list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/inventory?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            if ("stockIn".equals(action)) {
                int productId = Integer.parseInt(request.getParameter("productId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                String remarks = request.getParameter("remarks");

                User user = (User) request.getSession().getAttribute("user");

                boolean ok = stockDAO.recordStockIn(productId, quantity, user.getUserId(), remarks);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/inventory?action=list");
                } else {
                    request.setAttribute("error", "Stock In failed.");
                    request.setAttribute("products", productDAO.getAllProducts());
                    request.getRequestDispatcher("/inventory/stock-in.jsp").forward(request, response);
                }

            } else if ("stockOut".equals(action)) {
                int productId = Integer.parseInt(request.getParameter("productId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                String remarks = request.getParameter("remarks");

                User user = (User) request.getSession().getAttribute("user");

                boolean ok = stockDAO.recordStockOut(productId, quantity, user.getUserId(), remarks);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/inventory?action=list");
                } else {
                    request.setAttribute("error", "Stock Out failed. Check available quantity.");
                    request.setAttribute("products", productDAO.getAllProducts());
                    request.getRequestDispatcher("/inventory/stock-out.jsp").forward(request, response);
                }

            } else {
                response.sendRedirect(request.getContextPath() + "/inventory?action=list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/inventory?action=list");
        }
    }

    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("user") != null;
    }
}