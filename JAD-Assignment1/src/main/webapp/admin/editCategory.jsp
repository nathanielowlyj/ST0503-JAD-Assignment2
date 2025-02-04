<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingAdmin.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Update Category</title>
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

        .form-container input, .form-container textarea {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }

        .form-container button {
            width: 100%;
            padding: 10px;
            border: none;
            border-radius: 5px;
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
    int categoryId = Integer.parseInt(request.getParameter("id"));
    String categoryName = "";
    String categoryDescription = "";

    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    if (!isSubmitted) {
        try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
            PreparedStatement stmt = connection.prepareStatement("SELECT * FROM service_category WHERE id = ?")) {
            Class.forName("org.postgresql.Driver");
            stmt.setInt(1, categoryId);
            try (ResultSet resultSet = stmt.executeQuery()) {
                if (resultSet.next()) {
                    categoryName = resultSet.getString("name");
                    categoryDescription = resultSet.getString("description");
                } else {
                    message = "Category not found.";
                }
            }
        } catch (Exception e) {
            application.log("Error fetching category: " + e.getMessage());
            message = "An error occurred while fetching the category.";
        }
    } else {
        categoryName = request.getParameter("name");
        categoryDescription = request.getParameter("description");

        try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
             PreparedStatement pstmt = connection.prepareStatement(
                "UPDATE service_category SET name = ?, description = ? WHERE id = ?")) {
            Class.forName("org.postgresql.Driver");
            pstmt.setString(1, categoryName);
            pstmt.setString(2, categoryDescription);
            pstmt.setInt(3, categoryId);

            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                updateSuccess = true;
                message = "Category updated successfully.";
            } else {
                message = "Failed to update the category. Please try again.";
            }
        } catch (Exception e) {
            application.log("Error updating category: " + e.getMessage());
            message = "An error occurred while updating the category.";
        }
    }
%>

<div class="form-container">
    <% if (!isSubmitted || !updateSuccess) { %>
        <h1>Update Category</h1>
        <% if (!message.isEmpty()) { %>
            <p class="message" style="color: red;"><%= message %></p>
        <% } %>
        <form method="POST">
            <label for="name">Category Name</label>
            <input type="text" id="name" name="name" value="<%= categoryName %>" required>

            <label for="description">Description</label>
            <textarea id="description" name="description" required><%= categoryDescription %></textarea>

            <input type="hidden" name="id" value="<%= categoryId %>">
            <input type="hidden" name="submit" value="true">
            <button type="submit">Update Category</button>
        </form>
    <% } else { %>
        <p class="message" style="color: green;"><%= message %></p>
        <button onclick="window.location.href='adminServices.jsp';">Back to Categories</button>
    <% } %>
</div>

</body>
</html>
</html>