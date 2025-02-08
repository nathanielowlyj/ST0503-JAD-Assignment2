package DBaccess;

import java.sql.*;

public class CategoryServiceDAO {

    // Add a new category
    public void addCategory(String name, String description, String imagePath) throws SQLException {
        String sql = "INSERT INTO service_category (name, description, img_path) VALUES (?, ?, ?)";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, name);
            pstmt.setString(2, description);
            pstmt.setString(3, imagePath);
            pstmt.executeUpdate();
        }
    }

    // Add a new service
    public int addService(String name, String description, double price, int categoryId) throws SQLException {
        String sql = "INSERT INTO service (name, description, price, category_id) VALUES (?, ?, ?, ?) RETURNING id";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, name);
            pstmt.setString(2, description);
            pstmt.setDouble(3, price);
            pstmt.setInt(4, categoryId);
            try (ResultSet resultSet = pstmt.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt("id");
                }
            }
        }
        throw new SQLException("Failed to add service.");
    }

    // Update an existing category
    public void updateCategory(int id, String name, String description, String imagePath) throws SQLException {
        String sql;
        if (imagePath != null && !imagePath.isEmpty()) {
            sql = "UPDATE service_category SET name = ?, description = ?, img_path = ? WHERE id = ?";
        } else {
            sql = "UPDATE service_category SET name = ?, description = ? WHERE id = ?";
        }
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, name);
            pstmt.setString(2, description);
            if (imagePath != null && !imagePath.isEmpty()) {
                pstmt.setString(3, imagePath);
                pstmt.setInt(4, id);
            } else {
                pstmt.setInt(3, id);
            }
            pstmt.executeUpdate();
        }
    }

    // Update an existing service
    public void updateService(int id, String name, String description, Double price, Integer categoryId, String imagePath) throws SQLException {
        StringBuilder queryBuilder = new StringBuilder("UPDATE service SET ");
        boolean hasPreviousField = false;

        if (name != null && !name.trim().isEmpty()) {
            queryBuilder.append("name = ?");
            hasPreviousField = true;
        }
        if (description != null && !description.trim().isEmpty()) {
            if (hasPreviousField) queryBuilder.append(", ");
            queryBuilder.append("description = ?");
            hasPreviousField = true;
        }
        if (price != null) {
            if (hasPreviousField) queryBuilder.append(", ");
            queryBuilder.append("price = ?");
            hasPreviousField = true;
        }
        if (categoryId != null) {
            if (hasPreviousField) queryBuilder.append(", ");
            queryBuilder.append("category_id = ?");
            hasPreviousField = true;
        }
        if (imagePath != null && !imagePath.isEmpty()) {
            if (hasPreviousField) queryBuilder.append(", ");
            queryBuilder.append("img_path = ?");
        }
        queryBuilder.append(" WHERE id = ?");

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement pstmt = connection.prepareStatement(queryBuilder.toString())) {
            int paramIndex = 1;

            if (name != null && !name.trim().isEmpty()) {
                pstmt.setString(paramIndex++, name.trim());
            }
            if (description != null && !description.trim().isEmpty()) {
                pstmt.setString(paramIndex++, description.trim());
            }
            if (price != null) {
                pstmt.setDouble(paramIndex++, price);
            }
            if (categoryId != null) {
                pstmt.setInt(paramIndex++, categoryId);
            }
            if (imagePath != null && !imagePath.isEmpty()) {
                pstmt.setString(paramIndex++, imagePath);
            }
            pstmt.setInt(paramIndex, id);
            pstmt.executeUpdate();
        }
    }
    
 // Update the image path for a service in the database
    public void updateServiceImagePath(int serviceId, String imagePath) throws SQLException {
        String query = "UPDATE service SET img_path = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setString(1, imagePath);
            pstmt.setInt(2, serviceId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new SQLException("Error updating image path for service ID: " + serviceId, e);
        }
    }

}
