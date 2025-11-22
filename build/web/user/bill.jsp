
<%@page import="java.util.Base64"%>
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@include file="aheader.jsp" %>

<%
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");

    if (loggedEmail == null || loggedEmail.trim().isEmpty()) {
        response.sendRedirect("user_login.jsp?redirect=bill.jsp");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    double grandTotal = 0;
    double finalTotal = 0;
    int availableLoyaltyPoints = 0;
    int baseConstant = 1000;
    int pointsToEarn = 0;
    int pointsToRedeem = 0;
    double pointsDiscount = 0;
    int userId = 0;
    String debugInfo = "";

    String selectedAddressId = (String) sessionUser.getAttribute("selectedAddressId");
    String paymentMethod = request.getParameter("paymentType");
    if (paymentMethod != null && !paymentMethod.trim().equals("")) {
        sessionUser.setAttribute("payment", paymentMethod);
    }
    paymentMethod = (String) sessionUser.getAttribute("payment");
    if (paymentMethod == null) paymentMethod = "Not Selected";

    String redeemPointsParam = request.getParameter("redeemPoints");
    if (redeemPointsParam != null && !redeemPointsParam.trim().equals("")) {
        try {
            pointsToRedeem = Integer.parseInt(redeemPointsParam);
            sessionUser.setAttribute("redeemPoints", pointsToRedeem);
        } catch (Exception e) {}
    } else if (sessionUser.getAttribute("redeemPoints") != null) {
        pointsToRedeem = (Integer) sessionUser.getAttribute("redeemPoints");
    }

    String uname = "", phone = "", building = "", area = "", city = "", pincode = "", state = "";
    java.util.List<String[]> cartItems = new java.util.ArrayList<String[]>();

    try {
        con = new dbconfig().getConnection();

        // --- Method 1: Try to find user ID from user table ---
        String userIdColumn = null;
        try {
            DatabaseMetaData md = con.getMetaData();
            ResultSet cols = md.getColumns(null, null, "%", "%");
            java.util.Set<String> colsForUser = new java.util.HashSet<String>();
            while (cols.next()) {
                String tbl = cols.getString("TABLE_NAME");
                String col = cols.getString("COLUMN_NAME");
                if (tbl != null && tbl.equalsIgnoreCase("user")) {
                    colsForUser.add(col.toLowerCase());
                }
            }
            cols.close();

            String[] prefer = new String[] {"id", "user_id", "userid", "uid", "u_id", "userId", "userID"};
            for (String p : prefer) {
                if (colsForUser.contains(p.toLowerCase())) {
                    userIdColumn = p;
                    break;
                }
            }

            if (userIdColumn == null) {
                for (String c : colsForUser) {
                    if (c.toLowerCase().contains("id")) {
                        userIdColumn = c;
                        break;
                    }
                }
            }
        } catch (Exception mdEx) {
            debugInfo += "Metadata error: " + mdEx.getMessage() + "; ";
        }

        if (userIdColumn != null) {
            String q = "SELECT " + userIdColumn + " FROM `user` WHERE emailid=?";
            ps = con.prepareStatement(q);
            ps.setString(1, loggedEmail);
            rs = ps.executeQuery();
            if (rs.next()) {
                try {
                    userId = rs.getInt(1);
                    debugInfo += "Found userId=" + userId + " using column '" + userIdColumn + "'; ";
                } catch (Exception ex) {
                    userId = 0;
                    debugInfo += "Error getting userId: " + ex.getMessage() + "; ";
                }
            } else {
                debugInfo += "No user found with email=" + loggedEmail + "; ";
            }
            if (rs != null) { rs.close(); rs = null; }
            if (ps != null) { ps.close(); ps = null; }
        } else {
            debugInfo += "Could not find ID column in user table; ";
        }

        // Get base constant from loyalty_points table
        try {
            ps = con.prepareStatement("SELECT points FROM loyalty_points WHERE id=1");
            rs = ps.executeQuery();
            if (rs.next()) {
                baseConstant = rs.getInt("points");
            }
            rs.close(); ps.close();
        } catch (Exception e) {
            debugInfo += "Error fetching base constant: " + e.getMessage() + "; ";
            baseConstant = 1000; // default
        }

        // --- Method 2: Try to get loyalty points using user_id ---
        if (userId > 0) {
            try {
                ps = con.prepareStatement(
                    "SELECT COALESCE(SUM(points_earned) - SUM(CAST(points_used AS SIGNED)), 0) AS total_points " +
                    "FROM loyalty_history WHERE user_id=?"
                );
                ps.setInt(1, userId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    availableLoyaltyPoints = rs.getInt("total_points");
                    if (availableLoyaltyPoints < 0) availableLoyaltyPoints = 0;
                    debugInfo += "Fetched points=" + availableLoyaltyPoints + " for userId=" + userId + "; ";
                }
                rs.close(); ps.close();
            } catch (Exception e) {
                debugInfo += "Error fetching loyalty points: " + e.getMessage() + "; ";
            }
        }

        // --- Method 3: Alternative - Try to fetch all records and check ---
        if (availableLoyaltyPoints == 0) {
            try {
                ps = con.prepareStatement(
                    "SELECT user_id, SUM(points_earned) - SUM(CAST(points_used AS SIGNED)) AS total_points " +
                    "FROM loyalty_history GROUP BY user_id"
                );
                rs = ps.executeQuery();
                debugInfo += "All loyalty records: ";
                while (rs.next()) {
                    int uid = rs.getInt("user_id");
                    int pts = rs.getInt("total_points");
                    debugInfo += "[uid=" + uid + ",pts=" + pts + "] ";
                    if (uid == userId && pts > 0) {
                        availableLoyaltyPoints = pts;
                    }
                }
                rs.close(); ps.close();
            } catch (Exception e) {
                debugInfo += "Error in alternative fetch: " + e.getMessage() + "; ";
            }
        }

        if (pointsToRedeem > availableLoyaltyPoints) {
            pointsToRedeem = availableLoyaltyPoints;
            sessionUser.setAttribute("redeemPoints", pointsToRedeem);
        }

        // Fetch cart items
        ps = con.prepareStatement(
            "SELECT p.id, p.name, p.price, p.image, c.quantity " +
            "FROM cart c INNER JOIN products p ON c.product_id=p.id " +
            "WHERE c.user_email=?"
        );
        ps.setString(1, loggedEmail);
        rs = ps.executeQuery();
        while (rs.next()) {
            String pname = rs.getString("name");
            double price = rs.getDouble("price");
            int qty = rs.getInt("quantity");
            double total = price * qty;
            grandTotal += total;

            byte[] img = rs.getBytes("image");
            String imgStr = (img != null && img.length > 0)
                    ? Base64.getEncoder().encodeToString(img) : "";

            cartItems.add(new String[]{pname, String.valueOf(price), String.valueOf(qty), String.valueOf(total), imgStr});
        }
        rs.close(); ps.close();

        // Loyalty discount calculation (1 point = Rs 1)
        pointsDiscount = pointsToRedeem * 1.0;
        if (pointsDiscount > grandTotal) {
            pointsDiscount = grandTotal;
            pointsToRedeem = (int) grandTotal;
            sessionUser.setAttribute("redeemPoints", pointsToRedeem);
        }

        finalTotal = grandTotal - pointsDiscount;

        // Calculate points to earn: For every Rs baseConstant spent, user gets 10 points
        pointsToEarn = (int) Math.floor((finalTotal / baseConstant) * 10);

        // Fetch selected address
        if (selectedAddressId != null && !selectedAddressId.trim().equals("")) {
            ps = con.prepareStatement(
                "SELECT name, phonenumber, buildingname, area, city, pincode, state " +
                "FROM address WHERE id=? AND emailid=?"
            );
            ps.setInt(1, Integer.parseInt(selectedAddressId));
            ps.setString(2, loggedEmail);
            rs = ps.executeQuery();
            if (rs.next()) {
                uname = rs.getString("name");
                phone = rs.getString("phonenumber");
                building = rs.getString("buildingname");
                area = rs.getString("area");
                city = rs.getString("city");
                pincode = rs.getString("pincode");
                state = rs.getString("state");
            }
            rs.close(); ps.close();
        }

    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        debugInfo += "General error: " + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
%>

<!-- Debug Info (remove this in production) -->
<!-- Debug: <%= debugInfo %> -->

<main class="content">
<div class="container-fluid p-0">
    <h2 class="mb-4">Billing Summary</h2>

    <!-- Debug Alert (can be removed once working) -->
    <% if (userId == 0 || availableLoyaltyPoints == 0) { %>
    <div class="alert alert-warning alert-dismissible fade show" role="alert">
        <strong>Debug Info:</strong> User ID: <%= userId %>, Email: <%= loggedEmail %>, Available Points: <%= availableLoyaltyPoints %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- Loyalty Points -->
    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-dark text-white">Loyalty Points</div>
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-4">
                    <div class="text-center p-3 bg-light rounded">
                        <i class="fas fa-coins fa-2x text-warning mb-2"></i>
                        <h6 class="text-muted mb-1">Available Points</h6>
                        <h3 class="mb-0 text-success fw-bold"><%= availableLoyaltyPoints %></h3>
                        <p class="text-muted small mb-0">1 Point = Rs 1 discount</p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center p-3 bg-light rounded">
                        <i class="fas fa-tag fa-2x text-danger mb-2"></i>
                        <h6 class="text-muted mb-1">Points Redeeming</h6>
                        <h3 class="mb-0 text-danger fw-bold"><%= pointsToRedeem %></h3>
                        <p class="text-muted small mb-0">Discount: Rs <%= String.format("%.2f", pointsDiscount) %></p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center p-3 bg-light rounded">
                        <i class="fas fa-star fa-2x text-primary mb-2"></i>
                        <h6 class="text-muted mb-1">Points to Earn</h6>
                        <h3 class="mb-0 text-primary fw-bold"><%= pointsToEarn %></h3>
                        <p class="text-muted small mb-0">On this order</p>
                    </div>
                </div>
            </div>

            <% if (pointsToRedeem > 0 || availableLoyaltyPoints > 0) { %>
            <div class="alert alert-info mb-3">
                <strong><i class="fas fa-calculator"></i> Points Calculation:</strong>
                Current: <strong><%= availableLoyaltyPoints %></strong> 
                - Redeeming: <strong><%= pointsToRedeem %></strong> 
                + Earning: <strong><%= pointsToEarn %></strong> 
                = Final Balance: <strong><%= (availableLoyaltyPoints - pointsToRedeem + pointsToEarn) %></strong> points
            </div>
            <% } %>

            <% if (availableLoyaltyPoints > 0) { %>
            <form method="post" action="bill.jsp" class="mt-3">
                <div class="row align-items-end">
                    <div class="col-md-8">
                        <label class="form-label fw-bold">Redeem Points (Max: <%= availableLoyaltyPoints %>)</label>
                        <input type="number" name="redeemPoints" class="form-control"
                               value="<%= pointsToRedeem %>" min="0" max="<%= availableLoyaltyPoints %>"
                               placeholder="Enter points to redeem">
                        <small class="text-muted">Maximum you can use: <%= Math.min(availableLoyaltyPoints, (int)grandTotal) %> points (Rs <%= String.format("%.2f", Math.min(availableLoyaltyPoints, grandTotal)) %>)</small>
                    </div>
                    <div class="col-md-4">
                        <button type="submit" class="btn btn-primary">Apply Points</button>
                        <% if (pointsToRedeem > 0) { %>
                        <a href="bill.jsp?redeemPoints=0" class="btn btn-secondary">Clear</a>
                        <% } %>
                    </div>
                </div>
            </form>
            <% } else { %>
            <div class="alert alert-info mb-0">
                <i class="fas fa-info-circle"></i> You don't have any loyalty points yet.
                <% if (pointsToEarn > 0) { %>
                Complete this order to earn <strong><%= pointsToEarn %></strong> points!
                <% } else { %>
                Spend at least Rs <%= baseConstant %> to start earning loyalty points!
                <% } %>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Order Summary -->
    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-dark text-white">Order Summary</div>
        <div class="card-body">
            <table class="table table-bordered text-center align-middle">
                <thead class="table-secondary">
                    <tr>
                        <th>Image</th><th>Product</th><th>Price (Rs)</th><th>Qty</th><th>Total (Rs)</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (cartItems.isEmpty()) { %>
                    <tr><td colspan="5" class="text-muted">No items in cart.</td></tr>
                    <% } else {
                        for (String[] item : cartItems) { %>
                        <tr>
                            <td>
                                <% if (item[4] != null && !item[4].isEmpty()) { %>
                                <img src="data:image/jpeg;base64,<%= item[4] %>" width="60" height="60" class="rounded shadow-sm">
                                <% } else { %>
                                <span>No Image</span>
                                <% } %>
                            </td>
                            <td><%= item[0] %></td>
                            <td><%= item[1] %></td>
                            <td><%= item[2] %></td>
                            <td><%= item[3] %></td>
                        </tr>
                    <% } } %>
                </tbody>
                <tfoot class="fw-bold">
                    <tr><td colspan="4" class="text-end">Subtotal</td><td>Rs <%= String.format("%.2f", grandTotal) %></td></tr>
                    <% if (pointsToRedeem > 0) { %>
                    <tr class="text-success">
                        <td colspan="4" class="text-end">Loyalty Points Discount (<%= pointsToRedeem %> pts)</td>
                        <td>- Rs <%= String.format("%.2f", pointsDiscount) %></td>
                    </tr>
                    <% } %>
                    <tr class="table-warning"><td colspan="4" class="text-end">Grand Total</td><td>Rs <%= String.format("%.2f", finalTotal) %></td></tr>
                </tfoot>
            </table>
        </div>
    </div>

    <!-- Address -->
    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-dark text-white">Delivery Address</div>
        <div class="card-body">
            <% if (selectedAddressId != null && !selectedAddressId.trim().equals("") && uname != null && !uname.trim().equals("")) { %>
            <p><strong>Name:</strong> <%= uname %></p>
            <p><strong>Phone:</strong> <%= phone %></p>
            <p><strong>Address:</strong> <%= building %>, <%= area %>, <%= city %>, <%= state %> - <%= pincode %></p>
            <% } else { %>
            <p class="text-warning">No address selected. Please go back and select one.</p>
            <% } %>
        </div>
    </div>

    <!-- Payment -->
    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-dark text-white">Payment Method</div>
        <div class="card-body"><p><%= paymentMethod %></p></div>
    </div>

    <!-- Buttons -->
    <div class="text-center mb-4">
        <form action="place_order.jsp" method="post" class="d-inline">
            <input type="hidden" name="userId" value="<%= userId %>">
            <input type="hidden" name="emailid" value="<%= loggedEmail %>">
            <input type="hidden" name="payment" value="<%= paymentMethod %>">
            <input type="hidden" name="selectedAddress" value="<%= selectedAddressId %>">
            <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
            <input type="hidden" name="finalTotal" value="<%= finalTotal %>">
            <input type="hidden" name="pointsToRedeem" value="<%= pointsToRedeem %>">
            <input type="hidden" name="pointsToEarn" value="<%= pointsToEarn %>">
            <input type="hidden" name="pointsDiscount" value="<%= pointsDiscount %>">
            <button type="submit" class="btn btn-success btn-lg">Place Order</button>
        </form>
        <a href="checkout.jsp" class="btn btn-warning btn-lg ms-2">Back</a>
    </div>
</div>
</main>

<%@include file="footer.jsp" %>