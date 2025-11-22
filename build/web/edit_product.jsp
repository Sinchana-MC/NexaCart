<%@page import="Database.dbconfig"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
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


    try {
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String caption = request.getParameter("caption");
        String quantity = request.getParameter("quantity");
        String price = request.getParameter("price");
        String category_name = request.getParameter("category_name");

        Class.forName("com.mysql.jdbc.Driver");
        Connection con = new dbconfig().getConnection();

        // Step 1: Get cat_id from category name
        PreparedStatement getCatIdStmt = con.prepareStatement("SELECT id FROM cat WHERE name = ?");
        getCatIdStmt.setString(1, category_name);
        ResultSet rs = getCatIdStmt.executeQuery();

        String cat_id = null;
        if (rs.next()) {
            cat_id = rs.getString("id");
        } else {
            out.println("Invalid category name.");
            return;
        }

        // Step 2: Update product with cat_id
        PreparedStatement pst = con.prepareStatement(
            "UPDATE products SET name=?, caption=?, quantity=?, price=?, cat_id=? WHERE id=?"
        );
        pst.setString(1, name);
        pst.setString(2, caption);
        pst.setString(3, quantity);
        pst.setString(4, price);
        pst.setString(5, cat_id);
        pst.setString(6, id);

        int rows = pst.executeUpdate();
        con.close();

        if (rows > 0) {
            response.sendRedirect("home_admin.jsp");
        } else {
            out.println("Update failed.");
        }

    } catch (Exception e) {
        out.println("Error: " + e);
    }
%>
