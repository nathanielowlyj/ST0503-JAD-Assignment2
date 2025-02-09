<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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

<div class="table-container">
    <h1>Services</h1>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Category Name</th>
                <th>Name</th>
                <th>Description</th>
                <th>Price</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody id="servicesTableBody">
            <!-- Table rows will be populated dynamically -->
        </tbody>
    </table>
    <div class="pagination" id="servicesPagination">
        <!-- Pagination buttons will be dynamically populated -->
    </div>
    <form action="addService.jsp" method="GET">
        <button type="submit" class="create-btn">Create New Service</button>
    </form>
</div>

<div class="table-container">
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
        <tbody id="categoriesTableBody">
            <!-- Table rows will be populated dynamically -->
        </tbody>
    </table>
    <div class="pagination" id="categoriesPagination">
        <!-- Pagination buttons will be dynamically populated -->
    </div>
    <form action="addCategory.jsp" method="GET">
        <button type="submit" class="create-btn">Create New Category</button>
    </form>
</div>

<script>
const pageSize = 5;

function fetchServices(page = 1) {
    fetch('http://localhost:8081/api/services?page=' + page + '&size=' + pageSize)
        .then(response => response.json())
        .then(data => {
            const servicesTableBody = document.getElementById('servicesTableBody');
            const servicesPagination = document.getElementById('servicesPagination');
            servicesTableBody.innerHTML = '';
            servicesPagination.innerHTML = '';

            data.content.forEach(service => {
                servicesTableBody.innerHTML += 
                    '<tr>' +
                        '<td>' + service.id + '</td>' +
                        '<td>' + service.category_name + '</td>' +
                        '<td>' + service.name + '</td>' +
                        '<td>' + service.description + '</td>' +
                        '<td>$' + service.price.toFixed(2) + '</td>' +
                        '<td class="action-buttons">' +
                            '<form action="editServices.jsp" method="GET" style="display:inline;">' +
                                '<input type="hidden" name="id" value="' + service.id + '">' +
                                '<button type="submit">Edit</button>' +
                            '</form>' +
                            '<form action="deleteServices.jsp" method="POST" style="display:inline;">' +
                                '<input type="hidden" name="id" value="' + service.id + '">' +
                                '<button type="submit" class="delete">Delete</button>' +
                            '</form>' +
                        '</td>' +
                    '</tr>';
            });

            for (let i = 1; i <= data.totalPages; i++) {
                servicesPagination.innerHTML += 
                    '<a href="#" class="' + (i === page ? 'active' : '') + '" onclick="fetchServices(' + i + ')">' + i + '</a>';
            }
        })
        .catch(error => console.error('Error fetching services:', error));
}

function fetchCategories(page = 1) {
    fetch('http://localhost:8081/api/categories?page=' + page + '&size=' + pageSize)
        .then(response => response.json())
        .then(data => {
            const categoriesTableBody = document.getElementById('categoriesTableBody');
            const categoriesPagination = document.getElementById('categoriesPagination');
            categoriesTableBody.innerHTML = '';
            categoriesPagination.innerHTML = '';

            data.content.forEach(category => {
                categoriesTableBody.innerHTML += 
                    '<tr>' +
                        '<td>' + category.id + '</td>' +
                        '<td>' + category.name + '</td>' +
                        '<td>' + category.description + '</td>' +
                        '<td class="action-buttons">' +
                            '<form action="editCategory.jsp" method="GET" style="display:inline;">' +
                                '<input type="hidden" name="id" value="' + category.id + '">' +
                                '<button type="submit">Edit</button>' +
                            '</form>' +
                            '<form action="deleteCategory.jsp" method="POST" style="display:inline;">' +
                                '<input type="hidden" name="id" value="' + category.id + '">' +
                                '<button type="submit" class="delete">Delete</button>' +
                            '</form>' +
                        '</td>' +
                    '</tr>';
            });

            for (let i = 1; i <= data.totalPages; i++) {
                categoriesPagination.innerHTML += 
                    '<a href="#" class="' + (i === page ? 'active' : '') + '" onclick="fetchCategories(' + i + ')">' + i + '</a>';
            }
        })
        .catch(error => console.error('Error fetching categories:', error));
}

document.addEventListener('DOMContentLoaded', function () {
    fetchServices();
    fetchCategories();
});
</script>


<%@ include file="../footer.html" %>
</body>
</html>
