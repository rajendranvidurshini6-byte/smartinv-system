package model;

public class Stock {

    private int transactionId;
    private int productId;
    private String productName;       // joined field (from products table)
    private String transactionType;   // "IN" or "OUT"
    private int quantity;
    private String transactionDate;
    private int userId;
    private String username;          // joined field (from users table)
    private String remarks;

    // ============================================================
    //  CONSTRUCTORS
    // ============================================================

    public Stock() { }

    // For inserting a new transaction (Stock In / Stock Out)
    public Stock(int productId, String transactionType, int quantity, int userId, String remarks) {
        this.productId = productId;
        this.transactionType = transactionType;
        this.quantity = quantity;
        this.userId = userId;
        this.remarks = remarks;
    }

    // Full constructor (for reading from DB with JOINs)
    public Stock(int transactionId, int productId, String productName, String transactionType,
                 int quantity, String transactionDate, int userId, String username, String remarks) {
        this.transactionId = transactionId;
        this.productId = productId;
        this.productName = productName;
        this.transactionType = transactionType;
        this.quantity = quantity;
        this.transactionDate = transactionDate;
        this.userId = userId;
        this.username = username;
        this.remarks = remarks;
    }

    // ============================================================
    //  GETTERS & SETTERS
    // ============================================================

    public int getTransactionId() {
        return transactionId;
    }
    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getProductId() {
        return productId;
    }
    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }
    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getTransactionType() {
        return transactionType;
    }
    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public int getQuantity() {
        return quantity;
    }
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getTransactionDate() {
        return transactionDate;
    }
    public void setTransactionDate(String transactionDate) {
        this.transactionDate = transactionDate;
    }

    public int getUserId() {
        return userId;
    }
    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }

    public String getRemarks() {
        return remarks;
    }
    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    // ============================================================
    //  HELPER METHODS
    // ============================================================

    // Returns "IN" / "OUT" as a display label
    public String getTypeLabel() {
        if ("IN".equalsIgnoreCase(transactionType)) return "Stock In";
        if ("OUT".equalsIgnoreCase(transactionType)) return "Stock Out";
        return transactionType;
    }

    // Returns CSS class for badge (used in JSP)
    public String getBadgeClass() {
        return "IN".equalsIgnoreCase(transactionType) ? "badge-in" : "badge-out";
    }

    // ============================================================
    //  toString
    // ============================================================

    @Override
    public String toString() {
        return "Stock{" +
                "transactionId=" + transactionId +
                ", productId=" + productId +
                ", productName='" + productName + '\'' +
                ", transactionType='" + transactionType + '\'' +
                ", quantity=" + quantity +
                ", transactionDate='" + transactionDate + '\'' +
                ", userId=" + userId +
                ", username='" + username + '\'' +
                ", remarks='" + remarks + '\'' +
                '}';
    }
}