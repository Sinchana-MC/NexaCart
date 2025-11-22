

<%@ page import="java.sql.*" %>
<%@ page import="Database.dbconfig" %>

<%
    String emailid = request.getParameter("emailid");
    String name = request.getParameter("name");
    String phone = request.getParameter("phonenumber");
    String building = request.getParameter("buildingname");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String pincode = request.getParameter("pincode");
    String state = request.getParameter("state");

    Connection con = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = new dbconfig().getConnection();

        ps = con.prepareStatement(
            "INSERT INTO address (emailid, name, phonenumber, buildingname, area, city, pincode, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
        );
        ps.setString(1, emailid);
        ps.setString(2, name);
        ps.setString(3, phone);
        ps.setString(4, building);
        ps.setString(5, area);
        ps.setString(6, city);
        ps.setString(7, pincode);
        ps.setString(8, state);

        int rows = ps.executeUpdate();
        if(rows > 0){
            response.sendRedirect("userdetails.jsp");
        } else {
            out.println("<div class='alert alert-danger'>Failed to save address. Try again.</div>");
        }

    } catch(Exception e){
        out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
    } finally {
        if(ps!=null) try{ ps.close(); }catch(Exception e){}
        if(con!=null) try{ con.close(); }catch(Exception e){}
    }
%>
