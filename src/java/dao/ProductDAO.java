package dao;

import model.Product;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    /* ============================================================
       GET ALL PRODUCTS (with category name via JOIN)
       ============================================================ */
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();

        String sql = "SELECT p.product_id, p.product_name, p.category_id, c.category_name, " +
                     "       p.price, p.quantity, p.reorder_level, p.created_at " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "ORDER BY p.product_id DESC";

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
       GET PRODUCT BY ID
       ============================================================ */
    public Product getProductById(int productId) {
        Product p = null;

        String sql = "SELECT p.product_id, p.product_name, p.category_id, c.category_name, " +
                     "       p.price, p.quantity, p.reorder_level, p.created_at " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "WHERE p.product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    p = mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return p;
    }

    /* ============================================================
       ADD PRODUCT
       ============================================================ */
    public boolean addProduct(Product p) {
        String sql = "INSERT INTO products " +
                     "(product_name, category_id, price, quantity, reorder_level) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, p.getProductName());
            ps.setInt(2, p.getCategoryId());
            ps.setDouble(3, p.getPrice());
            ps.setInt(4, p.getQuantity());
            ps.setInt(5, p.getReorderLevel());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ============================================================
       UPDATE PRODUCT
       ============================================================ */
    public boolean updateProduct(Product p) {
        String sql = "UPDATE products SET product_name = ?, category_id = ?, price = ?, " +
                     "quantity = ?, reorder_level = ? WHERE product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, p.getProductName());
            ps.setInt(2, p.getCategoryId());
            ps.setDouble(3, p.getPrice());
            ps.setInt(4, p.getQuantity());
            ps.setInt(5, p.getReorderLevel());
            ps.setInt(6, p.getProductId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ============================================================
       DELETE PRODUCT
       ============================================================ */
    public boolean deleteProduct(int productId) {
        String sql = "DELETE FROM products WHERE product_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /* ============================================================
       STATS - Total Products
       ============================================================ */
    public int getTotalProductCount() {
        String sql = "SELECT COUNT(*) AS total FROM products";
        return getSingleInt(sql);
    }

    /* ============================================================
       STATS - Total Stock Units
       ============================================================ */
    public int getTotalStockUnits() {
    String sql = "SELECT COALESCE(SUM(quantity), 0) AS total FROM products";
    return getSingleInt(sql);
}

    /* ============================================================
       STATS - Low Stock Count (qty <= reorder_level AND qty > 0)
       ============================================================ */
    public int getLowStockCount() {
        String sql = "SELECT COUNT(*) AS total FROM products " +
                     "WHERE quantity > 0 AND quantity <= reorder_level";
        return getSingleInt(sql);
    }

    /* ============================================================
       STATS - Out of Stock Count
       ============================================================ */
    public int getOutOfStockCount() {
        String sql = "SELECT COUNT(*) AS total FROM products WHERE quantity = 0";
        return getSingleInt(sql);
    }

    /* ============================================================
       LOW STOCK PRODUCTS (for report)
       ============================================================ */
    public List<Product> getLowStockProducts() {
        List<Product> list = new ArrayList<>();

        String sql = "SELECT p.product_id, p.product_name, p.category_id, c.category_name, " +
                     "       p.price, p.quantity, p.reorder_level, p.created_at " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "WHERE p.quantity <= p.reorder_level " +
                     "ORDER BY p.quantity ASC";

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
       SEARCH PRODUCTS BY NAME
       ============================================================ */
    public List<Product> searchProducts(String keyword) {
        List<Product> list = new ArrayList<>();

        String sql = "SELECT p.product_id, p.product_name, p.category_id, c.category_name, " +
                     "       p.price, p.quantity, p.reorder_level, p.created_at " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "WHERE p.product_name LIKE ? " +
                     "ORDER BY p.product_name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ============================================================
       HELPERS
       ============================================================ */
    private int getSingleInt(String sql) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) return rs.getInt(1);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setProductName(rs.getString("product_name"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setCategoryName(rs.getString("category_name"));
        p.setPrice(rs.getDouble("price"));
        p.setQuantity(rs.getInt("quantity"));
        p.setReorderLevel(rs.getInt("reorder_level"));
        p.setCreatedAt(rs.getString("created_at"));
        return p;
    }
}