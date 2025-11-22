<%
    HttpSession hs = request.getSession(false); // Do not create a new session
    if (hs == null || hs.getAttribute("ausername") == null || hs.getAttribute("apassword") == null) {
        response.sendRedirect("ulogout.java");
        return;
    }

    String ausername = hs.getAttribute("ausername").toString();
    String apassword = hs.getAttribute("apassword").toString();

    if (ausername.trim().isEmpty() || apassword.trim().isEmpty()) {
        response.sendRedirect("ulogout.java");
        return;
    }
%>
<%@page import="Database.dbconfig"%>
<%@page import="java.sql.*"%>

<%
    String id = request.getParameter("id");
    String name = request.getParameter("name");

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = new dbconfig().getConnection();

        PreparedStatement pst = con.prepareStatement("UPDATE cat SET name = ? WHERE id = ?");
        pst.setString(1, name);
        pst.setString(2, id);

        int rows = pst.executeUpdate();
        if (rows > 0) {
            response.sendRedirect("add_category.jsp"); // go back to listing page
        } else {
            out.println("<h3>Update failed. Category not found.</h3>");
        }

        con.close();
    } catch (Exception e) {
        out.println("<h3>Error: " + e.getMessage() + "</h3>");
    }
%>
