
<%@page import="java.util.Base64"%>
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@include file="aheader.jsp" %>

<%
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");

    if (loggedEmail == null || loggedEmail.trim().isEmpty()) {
        response.sendRedirect("user_login.jsp?redirect=cart.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = new dbconfig().getConnection();

        // Handle delete request (remove from this user's cart only)
        if (request.getParameter("deleteId") != null) {
            ps = con.prepareStatement(
                "DELETE FROM cart WHERE user_email = ? AND product_id = ?"
            );
            ps.setString(1, loggedEmail);
            ps.setString(2, request.getParameter("deleteId"));
            ps.executeUpdate();
        }

        // Fetch only this user's cart items
        ps = con.prepareStatement(
            "SELECT p.id, p.name, p.price, p.image, c.quantity " +
            "FROM cart c INNER JOIN products p ON c.product_id = p.id " +
            "WHERE c.user_email = ?"
        );
        ps.setString(1, loggedEmail);
        rs = ps.executeQuery();
%>

<div class="container mt-4">
    <h2 class="mb-4">Your Shopping Cart</h2>
    <div class="table-responsive">
        <table class="table table-bordered table-striped text-center align-middle">
            <thead class="table-dark">
                <tr>
                    <th>Image</th>
                    <th>Name</th>
                    <th>Price (Rs)</th>
                    <th>Quantity</th>
                    <th>Total (Rs)</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    double grandTotal = 0;
                    boolean hasItems = false;

                    while (rs.next()) {
                        hasItems = true;
                        String pid = rs.getString("id");
                        String pname = rs.getString("name");
                        double price = rs.getDouble("price");
                        int qty = rs.getInt("quantity");
                        double total = price * qty;
                        grandTotal += total;

                        byte[] imgBytes = rs.getBytes("image");
                        String base64Img = (imgBytes != null && imgBytes.length > 0) 
                            ? Base64.getEncoder().encodeToString(imgBytes) 
                            : "";
                %>
                <tr>
                    <td>
                        <% if (!base64Img.isEmpty()) { %>
                            <img src="data:image/jpeg;base64,<%= base64Img %>" width="60" height="60" style="object-fit:cover;">
                        <% } else { %>
                            <span>No Image</span>
                        <% } %>
                    </td>
                    <td><%= pname %></td>
                    <td><%= price %></td>
                    <td><%= qty %></td>
                    <td><%= total %></td>
                    <td>
                        <form method="post" action="cart.jsp" style="display:inline;">
                            <input type="hidden" name="deleteId" value="<%= pid %>">
                            <button type="submit" class="btn btn-sm btn-danger">Remove</button>
                        </form>
                    </td>
                </tr>
                <% } // end while %>

                <% if (!hasItems) { %>
                    <tr>
                        <td colspan="6" class="text-center">Your cart is empty.</td>
                    </tr>
                <% } %>
            </tbody>
            <tfoot class="table-light">
                <tr>
                    <td colspan="4" class="text-end fw-bold">Grand Total</td>
                    <td colspan="2" class="fw-bold"><%= grandTotal %> Rs</td>
                </tr>
            </tfoot>
        </table>
    </div>

        </div>
    <% if (grandTotal > 0) { %>
        <div class="text-end">
            <a href="checkout.jsp" class="btn btn-success">Proceed to Checkout</a>
        </div>
    <% } %>


<%
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error loading cart: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
%>

<%@include file="footer.jsp" %>
