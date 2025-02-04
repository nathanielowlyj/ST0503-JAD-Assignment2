<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="sessionHandlingAdmin.jsp" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Booking</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            background-color: #f9f9f9;
            margin: 0;
            padding: 0;
        }

        .container {
            margin: 20px auto;
        }

        table {
            width: 90%;
            margin: 20px auto;
            border-collapse: separate;
            border-spacing: 0;
            border: 1px solid #6c757d;
            background-color: #343a40;
            border-radius: 10px;
            overflow: hidden;
        }

        table th, table td {
            padding: 15px;
            text-align: left;
            color: white;
            border: 1px solid #495057;
        }

        table th {
            background-color: #495057;
        }

        table tr:hover {
            background-color: #3a3f44;
        }

        button {
            padding: 8px 12px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        button:hover {
            background-color: #0056b3;
        }

        h1 {
            color: white;
            margin-top: 70px;
            margin-bottom: 30px;
        }

        .pagination {
            margin: 20px auto;
            display: flex;
            justify-content: center;
            gap: 10px;
        }

        .pagination a {
            padding: 8px 12px;
            text-decoration: none;
            border: 1px solid #6c757d;
            color: white;
            background-color: #495057;
            border-radius: 5px;
        }

        .pagination a.active {
            font-weight: bold;
            background-color: #6c757d;
        }

        .pagination a:hover {
            background-color: #6c757d;
        }

        .pop-up {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
        }

        .pop-up-content {
            background-color: white;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 40%;
            border-radius: 10px;
        }

        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }

        .close:hover, .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }
    </style>
    <script>
        function showDetails(bookingId) {
            const popUp = document.getElementById('pop-up-' + bookingId);
            popUp.style.display = 'flex';
        }

        function closeDetails(bookingId) {
            const popUp = document.getElementById('pop-up-' + bookingId);
            popUp.style.display = 'none';
        }
    </script>
</head>
<body>
<%@ include file="../header/header.jsp" %>

<div class="container">
    <h1>Booking List with Service Details</h1>
    <%
    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    int currentPage = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
    int recordsPerPage = 6;
    int offset = (currentPage - 1) * recordsPerPage;

    Connection connection = null;
    PreparedStatement stmt = null;
    PreparedStatement countStmt = null;
    ResultSet resultSet = null;
    ResultSet countResultSet = null;

    try {
        Class.forName("org.postgresql.Driver");
        connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        String sql = "SELECT bl.id AS booking_id, " +
                     "u.id AS user_id, " +
                     "u.name AS user_name, " +
                     "bd.booking_date, " +
                     "bd.quantity, " +
                     "bd.price, " +
                     "bd.total, " +
                     "s.name AS service_name, " +
                     "s.description AS service_description " +
                     "FROM booking_list bl " +
                     "JOIN users u ON bl.user_id = u.id " +
                     "JOIN booking_details bd ON bl.id = bd.booking_id " +
                     "JOIN service s ON bd.service_id = s.id " +
                     "LIMIT ? OFFSET ?";
        stmt = connection.prepareStatement(sql);
        stmt.setInt(1, recordsPerPage);
        stmt.setInt(2, offset);
        resultSet = stmt.executeQuery();

        countStmt = connection.prepareStatement("SELECT COUNT(*) AS total FROM booking_list");
        countResultSet = countStmt.executeQuery();
        countResultSet.next();
        int totalRecords = countResultSet.getInt("total");
        int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
    %>
        <table>
            <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>User ID</th>
                    <th>User Name</th>
                    <th>Booking Date</th>
                    <th>Service Name</th>
                    <th>Quantity</th>
                    <th>Price</th>
                    <th>Total</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    while (resultSet.next()) {
                        int bookingId = resultSet.getInt("booking_id");
                        int user_id = resultSet.getInt("user_id");
                        String userName = resultSet.getString("user_name");
                        String bookingDate = resultSet.getString("booking_date");
                        String serviceName = resultSet.getString("service_name");
                        String serviceDescription = resultSet.getString("service_description");
                        int quantity = resultSet.getInt("quantity");
                        double price = resultSet.getDouble("price");
                        double total = resultSet.getDouble("total");
                %>
                <tr>
                    <td><%= bookingId %></td>
                    <td><%= user_id %></td>
                    <td><%= userName %></td>
                    <td><%= bookingDate %></td>
                    <td><%= serviceName %></td>
                    <td><%= quantity %></td>
                    <td>$<%= price %></td>
                    <td>$<%= total %></td>
                    <td><button onclick="showDetails(<%= bookingId %>)">Details</button></td>
                </tr>
                <div id="pop-up-<%= bookingId %>" class="pop-up">
                    <div class="pop-up-content">
                        <span class="close" onclick="closeDetails(<%= bookingId %>)">&times;</span>
                        <h2>Booking Details</h2>
                        <p><strong>Booking ID:</strong> <%= bookingId %></p>
                        <p><strong>User ID:</strong> <%= user_id %></p>
                        <p><strong>User Name:</strong> <%= userName %></p>
                        <p><strong>Booking Date:</strong> <%= bookingDate %></p>
                        <p><strong>Service Name:</strong> <%= serviceName %></p>
                        <p><strong>Service Description:</strong> <%= serviceDescription %></p>
                        <p><strong>Quantity:</strong> <%= quantity %></p>
                        <p><strong>Price:</strong> $<%= price %></p>
                        <p><strong>Total:</strong> $<%= total %></p>
                    </div>
                </div>
                <%
                    }
                %>
            </tbody>
        </table>
        <div class="pagination">
            <%
                for (int i = 1; i <= totalPages; i++) {
            %>
                <a href="?page=<%= i %>" class="<%= (i == currentPage) ? "active" : "" %>"><%= i %></a>
            <%
                }
            %>
        </div>
    <%
        } catch (Exception e) {
            application.log("Error: " + e.getMessage());
            out.println("<p style='color:red;'>An error occurred while fetching the booking data.</p>");
        } finally {
            if (resultSet != null) try { resultSet.close(); } catch (SQLException ignore) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
            if (countResultSet != null) try { countResultSet.close(); } catch (SQLException ignore) {}
            if (countStmt != null) try { countStmt.close(); } catch (SQLException ignore) {}
            if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
        }
    %>
</div>

<%@ include file="../footer.html" %>
</body>
</html>
