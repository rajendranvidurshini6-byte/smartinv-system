package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import model.Product;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/product")
public class ProductServlet extends HttpServlet {

    private ProductDAO productDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
        categoryDAO = new CategoryDAO();
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
                    List<Product> products = productDAO.getAllProducts();
                    request.setAttribute("products", products);
                    request.getRequestDispatcher("/products/list.jsp").forward(request, response);
                    break;

                case "new":
                    request.setAttribute("categories", categoryDAO.getAllCategories());
                    request.getRequestDispatcher("/products/add.jsp").forward(request, response);
                    break;

                case "edit":
                    int editId = Integer.parseInt(request.getParameter("id"));
                    Product product = productDAO.getProductById(editId);
                    request.setAttribute("product", product);
                    request.setAttribute("categories", categoryDAO.getAllCategories());
                    request.getRequestDispatcher("/products/edit.jsp").forward(request, response);
                    break;

                case "delete":
                    int deleteId = Integer.parseInt(request.getParameter("id"));
                    productDAO.deleteProduct(deleteId);
                    response.sendRedirect(request.getContextPath() + "/product?action=list");
                    break;

                default:
                    response.sendRedirect(request.getContextPath() + "/product?action=list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/product?action=list");
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
            if ("add".equals(action)) {
                Product p = new Product();
                p.setProductName(request.getParameter("productName"));
                p.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
                p.setPrice(Double.parseDouble(request.getParameter("price")));
                p.setQuantity(Integer.parseInt(request.getParameter("quantity")));
                p.setReorderLevel(Integer.parseInt(request.getParameter("reorderLevel")));

                boolean success = productDAO.addProduct(p);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/product?action=list");
                } else {
                    request.setAttribute("error", "Failed to add product.");
                    request.setAttribute("categories", categoryDAO.getAllCategories());
                    request.getRequestDispatcher("/products/add.jsp").forward(request, response);
                }

            } else if ("update".equals(action)) {
                Product p = new Product();
                p.setProductId(Integer.parseInt(request.getParameter("productId")));
                p.setProductName(request.getParameter("productName"));
                p.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
                p.setPrice(Double.parseDouble(request.getParameter("price")));
                p.setQuantity(Integer.parseInt(request.getParameter("quantity")));
                p.setReorderLevel(Integer.parseInt(request.getParameter("reorderLevel")));

                boolean success = productDAO.updateProduct(p);
                response.sendRedirect(request.getContextPath() + "/product?action=list");

            } else {
                response.sendRedirect(request.getContextPath() + "/product?action=list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Operation failed: " + e.getMessage());
            request.setAttribute("categories", categoryDAO.getAllCategories());
            request.getRequestDispatcher("/products/add.jsp").forward(request, response);
        }
    }

    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("user") != null;
    }
}