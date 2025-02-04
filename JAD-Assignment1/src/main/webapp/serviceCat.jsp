<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Service Categories</title>
<style>
    .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); /* Adjusts column width based on screen size */
        gap: 20px;
        justify-content: center;
        margin: 20px;
        margin-top: 0px;
    }

    .card {
        position: relative;
        width: 100%; 
        padding-bottom: 133.33%; 
        background-color: #f9f9f9;
        border: 1px solid #ccc;
        border-radius: 5px;
        box-sizing: border-box;
        overflow: hidden;
        background-size: cover; 
        background-position: center; 
    }
    
	.card::before {
	    content: "";
	    position: absolute;
	    top: 0;
	    left: 0;
	    width: 100%;
	    height: 100%;
	    background: rgba(0, 0, 0, 0.5); 
	    z-index: 0;
	}
	
    .card h3, .card p {
        position: absolute;
        z-index: 1;
        color: white;
        text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.7); 
        text-align: center;
        width: 100%;
    }

    .card h3 {
        top: 30%;
        font-size: 24px;
    }

    .card p {
        bottom: 50%;
        font-size: 16px;
    }

    .card .button-wrapper {
	    position: absolute;
	    bottom: 20%;
	    left: 50%;
	    transform: translateX(-50%);
	    display: flex;
	    justify-content: center;
	    align-items: center;
	    width: 100px; 
	    height: 40px; 
	}
	
	.card button {
	    width: 100%; 
	    height: 100%; 
	    padding: 10px 30px;
	    border: none;
	    border-radius: 5px;
	    background-color: #007bff;
	    color: white;
	    font-size: 16px;
	    cursor: pointer;
	    transition: background-color 0.3s ease, transform 0.2s ease;
	    text-transform: uppercase;
	    z-index: 1;
	}
	
	.card button:hover {
	    background-color: #0056b3;
	    transform: scale(1.1);
	}

    .error {
        color: red;
        font-weight: bold;
        margin: 20px;
    }
</style>
</head>
<body>
<%@ include file="header/header.jsp" %>

<h1>Service Categories</h1>

<div class="grid">
    <%
        String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
        String dbUser = "cleaningServices_owner";
        String dbPassword = "mh0zgxauP6HJ";

        Connection connection = null;
        Statement statement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
            String sql = "SELECT * FROM service_category";
            statement = connection.createStatement();
            resultSet = statement.executeQuery(sql);
            while (resultSet.next()) {
                int id = resultSet.getInt("id");
                String categoryName = resultSet.getString("name");
                String description = resultSet.getString("description");
                String imagePath = resultSet.getString("img_path");
    %>
            <div class="card" style="background-image: url('<%= imagePath %>');">
                <h3><%= categoryName %></h3>
                <p><%= description %></p>
                <div class="button-wrapper">
	                <form action="serviceDetails.jsp" method="GET">
	                    <input type="hidden" name="id" value="<%= id %>">
	                    <button type="submit">View Details</button>
	                </form>
                </div>
            </div>
    <%
            }
        } catch (Exception e) {
            application.log("Error fetching service categories: " + e.getMessage());
    %>
        <div class="error">
            An error occurred while loading the service categories. Please try again later.
        </div>
    <%
        } finally {
            if (resultSet != null) try { resultSet.close(); } catch (SQLException ignore) {}
            if (statement != null) try { statement.close(); } catch (SQLException ignore) {}
            if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
        }
    %>
</div>
<%@ include file="footer.html" %>

</body>
</html>
