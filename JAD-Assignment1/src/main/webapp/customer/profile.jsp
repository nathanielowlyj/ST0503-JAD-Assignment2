<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingCustomer.jsp" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Profile</title>
<style>    
    .container {
        margin-top: 60px;
        width: 60%;
        height: 100%;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        background-color: #00000022;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        padding: 25px;
        padding-top:50px;
        align-self: center;
    }
    .row {
        margin-top: 15px;
        margin-bottom: 15px;
        padding-left: 20%;
        padding-right: 20%;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .row label {
        color: white;
        font-size: 16px;
        flex: 1;
    }
    .button {
        flex: 0 0 auto;
        height: 30px;
        width: 150px;
        background-color: white;
        color: black;
        border: 1px solid black;
        cursor: pointer;
        text-align: center;
        line-height: 30px;
        font-size: 14px;
        padding: 0 10px;
        box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2);
        transition: transform 0.2s, box-shadow 0.2s;
    }
    .button:hover {
        transform: translateY(-2px);
        box-shadow: 4px 4px 10px rgba(0, 0, 0, 0.3);
    }
    .left-aligned {
        justify-content: flex-start;
    }
</style>
</head>
<body>
<%@ include file="../header/header.jsp" %>
<div class="container">
<%
    String uId = (String) session.getAttribute("id");
    String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    String dbUser = "cleaningServices_owner";
    String dbPassword = "mh0zgxauP6HJ";

    try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);
         PreparedStatement preparedStatement = connection.prepareStatement(
             "SELECT name, email, account_creation_date FROM users WHERE id = ?")) {
        
        preparedStatement.setInt(1, Integer.parseInt(uId));
        try (ResultSet resultSet = preparedStatement.executeQuery()) {
            if (resultSet.next()) {
                String name = resultSet.getString("name");
                String email = resultSet.getString("email");
                String accountCreationDate = resultSet.getString("account_creation_date");
%>
    <div class="row">
        <label>Username: <%= name %></label>
        <button class="button" onclick="window.location.href='updateUsername.jsp'">Change Username</button>
    </div>
    <div class="row">
        <label>Email: <%= email %></label>
        <button class="button" onclick="window.location.href='updateEmail.jsp'">Change Email</button>
    </div>
    <div class="row">
        <label>Account created at: <%= accountCreationDate %></label>
    </div>
    <div class="row left-aligned">
        <button class="button" onclick="window.location.href='updatePassword.jsp'">Change Password</button>
    </div>
<%
            } else {
%>
    <div class="error">User details not found.</div>
<%
            }
        }
    } catch (Exception e) {
%>
    <div class="error">An error occurred while loading the user details. Please try again later.</div>
<%
        e.printStackTrace();
    }
%>
</div>
<%@ include file="../footer.html" %>
</body>
</html>
