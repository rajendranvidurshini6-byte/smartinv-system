package dao;

import model.User;
import util.DBConnection;
import util.PasswordUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    /* ============================================================
       VALIDATE LOGIN
       ============================================================ */
  public User validateUser(String username, String plainPassword) {
    User user = null;

    String sql = "SELECT user_id, username, password, full_name, role, created_at " +
                 "FROM users WHERE username = ?";

    System.out.println("[UserDAO] Querying user: [" + username + "]");

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, username);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String storedPassword = rs.getString("password");
                System.out.println("[UserDAO] User FOUND");
                System.out.println("[UserDAO]   Stored:   [" + storedPassword + "]");
                System.out.println("[UserDAO]   Provided: [" + plainPassword + "]");

                boolean valid = PasswordUtil.verifyPassword(plainPassword, storedPassword);
                System.out.println("[UserDAO]   Match: " + valid);

                if (valid) {
                    user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setPassword(storedPassword);
                    user.setFullName(rs.getString("full_name"));
                    user.setRole(rs.getString("role"));
                    user.setCreatedAt(rs.getString("created_at"));
                }
            } else {
                System.out.println("[UserDAO] ✘ No user with username: [" + username + "]");
            }
        }
    } catch (SQLException e) {
        System.out.println("[UserDAO] ✘ SQLException:");
        e.printStackTrace();
        // Re-throw so LoginServlet can show the real error
        throw new RuntimeException("Database error: " + e.getMessage(), e);
    }
    return user;
}
    /* ============================================================
       GET USER BY ID
       ============================================================ */
    public User getUserById(int userId) {
        User user = null;
        String sql = "SELECT user_id, username, full_name, role, created_at " +
                     "FROM users WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    user = mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

    /* ============================================================
       GET ALL USERS
       ============================================================ */
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT user_id, username, full_name, role, created_at " +
                     "FROM users ORDER BY user_id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ============================================================
       ADD USER (password is hashed)
       ============================================================ */
    public boolean addUser(User user) {
        String sql = "INSERT INTO users (username, password, full_name, role) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, PasswordUtil.hashPassword(user.getPassword()));
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getRole());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ============================================================
       UPDATE USER (username, fullName, role — password optional)
       ============================================================ */
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET username = ?, full_name = ?, role = ? WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getRole());
            ps.setInt(4, user.getUserId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ============================================================
       UPDATE PASSWORD
       ============================================================ */
    public boolean updatePassword(int userId, String newPlainPassword) {
        String sql = "UPDATE users SET password = ? WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, PasswordUtil.hashPassword(newPlainPassword));
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ============================================================
       DELETE USER
       ============================================================ */
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ============================================================
       CHECK IF USERNAME EXISTS
       ============================================================ */
    public boolean usernameExists(String username) {
        String sql = "SELECT 1 FROM users WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ============================================================
       MAP ROW → User
       ============================================================ */
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setFullName(rs.getString("full_name"));
        u.setRole(rs.getString("role"));
        u.setCreatedAt(rs.getString("created_at"));
        return u;
    }
}