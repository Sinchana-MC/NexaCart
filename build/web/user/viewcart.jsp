

<%@page import="java.util.Base64"%>
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@include file="aheader.jsp" %>

<%
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");

    if (loggedEmail == null) {
        response.sendRedirect("user_login.jsp?redirect=cart.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    double grandTotal = 0;
    boolean hasItems = false;

    try {
        con = new dbconfig().getConnection();

        // ? Handle delete request
        if (request.getParameter("deleteId") != null) {
            ps = con.prepareStatement("DELETE FROM cart WHERE user_email=? AND product_id=?");
            ps.setString(1, loggedEmail);
            ps.setString(2, request.getParameter("deleteId"));
            ps.executeUpdate();
            ps.close();
        }

        // ? Handle quantity update request
        if (request.getParameter("productId") != null && request.getParameter("quantity") != null) {
            int productId = Integer.parseInt(request.getParameter("productId"));
            int qty = Integer.parseInt(request.getParameter("quantity"));
            if (qty < 1) qty = 1;
            if (qty > 10) qty = 10;

            ps = con.prepareStatement("UPDATE cart SET quantity=? WHERE product_id=? AND user_email=?");
            ps.setInt(1, qty);
            ps.setInt(2, productId);
            ps.setString(3, loggedEmail);
            ps.executeUpdate();
            ps.close();
        }

        // ? Fetch cart details
        ps = con.prepareStatement(
            "SELECT p.id, p.name, p.price, p.image, c.quantity " +
            "FROM cart c INNER JOIN products p ON c.product_id=p.id " +
            "WHERE c.user_email=?"
        );
        ps.setString(1, loggedEmail);
        rs = ps.executeQuery();
%>
<main class="content">
	<div class="container-fluid p-0">
        <div class="card">
			<div class="card-body">
                <div class="container mt-5 mb-5">
                    <h2 class="mb-4">Your Cart</h2>
                    <div class="table-responsive">
                        <table class="table table-bordered text-center align-middle shadow-lg">
                            <thead class="table-dark">
                                <tr>
                                    <th>Image</th>
                                    <th>Name</th>
                                    <th>Price (Rs)</th>
                                    <th>Qty</th>
                                    <th>Total (Rs)</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="cart-body">
                                <%
                                    while (rs.next()) {
                                        hasItems = true;
                                        String pid = rs.getString("id");
                                        String pname = rs.getString("name");
                                        double price = rs.getDouble("price");
                                        int qty = rs.getInt("quantity");
                                        double total = price * qty;
                                        grandTotal += total;

                                        byte[] img = rs.getBytes("image");
                                        String imgStr = (img != null && img.length > 0)
                                                        ? Base64.getEncoder().encodeToString(img)
                                                        : "";
                                %>
                                <tr class="cart-row">
                                    <td>
                                        <% if (!imgStr.isEmpty()) { %>
                                            <img src="data:image/jpeg;base64,<%= imgStr %>" width="60" height="60" class="rounded shadow-sm">
                                        <% } else { %>
                                            <span>No Image</span>
                                        <% } %>
                                    </td>
                                    <td><%= pname %></td>
                                    <td class="price" data-price="<%= price %>"><%= price %></td>
                                    <td>
                                        <!-- ? Inline form to update quantity -->
                                        <form action="viewcart.jsp" method="post" class="d-inline">
                                            <input type="hidden" name="productId" value="<%= pid %>">
                                            <input type="number" 
                                                   name="quantity" 
                                                   class="form-control form-control-sm" 
                                                   value="<%= qty %>" min="1" max="10"
                                                   onchange="this.form.submit()">
                                        </form>
                                    </td>
                                    <td class="total"><%= total %></td>
                                    <td>
                                        <form method="post" action="viewcart.jsp" class="d-inline">
                                            <input type="hidden" name="deleteId" value="<%= pid %>">
                                            <button type="submit" class="btn btn-sm btn-danger btn-remove"> Remove</button>
                                        </form>
                                    </td>
                                </tr>
                                <% } %>
                                <% if (!hasItems) { %>
                                    <tr><td colspan="6" class="text-center text-muted">Your cart is empty.</td></tr>
                                <% } %>
                            </tbody>
                            <tfoot class="fw-bold">
                                <tr>
                                    <td colspan="4" class="text-end">Grand Total</td>
                                    <td colspan="2" id="grand-total"><%= grandTotal %></td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                    <% if (grandTotal > 0) { %>
                        <div class="text-end mt-3">
                            <a href="userdetails.jsp" class="btn btn-success btn-lg shadow-sm">Proceed to Checkout </a>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</main>

<%
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
%>

<%@include file="footer.jsp" %>
