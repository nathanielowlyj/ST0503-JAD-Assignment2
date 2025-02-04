<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingCustomer.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Delete Feedback</title>
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

        button {
            padding: 10px 20px;
            margin: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .confirm-button {
            background-color: #dc3545;
            color: white;
        }

        .confirm-button:hover {
            background-color: #bd2130;
        }

        .cancel-button {
            background-color: #007bff;
            color: white;
        }

        .cancel-button:hover {
            background-color: #0056b3;
        }

        .message {
            color: white;
            font-weight: bold;
        }

        .error {
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Delete Feedback</h1>

    <%
        String feedbackId = request.getParameter("feedback_id");
        String action = request.getParameter("action");
        String message = "";
        String errorMessage = "";

        if ("confirm".equals(action)) {
            Connection connection = null;
            PreparedStatement stmt = null;

            try {
                String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
                String dbUser = "cleaningServices_owner";
                String dbPassword = "mh0zgxauP6HJ";

                Class.forName("org.postgresql.Driver");
                connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);

                String sql = "DELETE FROM feedback WHERE id = ?";
                stmt = connection.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(feedbackId));

                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    message = "Feedback successfully deleted.";
                } else {
                    errorMessage = "Failed to delete feedback. Please try again.";
                }
            } catch (Exception e) {
                errorMessage = "Error occurred: " + e.getMessage();
            } finally {
                if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
            }
        }

        if (!message.isEmpty()) {
    %>
        <p class="message"><%= message %></p>
        <button class="cancel-button" onclick="window.location.href='customerFeedback.jsp';">Back to Feedback</button>
    <%
        } else if (!errorMessage.isEmpty()) {
    %>
        <p class="error"><%= errorMessage %></p>
        <button class="cancel-button" onclick="window.location.href='customerFeedback.jsp';">Back to Feedback</button>
    <%
        } else {
    %>
        <p>Are you sure you want to delete this feedback?</p>
        <form action="deleteFeedback.jsp" method="POST">
            <input type="hidden" name="feedback_id" value="<%= feedbackId %>">
            <input type="hidden" name="action" value="confirm">
            <button class="confirm-button" type="submit">Yes, Delete</button>
        </form>
        <button class="cancel-button" onclick="window.history.back();">Cancel</button>
    <%
        }
    %>
</div>
</body>
</html>
