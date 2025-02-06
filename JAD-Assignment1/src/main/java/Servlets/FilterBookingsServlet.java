package Servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;

@WebServlet("/admin/FilterBookingsServlet")
public class FilterBookingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    private static final String DB_USER = "cleaningServices_owner";
    private static final String DB_PASSWORD = "mh0zgxauP6HJ";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String filterType = request.getParameter("filterType");
        String query = "SELECT bd.id AS booking_detail_id, bd.booking_id, bd.service_id, bd.booking_date, " +
                       "bd.quantity, bd.price, bd.total, s.name AS service_name, s.description AS service_description " +
                       "FROM booking_details bd JOIN service s ON bd.service_id = s.id ";
        boolean hasFilter = false;

        // Default behavior: Retrieve all records if no filter is applied
        if (filterType == null || "none".equals(filterType)) {
            filterType = "none";
        } else {
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
            }
        }

        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement stmt = connection.prepareStatement(query)) {

            if (hasFilter) {
                switch (filterType) {
                    case "specificDate":
                        String date = request.getParameter("date");
                        stmt.setString(1, date);
                        break;
                    case "dateRange":
                        String startDate = request.getParameter("startDate");
                        String endDate = request.getParameter("endDate");
                        stmt.setString(1, startDate);
                        stmt.setString(2, endDate);
                        break;
                    case "month":
                        int month = Integer.parseInt(request.getParameter("month"));
                        stmt.setInt(1, month);
                        break;
                }
            }

            ResultSet resultSet = stmt.executeQuery();
            List<Map<String, Object>> bookingDetailsList = new ArrayList<>();

            while (resultSet.next()) {
                Map<String, Object> booking = new HashMap<>();
                booking.put("bookingId", resultSet.getInt("booking_id"));
                booking.put("serviceName", resultSet.getString("service_name"));
                booking.put("bookingDate", resultSet.getTimestamp("booking_date"));
                booking.put("quantity", resultSet.getInt("quantity"));
                booking.put("price", resultSet.getDouble("price"));
                booking.put("total", resultSet.getDouble("total"));
                bookingDetailsList.add(booking);
            }

            request.setAttribute("bookingDetails", bookingDetailsList);
            request.setAttribute("filterType", filterType); // Persist the filter type in the dropdown
            request.getRequestDispatcher("/admin/adminBookingReports.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error fetching filtered bookings: " + e.getMessage());
            request.getRequestDispatcher("/admin/adminBookingReports.jsp").forward(request, response);
        }
    }
}
