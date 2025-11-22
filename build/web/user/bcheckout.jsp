
<%@page import="java.util.Base64"%>
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@include file="aheader.jsp" %>


<%
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");

    if (loggedEmail == null || loggedEmail.trim().isEmpty()) {
        response.sendRedirect("user_login.jsp?redirect=bbill.jsp");
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
    boolean isBuyNow = false;

    // Check if Buy Now session exists
    String buyNowId = (String) sessionUser.getAttribute("buyNowId");
    String buyNowQty = (String) sessionUser.getAttribute("buyNowQty");
    String buyNowPrice = (String) sessionUser.getAttribute("buyNowPrice");
    
    if (buyNowId != null && !buyNowId.trim().isEmpty()) {
        isBuyNow = true;
    }

    String selectedAddressId = request.getParameter("selectedAddressId");
    if (selectedAddressId != null && !selectedAddressId.trim().isEmpty()) {
        sessionUser.setAttribute("selectedAddressId", selectedAddressId);
    } else {
        selectedAddressId = (String) sessionUser.getAttribute("selectedAddressId");
    }

    String paymentMethod = request.getParameter("paymentType");
    if (paymentMethod != null && !paymentMethod.trim().equals("")) {
        sessionUser.setAttribute("payment", paymentMethod);
    }
    paymentMethod = (String) sessionUser.getAttribute("payment");
    if (paymentMethod == null) paymentMethod = "Not Selected";

    // Get card/UPI details from request
    String cardNumber = request.getParameter("cardNumber");
    String cvv = request.getParameter("cvv");
    String upiId = request.getParameter("upiId");

    String redeemPointsParam = request.getParameter("redeemPoints");
    if (redeemPointsParam != null && !redeemPointsParam.trim().equals("")) {
        try {
            pointsToRedeem = Integer.parseInt(redeemPointsParam);
            sessionUser.setAttribute("redeemPoints", pointsToRedeem);
        } catch (Exception e) {}
    } else if (sessionUser.getAttribute("redeemPoints") != null) {
        pointsToRedeem = (Integer) sessionUser.getAttribute("redeemPoints");
    }

    String uname = "", phone = "", building = "", area = "", city = "", pincode = "", state = "", addrFull = "";
    java.util.List<String[]> cartItems = new java.util.ArrayList<String[]>();
    java.util.List<String[]> addressList = new java.util.ArrayList<String[]>();

    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = new dbconfig().getConnection();

        // --- Get User ID ---
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
            baseConstant = 1000;
        }

        // --- Get loyalty points ---
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

        // --- Fetch items: Buy Now OR Cart ---
        if (isBuyNow && buyNowId != null && buyNowQty != null) {
            // Buy Now: Fetch single product only
            ps = con.prepareStatement("SELECT name, price, image FROM products WHERE id=?");
            ps.setString(1, buyNowId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                String pname = rs.getString("name");
                double price = rs.getDouble("price");
                int qty = Integer.parseInt(buyNowQty);
                double total = price * qty;
                grandTotal = total;

                byte[] img = rs.getBytes("image");
                String imgStr = (img != null && img.length > 0)
                        ? Base64.getEncoder().encodeToString(img) : "";

                cartItems.add(new String[]{pname, String.valueOf(price), String.valueOf(qty), String.valueOf(total), imgStr, buyNowId});
            }
            rs.close(); ps.close();
            
        } else {
            // Regular Cart: Fetch all cart items
            ps = con.prepareStatement(
                "SELECT p.id, p.name, p.price, p.image, c.quantity " +
                "FROM cart c INNER JOIN products p ON c.product_id=p.id " +
                "WHERE c.user_email=?"
            );
            ps.setString(1, loggedEmail);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                String productId = rs.getString("id");
                String pname = rs.getString("name");
                double price = rs.getDouble("price");
                int qty = rs.getInt("quantity");
                double total = price * qty;
                grandTotal += total;

                byte[] img = rs.getBytes("image");
                String imgStr = (img != null && img.length > 0)
                        ? Base64.getEncoder().encodeToString(img) : "";

                cartItems.add(new String[]{pname, String.valueOf(price), String.valueOf(qty), String.valueOf(total), imgStr, productId});
            }
            rs.close(); ps.close();
        }

        // Loyalty discount calculation
        pointsDiscount = pointsToRedeem * 1.0;
        if (pointsDiscount > grandTotal) {
            pointsDiscount = grandTotal;
            pointsToRedeem = (int) grandTotal;
            sessionUser.setAttribute("redeemPoints", pointsToRedeem);
        }

        finalTotal = grandTotal - pointsDiscount;

        // Calculate points to earn
        pointsToEarn = (int) Math.floor((finalTotal / baseConstant) * 10);

        // Fetch all addresses for selection
        ps = con.prepareStatement(
            "SELECT id, name, phonenumber, buildingname, area, city, pincode, state " +
            "FROM address WHERE emailid=?"
        );
        ps.setString(1, loggedEmail);
        rs = ps.executeQuery();
        while (rs.next()) {
            String[] addr = new String[8];
            addr[0] = rs.getString("id");
            addr[1] = rs.getString("name");
            addr[2] = rs.getString("phonenumber");
            addr[3] = rs.getString("buildingname");
            addr[4] = rs.getString("area");
            addr[5] = rs.getString("city");
            addr[6] = rs.getString("pincode");
            addr[7] = rs.getString("state");
            addressList.add(addr);
        }
        rs.close(); ps.close();

        // Fetch selected address details
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
                addrFull = building + ", " + area + ", " + city + ", " + state + " - " + pincode;
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

    String currentDate = new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
