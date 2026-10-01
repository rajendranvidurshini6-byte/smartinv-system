package model;

public class Report {

    private int productId;
    private String productName;
    private String categoryName;
    private double price;
    private int quantity;
    private double totalValue;
    private int reorderLevel;
    private String status;   // "OK" / "LOW" / "OUT"

    // ---------- Constructors ----------
    public Report() { }

    public Report(int productId, String productName, String categoryName,
                  double price, int quantity, int reorderLevel) {
        this.productId = productId;
        this.productName = productName;
        this.categoryName = categoryName;
        this.price = price;
        this.quantity = quantity;
        this.reorderLevel = reorderLevel;
        this.totalValue = price * quantity;
        this.status = computeStatus(quantity, reorderLevel);
    }

    // ---------- Getters & Setters ----------
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getTotalValue() { return totalValue; }
    public void setTotalValue(double totalValue) { this.totalValue = totalValue; }

    public int getReorderLevel() { return reorderLevel; }
    public void setReorderLevel(int reorderLevel) { this.reorderLevel = reorderLevel; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    // ---------- Helper ----------
    private String computeStatus(int qty, int reorder) {
        if (qty == 0) return "OUT";
        if (qty <= reorder) return "LOW";
        return "OK";
    }

    @Override
    public String toString() {
        return "Report{product='" + productName + "', qty=" + quantity +
               ", value=" + totalValue + ", status='" + status + "'}";
    }
}