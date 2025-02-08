package Servlets;

import DBaccess.CategoryServiceDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;

@WebServlet("/admin/UpdateCategoryServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class UpdateCategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String UPLOAD_DIR = "category_images";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int categoryId = Integer.parseInt(request.getParameter("id"));
        String categoryName = request.getParameter("name");
        String categoryDescription = request.getParameter("description");

        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String imagePath = null;
        for (Part part : request.getParts()) {
            if (part.getSize() > 0 && part.getHeader("content-disposition").contains("filename=")) {
                String fileName = extractFileName(part);
                String filePath = uploadPath + File.separator + fileName;
                part.write(filePath);
                imagePath = UPLOAD_DIR + "/" + fileName;
            }
        }

        try {
            CategoryServiceDAO dao = new CategoryServiceDAO();
            dao.updateCategory(categoryId, categoryName, categoryDescription, imagePath);
            request.setAttribute("message", "Category updated successfully.");
        } catch (Exception e) {
            request.setAttribute("message", "Error: " + e.getMessage());
        }

        request.getRequestDispatcher("/admin/editCategory.jsp").forward(request, response);
    }

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
