package DBaccess;

import java.sql.*;
import java.util.*;

public class BookingDAO {

    public List<Map<String, Object>> getAllBookings() throws SQLException {
        String query = "SELECT bd.id AS booking_detail_id, bd.booking_id, bd.service_id, bd.booking_date, " +
                       "bd.quantity, bd.price, bd.total, bd.status, s.name AS service_name, s.description AS service_description " +
                       "FROM booking_details bd JOIN service s ON bd.service_id = s.id";
        List<Map<String, Object>> bookingDetailsList = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement stmt = connection.prepareStatement(query);
             ResultSet resultSet = stmt.executeQuery()) {

            while (resultSet.next()) {
                Map<String, Object> booking = new HashMap<>();
                booking.put("bookingId", resultSet.getInt("booking_id"));
                booking.put("serviceName", resultSet.getString("service_name"));
                booking.put("bookingDate", resultSet.getTimestamp("booking_date"));
                booking.put("quantity", resultSet.getInt("quantity"));
                booking.put("price", resultSet.getDouble("price"));
                booking.put("total", resultSet.getDouble("total"));
                booking.put("status", resultSet.getString("status"));
                bookingDetailsList.add(booking);
            }
        }
        return bookingDetailsList;
    }

    public List<Map<String, Object>> getFilteredBookings(String filterType, String... params) throws SQLException {
        String query = "SELECT bd.id AS booking_detail_id, bd.booking_id, bd.service_id, bd.booking_date, " +
                       "bd.quantity, bd.price, bd.total, bd.status, s.name AS service_name, s.description AS service_description " +
                       "FROM booking_details bd JOIN service s ON bd.service_id = s.id ";
        List<Map<String, Object>> bookingDetailsList = new ArrayList<>();

        boolean hasFilter = false;
        switch (filterType) {
            case "specificDate":
                query += "WHERE DATE(bd.booking_date) = CAST(? AS DATE)";
                hasFilter = true;
                break;
            case "dateRange":
                query += "WHERE DATE(bd.booking_date) BETWEEN CAST(? AS DATE) AND CAST(? AS DATE)";
                hasFilter = true;
                break;
            case "month":
                query += "WHERE EXTRACT(MONTH FROM bd.booking_date) = ?";
                hasFilter = true;
                break;
            case "status":
                query += "WHERE bd.status = ?";
                hasFilter = true;
                break;
            default:
                throw new IllegalArgumentException("Invalid filter type");
        }

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement stmt = connection.prepareStatement(query)) {

            if (hasFilter) {
                for (int i = 0; i < params.length; i++) {
                    // Use setInt for numeric values like month
                    if (filterType.equals("month")) {
                        stmt.setInt(i + 1, Integer.parseInt(params[i]));
                    } else {
                        stmt.setString(i + 1, params[i]);
                    }
                }
            }

            try (ResultSet resultSet = stmt.executeQuery()) {
                while (resultSet.next()) {
                    Map<String, Object> booking = new HashMap<>();
                    booking.put("bookingId", resultSet.getInt("booking_id"));
                    booking.put("serviceName", resultSet.getString("service_name"));
                    booking.put("bookingDate", resultSet.getTimestamp("booking_date"));
                    booking.put("quantity", resultSet.getInt("quantity"));
                    booking.put("price", resultSet.getDouble("price"));
                    booking.put("total", resultSet.getDouble("total"));
                    booking.put("status", resultSet.getString("status"));
                    bookingDetailsList.add(booking);
                }
            }
        }
        return bookingDetailsList;
    }
}
