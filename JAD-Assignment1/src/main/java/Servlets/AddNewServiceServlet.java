package Servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/admin/AddNewServiceServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50   // 50MB
)
public class AddNewServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Directory where uploaded images will be saved
    private static final String UPLOAD_DIR = "img";

    // Database credentials
    private static final String DB_URL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    private static final String DB_USER = "cleaningServices_owner";
    private static final String DB_PASSWORD = "mh0zgxauP6HJ";

    /**
     * Handles the HTTP POST method to create a service and upload an image.
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String serviceName = request.getParameter("name");
        String serviceDescription = request.getParameter("description");
        String servicePriceStr = request.getParameter("price");
        String categoryIdStr = request.getParameter("category_id");

        // Validate and parse price and category ID
        double servicePrice = 0.0;
        int categoryId = 0;
        try {
            servicePrice = Double.parseDouble(servicePriceStr);
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("message", "Invalid price or category ID.");
            getServletContext().getRequestDispatcher("/admin/uploadResult.jsp").forward(request, response);
            return;
        }

        // Get the upload directory path
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String fileName = null;
        int newServiceId = 0;

        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            // Step 1: Insert service record into the database
            String insertServiceSQL = "INSERT INTO service (name, description, price, category_id) VALUES (?, ?, ?, ?) RETURNING id";
            try (PreparedStatement pstmt = connection.prepareStatement(insertServiceSQL)) {
                pstmt.setString(1, serviceName);
                pstmt.setString(2, serviceDescription);
                pstmt.setDouble(3, servicePrice);
                pstmt.setInt(4, categoryId);

                try (ResultSet resultSet = pstmt.executeQuery()) {
                    if (resultSet.next()) {
                        newServiceId = resultSet.getInt("id"); // Get the new service ID
                    }
                }
            }

            // Step 2: Process the uploaded image
            for (Part part : request.getParts()) {
                String contentDisposition = part.getHeader("content-disposition");
                if (contentDisposition != null && contentDisposition.contains("filename=")) {
                    fileName = extractFileName(part);
                    if (fileName != null && !fileName.isEmpty()) {
                        String filePath = uploadPath + File.separator + fileName;
                        part.write(filePath); // Save the file

                        // Step 3: Update the image path in the database
                        String updateImageSQL = "UPDATE service SET img_path = ? WHERE id = ?";
                        try (PreparedStatement pstmt = connection.prepareStatement(updateImageSQL)) {
                            pstmt.setString(1, UPLOAD_DIR + "/" + fileName);
                            pstmt.setInt(2, newServiceId);
                            pstmt.executeUpdate();
                        }
                    }
                }
            }

            request.setAttribute("message", "Service created successfully with ID: " + newServiceId);
        } catch (Exception e) {
            request.setAttribute("message", "Error: " + e.getMessage());
        }

        // Redirect to result page
        getServletContext().getRequestDispatcher("/admin/addService.jsp").forward(request, response);
    }

    /**
     * Extracts the file name from the content-disposition header of the file part.
     */
    private String extractFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition != null && contentDisposition.contains("filename=")) {
            return contentDisposition.substring(contentDisposition.indexOf("filename=") + 10, contentDisposition.length() - 1).replace("\"", "");
        }
        return null;
    }
}
