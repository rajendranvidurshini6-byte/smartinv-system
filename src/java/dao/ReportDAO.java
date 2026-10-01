package dao;

import model.Report;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO {

    /* ============================================================
       FULL STOCK REPORT (all products + computed total value)
       ============================================================ */
    public List<Report> getStockReport() {
        List<Report> list = new ArrayList<>();

        String sql = "SELECT p.product_id, p.product_name, c.category_name, " +
                     "       p.price, p.quantity, p.reorder_level " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "ORDER BY p.product_name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Report r = new Report(
                        rs.getInt("product_id"),
                        rs.getString("product_name"),
                        rs.getString("category_name"),
                        rs.getDouble("price"),
                        rs.getInt("quantity"),
                        rs.getInt("reorder_level")
                );
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ============================================================
       LOW STOCK REPORT
       ============================================================ */
    public List<Report> getLowStockReport() {
        List<Report> list = new ArrayList<>();

        String sql = "SELECT p.product_id, p.product_name, c.category_name, " +
                     "       p.price, p.quantity, p.reorder_level " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "WHERE p.quantity <= p.reorder_level " +
                     "ORDER BY p.quantity ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Report r = new Report(
                        rs.getInt("product_id"),
                        rs.getString("product_name"),
                        rs.getString("category_name"),
                        rs.getDouble("price"),
                        rs.getInt("quantity"),
                        rs.getInt("reorder_level")
                );
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ============================================================
       TOTAL INVENTORY VALUE (sum of price * quantity)
       ============================================================ */
    public double getTotalInventoryValue() {
        String sql = "SELECT IFNULL(SUM(price * quantity), 0) AS total FROM products";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getDouble("total");

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    /* ============================================================
       REPORT BY DATE RANGE (using stock_transactions)
       ============================================================ */
    public List<Report> getTransactionSummary(String fromDate, String toDate) {
        List<Report> list = new ArrayList<>();

        String sql = "SELECT p.product_id, p.product_name, c.category_name, " +
                     "       p.price, " +
                     "       SUM(CASE WHEN st.transaction_type='IN'  THEN st.quantity ELSE 0 END) AS qty_in, " +
                     "       SUM(CASE WHEN st.transaction_type='OUT' THEN st.quantity ELSE 0 END) AS qty_out " +
                     "FROM stock_transactions st " +
                     "JOIN products p ON st.product_id = p.product_id " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "WHERE DATE(st.transaction_date) BETWEEN ? AND ? " +
                     "GROUP BY p.product_id, p.product_name, c.category_name, p.price " +
                     "ORDER BY p.product_name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fromDate);
            ps.setString(2, toDate);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int qtyIn  = rs.getInt("qty_in");
                    int qtyOut = rs.getInt("qty_out");

                    Report r = new Report(
                            rs.getInt("product_id"),
                            rs.getString("product_name"),
                            rs.getString("category_name"),
                            rs.getDouble("price"),
                            qtyIn - qtyOut,   // net quantity
                            0
                    );
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}