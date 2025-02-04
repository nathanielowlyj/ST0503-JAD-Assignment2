<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingCustomer.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Update Feedback</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #4D637A;
            margin: 0;
            padding: 0;
        }

        .container {
            width: 80%;
            margin: 40px auto;
            text-align: center;
        }

        h1 {
            color: #ffffff;
        }

        form {
            margin-top: 20px;
        }

        textarea, select, button {
            width: 80%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 5px;
        }

        button {
            background-color: #007bff;
            color: white;
            border: none;
            cursor: pointer;
        }

        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Update Feedback</h1>
    <%
        String feedbackId = request.getParameter("feedback_id");
        String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
        String dbUser = "cleaningServices_owner";
        String dbPassword = "mh0zgxauP6HJ";

        String existingDescription = "";
        int existingRating = 0;

        try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
            Class.forName("org.postgresql.Driver");
            String sql = "SELECT description, rating FROM feedback WHERE id = ?";
            PreparedStatement stmt = connection.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(feedbackId));
            ResultSet resultSet = stmt.executeQuery();
            if (resultSet.next()) {
                existingDescription = resultSet.getString("description");
                existingRating = resultSet.getInt("rating");
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error fetching feedback: " + e.getMessage() + "</p>");
        }
    %>
    <form action="updateFeedbackAction.jsp" method="POST">
        <textarea name="description" required><%= existingDescription %></textarea>
        <select name="rating" required>
            <option value="" disabled>Rating</option>
            <option value="1" <%= (existingRating == 1) ? "selected" : "" %>>1 - Poor</option>
            <option value="2" <%= (existingRating == 2) ? "selected" : "" %>>2 - Fair</option>
            <option value="3" <%= (existingRating == 3) ? "selected" : "" %>>3 - Good</option>
            <option value="4" <%= (existingRating == 4) ? "selected" : "" %>>4 - Very Good</option>
            <option value="5" <%= (existingRating == 5) ? "selected" : "" %>>5 - Excellent</option>
        </select>
        <input type="hidden" name="feedback_id" value="<%= feedbackId %>">
        <button type="submit">Update Feedback</button>
    </form>
</div>
</body>
</html>
