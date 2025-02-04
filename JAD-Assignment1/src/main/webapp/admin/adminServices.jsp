<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingAdmin.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Services and Categories</title>
	<style>
	    body {
	        font-family: Arial, sans-serif;
	        text-align: center;
	        background-color: #4d637a;
	    }

	    .table-container {
	        margin: 40px auto;
	        width: 80%;
	    }

	    table {
	        width: 100%;
	        border-collapse: separate;
	        border-spacing: 0;
	        margin: 0 auto;
	        border: 1px solid #6c757d;
	        border-radius: 10px;
	        overflow: hidden;
	        background-color: #343a40; 
	    }

	    table th, table td {
	        padding: 10px;
	        text-align: left;
	        color: white;
	        border: 1px solid #6c757d;
	    }

	    table th {
	        background-color: #495057; 
	    }

	    table td {
	        background-color: #343a40;
	    }

	    .pagination {
	        margin: 20px 0;
	        display: flex;
	        justify-content: center;
	        gap: 10px;
	    }

	    .pagination a {
	        padding: 5px 10px;
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
	        text-align: center;
	        margin-bottom: 20px;
	        color: #ffffff;
	    }

	    .create-btn {
	        margin: 20px;
	        padding: 10px 20px;
	        background-color: #28a745;
	        color: white;
	        border: none;
	        border-radius: 5px;
	        cursor: pointer;
	    }

	    .create-btn:hover {
	        background-color: #218838;
	    }

	    .footer-space {
	        margin-bottom: 40px; 
	    }

	    .action-buttons button {
	        padding: 8px 15px;
	        margin: 0 5px;
	        background-color: #007bff;
	        color: white;
	        border: none;
	        border-radius: 5px;
	        cursor: pointer;
	    }

	    .action-buttons button:hover {
	        background-color: #0056b3;
	    }

	    .action-buttons button.delete {
	        background-color: #dc3545;
	    }

	    .action-buttons button.delete:hover {
	        background-color: #bd2130;
	    }
	</style>
</head>
<body>
<%@ include file="../header/header.jsp" %>
<h1>Manage Services and Categories</h1>

<%
    int servicePage = request.getParameter("servicePage") != null ? Integer.parseInt(request.getParameter("servicePage")) : 1;
    int categoryPage = request.getParameter("categoryPage") != null ? Integer.parseInt(request.getParameter("categoryPage")) : 1;
    int pageSize = 5; 
    int serviceOffset = (servicePage - 1) * pageSize;
    int categoryOffset = (categoryPage - 1) * pageSize;

    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    Connection connection = null;
    Statement serviceStmt = null;
    Statement categoryStmt = null;
    ResultSet serviceResultSet = null;
    ResultSet categoryResultSet = null;

    try {
        Class.forName("org.postgresql.Driver");
        connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        String serviceSql = "SELECT * FROM service ORDER BY id ASC LIMIT " + pageSize + " OFFSET " + serviceOffset;
        serviceStmt = connection.createStatement();
        serviceResultSet = serviceStmt.executeQuery(serviceSql);
%>

<div class="table-container">
    <h1>Services</h1>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Category ID</th> 
                <th>Name</th>
                <th>Description</th>
                <th>Price</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
                while (serviceResultSet.next()) {
                    int id = serviceResultSet.getInt("id");
                    int categoryId = serviceResultSet.getInt("category_id"); 
                    String name = serviceResultSet.getString("name");
                    String description = serviceResultSet.getString("description");
                    double price = serviceResultSet.getDouble("price");
            %>
            <tr>
                <td><%= id %></td>
                <td><%= categoryId %></td> 
                <td><%= name %></td>
                <td><%= description %></td>
                <td>$<%= price %></td>
                <td class="action-buttons">
                    <form action="editServices.jsp" method="GET" style="display:inline;">
                        <input type="hidden" name="id" value="<%= id %>">
                        <button type="submit">Edit</button>
                    </form>
                    <form action="deleteServices.jsp" method="POST" style="display:inline;">
                        <input type="hidden" name="id" value="<%= id %>">
                        <button type="submit" class="delete">Delete</button>
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
            serviceResultSet = serviceStmt.executeQuery("SELECT COUNT(*) AS total FROM service");
            serviceResultSet.next();
            int totalServices = serviceResultSet.getInt("total");
            int totalServicePages = (int) Math.ceil((double) totalServices / pageSize);

            for (int i = 1; i <= totalServicePages; i++) {
        %>
        <a href="?servicePage=<%= i %>&categoryPage=<%= categoryPage %>" class="<%= (i == servicePage) ? "active" : "" %>"><%= i %></a>
        <%
            }
        %>
    </div>

    <form action="addService.jsp" method="GET">
        <button type="submit" class="create-btn">Create New Service</button>
    </form>
</div>

<%
    String categorySql = "SELECT * FROM service_category ORDER BY id ASC LIMIT " + pageSize + " OFFSET " + categoryOffset;
    categoryStmt = connection.createStatement();
    categoryResultSet = categoryStmt.executeQuery(categorySql);
%>

<div class="table-container footer-space">
    <h1>Categories</h1>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Description</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
                while (categoryResultSet.next()) {
                    int id = categoryResultSet.getInt("id");
                    String name = categoryResultSet.getString("name");
                    String description = categoryResultSet.getString("description");
            %>
            <tr>
                <td><%= id %></td>
                <td><%= name %></td>
                <td><%= description %></td>
                <td class="action-buttons">
                    <form action="editCategory.jsp" method="GET" style="display:inline;">
                        <input type="hidden" name="id" value="<%= id %>">
                        <button type="submit">Edit</button>
                    </form>
                    <form action="deleteCategory.jsp" method="POST" style="display:inline;">
                        <input type="hidden" name="id" value="<%= id %>">
                        <button type="submit" class="delete">Delete</button>
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
            categoryResultSet = categoryStmt.executeQuery("SELECT COUNT(*) AS total FROM service_category");
            categoryResultSet.next();
            int totalCategories = categoryResultSet.getInt("total");
            int totalCategoryPages = (int) Math.ceil((double) totalCategories / pageSize);

            for (int i = 1; i <= totalCategoryPages; i++) {
        %>
        <a href="?servicePage=<%= servicePage %>&categoryPage=<%= i %>" class="<%= (i == categoryPage) ? "active" : "" %>"><%= i %></a>
        <%
            }
        %>
    </div>

    <form action="addCategory.jsp" method="GET">
        <button type="submit" class="create-btn">Create New Category</button>
    </form>
</div>

<%
    } catch (Exception e) {
        application.log("Error: " + e.getMessage());
%>
<p style="color:red;">An error occurred while fetching the data.</p>
<%
    } finally {
        if (serviceResultSet != null) try { serviceResultSet.close(); } catch (SQLException ignore) {}
        if (categoryResultSet != null) try { categoryResultSet.close(); } catch (SQLException ignore) {}
        if (serviceStmt != null) try { serviceStmt.close(); } catch (SQLException ignore) {}
        if (categoryStmt != null) try { categoryStmt.close(); } catch (SQLException ignore) {}
        if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
    }
%>
<%@ include file="../footer.html" %>
</body>
</html>
