/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import Database.dbconfig;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author veda1
 */
public class add_loyalty_point extends HttpServlet {

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
            String[] pointsArray = request.getParameterValues("points");

if (pointsArray != null && pointsArray.length > 0) {

    Class.forName("com.mysql.jdbc.Driver");
    Connection con = new dbconfig().getConnection();

    // Get today's date in yyyy-MM-dd format
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String todayDate = sdf.format(new java.util.Date());

    int points = Integer.parseInt(pointsArray[0]);

    // Step 1: Mark previous today's record as "old"
    String updateOldSql = "UPDATE loyalty_points SET status = 'old' WHERE update_date = ? AND status = 'latest'";
    PreparedStatement updateOldStmt = con.prepareStatement(updateOldSql);
    updateOldStmt.setString(1, todayDate);
    updateOldStmt.executeUpdate();
    updateOldStmt.close();

    // Step 2: Insert new "latest" record
    String insertSql = "INSERT INTO loyalty_points (points, update_date, status) VALUES (?, ?, 'latest')";
    PreparedStatement insertStmt = con.prepareStatement(insertSql);
    insertStmt.setInt(1, points);
    insertStmt.setString(2, todayDate);
    insertStmt.executeUpdate();
    insertStmt.close();

    con.close();

    out.print("<script>alert('Loyalty points updated for today (history saved)')</script>");
    out.println("<meta http-equiv='refresh' content='0;add_loyalty_points.jsp' />");

} else {
    out.print("<script>alert('No points received')</script>");
    out.println("<meta http-equiv='refresh' content='0;add_loyalty_points.jsp' />");
}
        }
        catch(Exception e){
             e.printStackTrace(out);
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
