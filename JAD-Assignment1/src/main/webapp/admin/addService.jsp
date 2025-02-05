<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="sessionHandlingAdmin.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Create Service</title>
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
            background-color: #4d637a;
        }

        .form-container {
            background-color: white;
            padding: 30px 40px;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
            width: 400px;
        }

        .form-container h1 {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
            text-align: center;
        }

        .form-container label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }

        .form-container input, .form-container textarea, .form-container select, .form-container button {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }

        .form-container textarea {
            resize: none;
        }

        .add-btn {
            background-color: #28a745;
            color: white;
            border: none;
        }

        .add-btn:hover {
            background-color: #218838;
        }

        .close-btn {
            background-color: #dc3545;
            color: white;
            border: none;
        }

        .close-btn:hover {
            background-color: #c82333;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
        }

        .modal-content {
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.3);
            text-align: center;
        }

        .modal-content button {
            margin-top: 15px;
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .modal-content button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
<%
    // Fetch categories for the dropdown
    List<String[]> categories = new ArrayList<>();
    try (Connection connection = DriverManager.getConnection("jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require", "cleaningServices_owner", "mh0zgxauP6HJ");
         PreparedStatement pstmt = connection.prepareStatement("SELECT id, name FROM service_category");
         ResultSet resultSet = pstmt.executeQuery()) {

        while (resultSet.next()) {
            categories.add(new String[]{resultSet.getString("id"), resultSet.getString("name")});
        }
    } catch (Exception e) {
        application.log("Error fetching categories: " + e.getMessage());
    }
%>

<div class="form-container">
    <h1>Create Service</h1>
    <form action="/JAD-Assignment2/admin/AddNewServiceServlet" method="POST" enctype="multipart/form-data" onsubmit="showSuccessModal(event)">
        <label for="name">Service Name</label>
        <input type="text" id="name" name="name" required>

        <label for="description">Description</label>
        <textarea id="description" name="description" required></textarea>

        <label for="price">Price</label>
        <input type="number" step="0.01" id="price" name="price" required>

        <label for="category_id">Category</label>
        <select id="category_id" name="category_id" required>
            <% for (String[] category : categories) { %>
                <option value="<%= category[0] %>"><%= category[1] %></option>
            <% } %>
        </select>

        <label for="image">Service Image</label>
        <input type="file" id="image" name="image" accept="image/*" required>

        <button type="submit" class="add-btn">Create Service</button>
        <button type="button" class="close-btn" onclick="window.location.href='adminServices.jsp';">Close</button>
    </form>
</div>

<div class="modal" id="successModal">
    <div class="modal-content">
        <p>Service created successfully!</p>
        <button onclick="closeSuccessModal()">Close</button>
    </div>
</div>

<script>
    function showSuccessModal(event) {
        event.preventDefault(); // Prevent the default form submission
        const form = event.target;

        const formData = new FormData(form);

        // Send the form data using Fetch API
        fetch(form.action, {
            method: form.method,
            body: formData,
        })
            .then(response => {
                if (response.ok) {
                    document.getElementById('successModal').style.display = 'flex';
                } else {
                    alert('An error occurred while creating the service.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred. Please try again.');
            });
    }

    function closeSuccessModal() {
        document.getElementById('successModal').style.display = 'none';
        window.location.href = 'adminServices.jsp';
    }
</script>
</body>
</html>
