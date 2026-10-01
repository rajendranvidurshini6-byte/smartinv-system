package controller;

import dao.UserDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        System.out.println("[LoginServlet] init() called — creating UserDAO");
        userDAO = new UserDAO();
    }

    /**
     * Lazy getter — ensures userDAO is never null.
     * If init() somehow didn't run, we create it here on first use.
     */
    private UserDAO getUserDAO() {
        if (userDAO == null) {
            System.out.println("[LoginServlet] userDAO was null — creating lazily");
            userDAO = new UserDAO();
        }
        return userDAO;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String selectedRole = request.getParameter("role");

        System.out.println("========== LOGIN ATTEMPT ==========");
        System.out.println("  Username:      " + username);
        System.out.println("  Selected Role: " + selectedRole);

        // ---- Basic validation ----
        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || selectedRole == null || selectedRole.trim().isEmpty()) {

            System.out.println("  ✘ Missing input");
            request.setAttribute("error", "Please select a role and enter credentials.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        username = username.trim();

        try {
            // ✅ Use the lazy getter — NEVER null
            UserDAO dao = getUserDAO();
            User user = dao.validateUser(username, password);

            System.out.println("  validateUser returned: " + user);

            if (user != null) {
                // Role must match the tab the user selected
                if (!selectedRole.equalsIgnoreCase(user.getRole())) {
                    System.out.println("  ✘ Role mismatch. Selected=" + selectedRole
                                     + ", Actual=" + user.getRole());
                    request.setAttribute("error",
                        "This account is not registered as " + selectedRole + ".");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }

                // Success — create session
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("role", user.getRole());
                session.setMaxInactiveInterval(30 * 60);

                System.out.println("  ✔ SUCCESS — redirecting to /dashboard");
                response.sendRedirect(request.getContextPath() + "/dashboard");

            } else {
                System.out.println("  ✘ Invalid credentials");
                request.setAttribute("error", "Invalid username or password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            System.out.println("  ✘ EXCEPTION in LoginServlet:");
            e.printStackTrace();
            request.setAttribute("error", "Login error: " + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }

        System.out.println("====================================");
    }
}