<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="sessionHandlingAdmin.jsp" %>
<%@ page import = "java.util.*" %>
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

        .tabs {
            display: flex;
            justify-content: center;
            margin: 20px 0;
        }

        .tabs button {
            padding: 10px 15px;
            margin: 0 5px;
            cursor: pointer;
            border: 1px solid #6c757d;
            background-color: #495057;
            color: white;
            border-radius: 5px;
        }

        .tabs button.active {
            background-color: #6c757d;
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        h1 {
            margin-top: 50px;
            margin-bottom: 30px;
            color: #ffffff;
        }

        .footer-space {
            margin-bottom: 50px;
        }

        .search-bar {
            margin: 20px;
            display: flex;
            justify-content: center;
            gap: 10px;
        }

        .search-bar input {
            padding: 10px;
            font-size: 14px;
            width: 200px;
            border: 1px solid #6c757d;
            border-radius: 5px;
        }

        .search-bar button {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            color: white;
            background-color: #007bff;
        }

        .search-bar button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
<%@ include file="../header/header.jsp" %>

<div class="container">
    <h1>Manage Registered Customers</h1>

    <!-- Tabs -->
    <div class="tabs">
        <button class="tab-button" data-tab="manageCustomers">Manage Customers</button>
        <button class="tab-button" data-tab="top10Customers">Top 10 Customers</button>
        <button class="tab-button" data-tab="customersByArea">Customers by Area</button>
        <button class="tab-button" data-tab="customersByService">Customers by Service</button>
    </div>

	<!-- Manage Customers -->
	<div id="manageCustomers" class="tab-content">
	    <h2>All Customers</h2>
	    <div class="search-bar">
	        <input 
	            type="text" 
	            id="manageCustomersSearch" 
	            placeholder="Search by Name..." 
	            style="padding: 10px; width: 300px; border: 1px solid #6c757d; border-radius: 5px;" 
	        />
	    </div>
	    <table>
	        <thead>
	            <tr>
	                <th>ID</th>
	                <th>Name</th>
	                <th>Email</th>
	                <th>Postal Code</th>
	                <th>Account Creation Date</th>
	                <th>Last Login</th>
	                <th>Actions</th> 
	            </tr>
	        </thead>
	        <tbody id="manageCustomersTable"></tbody>
	    </table>
	</div>


    <!-- Top 10 Customers -->
    <div id="top10Customers" class="tab-content">
        <h2>Top 10 Customers</h2>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Total Spent</th>
                </tr>
            </thead>
            <tbody id="top10CustomersTable"></tbody>
        </table>
    </div>

    <!-- Customers by Area -->
    <div id="customersByArea" class="tab-content">
        <h2>Search Customers by Area Code</h2>
        <form id="areaSearchForm" class="search-bar">
            <input type="text" name="areaCode" placeholder="Enter area code" required>
            <button type="submit">Search</button>
        </form>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Postal Code</th>
                </tr>
            </thead>
            <tbody id="areaCustomersTable"></tbody>
        </table>
    </div>

    <!-- Customers by Service -->
    <div id="customersByService" class="tab-content">
        <h2>Search Customers by Service Id</h2>
        <form id="serviceSearchForm" class="search-bar">
            <input type="text" name="serviceId" placeholder="Enter service ID" required>
            <button type="submit">Search</button>
        </form>
        <table>
	    <thead>
	        <tr>
	            <th>ID</th>
	            <th>Name</th>
	            <th>Email</th>
	            <th>Service Quantity</th>
	            <th>Booking Date</th> 
	            <th>Status</th> 
	        </tr>
	    </thead>
	    	<tbody id="serviceCustomersTable"></tbody>
		</table>

    </div>
</div>

<div class="footer-space"></div>
<%@ include file="../footer.html" %>

<script>
    let manageCustomersData = []; // Store fetched customer data for filtering

    function showTab(tabId) {
        const tabs = document.querySelectorAll('.tab-content');
        tabs.forEach(tab => tab.classList.remove('active'));

        const activeTab = document.getElementById(tabId);
        if (activeTab) activeTab.classList.add('active');

        const buttons = document.querySelectorAll('.tabs button');
        buttons.forEach(button => button.classList.remove('active'));

        const activeButton = document.querySelector(`[data-tab="${tabId}"]`);
        if (activeButton) activeButton.classList.add('active');

        if (tabId === "manageCustomers") {
            fetchManageCustomers();
        } else if (tabId === "top10Customers") {
            fetchTop10Customers();
        }
    }

    // Fetch and store Manage Customers data
    function fetchManageCustomers() {
        fetch('/JAD-Assignment2/admin/ManageCustomers')
            .then(response => response.json())
            .then(data => {
                manageCustomersData = data; // Store fetched data
                updateFilteredCustomers(); // Initial display of all data
            })
            .catch(error => console.error('Error fetching Manage Customers:', error));
    }

    // Function to update the displayed customers based on search term
    function updateFilteredCustomers() {
        const searchTerm = document.getElementById("manageCustomersSearch").value.toLowerCase();
        const filteredData = manageCustomersData.filter(customer =>
            customer.name.toLowerCase().includes(searchTerm)
        );
        populateTable(filteredData, 'manageCustomersTable');
    }

    // Fetch Top 10 Customers
    function fetchTop10Customers() {
        fetch('/JAD-Assignment2/admin/GetTopCustomersServlet')
            .then(response => response.json())
            .then(data => {
                populateTable(data, 'top10CustomersTable');
            })
            .catch(error => console.error('Error fetching Top 10 Customers:', error));
    }

    // Fetch Customers By Area
    document.getElementById("areaSearchForm").addEventListener("submit", function (e) {
        e.preventDefault();
        const formData = new URLSearchParams(new FormData(this)).toString();

        fetch('/JAD-Assignment2/admin/GetCustomersByAreaServlet', {
            method: 'POST',
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData
        })
            .then(response => response.json())
            .then(data => {
                if (Array.isArray(data)) {
                    populateTable(data, 'areaCustomersTable');
                } else if (data.message) {
                    displayMessage('areaCustomersTable', data.message);
                } else if (data.error) {
                    displayMessage('areaCustomersTable', `Error: ${data.error}`);
                }
            })
            .catch(error => displayMessage('areaCustomersTable', `Error fetching Customers by Area: ${error}`));
    });

    // Fetch Customers By Service
    document.getElementById("serviceSearchForm").addEventListener("submit", function (e) {
        e.preventDefault();
        const formData = new URLSearchParams(new FormData(this)).toString();

        fetch('/JAD-Assignment2/admin/GetCustomersByServiceServlet', {
            method: 'POST',
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData
        })
            .then(response => response.json())
            .then(data => {
                if (Array.isArray(data)) {
                    populateTable(data, 'serviceCustomersTable');
                } else if (data.message) {
                    displayMessage('serviceCustomersTable', data.message);
                } else if (data.error) {
                    displayMessage('serviceCustomersTable', `Error: ${data.error}`);
                }
            })
            .catch(error => displayMessage('serviceCustomersTable', `Error fetching Customers by Service: ${error}`));
    });


    function populateTable(dataArray, tableId) {
        const tableBody = document.getElementById(tableId);
        tableBody.innerHTML = "";

        if (!Array.isArray(dataArray) || dataArray.length === 0) {
            displayMessage(tableId, "No customers found.");
            return;
        }

        dataArray.forEach(item => {
            const row = document.createElement('tr');
            row.setAttribute("data-id", item.id);

            if (tableId === 'manageCustomersTable') {
                const idCell = document.createElement('td');
                idCell.textContent = item.id;
                row.appendChild(idCell);

                const nameCell = document.createElement('td');
                nameCell.textContent = item.name;
                row.appendChild(nameCell);

                const emailCell = document.createElement('td');
                emailCell.textContent = item.email;
                row.appendChild(emailCell);

                const postalCodeCell = document.createElement('td');
                postalCodeCell.textContent = item.postalCode;
                row.appendChild(postalCodeCell);

                const accountCreationDateCell = document.createElement('td');
                accountCreationDateCell.textContent = item.accountCreationDate;
                row.appendChild(accountCreationDateCell);

                const lastLoginCell = document.createElement('td');
                lastLoginCell.textContent = item.lastLogin;
                row.appendChild(lastLoginCell);

                const actionsCell = document.createElement('td');

                (function(currentId) {
                    const editButton = document.createElement('button');
                    editButton.textContent = "Edit";
                    editButton.style.padding = "8px 12px";
                    editButton.style.marginRight = "5px";
                    editButton.style.backgroundColor = "#28a745";
                    editButton.style.color = "white";
                    editButton.style.border = "none";
                    editButton.style.borderRadius = "5px";
                    editButton.style.cursor = "pointer";
                    editButton.onclick = function() { window.location.href = `/JAD-Assignment2/admin/editCustomerInfo.jsp?customerId=${currentId}`; }; 

                    const banButton = document.createElement('button');
                    banButton.textContent = "Ban User";
                    banButton.style.padding = "8px 12px";
                    banButton.style.backgroundColor = "#dc3545";
                    banButton.style.color = "white";
                    banButton.style.border = "none";
                    banButton.style.borderRadius = "5px";
                    banButton.style.cursor = "pointer";
                    banButton.onclick = function() {
                        if (confirm(`Are you sure you want to ban User ID: ${currentId}? This action cannot be undone.`)) {
                            fetch(`/JAD-Assignment2/admin/BanCustomerServlet`, {
                                method: 'POST',
                                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                                body: `customerId=${currentId}`
                            })
                            .then(response => response.json())
                            .then(data => {
                                if (data.success) {
                                    alert(`User ID ${currentId} has been banned successfully.`);
                                    fetchManageCustomers(); 
                                } else {
                                    alert(`Error banning user: ${data.error}`);
                                }
                            })
                            .catch(error => alert(`Error processing ban request: ${error}`));
                        }
                    }; 

                    actionsCell.appendChild(editButton);
                    actionsCell.appendChild(banButton);

                })(item.id); // Pass the current id to the IIFE

                row.appendChild(actionsCell);
            } else { // Handle other tables (top10Customers, etc.) dynamically
                Object.keys(item).forEach(key => {
                    const cell = document.createElement('td');
                    cell.textContent = item[key];
                    row.appendChild(cell);
                });
            }

            tableBody.appendChild(row);
        });
    }

    // Function to handle banning a customer with confirmation popup
    function banCustomer(id) {
        if (confirm(`Are you sure you want to ban User ID: ${id}? This action cannot be undone.`)) {
            fetch(`/JAD-Assignment2/admin/BanCustomerServlet`, {
                method: 'POST',
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: `customerId=${id}`
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert(`User ID ${id} has been banned successfully.`);
                    fetchManageCustomers(); // Refresh table after banning
                } else {
                    alert(`Error banning user: ${data.error}`);
                }
            })
            .catch(error => alert(`Error processing ban request: ${error}`));
        }
    }


    // Display a Message in the Table
    function displayMessage(tableId, message) {
        const tableBody = document.getElementById(tableId);
        tableBody.innerHTML = "<tr><td colspan='7'>" + message + "</td></tr>";
    }

    // Attach event listener for live search in Manage Customers
    document.addEventListener("DOMContentLoaded", function () {
        const searchInput = document.getElementById("manageCustomersSearch");
        if (searchInput) {
            searchInput.addEventListener("input", updateFilteredCustomers);
        }

        const buttons = document.querySelectorAll('.tab-button');
        buttons.forEach(button => {
            button.addEventListener('click', () => {
                showTab(button.getAttribute('data-tab'));
            });
        });

        showTab('manageCustomers');
        fetchManageCustomers(); 
        fetchTop10Customers();
    });
</script>
</body>
</html>
