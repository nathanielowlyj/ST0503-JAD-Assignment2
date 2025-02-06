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

/**
 * Servlet implementation class AddCategoryImageServlet
 */
@WebServlet("/admin/AddNewCategoryServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50   // 50MB
)
public class AddNewCategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Directory where uploaded images will be saved
    private static final String UPLOAD_DIR = "img";

    // Database credentials
    private static final String DB_URL = "jdbc:postgresql://ep-wild-feather-a1euu27g.ap-southeast-1.aws.neon.tech/cleaningServices?sslmode=require";
    private static final String DB_USER = "cleaningServices_owner";
    private static final String DB_PASSWORD = "mh0zgxauP6HJ";

    /**
     * Handles the HTTP POST method to upload image and add a category.
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get the upload directory path
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;

        // Create the directory if it does not exist
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String fileName = "";
        String categoryName = request.getParameter("name");
        String categoryDescription = request.getParameter("description");

        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            // Process the file upload
            for (Part part : request.getParts()) {
                if (part.getName().equals("image")) {
                    fileName = extractFileName(part);
                    if (fileName != null && !fileName.isEmpty()) {
                        String filePath = uploadPath + File.separator + fileName;
                        part.write(filePath); // Save the file to the server
                    }
                }
            }

            // Insert the category details into the database
            String sql = "INSERT INTO service_category (name, description, img_path) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
                pstmt.setString(1, categoryName);
                pstmt.setString(2, categoryDescription);
                pstmt.setString(3, UPLOAD_DIR + "/" + fileName);
                pstmt.executeUpdate();
            }

            // Set success message
            request.setAttribute("message", "Category created successfully with image.");
        } catch (Exception e) {
            request.setAttribute("message", "An error occurred: " + e.getMessage());
        }

        // Redirect back with a message
        getServletContext().getRequestDispatcher("/admin/addCategory.jsp").forward(request, response);
    }

    /**
     * Extracts the file name from the content-disposition header of the file part.
     */
    private String extractFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        for (String content : contentDisposition.split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf("=") + 2, content.length() - 1);
            }
        }
        return null;
    }
}
