package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // ============================================================
    //  POSTGRESQL CONFIGURATION
    // ============================================================
    private static final String URL      = "jdbc:postgresql://localhost:5432/smartinv_db";
    private static final String USERNAME = "postgres";
    private static final String PASSWORD = "postgres";   // ← FIXED

    static {
        try {
            Class.forName("org.postgresql.Driver");
            System.out.println("✔ PostgreSQL JDBC Driver loaded.");
        } catch (ClassNotFoundException e) {
            System.err.println("✘ PostgreSQL JDBC Driver NOT FOUND!");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("✔ Connected to smartinv_db (PostgreSQL) successfully!");
                System.out.println("  DB: " + conn.getCatalog());

                // Test the users table
                java.sql.Statement st = conn.createStatement();
                java.sql.ResultSet rs = st.executeQuery("SELECT username, password FROM users");
                while (rs.next()) {
                    System.out.println("  User: " + rs.getString("username")
                                     + " / " + rs.getString("password"));
                }
            }
        } catch (SQLException e) {
            System.err.println("✘ Connection FAILED.");
            e.printStackTrace();
        }
    }
}