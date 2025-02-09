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
    }
%>

<!DOCTYPE html>
<html>
<head>
<script src="https://js.stripe.com/v3/"></script>
<meta charset="UTF-8">
<title>Booking</title>
<style>
   	body {
	    margin: 0;
	    font-family: Arial, sans-serif;
	    background-color: #f4f4f4;
	}
	
	.header-gap {
	    height: 60px; 
	}
	
	.container {
	    margin: 0 auto;
	    margin-top: 30px; /* Adjust margin to create space below header gap */
	    width: 60%;
	    display: flex;
	    background-color: #00000022;
	    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
	    padding: 20px;
	}
	
	.details {
	    width: 70%;
	    display: flex;
	    flex-direction: column;
	    padding: 20px;
	    color: white;
	}
	
	.row {
	    margin-top: 15px;
	    display: flex;
	    justify-content: space-between;
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
	    width: 30%;
	    background-color: #00000010;
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
	    height: 250px;
	    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	    border-radius: 10px;
	    padding: 10px;
	    color: white;
	    text-align: center;
	}
	
	.button {
	    width: 100%;
	    height: 40px;
	    background-color: #4285F4;
	    color: white;
	    border: none;
	    cursor: pointer;
	    border-radius: 4px;
	    font-size: 14px;
	}
	
	/* Background Dimming Effect */
	.modal-overlay {
	    display: none;
	    position: fixed;
	    top: 0;
	    left: 0;
	    width: 100%;
	    height: 100%;
	    background: rgba(0, 0, 0, 0.5);
	    z-index: 999;
	}
	
	/* Modal Box */
	.modal {
	    display: none;
	    position: fixed;
	    top: 50%;
	    left: 50%;
	    transform: translate(-50%, -50%);
	    width: 320px;
	    background: white;
	    padding: 20px;
	    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
	    border-radius: 8px;
	    text-align: center;
	    z-index: 1000;
	}
	
	/* Modal Close Button */
	.modal .close-btn {
	    position: absolute;
	    top: 10px;
	    right: 10px;
	    background: none;
	    border: none;
	    font-size: 18px;
	    font-weight: bold;
	    cursor: pointer;
	    color: #333;
	}
	
	/* Modal Input Fields */
	.modal input {
	    width: 90%;
	    padding: 10px;
	    margin: 5px 0;
	    border: 1px solid #ddd;
	    border-radius: 4px;
	}
	
	/* Modal Button */
	.modal button {
	    width: 100%;
	    padding: 10px;
	    background-color: #28a745;
	    color: white;
	    border: none;
	    cursor: pointer;
	    margin-top: 10px;
	}
	
	/* Footer */
	footer {
	    position: fixed;
	    bottom: 0;
	    left: 0;
	    width: 100%;
	    background: #333;
	    color: white;
	    text-align: center;
	    padding: 10px 0;
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

    function updateCost() {
        const servicesDropdown = document.getElementById('services');
        const durationInput = document.getElementById('duration');
        const costSpan = document.getElementById('cost');
        const totalSpan = document.getElementById('total');
        const GSTSpan = document.getElementById('GSTcontent');
        const totalGSTSpan = document.getElementById('totalGST');

        const selectedOption = servicesDropdown.options[servicesDropdown.selectedIndex];
        const costPerHour = parseFloat(selectedOption.getAttribute('data-price')) || 0;
        const duration = parseInt(durationInput.value) || 0;

        const totalCost = costPerHour * duration;
        const gst = totalCost * 0.09;
        const totalWithGST = totalCost + gst;

        costSpan.textContent = costPerHour.toFixed(2);
        totalSpan.textContent = totalCost.toFixed(2);
        GSTSpan.textContent = gst.toFixed(2);
        totalGSTSpan.textContent = totalWithGST.toFixed(2);
    }

    function validateCheckout() {
        const servicesDropdown = document.getElementById('services');
        const dateInput = document.getElementById('date');
        const timeInput = document.getElementById('time');
        const durationInput = document.getElementById('duration');

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


    async function confirmPayment() {
        const serviceId = document.getElementById('services').value;
        const serviceName = document.getElementById('services').options[document.getElementById('services').selectedIndex].text;
        const date = document.getElementById('date').value;
        const time = document.getElementById('time').value;
        const duration = parseInt(document.getElementById('duration').value);

        if (!serviceId || !date || !time || !duration) {
            alert('Please fill in all fields.');
            return;
        }

        // Fetch the cost per hour from the selected service
        const selectedServiceOption = document.getElementById('services').options[document.getElementById('services').selectedIndex];
        const costPerHour = parseFloat(selectedServiceOption.getAttribute('data-price')) || 0;

        // Calculate total cost
        const totalCost = costPerHour * duration;
        const gst = totalCost * 0.09;
        const totalWithGST = totalCost + gst;

        // Construct the payment request payload
        const paymentRequest = {
            productName: serviceName,
            amount: Math.round(totalWithGST * 100), 
            quantity: 1
        };

        try {
            // Step 1: Create Stripe checkout session
            const stripeResponse = await fetch('http://localhost:8081/api/payment/checkout-session', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(paymentRequest)
            });

            if (!stripeResponse.ok) {
                throw new Error('Failed to create Stripe checkout session');
            }

            const stripeData = await stripeResponse.json();
            const sessionId = stripeData.sessionId;

            // Redirect user to Stripe checkout
            const stripe = Stripe('pk_test_51QqjHaRlZMaA2Tk8oxnxP6g6QvFohAkkLzBim5lrIN66f4ZZYXsS1xWuodCCCAbqMpxdJ9osaO9ml1yKjyvp5fYt00NfnmOKoT'); // Replace with your publishable key
            const { error } = await stripe.redirectToCheckout({ sessionId });

            if (error) {
                console.error('Stripe checkout error:', error);
                alert('Payment process failed. Please try again.');
                return;
            }

            // Step 2: Add the booking to the database
            const bookingDetails = {
                serviceId,
                date,
                time,
                duration
            };

            const bookingResponse = await fetch('http://localhost:8081/api/bookings', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(bookingDetails)
            });

            if (!bookingResponse.ok) {
                throw new Error('Failed to add booking to database');
            }

            alert('Payment successful! Booking confirmed.');
            closePaymentPopup();
            window.location.href = '../landing.jsp';

        } catch (error) {
            console.error('Error processing payment:', error);
            alert('An error occurred. Please try again.');
        }
    }

    document.addEventListener('DOMContentLoaded', () => {
        const servicesDropdown = document.getElementById('services');
        const durationInput = document.getElementById('duration');

        servicesDropdown.addEventListener('change', updateCost);
        durationInput.addEventListener('input', updateCost);

        document.getElementById('paymentModal').style.display = 'none';
        document.getElementById('modalOverlay').style.display = 'none';

        // ✅ Check if `success=true` is in the URL after Stripe redirects the user
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('success') === 'true') {
            alert('✅ Payment successful! Booking confirmed.');
        } else if (urlParams.get('success') === 'false') {
            alert('❌ Payment was cancelled or failed.');
        }
    });

