package Servlets;

import DBaccess.CustomerDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/GetTopCustomersServlet")
public class GetTopCustomersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            CustomerDAO dao = new CustomerDAO();
            List<Map<String, Object>> topCustomers = dao.getTop10CustomersByValue();

            StringBuilder json = new StringBuilder();
            json.append("[");
            for (int i = 0; i < topCustomers.size(); i++) {
                Map<String, Object> customer = topCustomers.get(i);
                json.append("{")
                    .append("\"id\":").append(customer.get("id")).append(",")
                    .append("\"name\":\"").append(customer.get("name")).append("\",")
                    .append("\"email\":\"").append(customer.get("email")).append("\",")
                    .append("\"totalSpent\":").append(customer.get("totalSpent"))
                    .append("}");
                if (i < topCustomers.size() - 1) json.append(",");
            }
            json.append("]");
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            response.getWriter().write("{\"error\":\"Error retrieving top customers: " + e.getMessage() + "\"}");
        }
    }
}
