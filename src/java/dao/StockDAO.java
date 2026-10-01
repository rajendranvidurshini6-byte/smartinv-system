package dao;

import model.Stock;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StockDAO {

    /* ============================================================
       RECORD STOCK IN  → increases product quantity + logs transaction
       ============================================================ */
    public boolean recordStockIn(int productId, int quantity, int userId, String remarks) {
        Connection conn = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psInsert = null;

        String updateSql = "UPDATE products SET quantity = quantity + ? WHERE product_id = ?";
        String insertSql = "INSERT INTO stock_transactions " +
                           "(product_id, transaction_type, quantity, user_id, remarks) " +
                           "VALUES (?, 'IN', ?, ?, ?)";

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);   // begin transaction

            // 1. Update product quantity
            psUpdate = conn.prepareStatement(updateSql);
            psUpdate.setInt(1, quantity);
            psUpdate.setInt(2, productId);
            int rowsUpdated = psUpdate.executeUpdate();

            if (rowsUpdated == 0) {
                conn.rollback();
                return false;
            }

            // 2. Insert stock transaction record
            psInsert = conn.prepareStatement(insertSql);
            psInsert.setInt(1, productId);
            psInsert.setInt(2, quantity);
            psInsert.setInt(3, userId);
            psInsert.setString(4, remarks);
            psInsert.executeUpdate();

            conn.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;
        } finally {
            closeQuietly(psUpdate);
            closeQuietly(psInsert);
            closeQuietly(conn);
        }
    }

    /* ============================================================
       RECORD STOCK OUT → decreases product quantity + logs transaction
       (Fails if stock is insufficient)
       ============================================================ */
    public boolean recordStockOut(int productId, int quantity, int userId, String remarks) {
        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psInsert = null;
        ResultSet rs = null;

        String checkSql  = "SELECT quantity FROM products WHERE product_id = ?";
        String updateSql = "UPDATE products SET quantity = quantity - ? WHERE product_id = ? AND quantity >= ?";
        String insertSql = "INSERT INTO stock_transactions " +
                           "(product_id, transaction_type, quantity, user_id, remarks) " +
                           "VALUES (?, 'OUT', ?, ?, ?)";

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Check current stock
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, productId);
            rs = psCheck.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return false;
            }
            int availableQty = rs.getInt("quantity");
            if (availableQty < quantity) {
                conn.rollback();
                return false;   // insufficient stock
            }

            // 2. Deduct quantity
            psUpdate = conn.prepareStatement(updateSql);
            psUpdate.setInt(1, quantity);
            psUpdate.setInt(2, productId);
            psUpdate.setInt(3, quantity);
            int rowsUpdated = psUpdate.executeUpdate();

            if (rowsUpdated == 0) {
                conn.rollback();
                return false;
            }

            // 3. Log transaction
            psInsert = conn.prepareStatement(insertSql);
            psInsert.setInt(1, productId);
            psInsert.setInt(2, quantity);
            psInsert.setInt(3, userId);
            psInsert.setString(4, remarks);
            psInsert.executeUpdate();

            conn.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;
        } finally {
            closeQuietly(rs);
            closeQuietly(psCheck);
            closeQuietly(psUpdate);
            closeQuietly(psInsert);
            closeQuietly(conn);
        }
    }

    /* ============================================================
       GET ALL TRANSACTIONS (with product name + username via JOIN)
       ============================================================ */
    public List<Stock> getAllTransactions() {
        List<Stock> list = new ArrayList<>();

        String sql = "SELECT st.transaction_id, st.product_id, p.product_name, " +
                     "       st.transaction_type, st.quantity, st.transaction_date, " +
                     "       st.user_id, u.username, st.remarks " +
                     "FROM stock_transactions st " +
                     "JOIN products p ON st.product_id = p.product_id " +
                     "LEFT JOIN users u ON st.user_id = u.user_id " +
                     "ORDER BY st.transaction_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Stock s = new Stock();
                s.setTransactionId(rs.getInt("transaction_id"));
                s.setProductId(rs.getInt("product_id"));
                s.setProductName(rs.getString("product_name"));
                s.setTransactionType(rs.getString("transaction_type"));
                s.setQuantity(rs.getInt("quantity"));
                s.setTransactionDate(rs.getString("transaction_date"));
                s.setUserId(rs.getInt("user_id"));
                s.setUsername(rs.getString("username"));
                s.setRemarks(rs.getString("remarks"));
                list.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ============================================================
       GET TRANSACTIONS BY PRODUCT (optional filter)
       ============================================================ */
    public List<Stock> getTransactionsByProduct(int productId) {
        List<Stock> list = new ArrayList<>();

        String sql = "SELECT st.transaction_id, st.product_id, p.product_name, " +
                     "       st.transaction_type, st.quantity, st.transaction_date, " +
                     "       st.user_id, u.username, st.remarks " +
                     "FROM stock_transactions st " +
                     "JOIN products p ON st.product_id = p.product_id " +
                     "LEFT JOIN users u ON st.user_id = u.user_id " +
                     "WHERE st.product_id = ? " +
                     "ORDER BY st.transaction_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Stock s = new Stock();
                    s.setTransactionId(rs.getInt("transaction_id"));
                    s.setProductId(rs.getInt("product_id"));
                    s.setProductName(rs.getString("product_name"));
                    s.setTransactionType(rs.getString("transaction_type"));
                    s.setQuantity(rs.getInt("quantity"));
                    s.setTransactionDate(rs.getString("transaction_date"));
                    s.setUserId(rs.getInt("user_id"));
                    s.setUsername(rs.getString("username"));
                    s.setRemarks(rs.getString("remarks"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ============================================================
       GET TRANSACTIONS BY TYPE ("IN" / "OUT")
       ============================================================ */
    public List<Stock> getTransactionsByType(String type) {
        List<Stock> list = new ArrayList<>();

        String sql = "SELECT st.transaction_id, st.product_id, p.product_name, " +
                     "       st.transaction_type, st.quantity, st.transaction_date, " +
                     "       st.user_id, u.username, st.remarks " +
                     "FROM stock_transactions st " +
                     "JOIN products p ON st.product_id = p.product_id " +
                     "LEFT JOIN users u ON st.user_id = u.user_id " +
                     "WHERE st.transaction_type = ? " +
                     "ORDER BY st.transaction_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, type);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Stock s = new Stock();
                    s.setTransactionId(rs.getInt("transaction_id"));
                    s.setProductId(rs.getInt("product_id"));
                    s.setProductName(rs.getString("product_name"));
                    s.setTransactionType(rs.getString("transaction_type"));
                    s.setQuantity(rs.getInt("quantity"));
                    s.setTransactionDate(rs.getString("transaction_date"));
                    s.setUserId(rs.getInt("user_id"));
                    s.setUsername(rs.getString("username"));
                    s.setRemarks(rs.getString("remarks"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ============================================================
       HELPER - close resources silently
       ============================================================ */
    private void closeQuietly(AutoCloseable c) {
        if (c != null) {
            try { c.close(); } catch (Exception ignored) { }
        }
    }
}