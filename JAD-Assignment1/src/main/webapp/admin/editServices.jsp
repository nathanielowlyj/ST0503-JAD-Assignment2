<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="sessionHandlingAdmin.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
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
    String message = (String) request.getAttribute("message");
    int serviceId = Integer.parseInt(request.getParameter("id"));
    String serviceName = "";
    String serviceDescription = "";
    double servicePrice = 0.0;
    int currentCategoryId = 0;
    String imagePath = "";

    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    // Retrieve service details
    try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
        String serviceSQL = "SELECT * FROM service WHERE id = ?";
        try (PreparedStatement pstmt = connection.prepareStatement(serviceSQL)) {
            pstmt.setInt(1, serviceId);
            try (ResultSet resultSet = pstmt.executeQuery()) {
                if (resultSet.next()) {
                    serviceName = resultSet.getString("name");
                    serviceDescription = resultSet.getString("description");
                    servicePrice = resultSet.getDouble("price");
                    currentCategoryId = resultSet.getInt("category_id");
                    imagePath = resultSet.getString("img_path");
                } else {
                    message = "Service not found.";
                }
            }
        }
    } catch (Exception e) {
        application.log("Error fetching service: " + e.getMessage());
        message = "An error occurred while fetching the service.";
    }

    // Retrieve categories for the dropdown
    List<String[]> categories = new ArrayList<>();
    try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
         PreparedStatement pstmt = connection.prepareStatement("SELECT id, name FROM service_category");
         ResultSet resultSet = pstmt.executeQuery()) {

        while (resultSet.next()) {
            categories.add(new String[]{String.valueOf(resultSet.getInt("id")), resultSet.getString("name")});
        }
    } catch (Exception e) {
        application.log("Error fetching categories: " + e.getMessage());
    }
%>

<div class="form-container">
    <h1>Update Service</h1>

    <% if (message != null && !message.isEmpty()) { %>
        <p class="message" style="<%= message.contains("success") ? "color: green;" : "color: red;" %>">
            <%= message %>
        </p>
    <% } %>

    <form action="/JAD-Assignment2/admin/UpdateServiceServlet" method="POST" enctype="multipart/form-data">
        <input type="hidden" name="id" value="<%= serviceId %>">

        <label for="name">Service Name</label>
        <input type="text" id="name" name="name" value="<%= serviceName %>">

        <label for="description">Description</label>
        <textarea id="description" name="description"><%= serviceDescription %></textarea>

        <label for="price">Price</label>
        <input type="number" step="0.01" id="price" name="price" value="<%= servicePrice %>">

        <label for="category_id">Category</label>
        <select id="category_id" name="category_id">
            <% for (String[] category : categories) { %>
                <option value="<%= category[0] %>" <%= category[0].equals(String.valueOf(currentCategoryId)) ? "selected" : "" %>>
                    <%= category[1] %>
                </option>
            <% } %>
        </select>

        <label for="image">Service Image</label>
        <input type="file" id="image" name="image" accept="image/*">

        <button type="submit">Update Service</button>
    </form>

    <button onclick="window.location.href='adminServices.jsp';">Back to Services</button>
</div>

</body>
</html>
