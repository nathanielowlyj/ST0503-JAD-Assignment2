package Servlets;

import DBaccess.BookingDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/FilterBookingsServlet")
public class FilterBookingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String filterType = request.getParameter("filterType");
        BookingDAO bookingDAO = new BookingDAO();

        try {
            List<Map<String, Object>> bookingDetailsList;

            if (filterType == null || "none".equals(filterType)) {
                // No filter: Retrieve all records
                bookingDetailsList = bookingDAO.getAllBookings();
            } else {
                switch (filterType) {
                    case "specificDate":
                        String date = request.getParameter("date");
                        if (date == null || date.isEmpty()) {
                            throw new IllegalArgumentException("Specific date is required.");
                        }
                        bookingDetailsList = bookingDAO.getFilteredBookings("specificDate", date);
                        break;
                    case "dateRange":
                        String startDate = request.getParameter("startDate");
                        String endDate = request.getParameter("endDate");
                        if ((startDate == null || startDate.isEmpty()) || (endDate == null || endDate.isEmpty())) {
                            throw new IllegalArgumentException("Both start and end dates are required.");
                        }
                        bookingDetailsList = bookingDAO.getFilteredBookings("dateRange", startDate, endDate);
                        break;
                    case "month":
                        int month = Integer.parseInt(request.getParameter("month"));
                        bookingDetailsList = bookingDAO.getFilteredBookings("month", String.valueOf(month));
                        break;
                    default:
                        throw new IllegalArgumentException("Invalid filter type");
                }
            }

            // Set attributes for the JSP
            request.setAttribute("bookingDetails", bookingDetailsList);
            request.setAttribute("filterType", filterType); // Persist the filter type in the dropdown
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            request.setAttribute("error", "Error fetching filtered bookings: " + e.getMessage());
        }

        // Forward to the JSP
        request.getRequestDispatcher("/admin/adminBookingReports.jsp").forward(request, response);
    }
}
