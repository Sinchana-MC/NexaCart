

<%@page import="java.util.Base64"%>
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@include file="aheader.jsp" %>

<%
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");

    if (loggedEmail == null || loggedEmail.trim().isEmpty()) {
        response.sendRedirect("user_login.jsp?redirect=my_orders.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    double totalSpent = 0;
%>

<main class="content">
<div class="container-fluid p-0">
    <h2 class="mb-4">My Orders</h2>

    <%
        try {
            con = new dbconfig().getConnection();
            ps = con.prepareStatement(
                "SELECT o.id, o.product_name, o.quantity, o.total, o.status, o.order_date, " +
                "p.id AS product_id, p.image " +
                "FROM `orders` o LEFT JOIN `products` p ON o.product_name = p.name " +
                "WHERE o.username = ? ORDER BY o.order_date DESC"
            );
            ps.setString(1, loggedEmail);
            rs = ps.executeQuery();

            boolean hasOrders = false;
            while (rs.next()) {
                hasOrders = true;
                int orderId = rs.getInt("id");
                String productName = rs.getString("product_name");
                int qty = rs.getInt("quantity");
                double total = rs.getDouble("total");
                String status = rs.getString("status");
                Timestamp date = rs.getTimestamp("order_date");
                int productId = rs.getInt("product_id");

                totalSpent += total;

                byte[] img = rs.getBytes("image");
                String imgStr = (img != null && img.length > 0)
                    ? Base64.getEncoder().encodeToString(img)
                    : "";
    %>

    <!-- Order Card -->
    <div class="card mb-3 shadow-sm">
        <div class="card-body">
            <!-- Order Info Row -->
            <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-3">
                <div>
                    <strong>ORDER PLACED</strong>: <%= date %><br>
                    <strong>TOTAL</strong>: <%= total %><br>
                    <strong>SHIP TO</strong>: <%= loggedEmail %>
                </div>
            </div>

            <!-- Product Row -->
            <div class="d-flex">
                <div class="me-3">
                    <% if (!imgStr.isEmpty()) { %>
                        <a href="view.jsp?id=<%= productId %>">
                            <img src="data:image/jpeg;base64,<%= imgStr %>"
                                 width="100" height="100" class="rounded border" alt="product">
                        </a>
                    <% } else { %>
                        <span class="text-muted">No Image</span>
                    <% } %>
                </div>

                <div class="flex-grow-1">
                    <h5><%= productName %></h5>
                    <p>Qty: <%= qty %> | Status: <%= status %></p>

                    <!-- Action Buttons -->
                    <a href="userdetails.jsp" class="btn btn-light border me-2">Buy it again</a>
                    <a href="view.jsp?id=<%= productId %>" class="btn btn-light border me-2">View your item</a>

                    <% if (!"Cancelled".equalsIgnoreCase(status)) { %>
                        <button class="btn btn-danger btn-sm"
                                onclick="showCancelBox(<%= orderId %>, '<%= productName.replace("'", "\\'") %>')">
                            Cancel
                        </button>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <%
            }
            if (!hasOrders) {
    %>
        <p class="text-muted">No orders found.</p>
    <%
            }
        } catch (Exception e) {
            out.println("<div class='text-danger'>Error: " + e.getMessage() + "</div>");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (con != null) try { con.close(); } catch (Exception e) {}
        }
    %>

    <!-- Total Spent -->
    <div class="alert alert-secondary mt-4 fw-bold">
        Total Spent: <%= totalSpent %>
    </div>
</div>
</main>

<!-- Cancel Modal -->
<div id="cancelModal" style="display:none; position:fixed; top:20%; left:35%; background:#fff; border:1px solid #ccc; padding:20px; z-index:1000;">
    <form action="cancel_order.jsp" method="post">
        <input type="hidden" id="cancelOrderId" name="orderId">
        <h3>Cancel Order: <span id="productName"></span></h3>
        <label>Reason:</label><br>
        <textarea name="cancel_reason" rows="4" cols="30" required></textarea><br><br>
        <button type="submit" class="btn btn-danger">Submit</button>
        <button type="button" class="btn btn-secondary" onclick="hideCancelBox()">Close</button>
    </form>
</div>

<script>
    function showCancelBox(orderId, productName) {
        document.getElementById('cancelOrderId').value = orderId;
        document.getElementById('productName').innerText = productName;
        document.getElementById('cancelModal').style.display = 'block';
    }
    function hideCancelBox() {
        document.getElementById('cancelModal').style.display = 'none';
    }
</script>

<%@include file="footer.jsp" %>
