package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordUtil {

    /* ============================================================
       HASH PASSWORD with SHA-256
       ============================================================ */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null) return null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plainPassword.getBytes("UTF-8"));
            return bytesToHex(hash);
        } catch (NoSuchAlgorithmException | java.io.UnsupportedEncodingException e) {
            e.printStackTrace();
            return null;
        }
    }

    /* ============================================================
       VERIFY PASSWORD (also allows plaintext for first-time setup)
       ============================================================ */
    public static boolean verifyPassword(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) return false;

        // If the stored password is plain (during initial setup), allow direct match
        if (plainPassword.equals(storedPassword)) return true;

        // Otherwise compare with hashed version
        String hashed = hashPassword(plainPassword);
        return hashed != null && hashed.equalsIgnoreCase(storedPassword);
    }

    /* ============================================================
       Helper: convert byte[] → hex string
       ============================================================ */
    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}