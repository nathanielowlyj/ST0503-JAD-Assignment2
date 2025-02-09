package Servlets;

import DBaccess.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/GetCustomersByAreaServlet")
public class GetCustomersByAreaServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String areaCodeStr = request.getParameter("areaCode");

        if (areaCodeStr == null || areaCodeStr.trim().isEmpty()) {
            response.getWriter().write("{\"error\":\"Area code is required.\"}");
            return;
        }

        try {
            int areaCode = Integer.parseInt(areaCodeStr.trim());
            CustomerDAO dao = new CustomerDAO();
            List<Map<String, Object>> customersByArea = dao.getCustomersByAreaCode(areaCode);

            if (customersByArea.isEmpty()) {
                response.getWriter().write("{\"message\":\"No customers found for this area code.\"}");
            } else {
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < customersByArea.size(); i++) {
                    Map<String, Object> customer = customersByArea.get(i);
                    json.append("{")
                        .append("\"id\":").append(customer.get("id")).append(",")
                        .append("\"name\":\"").append(customer.get("name")).append("\",")
                        .append("\"email\":\"").append(customer.get("email")).append("\",")
                        .append("\"postalCode\":\"").append(customer.get("postal_code")).append("\"")
                        .append("}");
                    if (i < customersByArea.size() - 1) {
                        json.append(",");
                    }
                }
                json.append("]");
                response.getWriter().write(json.toString());
            }
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"error\":\"Invalid Area Code format. Please enter a valid number.\"}");
        } catch (Exception e) {
            response.getWriter().write("{\"error\":\"Error retrieving customers: " + e.getMessage() + "\"}");
        }
    }
}
