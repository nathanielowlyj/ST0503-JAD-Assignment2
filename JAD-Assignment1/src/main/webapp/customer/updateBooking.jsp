<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="sessionHandlingCustomer.jsp" %>

<%
    String bookingId = request.getParameter("bookingId");
    String date = request.getParameter("date");
    String time = request.getParameter("time");

    if (bookingId != null && date != null && time != null) {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(
                "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require",
                "cleaningServices_owner",
                "mh0zgxauP6HJ");

            String updateSql = "UPDATE booking_details SET booking_date = ? WHERE id = ?";
            stmt = conn.prepareStatement(updateSql);
            stmt.setTimestamp(1, Timestamp.valueOf(date + " " + time + ":00"));
            stmt.setInt(2, Integer.parseInt(bookingId));

            int rowsUpdated = stmt.executeUpdate();

            if (rowsUpdated > 0) {
                out.print("success");
            } else {
                out.print("error");
            }
        } catch (Exception e) {
            application.log("Error updating booking: " + e.getMessage());
            out.print("error");
        } finally {
            if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    } else {
        out.print("error");
    }
%>
