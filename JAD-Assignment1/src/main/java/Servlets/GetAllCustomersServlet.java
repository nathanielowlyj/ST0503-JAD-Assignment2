package Servlets;

import DBaccess.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/ManageCustomers")
public class GetAllCustomersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            CustomerDAO dao = new CustomerDAO();
            List<Map<String, Object>> customers = dao.getAllCustomers(0, Integer.MAX_VALUE);

            StringBuilder json = new StringBuilder();
            json.append("[");

            for (int i = 0; i < customers.size(); i++) {
                Map<String, Object> customer = customers.get(i);

                json.append("{");

                json.append("\"id\":").append(customer.get("id")).append(",");
                json.append("\"name\":\"").append(escapeJsonString(customer.get("name"))).append("\","); // Escape name
                json.append("\"email\":\"").append(escapeJsonString(customer.get("email"))).append("\","); // Escape email
                json.append("\"postalCode\":\"").append(escapeJsonString(customer.get("postal_code"))).append("\","); // Escape postal code
                json.append("\"accountCreationDate\":\"").append(customer.get("account_creation_date")).append("\",");
                json.append("\"lastLogin\":\"").append(customer.get("last_login") != null ? customer.get("last_login") : "Never").append("\"");

                json.append("}");

                if (i < customers.size() - 1) {
                    json.append(",");
                }
            }

            json.append("]");
            response.getWriter().write(json.toString());

        } catch (Exception e) {
            response.getWriter().write("{\"error\":\"Error retrieving customers: " + e.getMessage() + "\"}");
            e.printStackTrace(); // Important for debugging
        }
    }

    // Helper function to escape JSON strings
    private String escapeJsonString(Object obj) {
        if (obj == null) return ""; // Handle null values
        String str = obj.toString();
        return str.replace("\\", "\\\\") // Escape backslashes
                  .replace("\"", "\\\""); // Escape double quotes
    }
}