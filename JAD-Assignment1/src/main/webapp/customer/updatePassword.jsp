<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.security.MessageDigest, java.util.Base64" %>
<%@ include file="sessionHandlingCustomer.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Change Password</title>
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
        .container input[type="password"] {
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
    <h2>Change Password</h2>
    <form method="POST">
        <input type="password" name="currentPassword" placeholder="Enter current password" required>
        <input type="password" name="newPassword" placeholder="Enter new password" required>
        <button type="submit">Change Password</button>
    </form>
</div>

<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String currentPassword = request.getParameter("currentPassword");
    String newPassword = request.getParameter("newPassword");
    String uId = (String) session.getAttribute("id");

    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
        String getPasswordQuery = "SELECT password FROM users WHERE id = ?";
        try (PreparedStatement getPasswordStmt = connection.prepareStatement(getPasswordQuery)) {
            getPasswordStmt.setInt(1, Integer.parseInt(uId));
            try (ResultSet resultSet = getPasswordStmt.executeQuery()) {
                if (resultSet.next()) {
                    String storedHashedPassword = resultSet.getString("password");
                    MessageDigest digest = MessageDigest.getInstance("SHA-256");
                    byte[] hashBytes = digest.digest(currentPassword.getBytes("UTF-8"));
                    String hashedCurrentPassword = Base64.getEncoder().encodeToString(hashBytes);
                    if (!storedHashedPassword.equals(hashedCurrentPassword)) {
%>
<script>
    alert("The current password is incorrect. Please try again.");
    window.history.back();
</script>
<%
                        return;
                    }
                } else {
%>
<script>
    alert("User not found. Please try again.");
    window.history.back();
</script>
<%
                    return;
                }
            }
        }

        // Hash the new password
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] newHashBytes = digest.digest(newPassword.getBytes("UTF-8"));
        String hashedNewPassword = Base64.getEncoder().encodeToString(newHashBytes);

        // Update the password in the database
        String updatePasswordQuery = "UPDATE users SET password = ? WHERE id = ?";
        try (PreparedStatement updatePasswordStmt = connection.prepareStatement(updatePasswordQuery)) {
            updatePasswordStmt.setString(1, hashedNewPassword);
            updatePasswordStmt.setInt(2, Integer.parseInt(uId));
            int rowsAffected = updatePasswordStmt.executeUpdate();

            if (rowsAffected > 0) {
                session.invalidate(); 
            	%>
            	<script>
            	    alert("Password successfully changed. Please sign in again again.");
            	    window.location.href = "../login.jsp";
            	</script>
            	<%
            } else {
%>
<script>
    alert("Failed to update password. Please try again.");
    window.history.back();
</script>
<%
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
%>
<script>
    alert("An error occurred while updating the password. Please try again later.");
    window.history.back();
</script>
<%
    }
}
%>

<%@ include file="../footer.html" %>
</body>
</html>
