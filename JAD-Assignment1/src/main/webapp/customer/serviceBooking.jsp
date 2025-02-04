<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingCustomer.jsp" %> 
<%
    if ("fetchServices".equals(request.getParameter("action"))) {
        String categoryId = request.getParameter("categoryId");
        application.log("Received categoryId: " + categoryId);
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet result = null;

        try {
            if (categoryId == null || categoryId.trim().isEmpty()) {
                response.setContentType("application/json");
                out.print("[]");
                return;
            }

            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(
                "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require",
                "cleaningServices_owner",
                "mh0zgxauP6HJ");

            String sql = "SELECT id, name, price FROM service WHERE category_id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(categoryId));
            result = stmt.executeQuery();

            response.setContentType("application/json");
            StringBuilder json = new StringBuilder("[");
            while (result.next()) {
                if (json.length() > 1) json.append(",");
                json.append("{")
                    .append("\"id\":").append(result.getInt("id")).append(",")
                    .append("\"name\":\"").append(result.getString("name")).append("\",")
                    .append("\"price\":").append(result.getDouble("price"))
                    .append("}");
            }
            json.append("]");
            out.print(json.toString());
        } catch (Exception e) {
            application.log("Error fetching services: " + e.getMessage());
            response.setContentType("application/json");
            out.print("[]");
        } finally {
            if (result != null) try { result.close(); } catch (SQLException ignore) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
        return;
    } else if ("addBooking".equals(request.getParameter("action"))) {
        String userId = (String) session.getAttribute("id");
        String serviceId = request.getParameter("serviceId");
        String bookingDate = request.getParameter("date") + " " + request.getParameter("time") + ":00";
        String duration = request.getParameter("duration");
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(
                "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require",
                "cleaningServices_owner",
                "mh0zgxauP6HJ");

            String insertBookingListSQL = "INSERT INTO booking_list (user_id) VALUES (?) RETURNING id";
            stmt = conn.prepareStatement(insertBookingListSQL);
            stmt.setInt(1, Integer.parseInt(userId));
            ResultSet rs = stmt.executeQuery();
            rs.next();
            int bookingId = rs.getInt(1);

            String insertBookingDetailsSQL = "INSERT INTO booking_details (booking_id, service_id, booking_date, quantity, price) " +
                                             "VALUES (?, ?, ?, ?, (SELECT price FROM service WHERE id = ?))";
            stmt = conn.prepareStatement(insertBookingDetailsSQL);
            stmt.setInt(1, bookingId);
            stmt.setInt(2, Integer.parseInt(serviceId));
            stmt.setTimestamp(3, Timestamp.valueOf(bookingDate));
            stmt.setInt(4, Integer.parseInt(duration));
            stmt.setInt(5, Integer.parseInt(serviceId));
            stmt.executeUpdate();

            response.getWriter().write("success");
        } catch (Exception e) {
            application.log("Error booking service: " + e.getMessage());
            response.getWriter().write("error");
        } finally {
            if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Booking</title>
<style>
    body {
        margin: 0;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
    }
    .container {
        margin-top: 168px;
        width: 60%;
        height: auto;
        display: flex;
        background-color: #00000022;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        padding: 10px;
    }
    .details {
        width: 70%;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        padding: 20px;
        padding-top: 30px;
        color: white;
    }
    .row {
        margin-top: 15px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        width: 100%;
    }
    .row label {
        font-size: 16px;
        font-weight: bold;
        margin-right: 10px;
        text-align: left;
        flex: 1; 
    }
    .row input,
    .row select {
        flex: 2; 
        padding: 5px;
        font-size: 14px;
        margin-left: 10px; 
    }
    .checkout {
        margin: 20px;
        margin-top: 30px;
        width: 30%;
        background-color: #00000010;
        box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 10px;
    }
    .checkout .box p {
        top: 30%;
    }
    .box {
        width: 100%;
        height: 500px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        radius: 10px;
        margin-bottom: 10px;
        padding: 10px;
        color: white;
        text-align: center;
    }
    .button {
        width: 100%;
        height: 25px;
        background-color: #4285F4;
        color: white;
        border: none;
        cursor: pointer;
        text-align: center;
        line-height: 25px;
        border-radius: 4px;
        font-size: 14px;
    }
    footer {
        width: 100%;
    }
</style>
<script>
    async function updateServices(categoryId) {
        const servicesDropdown = document.getElementById('services');
        servicesDropdown.innerHTML = '<option value="">Select service</option>';

        if (!categoryId || categoryId.trim() === "") {
            alert('Please select a category.');
            return;
        }
        const url = 'serviceBooking.jsp?action=fetchServices&categoryId=' + categoryId;

        try {
            const response = await fetch(url);
            if (!response.ok) {
                console.error('Failed to fetch services:', response.status, response.statusText);
                return;
            }
            const services = await response.json();
            services.forEach(service => {
                const option = document.createElement('option');
                option.value = service.id;
                option.setAttribute('data-price', service.price || 0);
                option.textContent = service.name;
                servicesDropdown.appendChild(option);
            });
        } catch (error) {
            console.error('Error fetching services:', error);
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        const dateInput = document.getElementById('date');
        const servicesDropdown = document.getElementById('services');
        const durationInput = document.getElementById('duration');
        const timeInput = document.getElementById('time');
        const costSpan = document.getElementById('cost');
        const totalSpan = document.getElementById('total');
        const checkoutButton = document.querySelector('.button');

        const today = new Date();
        today.setDate(today.getDate() + 2);
        const minDate = today.toISOString().split('T')[0];
        dateInput.min = minDate;

        function updateCost() {
            const selectedOption = servicesDropdown.options[servicesDropdown.selectedIndex];
            const costPerHour = parseFloat(selectedOption.getAttribute('data-price')) || 0;
            const duration = parseInt(durationInput.value) || 0;

            costSpan.textContent = costPerHour.toFixed(2);
            totalSpan.textContent = (costPerHour * duration).toFixed(2);
        }

        async function handleCheckout() {
            if (!validateForm()) return;
            const serviceId = servicesDropdown.value;
            const date = dateInput.value;
            const time = timeInput.value;
            const duration = durationInput.value;

            const url = 'serviceBooking.jsp?action=addBooking';
            const params = new URLSearchParams({
                serviceId,
                date,
                time,
                duration,
            });

            try {
                const response = await fetch(url, {
                    method: 'POST',
                    body: params,
                });

                alert('Service booked successfully!');
                window.location.href = '../landing.jsp';
               
            } catch (error) {
                console.error('Error during checkout:', error);
                alert('An error occurred. Please try again.');
            }
        }

        function validateForm() {
            if (!servicesDropdown.value) {
                alert('Please select a service.');
                return false;
            }
            if (!dateInput.value) {
                alert('Please select a date.');
                return false;
            }
            if (!timeInput.value) {
                alert('Please select a time.');
                return false;
            }
            if (!durationInput.value || parseInt(durationInput.value) <= 0) {
                alert('Please enter a valid duration.');
                return false;
            }
            return true;
        }

        servicesDropdown.addEventListener('change', updateCost);
        durationInput.addEventListener('input', updateCost);
        checkoutButton.addEventListener('click', handleCheckout);
    });
</script>
</head>
<body>
<%@ include file="../header/header.jsp" %>
    <div class="container">
        <div class="details">
            <% 
                Connection connection = null;
                PreparedStatement categoryStmt = null;
                ResultSet categoryResult = null;

                try {
                    Class.forName("org.postgresql.Driver");
                    connection = DriverManager.getConnection(
                        "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require",
                        "cleaningServices_owner",
                        "mh0zgxauP6HJ");

                    String categoryQuery = "SELECT id, name FROM service_category";
                    categoryStmt = connection.prepareStatement(categoryQuery);
                    categoryResult = categoryStmt.executeQuery();
            %>
            <div class="row">
                <label for="categories">Categories:</label>
                <select id="categories" name="categories" onchange="updateServices(this.value)">
                    <option value="">Select category</option>
                    <% while (categoryResult.next()) { %>
                        <option value="<%= categoryResult.getInt("id") %>">
                            <%= categoryResult.getString("name") %>
                        </option>
                    <% } %>
                </select>
            </div>
            <div class="row">
                <label for="services">Service:</label>
                <select id="services" name="services">
                    <option value="">Select service</option>
                </select>
            </div>
            <div class="row">
                <label for="date">Date:</label>
                <input type="date" id="date" name="date" />
            </div>
            <div class="row">
                <label for="time">Time:</label>
                <input type="time" id="time" name="time"/>
            </div>
            <div class="row">
                <label for="duration">Duration (Hours):</label>
                <input type="number" id="duration" name="duration" min="1" placeholder="Hours" />
            </div>
            <% 
                } finally {
                    if (categoryResult != null) try { categoryResult.close(); } catch (SQLException ignore) {}
                    if (categoryStmt != null) try { categoryStmt.close(); } catch (SQLException ignore) {}
                    if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
                }
            %>
        </div>
        <div class="checkout">
            <div class="box">
                <p id="costPerHour">Cost: $<span id="cost">0</span>/hr</p>
                <p id="totalCost">Total: $<span id="total">0</span></p>
            </div>
            <button class="button">Checkout</button>
        </div>
    </div>
<%@ include file="../footer.html" %>
</body>
</html>
	