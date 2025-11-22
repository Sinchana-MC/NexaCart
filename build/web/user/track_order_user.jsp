

<%@page import="java.util.Base64"%>
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@include file="aheader.jsp" %>

<%
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");

    if (loggedEmail == null || loggedEmail.trim().isEmpty()) {
        response.sendRedirect("user_login.jsp?redirect=track_order_user.jsp");
        return;
    }
%>

<main class="content">
    <div class="container p-4">
        <h2 class="text-center mb-4">Track Your Orders</h2>

        <%
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection con = new dbconfig().getConnection();

                PreparedStatement ps = con.prepareStatement(
                    "SELECT o.id, o.product_name, o.quantity, o.total, o.order_date, o.status, o.cancel_reason, p.image " +
                    "FROM orders o " +
                    "LEFT JOIN products p ON o.product_name = p.name " +
                    "WHERE o.username = ? ORDER BY o.order_date DESC"
                );
                ps.setString(1, loggedEmail);
                ResultSet rs = ps.executeQuery();

                boolean hasOrders = false;
        %>

        <div class="table-responsive">
            <table class="table table-bordered table-striped align-middle text-center">
                <thead class="table-dark">
                    <tr>
                        <th>Image</th>
                        <th>Product Name</th>
                        <th>Quantity</th>
                        <th>Total (Rs)</th>
                        <th>Status</th>
                        <th>Cancel Reason</th>
                        <th>Order Date</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        while (rs.next()) {
                            hasOrders = true;

                            String productName = rs.getString("product_name");
                            int quantity = rs.getInt("quantity");
                            int total = rs.getInt("total");
                            String status = rs.getString("status");
                            String cancelReason = rs.getString("cancel_reason");
                            String orderDate = rs.getString("order_date");

                            byte[] imageBytes = rs.getBytes("image");
                            String base64Image = "";
                            if (imageBytes != null && imageBytes.length > 0) {
                                base64Image = Base64.getEncoder().encodeToString(imageBytes);
                            }
                    %>
                    <tr>
                        <td>
                            <% if (!base64Image.isEmpty()) { %>
                                <img src="data:image/jpeg;base64,<%= base64Image %>" 
                                     alt="<%= productName %>" 
                                     style="height: 60px; width: 60px; object-fit: cover; border-radius: 5px;">
                            <% } else { %>
                                <span>No Image</span>
                            <% } %>
                        </td>
                        <td><%= productName %></td>
                        <td><%= quantity %></td>
                        <td><%= total %></td>
                        <td>
                            <% if ("Cancelled".equalsIgnoreCase(status)) { %>
                                <span class="badge bg-danger"><%= status %></span>
                            <% } else if ("Pending".equalsIgnoreCase(status)) { %>
                                <span class="badge bg-warning text-dark"><%= status %></span>
                            <% } else { %>
                                <span class="badge bg-success"><%= status %></span>
                            <% } %>
                        </td>
                        <td><%= (cancelReason != null && !cancelReason.trim().isEmpty()) ? cancelReason : "-" %></td>
                        <td><%= orderDate %></td>
                    </tr>
                    <%
                        }

                        rs.close();
                        ps.close();
                        con.close();

                        if (!hasOrders) {
                    %>
                    <tr>
                        <td colspan="7" class="text-center text-muted">You have not placed any orders yet.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>

        <%
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
            }
        %>
    </div>
</main>

<%@include file="footer.jsp" %>
