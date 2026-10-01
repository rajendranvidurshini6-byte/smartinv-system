package util;

import java.util.regex.Pattern;

public class ValidationUtil {

    // ============================================================
    //  REGEX PATTERNS
    // ============================================================
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    private static final Pattern USERNAME_PATTERN =
            Pattern.compile("^[A-Za-z0-9_]{3,30}$");

    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^[0-9+\\-\\s()]{7,20}$");

    // ============================================================
    //  NULL / EMPTY CHECKS
    // ============================================================
    public static boolean isNullOrEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    public static boolean isNotNullOrEmpty(String value) {
        return !isNullOrEmpty(value);
    }

    public static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    // ============================================================
    //  NUMBER CHECKS
    // ============================================================
    public static boolean isPositiveInt(String value) {
        if (isNullOrEmpty(value)) return false;
        try {
            return Integer.parseInt(value.trim()) > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public static boolean isNonNegativeInt(String value) {
        if (isNullOrEmpty(value)) return false;
        try {
            return Integer.parseInt(value.trim()) >= 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public static boolean isPositiveDouble(String value) {
        if (isNullOrEmpty(value)) return false;
        try {
            return Double.parseDouble(value.trim()) > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    // ============================================================
    //  STRING LENGTH
    // ============================================================
    public static boolean hasMinLength(String value, int min) {
        return value != null && value.trim().length() >= min;
    }

    public static boolean hasMaxLength(String value, int max) {
        return value == null || value.trim().length() <= max;
    }

    public static boolean isLengthBetween(String value, int min, int max) {
        if (value == null) return false;
        int len = value.trim().length();
        return len >= min && len <= max;
    }

    // ============================================================
    //  USERNAME / PASSWORD
    // ============================================================
    public static boolean isValidUsername(String username) {
        return username != null && USERNAME_PATTERN.matcher(username.trim()).matches();
    }

    public static boolean isValidPassword(String password) {
        // At least 6 characters
        return password != null && password.length() >= 6;
    }

    public static boolean isValidPasswordStrength(String password) {
        // At least 8 chars, 1 uppercase, 1 lowercase, 1 digit
        if (password == null || password.length() < 8) return false;
        boolean hasUpper = false, hasLower = false, hasDigit = false;
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpper = true;
            else if (Character.isLowerCase(c)) hasLower = true;
            else if (Character.isDigit(c))     hasDigit = true;
        }
        return hasUpper && hasLower && hasDigit;
    }

    // ============================================================
    //  EMAIL / PHONE
    // ============================================================
    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidPhone(String phone) {
        return phone != null && PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    // ============================================================
    //  PRODUCT-SPECIFIC VALIDATION (used in ProductServlet)
    // ============================================================
    public static boolean isValidProductName(String name) {
        return isNotNullOrEmpty(name) && hasMaxLength(name, 150);
    }

    public static boolean isValidPrice(String price) {
        return isPositiveDouble(price);
    }

    public static boolean isValidQuantity(String qty) {
        return isNonNegativeInt(qty);
    }

    public static boolean isValidReorderLevel(String level) {
        return isPositiveInt(level);
    }

    // ============================================================
    //  XSS PREVENTION — escape HTML special characters
    // ============================================================
    public static String escapeHtml(String input) {
        if (input == null) return "";
        return input
                .replace("&",  "&amp;")
                .replace("<",  "&lt;")
                .replace(">",  "&gt;")
                .replace("\"", "&quot;")
                .replace("'",  "&#39;");
    }

    // ============================================================
    //  TRIM SAFELY (returns "" instead of null)
    // ============================================================
    public static String safeTrim(String value) {
        return value == null ? "" : value.trim();
    }
}