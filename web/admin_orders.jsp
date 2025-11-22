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
<%@page import="java.sql.*"%>
<%@page import="java.util.Base64"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="aheader.jsp" %>

<main class="content">
    <div class="container-fluid p-0">
        <h1 class="h3 mb-3"><strong>Order</strong> Tracking</h1>

        <!-- Filter Section -->
        <form method="get" class="mb-3">
            <div class="row g-2 align-items-center">
                <div class="col-auto">
                    <label for="filter" class="col-form-label fw-bold">Filter by:</label>
                </div>
                <div class="col-auto">
                    <select name="filter" id="filter" class="form-select">
                        <option value="all" <%= "all".equals(request.getParameter("filter")) || request.getParameter("filter") == null ? "selected" : "" %>>All</option>
                        <option value="daily" <%= "daily".equals(request.getParameter("filter")) ? "selected" : "" %>>Daily</option>
                        <option value="monthly" <%= "monthly".equals(request.getParameter("filter")) ? "selected" : "" %>>Monthly</option>
                        <option value="yearly" <%= "yearly".equals(request.getParameter("filter")) ? "selected" : "" %>>Yearly</option>
                    </select>
                </div>
                <div class="col-auto">
                    <button type="submit" class="btn btn-primary">Apply</button>
                </div>
            </div>
        </form>

        <div class="card">
            <div class="card-body">
                <div class="row">
                    <div class="col-12 col-lg-12 col-xxl-12 d-flex">
                        <table class="table table-bordered table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Order ID</th>
                                    <th>Name (Email)</th>
                                    <th>Product</th>
                                    <th>Qty</th>
                                    <th>Total (₹)</th>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>Cancel Reason</th>
                                    <th>Image</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                Connection con = null;
                                PreparedStatement ps = null;
                                ResultSet rs = null;
                                int grandTotal = 0;

                                // --- Status Update Logic ---
                                String updateId = request.getParameter("updateId");
                                String newStatus = request.getParameter("newStatus");
                                if (updateId != null && newStatus != null) {
                                    try {
                                        Class.forName("com.mysql.jdbc.Driver");
                                        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/e_commerce", "root", "");
                                        PreparedStatement psUpdate = con.prepareStatement("UPDATE orders SET status=? WHERE id=?");
                                        psUpdate.setString(1, newStatus);
                                        psUpdate.setString(2, updateId);
                                        psUpdate.executeUpdate();
                                        psUpdate.close();
                                        con.close();
                                        response.sendRedirect("admin_orders.jsp"); // Reload page after update
                                        return;
                                    } catch (Exception ex) {
                                        out.println("<script>alert('Error updating status: " + ex.getMessage() + "');</script>");
                                    }
                                }

                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/e_commerce", "root", "");

                                    String filter = request.getParameter("filter");
                                    String condition = "";

                                    if ("daily".equalsIgnoreCase(filter)) {
                                        condition = "WHERE DATE(o.order_date) = CURDATE()";
                                    } else if ("monthly".equalsIgnoreCase(filter)) {
                                        condition = "WHERE MONTH(o.order_date) = MONTH(CURDATE()) AND YEAR(o.order_date) = YEAR(CURDATE())";
                                    } else if ("yearly".equalsIgnoreCase(filter)) {
                                        condition = "WHERE YEAR(o.order_date) = YEAR(CURDATE())";
                                    }

                                    String query = "SELECT o.*, u.name AS fullname, u.emailid, p.image FROM orders o " +
                                                   "JOIN user u ON o.username = u.emailid " +
                                                   "LEFT JOIN products p ON o.product_name = p.name " +
                                                   condition + " ORDER BY o.order_date DESC";

                                    ps = con.prepareStatement(query);
                                    rs = ps.executeQuery();

                                    boolean hasData = false;
                                    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

                                    while (rs.next()) {
                                        hasData = true;
                                        int total = rs.getInt("total");
                                        grandTotal += total;
                                        String status = rs.getString("status");
                                        String cancelReason = rs.getString("cancel_reason");
                                        boolean isCancelled = "Cancelled".equalsIgnoreCase(status);
                                        byte[] imageBytes = rs.getBytes("image");
                                        String base64Image = (imageBytes != null && imageBytes.length > 0) ? Base64.getEncoder().encodeToString(imageBytes) : "";
                                        
                                        java.sql.Timestamp orderTimestamp = rs.getTimestamp("order_date");
                                        String formattedDate = (orderTimestamp != null) ? sdf.format(orderTimestamp) : "-";
                                %>
                                <tr style="<%= isCancelled ? "color:red;" : "" %>">
                                    <td><%= rs.getInt("id") %></td>
                                    <td><%= rs.getString("fullname") %> (<%= rs.getString("emailid") %>)</td>
                                    <td><%= rs.getString("product_name") %></td>
                                    <td><%= rs.getInt("quantity") %></td>
                                    <td>₹<%= total %></td>
                                    <td><%= formattedDate %></td>
                                    <td>
                                        <form method="post" style="display:inline;">
                                            <input type="hidden" name="updateId" value="<%= rs.getInt("id") %>">
                                            <select name="newStatus" class="form-select form-select-sm d-inline w-auto">
                                                <option value="Pending" <%= "Pending".equalsIgnoreCase(status) ? "selected" : "" %>>Pending</option>
                                                <option value="Shipped" <%= "Shipped".equalsIgnoreCase(status) ? "selected" : "" %>>Shipped</option>
                                                <option value="Arriving" <%= "Arriving".equalsIgnoreCase(status) ? "selected" : "" %>>Arriving</option>
                                                <option value="Delivered" <%= "Delivered".equalsIgnoreCase(status) ? "selected" : "" %>>Delivered</option>
                                                <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(status) ? "selected" : "" %>>Cancelled</option>
                                            </select>
                                            <button type="submit" class="btn btn-sm btn-success">Update</button>
                                        </form>
                                    </td>
                                    <td><%= cancelReason != null ? cancelReason : "-" %></td>
                                    <td>
                                        <% if (!base64Image.isEmpty()) { %>
                                            <img src="data:image/jpeg;base64,<%= base64Image %>" width="80" height="80" />
                                        <% } else { %>
                                            No Image
                                        <% } %>
                                    </td>
                                </tr>
                                <%
                                    }

                                    if (!hasData) {
                                        out.print("<tr><td colspan='9' class='text-center text-muted'>No orders found for the selected filter.</td></tr>");
                                    }
                                } catch (Exception e) {
                                    out.print("<tr><td colspan='9'>Error: " + e.getMessage() + "</td></tr>");
                                } finally {
                                    if (rs != null) rs.close();
                                    if (ps != null) ps.close();
                                    if (con != null) con.close();
                                }
                                %>
                                <tr class="table-secondary fw-bold">
                                    <td colspan="4" class="text-end">Total Revenue:</td>
                                    <td colspan="5">₹<%= grandTotal %></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<%@include file="footer.jsp" %>
