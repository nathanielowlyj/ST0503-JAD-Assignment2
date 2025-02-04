<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.Base64" %>
<%
if (session.getAttribute("id") != null) {
    response.sendRedirect("landing.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: url('img/kitchen-background.jpg') no-repeat center center;
            background-size: cover;
            backdrop-filter: blur(3px);
        }
        .register-container {
            width: 300px;
            padding: 30px;
            background-color: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(20px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.4);
            border-radius: 8px;
            text-align: center;
            position: relative;
        }
        .register-container h2 {
            color: #fefefe;
            font-size: 24px;
            margin-bottom: 20px;
        }
        .input-field {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .register-button {
            width: 100%;
            padding: 10px;
            background-color: #4285F4;
            border: none;
            color: white;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
        }
        .register-button:hover {
            background-color: #357ae8;
        }
        .login-link {
            padding-top: 10px;
            width: 100%;
            text-align: left;
            margin: 0 auto;
            display: block;
            color: #00BFFF;
            text-decoration: none;
        }
        .login-link:hover {
            text-decoration: underline;
        }
        .back-button {
            position: absolute; 
            top: 17px; 
            left: 17px; 
            color: #ffffff;
            text-decoration: none;
            font-size: 12px;
            cursor: pointer;
            transition: transform 0.1s ease; 
        }
        .back-button:hover {
            transform: scale(1.075); 
        }
    </style>
</head>
<body>
<%
    String method = request.getMethod();
    if ("POST".equalsIgnoreCase(method)) {
        String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?user=cleaningServices_owner&password=mh0zgxauP6HJ&sslmode=require";
        String dbUser = "cleaningServices_owner";
        String dbPassword = "mh0zgxauP6HJ";
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        boolean emailExists = false;
        String hashedPassword = null;
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(password.getBytes("UTF-8"));
            hashedPassword = Base64.getEncoder().encodeToString(hashBytes); // Base64 encoding
        } catch (Exception e) {
            out.println("<script>alert('Error hashing password. Please try again.');</script>");
        }

        if (hashedPassword != null) {
            try {
                Class.forName("org.postgresql.Driver");
                try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
                    String checkEmailSQL = "SELECT 1 FROM users WHERE email = ?";
                    try (PreparedStatement checkEmailStmt = connection.prepareStatement(checkEmailSQL)) {
                        checkEmailStmt.setString(1, email);
                        try (ResultSet rs = checkEmailStmt.executeQuery()) {
                            if (rs.next()) {
                                emailExists = true;
                            }
                        }
                    }

                    if (emailExists) {
%>
                        <script>
                            alert("The specified email is already registered. Please use a different email.");
                        </script>
<%
                    } else {
                        String insertUserSQL = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";
                        try (PreparedStatement insertUserStmt = connection.prepareStatement(insertUserSQL)) {
                            insertUserStmt.setString(1, username);
                            insertUserStmt.setString(2, email);
                            insertUserStmt.setString(3, hashedPassword);
                            insertUserStmt.executeUpdate();
%>
                        <script>
                            window.location.href = "login.jsp";
                        </script>
<%
                        }
                    }
                }
            } catch (Exception e) {
                out.println("<div class='error'>An error occurred: " + e.getMessage() + "</div>");
            }
        }
    }
%>
    <div class="register-container">
        <a href="landing.jsp" class="back-button">&lt; Back</a> 
        <h2>Register</h2>
        <form action="register.jsp" method="post">
            <input type="text" name="username" class="input-field" placeholder="Username" required><br>
            <input type="email" name="email" class="input-field" placeholder="Email" required><br>
            <input type="password" name="password" class="input-field" placeholder="Password" required><br>
            <button type="submit" class="register-button">Register</button>
            <a href="login.jsp" class="login-link">Login</a>
        </form>
    </div>
</body>
</html>
