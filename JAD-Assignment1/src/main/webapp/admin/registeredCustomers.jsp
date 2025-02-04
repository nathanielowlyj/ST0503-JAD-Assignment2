<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="sessionHandlingAdmin.jsp" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Registered Customers</title>
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
            width: 100%;
            margin: 30px auto;
            border-collapse: separate;
            border-spacing: 0;
            border: 1px solid #6c757d;
            border-radius: 15px; 
            overflow: hidden;
            background-color: #343a40;
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

        table td {
            background-color: #3a3f44;
        }

        table tr {
            border-bottom: 1px solid #6c757d;
        }

        table tr:last-child td {
            border-bottom: none;
        }

        button {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            color: white;
            background-color: #dc3545; 
        }

        button:hover {
            background-color: #c82333;
        }

        .pagination {
            margin: 20px auto;
            display: flex;
            justify-content: center;
            gap: 10px;
        }

        .pagination a {
            padding: 8px 12px;
            border: 1px solid #6c757d;
            text-decoration: none;
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

        h1 {
            margin-top: 50px;
            margin-bottom: 30px;
            color: #ffffff;
        }

        .footer-space {
            margin-bottom: 50px;
        }
    </style>
</head>
<body>
<%@ include file="../header/header.jsp" %>

<div class="container">
    <h1>Manage Registered Customers</h1>

    <%
        int currentPage = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
        int pageSize = 8;
        int offset = (currentPage - 1) * pageSize;

        String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
        String dbUser = "cleaningServices_owner";
        String dbPassword = "mh0zgxauP6HJ";

        Connection connection = null;
        PreparedStatement stmt = null;
        ResultSet resultSet = null;

        try {
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);

            String sql = "SELECT id, name, email, account_creation_date, last_login FROM users WHERE role = 'user' ORDER BY id ASC LIMIT ? OFFSET ?";
            stmt = connection.prepareStatement(sql);
            stmt.setInt(1, pageSize);
            stmt.setInt(2, offset);
            resultSet = stmt.executeQuery();
    %>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Account Creation Date</th>
                <th>Last Login</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <%
                while (resultSet.next()) {
                    int id = resultSet.getInt("id");
                    String name = resultSet.getString("name");
                    String email = resultSet.getString("email");
                    String accountCreationDate = resultSet.getString("account_creation_date");
                    String lastLogin = resultSet.getString("last_login") != null ? resultSet.getString("last_login") : "Never";
            %>
            <tr>
                <td><%= id %></td>
                <td><%= name %></td>
                <td><%= email %></td>
                <td><%= accountCreationDate %></td>
                <td><%= lastLogin %></td>
                <td>
                    <form action="banUser.jsp" method="POST" style="display:inline;">
                        <input type="hidden" name="id" value="<%= id %>">
                        <button type="submit">Ban</button>
                    </form>
                </td>
            </tr>
            <%
                }
            %>
        </tbody>
    </table>

    <div class="pagination">
        <%
            stmt = connection.prepareStatement("SELECT COUNT(*) AS total FROM users WHERE role = 'user'");
            resultSet = stmt.executeQuery();
            resultSet.next();
            int totalUsers = resultSet.getInt("total");
            int totalPages = (int) Math.ceil((double) totalUsers / pageSize);

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
    %>
    <p style="color:red;">An error occurred while fetching the data.</p>
    <%
        } finally {
            if (resultSet != null) try { resultSet.close(); } catch (SQLException ignore) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
            if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
        }
    %>
</div>

<div class="footer-space"></div>
<%@ include file="../footer.html" %>
</body>
</html>
