/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import Database.dbconfig;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

/**
 *
 * @author veda1
 */
public class productdb extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
    response.setContentType("text/html;charset=UTF-8");
    PrintWriter out = response.getWriter();

    try {
       String name = request.getParameter("name");
    String caption = request.getParameter("caption");
    String quantity = request.getParameter("quantity");
    String price = request.getParameter("price");
    String catId = request.getParameter("cat_id");
    String description = request.getParameter("description"); // ← Get description

    // Get image part
    Part filePart = request.getPart("image");
    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

    // Save file to "uploads" folder in webapp
    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdir();

    String filePath = uploadPath + File.separator + fileName;
    filePart.write(filePath);

    // Store relative path for DB
    String imagePath = "uploads/" + fileName;

    // Save product data to database
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = new dbconfig().getConnection();
    Statement stat = con.createStatement();

    // Updated SQL query to include description
    String query = "INSERT INTO products(name, caption, quantity, price, cat_id, description, image_path) " +
                   "VALUES ('" + name + "', '" + caption + "', '" + quantity + "', '" + price + "', '" + catId + "', '" + description + "', '" + imagePath + "')";

    stat.executeUpdate(query);

    out.print("<script>alert('Product successfully added')</script>");
    out.println("<meta http-equiv='refresh' content='0;products_add.jsp' />");
    } catch (Exception e) {
        out.print("<script>alert('Error: " + e.getMessage() + "')</script>");
    }
}

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
