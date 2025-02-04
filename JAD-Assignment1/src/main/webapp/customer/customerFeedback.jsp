<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingCustomer.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Feedback</title>
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
	    }
	
	    h1 {
	        text-align: center;
	        color: #ffffff;
	        margin-top: 40px; 
	    }
	
	    table {
	        width: 100%;
	        border-collapse: separate;
	        border-spacing: 0; 
	        margin: 20px 0;
	        background-color: white;
	        border-radius: 10px; 
	        overflow: hidden; 
	    }
	
	    table th, table td {
	        padding: 15px; 
	        text-align: left;
	        border: 1px solid #ddd;
	    }
	
	    table th {
	        background-color: #4d637a;
	        color: white;
	        text-align: center;
	    }
	
	    table tr:nth-child(even) {
	        background-color: #f2f2f2;
	    }
	
	    table tr:hover {
	        background-color: #ddd;
	    }
	
	    .form-container {
	        margin-top: 20px;
	    }
	
	    .form-container form {
	        display: flex;
	        flex-wrap: wrap;
	        gap: 10px;
	        align-items: center;
	    }
	
	    .form-container textarea {
	        flex: 2;
	        padding: 10px;
	        border: 1px solid #ddd;
	        border-radius: 5px;
	    }
	
	    .form-container select {
	        flex: 1;
	        padding: 10px;
	        border: 1px solid #ddd;
	        border-radius: 5px;
	    }
	
	    .form-container button {
	        padding: 10px 20px;
	        background-color: #28a745;
	        color: white;
	        border: none;
	        border-radius: 5px;
	        cursor: pointer;
	    }
	
	    .form-container button:hover {
	        background-color: #218838;
	    }
	
	    .update-button {
	        background-color: #007bff;
	        margin-top: 5px;
	    }
	
	    .update-button:hover {
	        background-color: #0056b3;
	    }
	    
	    .action-cell {
	        display: flex;
	        align-items: center;
	        justify-content: space-between;
	        gap: 10px;
	    }
	
	    .action-cell textarea {
	        width: 60%;
	        padding: 10px;
	        border: 1px solid #ddd;
	        border-radius: 5px;
	        resize: none;
	    }
	
	    .action-cell select {
	        width: 20%;
	        padding: 10px;
	        border: 1px solid #ddd;
	        border-radius: 5px;
	    }
	
	    .action-cell button {
	        width: 20%;
	        padding: 10px;
	        background-color: #28a745;
	        color: white;
	        border: none;
	        border-radius: 5px;
	        cursor: pointer;
	    }
	
	    .action-cell button:hover {
	        background-color: #218838;
	    }
	</style>

</head>
<body>
<%@ include file="../header/header.jsp" %>
<div class="container">
    <h1>Completed Bookings</h1>
    <table>
        <thead>
            <tr>
                <th>Booking ID</th>
                <th>Service Name</th>
                <th>Booking Date</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <%
                String user_id = (String)session.getAttribute("id");

                String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
                String dbUser = "cleaningServices_owner";
                String dbPassword = "mh0zgxauP6HJ";

                Connection connection = null;
                PreparedStatement stmt = null;
                ResultSet resultSet = null;

                try {
                    Class.forName("org.postgresql.Driver");
                    connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);

                    String sql = "SELECT bd.id AS booking_id, s.name AS service_name, bd.booking_date " +
                                 "FROM booking_details bd " +
                                 "JOIN booking_list bl ON bd.booking_id = bl.id " +
                                 "JOIN service s ON bd.service_id = s.id " +
                                 "LEFT JOIN feedback f ON f.id = bd.id " +
                                 "WHERE bl.user_id = ? AND bd.status = 'complete' AND f.id IS NULL " +
                                 "ORDER BY bd.booking_date DESC";

                    stmt = connection.prepareStatement(sql);
                    stmt.setInt(1, Integer.parseInt(user_id));
                    resultSet = stmt.executeQuery();

                    while (resultSet.next()) {
                        int bookingId = resultSet.getInt("booking_id");
                        String serviceName = resultSet.getString("service_name");
                        String bookingDate = resultSet.getString("booking_date");
            %>
            <tr>
                <td><%= bookingId %></td>
				<td><%= serviceName %></td>
				<td><%= bookingDate %></td>
				<td>
				    <form class="action-cell" action="addFeedback.jsp" method="POST">
				        <textarea name="description" placeholder="Write your review here..." required></textarea>
				        <select name="rating" required>
				            <option value="" disabled selected>Rating</option>
				            <option value="1">1 - Poor</option>
				            <option value="2">2 - Fair</option>
				            <option value="3">3 - Good</option>
				            <option value="4">4 - Very Good</option>
				            <option value="5">5 - Excellent</option>
				        </select>
				        <input type="hidden" name="booking_id" value="<%= bookingId %>">
				        <button type="submit">Submit Feedback</button>
				    </form>
				</td>
            </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='4' style='color: red;'>Error fetching completed bookings: " + e.getMessage() + "</td></tr>");
                } finally {
                    if (resultSet != null) try { resultSet.close(); } catch (SQLException ignore) {}
                    if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                    if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
                }
            %>
        </tbody>
    </table>

    <h1>Your Feedback</h1>
    <table>
        <thead>
            <tr>
                <th>Booking ID</th>
                <th>Service Name</th>
                <th>Feedback</th>
                <th>Rating</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <%
                try {
                    Class.forName("org.postgresql.Driver");
                    connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);

                    // Query to fetch feedback for the user
                    String feedbackSql = "SELECT f.id AS feedback_id, bd.id AS booking_id, s.name AS service_name, f.description, f.rating " +
                                         "FROM feedback f " +
                                         "JOIN booking_details bd ON f.id = bd.id " +
                                         "JOIN service s ON bd.service_id = s.id " +
                                         "JOIN booking_list bl ON bd.booking_id = bl.id " +
                                         "WHERE bl.user_id = ? " +
                                         "ORDER BY bd.booking_date DESC";

                    stmt = connection.prepareStatement(feedbackSql);
                    stmt.setInt(1, Integer.parseInt(user_id));
                    resultSet = stmt.executeQuery();

                    while (resultSet.next()) {
                        int feedbackId = resultSet.getInt("feedback_id");
                        int bookingId = resultSet.getInt("booking_id");
                        String serviceName = resultSet.getString("service_name");
                        String feedbackDescription = resultSet.getString("description");
                        int rating = resultSet.getInt("rating");
            %>
            <tr>
                <td><%= bookingId %></td>
                <td><%= serviceName %></td>
                <td><%= feedbackDescription %></td>
                <td><%= rating %></td>
                <td>
                    <form action="updateFeedback.jsp" method="POST" style="display: inline;">
                        <input type="hidden" name="feedback_id" value="<%= feedbackId %>">
                        <button class="update-button" type="submit">Update</button>
                    </form>
                    <form action="deleteFeedback.jsp" method="POST" style="display: inline;">
                        <input type="hidden" name="feedback_id" value="<%= feedbackId %>">
                        <button class="update-button" style="background-color: #dc3545;" type="submit">Delete</button>
                    </form>
                </td>
            </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='5' style='color: red;'>Error fetching feedback: " + e.getMessage() + "</td></tr>");
                } finally {
                    if (resultSet != null) try { resultSet.close(); } catch (SQLException ignore) {}
                    if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                    if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
                }
            %>
        </tbody>
    </table>
</div>
<%@ include file="../footer.html" %>
</body>
</html>
