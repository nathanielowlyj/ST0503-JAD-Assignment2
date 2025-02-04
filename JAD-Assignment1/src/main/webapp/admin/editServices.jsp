<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingAdmin.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Update Service</title>
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
            background-color: #4d637a;
        }

        .form-container {
            background-color: white;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
            width: 400px;
        }

        .form-container h1 {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
            text-align: center;
        }

        .form-container label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }

        .form-container select, .form-container input, .form-container textarea, .form-container button {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }

        .form-container button {
            background-color: #007bff;
            color: white;
            font-size: 16px;
            cursor: pointer;
        }

        .form-container button:hover {
            background-color: #0056b3;
        }

        .message {
            font-size: 18px;
            text-align: center;
            margin-top: 15px;
        }
    </style>
</head>
<body>
<%
    boolean isSubmitted = request.getParameter("submit") != null;
    boolean updateSuccess = false;
    String message = "";
    int serviceId = Integer.parseInt(request.getParameter("id"));
    String serviceName = "";
    String serviceDescription = "";
    double servicePrice = 0.0;
    int currentCategoryId = 0;

    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    if (!isSubmitted) {
        try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
             PreparedStatement stmt = connection.prepareStatement("SELECT * FROM service WHERE id = ?")) {
            Class.forName("org.postgresql.Driver");
            stmt.setInt(1, serviceId);
            try (ResultSet resultSet = stmt.executeQuery()) {
                if (resultSet.next()) {
                    serviceName = resultSet.getString("name");
                    serviceDescription = resultSet.getString("description");
                    servicePrice = resultSet.getDouble("price");
                    currentCategoryId = resultSet.getInt("category_id");
                } else {
                    message = "Service not found.";
                }
            }
        } catch (Exception e) {
            application.log("Error fetching service: " + e.getMessage());
            message = "An error occurred while fetching the service.";
        }
    } else {
        serviceName = request.getParameter("name");
        serviceDescription = request.getParameter("description");
        servicePrice = Double.parseDouble(request.getParameter("price"));
        int newCategoryId = Integer.parseInt(request.getParameter("category_id"));

        try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
             PreparedStatement pstmt = connection.prepareStatement(
                "UPDATE service SET name = ?, description = ?, price = ?, category_id = ? WHERE id = ?")) {
            Class.forName("org.postgresql.Driver");
            pstmt.setString(1, serviceName);
            pstmt.setString(2, serviceDescription);
            pstmt.setDouble(3, servicePrice);
            pstmt.setInt(4, newCategoryId);
            pstmt.setInt(5, serviceId);

            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                updateSuccess = true;
                message = "Service updated successfully.";
            } else {
                message = "Failed to update the service. Please try again.";
            }
        } catch (Exception e) {
            application.log("Error updating service: " + e.getMessage());
            message = "An error occurred while updating the service.";
        }
    }
%>

<div class="form-container">
    <% if (!isSubmitted || !updateSuccess) { %>
        <h1>Update Service</h1>
        <% if (!message.isEmpty()) { %>
            <p class="message" style="color: red;"><%= message %></p>
        <% } %>
        <form method="POST">
            <label for="name">Service Name</label>
            <input type="text" id="name" name="name" value="<%= serviceName %>" required>

            <label for="description">Description</label>
            <textarea id="description" name="description" required><%= serviceDescription %></textarea>

            <label for="price">Price</label>
            <input type="number" step="0.01" id="price" name="price" value="<%= servicePrice %>" required>

            <label for="category_id">Category</label>
            <select id="category_id" name="category_id" required>
                <%
                    try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
                         PreparedStatement stmt = connection.prepareStatement("SELECT * FROM service_category");
                         ResultSet categories = stmt.executeQuery()) {
                        while (categories.next()) {
                            int categoryId = categories.getInt("id");
                            String categoryName = categories.getString("name");
                %>
                            <option value="<%= categoryId %>" <%= (categoryId == currentCategoryId ? "selected" : "") %>>
                                <%= categoryName %>
                            </option>
                <%
                        }
                    } catch (Exception e) {
                        application.log("Error fetching categories: " + e.getMessage());
                %>
                    <option value="" disabled>Error loading categories</option>
                <%
                    }
                %>
            </select>

            <input type="hidden" name="id" value="<%= serviceId %>">
            <input type="hidden" name="submit" value="true">
            <button type="submit">Update Service</button>
        </form>
    <% } else { %>
        <p class="message" style="color: green;"><%= message %></p>
        <button onclick="window.location.href='adminServices.jsp';">Back to Services</button>
    <% } %>
</div>

</body>
</html>
