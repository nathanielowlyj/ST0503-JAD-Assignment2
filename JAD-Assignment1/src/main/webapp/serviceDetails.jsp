<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Service Details</title>
<style>
    .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 20px;
        justify-content: center;
        margin: 20px;
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
        bottom: 40%;
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
    
    .popup-button {
        padding: 10px 20px;
        border: none;
        border-radius: 5px;
        background-color: #28a745;
        color: white;
        font-size: 16px;
        cursor: pointer;
        transition: background-color 0.3s ease, transform 0.2s ease;
        text-transform: uppercase;
    }
    
    .popup-button:hover {
        background-color: #218838;
        transform: scale(1.1);
    }
    
    .pop-up-container {
        display: none; 
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7); 
        z-index: 1000;
        justify-content: center;
        align-items: center;
    }
    
    .pop-up-container {
        display: none; 
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7); 
        z-index: 1000;
        justify-content: center;
        align-items: center;
    }

    .pop-up-content {
        background-color: white;
        padding: 20px;
        border-radius: 5px;
        text-align: center;
        width: 50%;
        box-sizing: border-box;
        position: relative; 
        z-index: 1010; 
    }

    .pop-up-close {
        position: absolute;
        top: 10px;
        right: 10px;
        font-size: 24px;
        color: #000;
        cursor: pointer;
        z-index: 1020; 
    }

    .booking-button {
        padding: 10px 20px;
        border: none;
        border-radius: 5px;
        background-color: #007bff;
        color: white;
        font-size: 16px;
        cursor: pointer;
        text-transform: uppercase;
        margin-top: 20px;
    }

    .booking-button:hover {
        background-color: #0056b3;
    }

</style>
</head>
<body>
<%@ include file="header/header.jsp" %>
<div class="grid" style="margin-top: 80px;">
    <%
        String serviceId = request.getParameter("id");
        String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
        String dbUser = "cleaningServices_owner";
        String dbPassword = "mh0zgxauP6HJ";

        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("org.postgresql.Driver");
            connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
            String sql = "SELECT * FROM service WHERE category_id = ?";
            preparedStatement = connection.prepareStatement(sql);
            preparedStatement.setInt(1, Integer.parseInt(serviceId)); 
            resultSet = preparedStatement.executeQuery();

            while (resultSet.next()) {
                int id = resultSet.getInt("id");
                String serviceName = resultSet.getString("name");
                String description = resultSet.getString("description");
                String imagePath = resultSet.getString("img_path");
                double price = resultSet.getDouble("price");
    %>
            <div class="card" style="background-image: url('<%= imagePath %>');">
			    <h3 class="serviceName"><%= serviceName %></h3>
			    <p class="price">Price: $<%= price %></p>
			    <div class="description" style="display: none;"><%= description %></div>
			    <div class="button-wrapper">
			        <form action="serviceDetails.jsp" method="GET">
			            <input type="hidden" name="id" value="<%= id %>">
			            <button type="submit" class="popup-button">View Details</button>
			        </form>
			    </div>
			</div>
    <%
            }
        } catch (Exception e) {
            application.log("Error fetching services: " + e.getMessage());
    %>
        <div class="error">
            An error occurred while loading the services. Please try again later.
        </div>
    <%
        } finally {
            if (resultSet != null) try { resultSet.close(); } catch (SQLException ignore) {}
            if (preparedStatement != null) try { preparedStatement.close(); } catch (SQLException ignore) {}
            if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
        }
    %>
</div>

<!-- Popup -->
<div id="popup" class="pop-up-container">
    <div class="pop-up-content">
        <span class="pop-up-close" onclick="closePopup()">&times;</span>
        <h3 id="popup-name">Service Name</h3>
        <p id="popup-description">Description of the service goes here.</p>
        <p>Price: $<span id="popup-price"></span></p>
        <input type="hidden" id="popup-service-id" value="">
        <button class="booking-button" onclick="bookService()">Book Now</button>
    </div>
</div>

<script>
    function showPopup(serviceName, description, price, serviceId) {
        document.getElementById('popup-name').textContent = serviceName;
        document.getElementById('popup-description').textContent = description;
        document.getElementById('popup-price').textContent = price;
        document.getElementById('popup-service-id').value = serviceId;
        document.getElementById("popup").style.display = "flex";
    }

    function closePopup() {
        document.getElementById("popup").style.display = "none"; 
    }

    document.querySelectorAll('.popup-button').forEach(button => {
        button.addEventListener('click', function(event) {
            event.preventDefault();
            const card = this.closest('.card');
            const serviceName = card.querySelector('.serviceName').textContent;
            const description = card.querySelector('.description').textContent;
            const price = card.querySelector('.price').textContent.split('$')[1];
            const serviceId = card.querySelector('form input[name="id"]');
            showPopup(serviceName, description, price, serviceId);
        });
    });

    function bookService() {
    	const serviceId = document.getElementById('popup-service-id').value;
        window.location.href = "customer/serviceBooking.jsp";
    }
</script>

<%@ include file="footer.html" %>
</body>
</html>
