package DBaccess;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class CustomerDAO {
    // Retrieve all customers with pagination
    public List<Map<String, Object>> getAllCustomers(int offset, int pageSize) throws SQLException {
        List<Map<String, Object>> customers = new ArrayList<>();
        String query = "SELECT id, name, email, postal_code, account_creation_date, last_login " +
                       "FROM users WHERE role = 'user' ORDER BY id ASC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setInt(1, pageSize);
            pstmt.setInt(2, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> customer = new HashMap<>();
                    customer.put("id", rs.getInt("id"));
                    customer.put("name", rs.getString("name"));
                    customer.put("email", rs.getString("email"));
                    customer.put("postal_code", rs.getString("postal_code"));
                    customer.put("account_creation_date", rs.getDate("account_creation_date").toString());
                    customer.put("last_login", rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login").toString() : null);
                    customers.add(customer);
                }
            }
        }
        return customers;
    }

    // Retrieve customers by postal code
    public List<Map<String, Object>> getCustomersByAreaCode(int postalCode) throws SQLException {
        List<Map<String, Object>> customers = new ArrayList<>();
        String query = "SELECT id, name, email, postal_code, account_creation_date, last_login " +
                       "FROM users WHERE role = 'user' AND postal_code = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, postalCode);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> customer = new HashMap<>();
                customer.put("id", rs.getInt("id"));
                customer.put("name", rs.getString("name"));
                customer.put("email", rs.getString("email"));
                customer.put("postal_code", rs.getString("postal_code"));
                customer.put("account_creation_date", rs.getDate("account_creation_date").toString());
                customer.put("last_login", rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login").toString() : null);
                customers.add(customer);
            }
        }
        return customers;
    }

    // Retrieve top 10 customers by booking value
    public List<Map<String, Object>> getTop10CustomersByValue() throws SQLException {
        List<Map<String, Object>> customers = new ArrayList<>();
        String query = "SELECT u.id, u.name, u.email, u.postal_code, SUM(bd.totalwithgst) AS totalspent " +
                       "FROM users u " +
                       "JOIN booking_list bl ON u.id = bl.user_id " +
                       "JOIN booking_details bd ON bl.id = bd.booking_id " +
                       "WHERE u.role = 'user' " +
                       "GROUP BY u.id, u.name, u.email, u.postal_code " +
                       "ORDER BY totalspent DESC LIMIT 10";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> customer = new HashMap<>();
                customer.put("id", rs.getInt("id"));
                customer.put("name", rs.getString("name"));
                customer.put("email", rs.getString("email"));
                customer.put("postal_code", rs.getString("postal_code"));
                customer.put("totalSpent", rs.getDouble("totalspent"));
                customers.add(customer);
            }
        }
        return customers;
    }

    public List<Map<String, Object>> getCustomersByService(int serviceId) throws SQLException {
        List<Map<String, Object>> customers = new ArrayList<>();
        String query = "SELECT DISTINCT u.id, u.name, u.email, u.postal_code, " +
                       "bd.quantity AS service_quantity, bd.booking_date, bd.status " +
                       "FROM users u " +
                       "JOIN booking_list bl ON u.id = bl.user_id " +
                       "JOIN booking_details bd ON bl.id = bd.booking_id " +
                       "WHERE bd.service_id = ? AND u.role = 'user'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, serviceId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> customer = new HashMap<>();
                customer.put("id", rs.getInt("id"));
                customer.put("name", rs.getString("name"));
                customer.put("email", rs.getString("email"));
                customer.put("postal_code", rs.getString("postal_code"));
                customer.put("service_quantity", rs.getInt("service_quantity"));
                customer.put("booking_date", rs.getTimestamp("booking_date").toString());
                customer.put("status", rs.getString("status"));
                customers.add(customer);
            }
        }
        return customers;
    }
    
    public int getTotalCustomersCount() throws SQLException {
        int totalCustomers = 0;
        String query = "SELECT COUNT(*) AS total FROM users WHERE role = 'user'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                totalCustomers = rs.getInt("total");
            }
        }
        return totalCustomers;
    }
}
