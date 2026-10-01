package controller;

import dao.UserDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/user")
public class UserServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            switch (action) {

                case "list":
                    List<User> users = userDAO.getAllUsers();
                    request.setAttribute("users", users);
                    request.getRequestDispatcher("/users/list.jsp").forward(request, response);
                    break;

                case "delete":
                    int deleteId = Integer.parseInt(request.getParameter("id"));
                    User current = (User) request.getSession().getAttribute("user");
                    if (current.getUserId() != deleteId) {
                        userDAO.deleteUser(deleteId);
                    }
                    response.sendRedirect(request.getContextPath() + "/user?action=list");
                    break;

                default:
                    response.sendRedirect(request.getContextPath() + "/user?action=list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                User u = new User();
                u.setUsername(request.getParameter("username"));
                u.setPassword(request.getParameter("password"));
                u.setFullName(request.getParameter("fullName"));
                u.setRole(request.getParameter("role"));

                boolean ok = userDAO.addUser(u);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/user?action=list");
                } else {
                    request.setAttribute("error", "Failed to add user.");
                    request.getRequestDispatcher("/users/add.jsp").forward(request, response);
                }

            } else if ("update".equals(action)) {
                User u = new User();
                u.setUserId(Integer.parseInt(request.getParameter("userId")));
                u.setUsername(request.getParameter("username"));
                u.setFullName(request.getParameter("fullName"));
                u.setRole(request.getParameter("role"));

                userDAO.updateUser(u);
                response.sendRedirect(request.getContextPath() + "/user?action=list");

            } else {
                response.sendRedirect(request.getContextPath() + "/user?action=list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/user?action=list");
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && "ADMIN".equals(user.getRole());
    }
}