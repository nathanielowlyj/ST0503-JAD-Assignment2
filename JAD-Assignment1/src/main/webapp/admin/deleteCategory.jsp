<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingAdmin.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Delete Category</title>
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

        .confirmation-box {
            background-color: white;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
            text-align: center;
            width: 400px;
        }

        .confirmation-box h1 {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
        }

        .confirmation-box p {
            font-size: 18px;
            margin-bottom: 30px;
            color: #555;
        }

        .confirmation-box .buttons {
            display: flex;
            justify-content: center;
            gap: 20px;
        }

        .confirmation-box button {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }

        .cancel-btn {
            background-color: #ddd;
            color: #333;
        }

        .cancel-btn:hover {
            background-color: #bbb;
        }

        .delete-btn {
            background-color: red;
            color: white;
        }

        .delete-btn:hover {
            background-color: #cc0000;
        }

        .message {
            font-size: 18px;
            color: green;
            margin-top: 20px;
        }

        .error {
            font-size: 18px;
            color: red;
            margin-top: 20px;
        }
    </style>
</head>
<body>
<%
    boolean isConfirmed = request.getParameter("confirm") != null;
    boolean deletionSuccess = false;
    String message = "";
    String categoryName = "";
    int categoryId = Integer.parseInt(request.getParameter("id"));

    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    if (!isConfirmed) {
        try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
            PreparedStatement stmt = connection.prepareStatement("SELECT name FROM service_category WHERE id = ?")) {
            Class.forName("org.postgresql.Driver");
            stmt.setInt(1, categoryId);
            try (ResultSet resultSet = stmt.executeQuery()) {
                if (resultSet.next()) {
                    categoryName = resultSet.getString("name");
                } else {
                    message = "Category not found.";
                }
            }
        } catch (Exception e) {
            application.log("Error fetching category: " + e.getMessage());
            message = "An error occurred while fetching the category.";
        }
    } else {
        try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
             PreparedStatement pstmt = connection.prepareStatement("DELETE FROM service_category WHERE id = ?")) {
            Class.forName("org.postgresql.Driver");
            pstmt.setInt(1, categoryId);

            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                deletionSuccess = true;
                message = "Category deleted successfully.";
            } else {
                message = "Failed to delete the category. Please try again.";
            }
        } catch (Exception e) {
            application.log("Error deleting category: " + e.getMessage());
            message = "An error occurred while deleting the category.";
        }
    }
%>

<div class="confirmation-box">
    <% if (!isConfirmed && message.isEmpty()) { %>
        <h1>Delete Category</h1>
        <p>Are you sure you want to delete the category "<b><%= categoryName %></b>"?</p>
        <div class="buttons">
            <button class="cancel-btn" onclick="window.location.href='adminServices.jsp';">Cancel</button>
            <form method="POST" style="display: inline;">
                <input type="hidden" name="id" value="<%= categoryId %>">
                <input type="hidden" name="confirm" value="true">
                <button type="submit" class="delete-btn">Delete</button>
            </form>
        </div>
    <% } else { %>
        <div class="<%= deletionSuccess ? "message" : "error" %>">
            <%= message %>
        </div>
        <div class="buttons">
            <button class="cancel-btn" onclick="window.location.href='adminServices.jsp';">Back to Categories</button>
        </div>
    <% } %>
</div>

</body>
</html>
