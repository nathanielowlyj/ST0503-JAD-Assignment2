<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingCustomer.jsp" %>
<%
    String uId = (String) session.getAttribute("id");
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet result = null;

    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection(
            "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require",
            "cleaningServices_owner",
            "mh0zgxauP6HJ");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Booking History</title>
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

        h1 {
            text-align: center;
            margin-bottom: 20px;
            color: #ffffff;
        }
    </style>
</head>
<body>
    <%@ include file="../header/header.jsp" %>
    <h1>Booking History</h1>
    <div class="table-container">
        <h2>Upcoming Bookings</h2>
        <table>
            <tr>
                <th>Booking ID</th><th>Service</th>
                <th>Date</th>
                <th>Time</th>
                <th>Quantity</th>
                <th>Price</th>
                <th>Total (w/ GST)</th>
                <th>Actions</th>
            </tr>
            <% 
                String sql = "SELECT bd.id, s.name, bd.booking_date, bd.quantity, bd.price, bd.totalwithgst FROM booking_details bd " +
                             "JOIN booking_list bl ON bd.booking_id = bl.id " +
                             "JOIN service s ON bd.service_id = s.id " +
                             "WHERE bl.user_id = ? AND bd.status = 'pending' AND bd.booking_date >= CURRENT_TIMESTAMP ORDER BY bd.booking_date ASC";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(uId));
                result = stmt.executeQuery();
                
                while (result.next()) {
            %>
            <tr>
                <td><%= result.getInt("id") %></td><td><%= result.getString("name") %></td>
                <td><%= result.getTimestamp("booking_date").toLocalDateTime().toLocalDate() %></td>
                <td><%= result.getTimestamp("booking_date").toLocalDateTime().toLocalTime() %></td>
                <td><%= result.getInt("quantity") %></td>
                <td>$<%= String.format("%.2f", result.getDouble("price")) %></td>
                <td>$<%= String.format("%.2f", result.getDouble("totalwithgst")) %></td>
                <td>
                    <button class="btn edit-btn" onclick="editBooking(<%= result.getInt("id") %>)">Edit</button>
                    <button class="btn cancel-btn" onclick="cancelBooking(<%= result.getInt("id") %>)">Cancel</button>
                </td>
            </tr>
            <% } %>
        </table>
    </div>

    <div class="table-container">
        <h2>Completed Services</h2>
        <table>
            <tr>
                <th>Booking ID</th><th>Service</th>
                <th>Date</th>
                <th>Time</th>
                <th>Quantity</th>
                <th>Total (w/ GST)</th>
            </tr>
            <% 
                sql = "SELECT bd.id, s.name, bd.booking_date, bd.quantity, bd.totalwithgst FROM booking_details bd " +
                      "JOIN booking_list bl ON bd.booking_id = bl.id " +
                      "JOIN service s ON bd.service_id = s.id " +
                      "WHERE bl.user_id = ? AND bd.status = 'complete' ORDER BY bd.booking_date ASC";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(uId));
                result = stmt.executeQuery();
                
                while (result.next()) {
            %>
            <tr>
                <td><%= result.getInt("id") %></td><td><%= result.getString("name") %></td>
                <td><%= result.getTimestamp("booking_date").toLocalDateTime().toLocalDate() %></td>
                <td><%= result.getTimestamp("booking_date").toLocalDateTime().toLocalTime() %></td>
                <td><%= result.getInt("quantity") %></td>
                <td>$<%= String.format("%.2f", result.getDouble("totalwithgst")) %></td>
            </tr>
            <% } %>
        </table>
    </div>
    <%@ include file="../footer.html" %>
<script>
	document.addEventListener('DOMContentLoaded', function () {
	    let today = new Date();
	    today.setDate(today.getDate() + 3);
	    let minDate = today.toISOString().split('T')[0];
	    document.getElementById('editDate').setAttribute('min', minDate);
	});
    function cancelBooking(bookingId) {
        document.getElementById('popup-booking-id').innerText = bookingId;
        document.getElementById('cancelPopup').style.display = 'flex';
        document.getElementById('overlay').style.display = 'block';
    }
    
    function closePopup() {
        document.getElementById('editPopup').style.display = 'none';
        document.getElementById('cancelPopup').style.display = 'none';
        document.getElementById('overlay').style.display = 'none';
    }
    function confirmCancellation() {
        var bookingId = document.getElementById('popup-booking-id').innerText;
        fetch('cancelBooking.jsp?id=' + bookingId, {
            method: 'POST'
        }).then(response => response.text())
          .then(data => {
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
          }).catch(error => {
              document.getElementById('cancelPopupMessage').innerText = 'Error canceling booking: ' + error;
          });
        closePopup();
    }
</script>

<style>
    #overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        transition: opacity 0.3s ease;
    }
    
    #cancelPopup {
        display: none;
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: white;
        padding: 20px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        border-radius: 10px;
        text-align: center;
        transition: opacity 0.3s ease, transform 0.3s ease;
    }
    
    #cancelPopup button {
        margin: 10px;
        padding: 8px 16px;
        border: none;
        cursor: pointer;
    }
</style>

<div id="overlay" onclick="closePopup()"></div>
<div id="cancelPopup" style="display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);">
    <p>Are you sure you want to cancel booking ID: <span id="popup-booking-id"></span>?</p>
    <button onclick="closePopup()">No</button>
    <button onclick="confirmCancellation()">Yes</button>
</div>
<script>
    function editBooking(bookingId) {
        document.getElementById('editPopup-booking-id').value = bookingId;
        document.getElementById('editPopup').style.display = 'flex';
        document.getElementById('overlay').style.display = 'block';
    }
 
    
</script>

<style>
    #editPopup {
        display: none;
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: white;
        padding: 20px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        border-radius: 10px;
        text-align: center;
        transition: opacity 0.3s ease, transform 0.3s ease;
    }
    
    #editPopup button {
        margin: 10px;
        padding: 8px 16px;
        border: none;
        cursor: pointer;
    }
</style>

<div id="overlay" onclick="closeEditPopup()"></div>
<div id="editPopup" style="display: none;">
    <h3>Edit Booking</h3>
    <form id="editBookingForm">
        <input type="hidden" id="editPopup-booking-id" name="bookingId">
        <label for="editDate">Date:</label>
        <input type="date" id="editDate" name="date" required><br>
        <label for="editTime">Time:</label>
        <input type="time" id="editTime" name="time" required><br>
        <button type="button" onclick="closeEditPopup()">Cancel</button>
        <button type="submit">Save Changes</button>
    </form>
</div>
<script>
    document.getElementById('editBookingForm').addEventListener('submit', async function(event) {
        event.preventDefault();
        
        const bookingId = document.getElementById('editPopup-booking-id').value;
        const date = document.getElementById('editDate').value;
        const time = document.getElementById('editTime').value;
        
        fetch('updateBooking.jsp?bookingId=' + bookingId + '&date=' + date + '&time=' + time, {
            method: 'POST'
        }).then(response => response.text())
          .then(data => {
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
              location.reload();
          }).catch(error => {
              document.getElementById('cancelPopupMessage').innerText = 'Error updating booking: ' + error;
          });
    });
</script>
</body>
</html>
<%
    } catch (Exception e) {
        application.log("Error fetching booking history: " + e.getMessage());
    } finally {
        if (result != null) try { result.close(); } catch (SQLException ignore) {}
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
