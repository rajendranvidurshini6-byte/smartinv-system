package model;

public class Product {

    private int productId;
    private String productName;
    private int categoryId;
    private String categoryName;   // joined field for display
    private double price;
    private int quantity;
    private int reorderLevel;
    private String createdAt;

    // ---------- Constructors ----------
    public Product() { }

    public Product(String productName, int categoryId, double price, int quantity, int reorderLevel) {
        this.productName = productName;
        this.categoryId = categoryId;
        this.price = price;
        this.quantity = quantity;
        this.reorderLevel = reorderLevel;
    }

    public Product(int productId, String productName, int categoryId, String categoryName,
                   double price, int quantity, int reorderLevel) {
        this.productId = productId;
        this.productName = productName;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.price = price;
        this.quantity = quantity;
        this.reorderLevel = reorderLevel;
    }

    // ---------- Getters & Setters ----------
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public int getReorderLevel() { return reorderLevel; }
    public void setReorderLevel(int reorderLevel) { this.reorderLevel = reorderLevel; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    // ---------- Helper ----------
    public double getTotalValue() {
        return price * quantity;
    }

    public String getStockStatus() {
        if (quantity == 0) return "OUT";
        if (quantity <= reorderLevel) return "LOW";
        return "OK";
    }

    @Override
    public String toString() {
        return "Product{id=" + productId + ", name='" + productName +
               "', qty=" + quantity + ", price=" + price + "}";
    }
}