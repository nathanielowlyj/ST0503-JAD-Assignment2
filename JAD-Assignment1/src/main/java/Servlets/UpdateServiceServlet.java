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

@WebServlet("/admin/UpdateServiceServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50   // 50MB
)
public class UpdateServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Directory where uploaded images will be saved
    private static final String UPLOAD_DIR = "img";

    // Database credentials
    private static final String DB_URL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    private static final String DB_USER = "cleaningServices_owner";
    private static final String DB_PASSWORD = "mh0zgxauP6HJ";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String serviceIdStr = request.getParameter("id");
        String serviceName = request.getParameter("name");
        String serviceDescription = request.getParameter("description");
        String servicePriceStr = request.getParameter("price");
        String categoryIdStr = request.getParameter("category_id");

        // Validate and parse input
        int serviceId;
        Double servicePrice = null;
        Integer categoryId = null;
        try {
            serviceId = Integer.parseInt(serviceIdStr);
            if (servicePriceStr != null && !servicePriceStr.isEmpty()) {
                servicePrice = Double.parseDouble(servicePriceStr);
            }
            if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                categoryId = Integer.parseInt(categoryIdStr);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("message", "Invalid input values.");
            request.getRequestDispatcher("/admin/editServices.jsp").forward(request, response);
            return;
        }

        // Get the upload directory path
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String fileName = null;
        boolean isImageUploaded = false;

        // Handle file upload
        for (Part part : request.getParts()) {
            String contentDisposition = part.getHeader("content-disposition");
            if (contentDisposition != null && contentDisposition.contains("filename=")) {
                fileName = extractFileName(part);
                if (fileName != null && !fileName.isEmpty()) {
                    String filePath = uploadPath + File.separator + fileName;
                    part.write(filePath); // Save the file
                    isImageUploaded = true;
                }
            }
        }

        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            // Update only the fields provided
            StringBuilder queryBuilder = new StringBuilder("UPDATE service SET ");
            boolean hasPreviousField = false;

            if (serviceName != null && !serviceName.trim().isEmpty()) {
                queryBuilder.append("name = ?");
                hasPreviousField = true;
            }
            if (serviceDescription != null && !serviceDescription.trim().isEmpty()) {
                if (hasPreviousField) queryBuilder.append(", ");
                queryBuilder.append("description = ?");
                hasPreviousField = true;
            }
            if (servicePrice != null) {
                if (hasPreviousField) queryBuilder.append(", ");
                queryBuilder.append("price = ?");
                hasPreviousField = true;
            }
            if (categoryId != null) {
                if (hasPreviousField) queryBuilder.append(", ");
                queryBuilder.append("category_id = ?");
                hasPreviousField = true;
            }
            if (isImageUploaded) {
                if (hasPreviousField) queryBuilder.append(", ");
                queryBuilder.append("img_path = ?");
            }
            queryBuilder.append(" WHERE id = ?");

            try (PreparedStatement pstmt = connection.prepareStatement(queryBuilder.toString())) {
                int paramIndex = 1;

                if (serviceName != null && !serviceName.trim().isEmpty()) {
                    pstmt.setString(paramIndex++, serviceName.trim());
                }
                if (serviceDescription != null && !serviceDescription.trim().isEmpty()) {
                    pstmt.setString(paramIndex++, serviceDescription.trim());
                }
                if (servicePrice != null) {
                    pstmt.setDouble(paramIndex++, servicePrice);
                }
                if (categoryId != null) {
                    pstmt.setInt(paramIndex++, categoryId);
                }
                if (isImageUploaded) {
                    pstmt.setString(paramIndex++, UPLOAD_DIR + "/" + fileName);
                }
                pstmt.setInt(paramIndex, serviceId);

                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    request.setAttribute("message", "Service updated successfully.");
                } else {
                    request.setAttribute("message", "No changes were made to the service.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("message", "Error: " + e.getMessage());
        }

        // Redirect back to the edit service page
        request.getRequestDispatcher("/admin/editServices.jsp").forward(request, response);
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