</script>
</head>
<body>
<%@ include file="../header/header.jsp" %>
<div class="header-gap"></div>
<div class="container">
    <div class="details">
        <div class="row">
		    <label for="categories">Categories:</label>
		    <select id="categories" name="categories" onchange="updateServices(this.value)">
		        <option value="">Select category</option>
		        <% 
		            Connection conn = null;
		            PreparedStatement stmt = null;
		            ResultSet result = null;
		            try {
		                Class.forName("org.postgresql.Driver");
		                conn = DriverManager.getConnection(
		                    "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require",
		                    "cleaningServices_owner",
		                    "mh0zgxauP6HJ");
		
		                String sql = "SELECT id, name FROM service_category"; // Fetch all categories
		                stmt = conn.prepareStatement(sql);
		                result = stmt.executeQuery();
		
		                while (result.next()) {
		        %>
		        <option value="<%= result.getInt("id") %>"><%= result.getString("name") %></option>
		        <% 
		                }
		            } catch (Exception e) {
		                application.log("Error fetching categories: " + e.getMessage());
		            } finally {
		                if (result != null) try { result.close(); } catch (SQLException ignore) {}
		                if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
		                if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
		            }
		        %>
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
    </div>
    <div class="checkout">
        <div class="box">
            <p id="costPerHour">Cost: $<span id="cost">0</span>/hr</p>
            <p id="totalCost">Total: $<span id="total">0</span></p>
            <p id="GST">GST: $<span id="GSTcontent">0</span></p>
            <p id="totalCostGST">Total (With GST): $<span id="totalGST">0</span></p>
        </div>
        <button class="button" onclick="confirmPayment()">Checkout</button>
    </div>
</div>

<%@ include file="../footer.html" %>
</body>
</html>
