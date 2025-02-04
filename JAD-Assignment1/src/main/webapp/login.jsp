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
    <title>Login</title>
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
        .login-container {
            width: 300px;
            padding: 30px;
            background-color: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(20px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.4);
            border-radius: 8px;
            text-align: center;
            position: relative; 
        }
        .login-container h2 {
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
        .login-button {
            width: 100%;
            padding: 10px;
            background-color: #4285F4;
            border: none;
            color: white;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
        }
        .login-button:hover {
            background-color: #357ae8;
        }
        .register-link {
            padding-top: 10px;
            width: 100%;
            text-align: left;
            margin: 0 auto;
            display: block;
            color: #00BFFF;
            text-decoration: none;
        }
        .register-link:hover {
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

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        boolean isAuthenticated = false;
        String userId = null;
        String userRole = null;

        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(password.getBytes("UTF-8"));
            String hashedPassword = Base64.getEncoder().encodeToString(hashBytes);
            Class.forName("org.postgresql.Driver");
            try (Connection connection = DriverManager.getConnection(dbURL, dbUser, dbPassword)) {
                String checkUserSQL = "SELECT id, role FROM users WHERE email = ? AND password = ?";
                try (PreparedStatement checkUserStmt = connection.prepareStatement(checkUserSQL)) {
                    checkUserStmt.setString(1, email);
                    checkUserStmt.setString(2, hashedPassword);
                    try (ResultSet rs = checkUserStmt.executeQuery()) {
                        if (rs.next()) {
                            isAuthenticated = true;
                            userId = rs.getString("id");
                            userRole = rs.getString("role");
                        }
                    }
                }

                if (isAuthenticated) {
                    String updateLastLoginSQL = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?";
                    try (PreparedStatement updateLastLoginStmt = connection.prepareStatement(updateLastLoginSQL)) {
                        updateLastLoginStmt.setInt(1, Integer.parseInt(userId));
                        int rowsUpdated = updateLastLoginStmt.executeUpdate();
                        if (rowsUpdated > 0) {
                            System.out.println("Last login updated for user ID: " + userId);
                        } else {
                            System.out.println("Failed to update last login for user ID: " + userId);
                        }
                    }
                }
            }
        } catch (Exception e) {
            out.println("<div class='error'>An error occurred: " + e.getMessage() + "</div>");
        }

        if (isAuthenticated) {
            session.setAttribute("id", userId);
            session.setAttribute("role", userRole);
%>
            <script>
                window.location.href = "landing.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("Invalid email or password. Please try again.");
            </script>
<%
        }
    }
%>
    <div class="login-container">
        <a href="landing.jsp" class="back-button">&lt; Back</a> 
        <h2>Sign in</h2>
        <form action="login.jsp" method="post">
            <input type="text" name="email" class="input-field" placeholder="E-mail" required><br>
            <input type="password" name="password" class="input-field" placeholder="Password" required><br>
            <button type="submit" class="login-button">Login</button>
            <a href="register.jsp" class="register-link">register</a>
        </form>
    </div>
</body>
</html>
