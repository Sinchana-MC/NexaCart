
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%
    String id = request.getParameter("id");
    String emailid = request.getParameter("emailid");
    String name = request.getParameter("name");
    String phonenumber = request.getParameter("phonenumber");
    String buildingname = request.getParameter("buildingname");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String pincode = request.getParameter("pincode");
    String state = request.getParameter("state");

    Connection con = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = new dbconfig().getConnection();

        String sql = "UPDATE address SET name=?, phonenumber=?, buildingname=?, area=?, city=?, pincode=?, state=? WHERE id=? AND emailid=?";
        ps = con.prepareStatement(sql);
        ps.setString(1, name);
        ps.setString(2, phonenumber);
        ps.setString(3, buildingname);
        ps.setString(4, area);
        ps.setString(5, city);
        ps.setString(6, pincode);
        ps.setString(7, state);
        ps.setString(8, id);
        ps.setString(9, emailid);

        int updated = ps.executeUpdate();
        if (updated > 0) {
            response.sendRedirect("userdetails.jsp?msg=Address+updated+successfully");
        } else {
            out.println("<div class='alert alert-danger'>Failed to update address.</div>");
        }

    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (ps != null) try { ps.close(); } catch(Exception e){}
        if (con != null) try { con.close(); } catch(Exception e){}
    }
%>
