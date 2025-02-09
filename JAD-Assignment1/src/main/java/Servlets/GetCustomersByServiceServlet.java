package Servlets;

import DBaccess.CustomerDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/GetCustomersByServiceServlet")
public class GetCustomersByServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String serviceIdStr = request.getParameter("serviceId");

        if (serviceIdStr == null || serviceIdStr.trim().isEmpty()) {
            response.getWriter().write("{\"error\":\"Service ID is required.\"}");
            return;
        }

        try {
            int serviceId = Integer.parseInt(serviceIdStr.trim());
            CustomerDAO dao = new CustomerDAO();
            List<Map<String, Object>> customersByService = dao.getCustomersByService(serviceId);

            if (customersByService.isEmpty()) {
                response.getWriter().write("{\"message\":\"No customers found for this service ID.\"}");
            } else {
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < customersByService.size(); i++) {
                    Map<String, Object> customer = customersByService.get(i);
                    json.append("{")
                        .append("\"id\":").append(customer.get("id")).append(",")
                        .append("\"name\":\"").append(customer.get("name")).append("\",")
                        .append("\"email\":\"").append(customer.get("email")).append("\",")
                        .append("\"service_quantity\":").append(customer.get("service_quantity")).append(",") 
                        .append("\"booking_date\":\"").append(customer.get("booking_date")).append("\",") 
                        .append("\"status\":\"").append(customer.get("status")).append("\"") 
                        .append("}");
                    if (i < customersByService.size() - 1) {
                        json.append(",");
                    }
                }
                json.append("]");
                response.getWriter().write(json.toString());
            }
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"error\":\"Invalid Service ID format. Please enter a valid number.\"}");
        } catch (Exception e) {
            response.getWriter().write("{\"error\":\"Error retrieving customers: " + e.getMessage() + "\"}");
        }
    }
}
