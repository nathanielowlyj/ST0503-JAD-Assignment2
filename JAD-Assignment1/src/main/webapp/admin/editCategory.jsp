<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="sessionHandlingAdmin.jsp" %>
<%@ page import="java.sql.*" %>
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
            text-align: center;
        }

        .form-container h1 {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
        }

        .form-container label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            text-align: left;
        }

        .form-container input, .form-container textarea {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }

        .form-container .button-container {
            display: flex;
            flex-direction: column;
            align-items: center;
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

        /* Image Preview */
        .preview-container {
            text-align: center;
            margin-bottom: 15px;
        }

        .preview-container img {
            max-width: 100%;
            height: auto;
            border-radius: 5px;
        }

        /* Spacing between buttons */
        .button-container button {
            margin-bottom: 15px;
        }
    </style>
    <script>
        function previewImage(event) {
            var reader = new FileReader();
            reader.onload = function() {
                var output = document.getElementById('imagePreview');
                output.src = reader.result;
                output.style.display = 'block';
            };
            reader.readAsDataURL(event.target.files[0]);
        }
    </script>
</head>
<body>

<%
    String message = "";
    String categoryIdStr = request.getParameter("id");
    int categoryId = -1;
    String categoryName = "";
    String categoryDescription = "";
    String imagePath = ""; // Holds the current category image path

    if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
        try {
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            message = "Invalid category ID format.";
        }
    }

    if (categoryId > 0) {
        String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
        String dbUser = "cleaningServices_owner";
        String dbPassword = "mh0zgxauP6HJ";

        try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
             PreparedStatement stmt = connection.prepareStatement("SELECT * FROM service_category WHERE id = ?")) {
            stmt.setInt(1, categoryId);
            try (ResultSet resultSet = stmt.executeQuery()) {
                if (resultSet.next()) {
                    categoryName = resultSet.getString("name");
                    categoryDescription = resultSet.getString("description");
                    imagePath = resultSet.getString("img_path"); // Retrieve the current category image path
                } else {
                    message = "Category not found.";
                }
            }
        } catch (Exception e) {
            message = "Error fetching category: " + e.getMessage();
        }
    } else {
        message = "Invalid category ID.";
    }
%>

<div class="form-container">
    <% if (message != null && !message.isEmpty()) { %>
        <p class="message" style="<%= message.contains("success") ? "color: green;" : "color: red;" %>">
            <%= message %>
        </p>
    <% } %>

    <% if (categoryId > 0) { %>
        <h1>Update Category</h1>
        <form action="/JAD-Assignment2/admin/UpdateCategoryServlet" method="POST" enctype="multipart/form-data">
            <label for="name">Category Name</label>
            <input type="text" id="name" name="name" value="<%= categoryName %>" required>

            <label for="description">Description</label>
            <textarea id="description" name="description" required><%= categoryDescription %></textarea>

            <label for="image">Category Image</label>
            <input type="file" id="image" name="image" accept="image/*" onchange="previewImage(event)">

            <!-- Image Preview -->
            <div class="preview-container">
                <% if (imagePath != null && !imagePath.isEmpty()) { %>
                    <img id="imagePreview" src="<%= imagePath %>" alt="Current Image">
                <% } else { %>
                    <img id="imagePreview" src="#" alt="Image Preview" style="display: none;">
                <% } %>
            </div>

            <input type="hidden" name="id" value="<%= categoryId %>">

            <!-- Buttons with a gap -->
            <div class="button-container">
                <button type="submit">Update Category</button>
                <button type="button" onclick="window.location.href='adminServices.jsp';">Back to Categories</button>
            </div>
        </form>
    <% } else { %>
        <p class="message" style="color: red;">Invalid category ID or category not found.</p>
    <% } %>
</div>

</body>
</html>
