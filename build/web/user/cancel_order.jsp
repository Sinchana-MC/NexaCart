

<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");

    if (loggedEmail == null || loggedEmail.trim().isEmpty()) {
        response.sendRedirect("user_login.jsp?redirect=my_orders.jsp");
        return;
    }

    String orderIdStr = request.getParameter("orderId");
    String reason = request.getParameter("cancel_reason");

    if(orderIdStr == null || reason == null || reason.trim().isEmpty()){
        out.println("<script>alert('Invalid request.');window.location='my_orders.jsp';</script>");
        return;
    }

    int orderId = Integer.parseInt(orderIdStr);

    Connection con = null;
    PreparedStatement ps = null;

    try {
        con = new dbconfig().getConnection();
        ps = con.prepareStatement("UPDATE orders SET status=?, cancel_reason=? WHERE id=? AND username=?");
        ps.setString(1, "Cancelled");
        ps.setString(2, reason);
        ps.setInt(3, orderId);
        ps.setString(4, loggedEmail);

        int rows = ps.executeUpdate();
        if (rows > 0) {
            out.println("<script>alert('Order cancelled successfully!');window.location='my_orders.jsp';</script>");
        } else {
            out.println("<script>alert('Order not found or unauthorized.');window.location='my_orders.jsp';</script>");
        }
    } catch(Exception e) {
        out.println("<script>alert('Error: "+e.getMessage()+"');window.location='my_orders.jsp';</script>");
    } finally {
        if(ps!=null) try{ps.close();}catch(Exception e){}
        if(con!=null) try{con.close();}catch(Exception e){}
    }
%>
