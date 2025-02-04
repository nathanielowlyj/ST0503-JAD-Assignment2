<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingAdmin.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create Service</title>
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

        .form-container input, .form-container textarea, .form-container button {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
        }

        .form-container textarea {
            resize: none;
        }

        .add-btn {
            background-color: #28a745;
            color: white;
            border: none;
        }

        .add-btn:hover {
            background-color: #218838;
        }

        .close-btn {
            background-color: #dc3545;
            color: white;
            border: none;
        }

        .close-btn:hover {
            background-color: #c82333;
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
    String message = "";

    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    if (isSubmitted) {
        String serviceName = request.getParameter("name");
        String serviceDescription = request.getParameter("description");
        double servicePrice = Double.parseDouble(request.getParameter("price"));
        int categoryId = Integer.parseInt(request.getParameter("category_id"));
        boolean categoryExists = false;
        try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
             PreparedStatement categoryCheckStmt = connection.prepareStatement(
                "SELECT COUNT(*) AS count FROM service_category WHERE id = ?")) {
            Class.forName("org.postgresql.Driver");
            categoryCheckStmt.setInt(1, categoryId);

            try (ResultSet resultSet = categoryCheckStmt.executeQuery()) {
                if (resultSet.next()) {
                    categoryExists = resultSet.getInt("count") > 0;
                }
            }
        } catch (Exception e) {
            application.log("Error checking category: " + e.getMessage());
            message = "An error occurred while validating the category.";
        }

        if (!categoryExists) {
            message = "The specified Category ID does not exist. Please check and try again.";
        } else {
            try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
                 PreparedStatement pstmt = connection.prepareStatement(
                    "INSERT INTO service (name, description, price, category_id) VALUES (?, ?, ?, ?)")) {
                Class.forName("org.postgresql.Driver");
                pstmt.setString(1, serviceName);
                pstmt.setString(2, serviceDescription);
                pstmt.setDouble(3, servicePrice);
                pstmt.setInt(4, categoryId);

                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    message = "Service created successfully.";
                } else {
                    message = "Failed to create the service. Please try again.";
                }
            } catch (Exception e) {
                application.log("Error creating service: " + e.getMessage());
                message = "An error occurred while creating the service.";
            }
        }
    }
%>

<div class="form-container">
    <% if (!isSubmitted || message.contains("Failed") || message.contains("error") || message.contains("Category ID")) { %>
        <h1>Create Service</h1>
        <% if (!message.isEmpty()) { %>
            <p class="message" style="color: red;"><%= message %></p>
        <% } %>
        <form method="POST">
            <label for="name">Service Name</label>
            <input type="text" id="name" name="name" required>

            <label for="description">Description</label>
            <textarea id="description" name="description" required></textarea>

            <label for="price">Price</label>
            <input type="number" step="0.01" id="price" name="price" required>

            <label for="category_id">Category ID</label>
            <input type="number" id="category_id" name="category_id" required>

            <input type="hidden" name="submit" value="true">
            <button type="submit" class="add-btn">Create Service</button>
            <button type="button" class="close-btn" onclick="window.location.href='adminServices.jsp';">Close</button>
        </form>
    <% } else { %>
        <p class="message" style="color: green;"><%= message %></p>
        <button onclick="window.location.href='adminServices.jsp';">Back to Services</button>
    <% } %>
</div>
</body>
</html>
