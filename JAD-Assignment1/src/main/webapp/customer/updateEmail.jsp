<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingCustomer.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Change Email</title>
    <style>
	    .container {
	        margin-top: 60px;
	        width: 60%;
	        height: 100%;
	        display: flex;
	        flex-direction: column;
	        justify-content: flex-start;
	        background-color: #00000022;
	        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
	        padding: 25px;
	        padding-top:50px;
	        align-self: center;
	    }
	    h2 {
	    color: white;
	    }
        .container input[type="text"] {
            width: 95%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 16px;
        }
        .container button {
            background-color: #4CAF50;
            color: white;
            border: none;
            padding: 10px 20px;
            text-align: center;
            font-size: 16px;
            cursor: pointer;
            border-radius: 4px;
        }
        .container button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
<%@ include file="../header/header.jsp" %>

<div class="container">
    <h2>Change Email</h2>
    <form method="POST">
        <input type="text" name="newEmail" placeholder="Enter new email" required>
        <button type="submit">Change Email</button>
    </form>
</div>

<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String newEmail = request.getParameter("newEmail");
    String uId = (String) session.getAttribute("id");

    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
        String checkEmailQuery = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (PreparedStatement checkEmailStmt = connection.prepareStatement(checkEmailQuery)) {
            checkEmailStmt.setString(1, newEmail);
            try (ResultSet resultSet = checkEmailStmt.executeQuery()) {
                if (resultSet.next() && resultSet.getInt(1) > 0) {
%>
<script>
    alert("The email is already in use. Please try another email.");
    window.history.back();
</script>
<%
                    return;
                }
            }
        }
        String updateEmailQuery = "UPDATE users SET email = ? WHERE id = ?";
        try (PreparedStatement updateEmailStmt = connection.prepareStatement(updateEmailQuery)) {
            updateEmailStmt.setString(1, newEmail);
            updateEmailStmt.setInt(2, Integer.parseInt(uId));
            int rowsAffected = updateEmailStmt.executeUpdate();

            if (rowsAffected > 0) {
                response.sendRedirect("profile.jsp");
            } else {
%>
<script>
    alert("Failed to update email. Please try again.");
    window.history.back();
</script>
<%
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
%>
<script>
    alert("An error occurred while updating the email. Please try again later.");
    window.history.back();
</script>
<%
    }
}
%>

<%@ include file="../footer.html" %>
</body>
</html>
