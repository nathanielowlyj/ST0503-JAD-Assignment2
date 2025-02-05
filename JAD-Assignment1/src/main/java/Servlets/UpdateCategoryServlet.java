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

@WebServlet("/admin/UpdateCategoryServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class UpdateCategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Database credentials
    private static final String DB_URL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    private static final String DB_USER = "cleaningServices_owner";
    private static final String DB_PASSWORD = "mh0zgxauP6HJ";

    // Image upload directory
    private static final String UPLOAD_DIR = "category_images";

    /**
     * Handles POST requests to update category details, including an optional image upload.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String message = "";
        String imagePath = null;

        try {
            // Parse category ID
            String categoryIdStr = request.getParameter("id");
            if (categoryIdStr == null || categoryIdStr.isEmpty()) {
                throw new IllegalArgumentException("Invalid category ID.");
            }
            int categoryId = Integer.parseInt(categoryIdStr);

            // Get updated category name and description
            String categoryName = request.getParameter("name");
            String categoryDescription = request.getParameter("description");

            // Validate fields
            if (categoryName == null || categoryName.isEmpty() || categoryDescription == null || categoryDescription.isEmpty()) {
                throw new IllegalArgumentException("Category name and description cannot be empty.");
            }

            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                // Handle image upload if provided
                Part filePart = request.getPart("image");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = extractFileName(filePart);
                    if (fileName != null && !fileName.isEmpty()) {
                        // Define image upload path
                        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }

                        // Save the file
                        String filePath = uploadPath + File.separator + fileName;
                        filePart.write(filePath);
                        imagePath = UPLOAD_DIR + "/" + fileName;
                    }
                }

                // Construct SQL query based on whether an image was uploaded
                String updateSQL;
                if (imagePath != null) {
                    updateSQL = "UPDATE service_category SET name = ?, description = ?, img_path = ? WHERE id = ?";
                } else {
                    updateSQL = "UPDATE service_category SET name = ?, description = ? WHERE id = ?";
                }

                try (PreparedStatement pstmt = connection.prepareStatement(updateSQL)) {
                    pstmt.setString(1, categoryName);
                    pstmt.setString(2, categoryDescription);
                    if (imagePath != null) {
                        pstmt.setString(3, imagePath);
                        pstmt.setInt(4, categoryId);
                    } else {
                        pstmt.setInt(3, categoryId);
                    }

                    int rowsAffected = pstmt.executeUpdate();
                    if (rowsAffected > 0) {
                        message = "Category updated successfully.";
                    } else {
                        message = "Failed to update the category. Please try again.";
                    }
                }
            }
        } catch (Exception e) {
            message = "Error updating category: " + e.getMessage();
        }

        // Pass values back to JSP for display
        request.setAttribute("message", message);
        request.getRequestDispatcher("/admin/editCategory.jsp").forward(request, response);
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
