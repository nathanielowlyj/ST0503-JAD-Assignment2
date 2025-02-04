<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingCustomer.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add Feedback</title>
	<style>
	    body {
	        background-color: #4D637A;
	    }
	</style>
</head>
<body>
<%
    String userId = (String) session.getAttribute("id"); 
    String bookingId = request.getParameter("booking_id"); 
    String description = request.getParameter("description"); 
    String rating = request.getParameter("rating"); 

    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    Connection connection = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("org.postgresql.Driver");
        connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        // Insert feedback into the feedback table
        String sql = "INSERT INTO feedback (id, user_id, description, rating, feedback_date) VALUES (?, ?, ?, ?, NOW())";
        stmt = connection.prepareStatement(sql);
        stmt.setInt(1, Integer.parseInt(bookingId)); // Use the booking ID as feedback ID
        stmt.setInt(2, Integer.parseInt(userId));
        stmt.setString(3, description);
        stmt.setInt(4, Integer.parseInt(rating));

        int rowsAffected = stmt.executeUpdate();
        if (rowsAffected > 0) {
%>
        <script>
            alert("Feedback successfully submitted!");
            window.location.href = "customerFeedback.jsp"; 
        </script>
<%
        } else {
%>
        <script>
            alert("Failed to submit feedback. Please try again.");
            window.history.back();
        </script>
<%
        }
    } catch (Exception e) {
%>
    <p style="color: red;">Error: <%= e.getMessage() %></p>
<%
    } finally {
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
    }
%>
</body>
</html>