%>

<main class="content">
<div class="container-fluid p-0">
    <h1 class="h3 mb-3"><strong>Checkout</strong> Summary & Payment <%= isBuyNow ? "<span class='badge bg-info'>Buy Now</span>" : "" %></h1>

    <!-- Debug Alert -->
    <% if (userId == 0 || availableLoyaltyPoints == 0) { %>
    <div class="alert alert-warning alert-dismissible fade show" role="alert">
        <strong>Debug Info:</strong> User ID: <%= userId %>, Email: <%= loggedEmail %>, Available Points: <%= availableLoyaltyPoints %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- Loyalty Points Section -->
    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-dark text-white">
            <i class="fas fa-coins"></i> Loyalty Points
        </div>
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
            <form method="post" action="bbill.jsp" class="mt-3">
                <% if (selectedAddressId != null) { %>
                <input type="hidden" name="selectedAddressId" value="<%= selectedAddressId %>">
                <% } %>
                <% if (paymentMethod != null) { %>
                <input type="hidden" name="paymentType" value="<%= paymentMethod %>">
                <% } %>
                <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                
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
                        <a href="bbill.jsp?redeemPoints=0<%= selectedAddressId != null ? "&selectedAddressId=" + selectedAddressId : "" %><%= paymentMethod != null ? "&paymentType=" + paymentMethod : "" %>" class="btn btn-secondary">Clear</a>
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

    <div class="card shadow-sm p-4 rounded">
        <!-- Order Summary -->
        <h5 class="mb-3"><i class="fas fa-shopping-cart"></i> Order Summary</h5>
        <p><strong>Order Date:</strong> <%= currentDate %></p>
        
        <table class="table table-bordered align-middle">
            <thead class="table-dark">
                <tr>
                    <th>Product</th>
                    <th>Image</th>
                    <th>Price (Rs)</th>
                    <th>Quantity</th>
                    <th>Total (Rs)</th>
                </tr>
            </thead>
            <tbody>
            <% if (cartItems.isEmpty()) { %>
                <tr><td colspan="5" class="text-muted text-center">No items found.</td></tr>
            <% } else {
                for (String[] item : cartItems) { %>
                <tr>
                    <td><%= item[0] %></td>
                    <td>
                        <% if (item[4] != null && !item[4].isEmpty()) { %>
                        <img src="data:image/jpeg;base64,<%= item[4] %>" width="60" height="60" class="rounded shadow-sm"/>
                        <% } else { %>
                        <span>No Image</span>
                        <% } %>
                    </td>
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

        <!-- Address Selection or Display -->
        <div class="mb-4 mt-4">
            <h5><i class="fas fa-map-marker-alt"></i> Delivery Address</h5>
            <% if (selectedAddressId == null || selectedAddressId.trim().isEmpty()) { %>
                <% if (addressList.isEmpty()) { %>
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle"></i> No addresses found. 
                        <a href="userdetails.jsp" class="alert-link">Add an address</a> to proceed.
                    </div>
                <% } else { %>
                    <form method="post" action="bbill.jsp">
                        <% if (pointsToRedeem > 0) { %>
                        <input type="hidden" name="redeemPoints" value="<%= pointsToRedeem %>">
                        <% } %>
                        <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
                        
                        <h6 class="mb-3 fw-bold">Select Delivery Address:</h6>
                        <%
                            for (String[] addr : addressList) {
                                String addrId = addr[0];
                                String addrName = addr[1];
                                String addrPhone = addr[2];
                                String addrFullDisp = addr[3] + ", " + addr[4] + ", " + addr[5] + ", " + addr[7] + " - " + addr[6];
                        %>
                            <div class="border p-3 rounded mb-3">
                                <input type="radio" name="selectedAddressId" value="<%= addrId %>" required>
                                <strong><%= addrName %></strong> | <%= addrPhone %><br>
                                <span class="text-muted"><%= addrFullDisp %></span>
                            </div>
                        <% } %>
                        <button type="submit" class="btn btn-primary mb-3">Use Selected Address</button>
                    </form>
                <% } %>
            <% } else { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> <strong>Deliver to:</strong><br>
                    <strong><%= uname %></strong> | <%= phone %><br>
                    <%= addrFull %>
                </div>
            <% } %>
        </div>

        <!-- Payment Form -->
        <% if (selectedAddressId != null && !selectedAddressId.trim().isEmpty()) { %>
        <form action="place_order.jsp" method="post" onsubmit="return validateForm()" class="row g-3 mt-3">
            <input type="hidden" name="userId" value="<%= userId %>">
            <input type="hidden" name="emailid" value="<%= loggedEmail %>">
            <input type="hidden" name="selectedAddressId" value="<%= selectedAddressId %>">
            <input type="hidden" name="grandTotal" value="<%= grandTotal %>">
            <input type="hidden" name="finalTotal" value="<%= finalTotal %>">
            <input type="hidden" name="pointsToRedeem" value="<%= pointsToRedeem %>">
            <input type="hidden" name="pointsToEarn" value="<%= pointsToEarn %>">
            <input type="hidden" name="pointsDiscount" value="<%= pointsDiscount %>">
            <input type="hidden" name="isBuyNow" value="<%= isBuyNow %>">
            <% if (isBuyNow) { %>
            <input type="hidden" name="buyNowId" value="<%= buyNowId %>">
            <input type="hidden" name="buyNowQty" value="<%= buyNowQty %>">
            <% } %>

            <div class="col-12">
                <h5><i class="fas fa-credit-card"></i> Payment Method</h5>
            </div>

            <div class="col-md-6 mb-3">
                <label for="paymentType" class="form-label fw-bold">Select Payment Option:</label>
                <select name="paymentType" id="paymentType" class="form-select form-control-lg" required>
                    <option value="">--Select--</option>
                    <option value="Credit Card">Credit Card</option>
                    <option value="Debit Card">Debit Card</option>
                    <option value="UPI">UPI</option>
                    <option value="Cash on Delivery">Cash on Delivery</option>
                </select>
            </div>

            <div id="cardDetails" class="col-md-6 mb-3" style="display: none;">
                <label class="form-label">Card Number:</label>
                <input type="text" name="cardNumber" class="form-control form-control-lg mb-2" placeholder="Enter card number">

                <label class="form-label">CVV:</label>
                <input type="text" name="cvv" class="form-control form-control-lg" placeholder="Enter CVV">
            </div>

            <div id="upiDetails" class="col-md-6 mb-3" style="display: none;">
                <label class="form-label">UPI ID:</label>
                <input type="text" name="upiId" class="form-control form-control-lg" placeholder="Enter UPI ID">
            </div>

            <div class="text-center mt-4">
                <button type="submit" class="btn btn-lg btn-success shadow-sm">
                    <i class="fas fa-check-circle"></i> Place Order
                </button>
                <a href="<%= isBuyNow ? "products.jsp" : "viewcart.jsp" %>" class="btn btn-warning btn-lg ms-2">
                    <i class="fas fa-arrow-left"></i> Back
                </a>
            </div>
        </form>
        <% } else { %>
        <div class="alert alert-warning mt-3">
            <i class="fas fa-info-circle"></i> Please select a delivery address to proceed with payment.
        </div>
        <% } %>
    </div>
</div>
</main>

<script>
    const paymentType = document.getElementById("paymentType");
    const cardDetails = document.getElementById("cardDetails");
    const upiDetails = document.getElementById("upiDetails");

    if (paymentType) {
        paymentType.addEventListener("change", function () {
            const type = this.value;
            if (cardDetails && upiDetails) {
                cardDetails.style.display = (type === "Credit Card" || type === "Debit Card") ? "block" : "none";
                upiDetails.style.display = (type === "UPI") ? "block" : "none";
            }
        });
    }

    function validateForm() {
        const selected = paymentType.value;
        if (selected === "Credit Card" || selected === "Debit Card") {
            const cardNumber = document.querySelector("input[name='cardNumber']").value;
            const cvv = document.querySelector("input[name='cvv']").value;
            if (cardNumber.trim() === "" || cvv.trim() === "") {
                alert("Please enter card details.");
                return false;
            }
        } else if (selected === "UPI") {
            const upiId = document.querySelector("input[name='upiId']").value;
            if (upiId.trim() === "") {
                alert("Please enter UPI ID.");
                return false;
            }
        }
        return true;
    }
</script>

<%@include file="footer.jsp" %>