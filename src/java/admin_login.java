/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import Database.dbconfig;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author veda1
 */
public class admin_login extends HttpServlet {

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
            String username=request.getParameter("username");
            String password=request.getParameter("password");
            //out.print(uname+" "+pass);
            Class.forName("com.mysql.jdbc.Driver");
            Connection con=new dbconfig().getConnection();
            Statement stat=con.createStatement();
            ResultSet res=stat.executeQuery("SELECT * FROM `admin` WHERE `username`='"+username+"' AND `password`='"+password+"'");
            int flag=0;
            while(res.next())
            {
               flag=1;
                
            }
            if(flag==1)
                {
                    HttpSession hs=request.getSession();
                        hs.setAttribute("ausername", username);
                        hs.setAttribute("apassword", password);
                    
                     out.println("<meta http-equiv = \"refresh\" content = \"0;index1.jsp\" />");
                }
                else
                {
                     out.print("<script>alert('login invalid')</script>"); 
                     out.println("<meta http-equiv = \"refresh\" content = \"0;admin_login.jsp\" />");
                }
            
        }
        catch(Exception e)
        {
            out.print(e);
            out.print("<script>alert('Server error')</script>"); 
                // out.println("<meta http-equiv = \"refresh\" content = \"0;index.html\" />");
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
