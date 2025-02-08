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

@WebServlet("/admin/AddNewServiceServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50   // 50MB
)
public class AddNewServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String UPLOAD_DIR = "img";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String serviceName = request.getParameter("name");
        String serviceDescription = request.getParameter("description");
        String servicePriceStr = request.getParameter("price");
        String categoryIdStr = request.getParameter("category_id");

        double servicePrice;
        int categoryId;

        try {
            servicePrice = Double.parseDouble(servicePriceStr);
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("message", "Invalid price or category ID.");
            request.getRequestDispatcher("/admin/addService.jsp").forward(request, response);
            return;
        }

        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String fileName = null;
        int newServiceId;

        try {
            CategoryServiceDAO dao = new CategoryServiceDAO();
            newServiceId = dao.addService(serviceName, serviceDescription, servicePrice, categoryId);

            for (Part part : request.getParts()) {
                if (part.getHeader("content-disposition").contains("filename=")) {
                    fileName = extractFileName(part);
                    if (fileName != null && !fileName.isEmpty()) {
                        String filePath = uploadPath + File.separator + fileName;
                        part.write(filePath);
                        dao.updateServiceImagePath(newServiceId, UPLOAD_DIR + "/" + fileName);
                    }
                }
            }

            request.setAttribute("message", "Service created successfully with ID: " + newServiceId);
        } catch (Exception e) {
            request.setAttribute("message", "Error: " + e.getMessage());
        }

        request.getRequestDispatcher("/admin/addService.jsp").forward(request, response);
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
