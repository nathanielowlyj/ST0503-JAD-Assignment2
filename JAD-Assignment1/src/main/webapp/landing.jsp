<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <title>Cleaning Service Landing Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            color: #333;
            line-height: 1.6;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: #4d637a;
            padding: 15px 30px;
            color: white;
        }

        header .logo {
            font-size: 24px;
            font-weight: bold;
        }

        header .nav-links {
            display: flex;
            gap: 15px;
        }

        header .nav-links a {
            color: white;
            text-decoration: none;
            font-weight: bold;
        }

        header .nav-links a:hover {
            text-decoration: underline;
        }

        .hero {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            padding: 50px 30px;
            background: linear-gradient(135deg, #4d637a, #7da3d1);
            color: white;
        }

        #landingImg {
            max-width: 50%;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
        }

        .hero .hero-text {
            max-width: 45%;
        }

        .hero .hero-text h1 {
            font-size: 48px;
            margin-bottom: 20px;
        }

        .hero .hero-text p {
            font-size: 18px;
            margin-bottom: 20px;
        }

        .hero .hero-text button {
            padding: 10px 20px;
            font-size: 18px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .hero .hero-text button:hover {
            background-color: #0056b3;
        }

        .reviews {
            display: flex;
            justify-content: space-between;
            padding: 50px 30px;
            background-color: #fff;
        }

        .review, .fake-person {
            flex: 1;
            margin: 0 15px;
            padding: 20px;
            background-color: #f1f1f1;
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .review h2, .fake-person h2 {
            font-size: 24px;
            margin-bottom: 10px;
        }

        .review p, .fake-person p {
            font-size: 16px;
        }
    </style>
</head>
<body>
<%@ include file="header/header.jsp" %>
    <section class="hero">
        <div class="hero-text">
            <h1>Welcome to BrightSpace</h1>
            <p>Discover the best cleaning services for your home and office. Book today for a spotless tomorrow!</p>
            <button onclick="window.location.href='customer/serviceBooking.jsp'">Book Now</button>
        </div>
        <img src="img/landing.jpg" alt="Cleaning Service" id="landingImg">
    </section>

    <section class="reviews">
    <div class="review">
        <h2>Customer Reviews</h2>
        <%
            String user_id = "2"; 
            String dbURL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
            String dbUser = "cleaningServices_owner";
            String dbPassword = "mh0zgxauP6HJ";

            Connection connection = null;
            PreparedStatement stmt = null;
            ResultSet resultSet = null;

            try {
                Class.forName("org.postgresql.Driver");
                connection = DriverManager.getConnection(dbURL, dbUser, dbPassword);

                // Query to fetch feedback from user ID 2
                String sql = "SELECT description, rating FROM feedback WHERE user_id = ?";
                stmt = connection.prepareStatement(sql);
                stmt.setInt(1, Integer.parseInt(user_id));
                resultSet = stmt.executeQuery();

                if (resultSet.next()) {
                    do {
                        String feedback = resultSet.getString("description");
                        int rating = resultSet.getInt("rating");
        %>
                        <p>"<%= feedback %>"</p>
                        <p>Rating: <%= rating %>/5</p>
                        <hr>
        <%
                    } while (resultSet.next());
                } else {
        %>
                    <p>No reviews from this user yet.</p>
        <%
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>Error fetching reviews: " + e.getMessage() + "</p>");
            } finally {
                if (resultSet != null) try { resultSet.close(); } catch (SQLException ignore) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
            }
        %>
    </div>
    <div class="fake-person">
        <h2>Meet Jane Doe</h2>
        <p>Jane has been a trusted cleaner for 5 years, bringing smiles and cleanliness to every home.</p>
    </div>
</section>


<%@ include file="footer.html" %>
</body>
</html>
