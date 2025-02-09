<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="sessionHandlingAdmin.jsp" %>
<%@ page import="java.util.*" %>
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
            width: 80%;
        }

        .filter-section {
            margin: 20px auto;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            padding: 20px;
            background-color: #e8e8e8;
            border-radius: 10px;
        }

        .filter-section select,
        .filter-section input {
            padding: 12px;
            margin: 5px;
            border-radius: 5px;
            border: 1px solid #ccc;
            font-size: 16px;
            width: 200px;
        }

        .filter-section button {
            padding: 12px 20px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }

        .filter-section button:hover {
            background-color: #0056b3;
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

        h1 {
            margin-top: 70px;
            margin-bottom: 30px;
            color: white;
        }
    </style>
	<script>
	    function updateFilterOptions() {
	        var filterType = document.getElementById("filterType").value;
	
	        // Hide all filters initially
	        document.getElementById("dateInputs").style.display = "none";
	        document.getElementById("monthInput").style.display = "none";
	        document.getElementById("singleDateInput").style.display = "none";
	        document.getElementById("statusInput").style.display = "none"; // Hide status dropdown
	
	        // Show the correct input based on the selected filter
	        if (filterType === "dateRange") {
	            document.getElementById("dateInputs").style.display = "flex";
	        } else if (filterType === "specificDate") {
	            document.getElementById("singleDateInput").style.display = "block";
	        } else if (filterType === "month") {
	            document.getElementById("monthInput").style.display = "block";
	        } else if (filterType === "status") {
	            document.getElementById("statusInput").style.display = "block"; // Show status dropdown
	        }
	    }
	
	    window.onload = function () {
	        updateFilterOptions(); // Ensure the correct options are displayed when the page loads
	    };
	</script>
</head>
<body>

<%@ include file="../header/header.jsp" %>

<div class="container">
    <h1>Booking List with Service Details</h1>

    <!-- Filter Section -->
    <div class="filter-section">
    <form action="/JAD-Assignment2/admin/FilterBookingsServlet" method="GET" 
          style="display: flex; flex-wrap: wrap; gap: 15px; align-items: center;">
        <label for="filterType">Filter By:</label>
        <select id="filterType" name="filterType" onchange="updateFilterOptions()">
            <option value="none" <%= "none".equals(request.getParameter("filterType")) ? "selected" : "" %>>All Records</option>
            <option value="specificDate" <%= "specificDate".equals(request.getParameter("filterType")) ? "selected" : "" %>>Specific Date</option>
            <option value="dateRange" <%= "dateRange".equals(request.getParameter("filterType")) ? "selected" : "" %>>Date Range</option>
            <option value="month" <%= "month".equals(request.getParameter("filterType")) ? "selected" : "" %>>Month</option>
            <option value="status" <%= "status".equals(request.getParameter("filterType")) ? "selected" : "" %>>Status</option>
        </select>

        <!-- Single Date Filter -->
        <div id="singleDateInput" style="display: none;">
            <label for="date">Select Date:</label>
            <input type="date" id="date" name="date" value="<%= request.getParameter("date") %>">
        </div>

        <!-- Date Range Filter -->
        <div id="dateInputs" style="display: none; flex-direction: column;">
            <label for="startDate">Start Date:</label>
            <input type="date" id="startDate" name="startDate" value="<%= request.getParameter("startDate") %>">
            <label for="endDate">End Date:</label>
            <input type="date" id="endDate" name="endDate" value="<%= request.getParameter("endDate") %>">
        </div>

        <!-- Month Filter -->
        <div id="monthInput" style="display: none;">
            <label for="month">Select Month:</label>
            <select id="month" name="month">
                <% for (int i = 1; i <= 12; i++) { %>
                    <option value="<%= i %>" <%= (String.valueOf(i).equals(request.getParameter("month"))) ? "selected" : "" %>>
                        <%= new java.text.DateFormatSymbols().getMonths()[i - 1] %>
                    </option>
                <% } %>
            </select>
        </div>

        <!-- Status Filter (Hidden by Default) -->
        <div id="statusInput" style="display: none;">
            <label for="status">Select Status:</label>
            <select id="status" name="status">
                <option value="pending" <%= "pending".equals(request.getParameter("status")) ? "selected" : "" %>>Pending</option>
                <option value="complete" <%= "complete".equals(request.getParameter("status")) ? "selected" : "" %>>Complete</option>
                <option value="cancelled" <%= "cancelled".equals(request.getParameter("status")) ? "selected" : "" %>>Cancelled</option>
            </select>
        </div>

        <button type="submit">Filter</button>
    </form>
</div>


    <!-- Display Booking List -->
    <table>
        <thead>
            <tr>
                <th>Booking ID</th>
                <th>Service Name</th>
                <th>Booking Date</th>
                <th>Quantity</th>
                <th>Price</th>
                <th>Total (w/ GST)</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <%
                List<Map<String, Object>> bookingDetails = (List<Map<String, Object>>) request.getAttribute("bookingDetails");
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
                <tr>
                    <td colspan="6" style="color: red;"><%= error %></td>
                </tr>
            <%
                } else if (bookingDetails != null && !bookingDetails.isEmpty()) {
                    for (Map<String, Object> booking : bookingDetails) {
            %>
            <tr>
                <td><%= booking.get("bookingId") %></td>
                <td><%= booking.get("serviceName") %></td>
                <td><%= booking.get("bookingDate") %></td>
                <td><%= booking.get("quantity") %></td>
                <td>$<%= String.format("%.2f", Double.parseDouble(booking.get("price").toString())) %></td>
                <td>$<%= String.format("%.2f", Double.parseDouble(booking.get("total").toString()) * 1.09) %></td>
                <td><%= booking.get("status") %></td>
            </tr>
            <%
                    }
                } else {
            %>
            <tr>
                <td colspan="7">No bookings found.</td>
            </tr>
            <%
                }
            %>
        </tbody>
    </table>
</div>

<%@ include file="../footer.html" %>

</body>
</html>
