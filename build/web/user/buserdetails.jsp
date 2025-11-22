
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@include file="aheader.jsp" %>

<%
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");

    if (loggedEmail == null || loggedEmail.trim().isEmpty()) {
        response.sendRedirect("user_login.jsp?redirect=userdetails.jsp");
        return;
    }

    // ? Check if coming from Buy Now
    String buyNowId = request.getParameter("id");
    String buyNowQty = request.getParameter("quantity");
    String buyNowPrice = request.getParameter("price");

    if (buyNowId != null && buyNowQty != null && buyNowPrice != null) {
        sessionUser.setAttribute("buyNowId", buyNowId);
        sessionUser.setAttribute("buyNowQty", buyNowQty);
        sessionUser.setAttribute("buyNowPrice", buyNowPrice);
    } else {
        sessionUser.removeAttribute("buyNowId");
        sessionUser.removeAttribute("buyNowQty");
        sessionUser.removeAttribute("buyNowPrice");
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    boolean hasAddress = false;
    String uname = "", phone = "";

    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = new dbconfig().getConnection();

        // Fetch user basic details
        ps = con.prepareStatement("SELECT name, phonenumber FROM user WHERE emailid = ?");
        ps.setString(1, loggedEmail);
        rs = ps.executeQuery();
        if (rs.next()) {
            uname = rs.getString("name");
            phone = rs.getString("phonenumber");
        }
        if(rs!=null) rs.close();
        if(ps!=null) ps.close();

        // Fetch all addresses
        ps = con.prepareStatement("SELECT id, name, phonenumber, buildingname, area, city, state, pincode FROM address WHERE emailid = ?");
        ps.setString(1, loggedEmail);
        rs = ps.executeQuery();
        if(rs.isBeforeFirst()) hasAddress = true;

    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }
%>

<main class="content">
<div class="container-fluid p-0">
    <h1 class="h3 mb-3"><strong>User</strong> Details</h1>
    <div class="card shadow-sm p-4 rounded">

        <% if (!hasAddress) { %>
            <!-- NEW USER / NO ADDRESS -->
            <form method="post" action="updateUserDetails.jsp">
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Email</label>
                        <input type="email" class="form-control" name="emailid" value="<%= loggedEmail %>" readonly>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Name</label>
                        <input type="text" class="form-control" name="name" value="<%= uname %>" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Phone Number</label>
                        <input type="text" class="form-control" name="phonenumber" value="<%= phone %>" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Building Name</label>
                        <input type="text" class="form-control" name="buildingname">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Area</label>
                        <input type="text" class="form-control" name="area">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">City</label>
                        <input type="text" class="form-control" name="city">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Pincode</label>
                        <input type="text" class="form-control" name="pincode">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">State</label>
                        <select class="form-control" name="state">
                            <option value="">-- Select State --</option>
                            <option>Andhra Pradesh</option>
                            <option>Arunachal Pradesh</option>
                            <option>Assam</option>
                            <option>Bihar</option>
                            <option>Chhattisgarh</option>
                            <option>Goa</option>
                            <option>Gujarat</option>
                            <option>Haryana</option>
                            <option>Himachal Pradesh</option>
                            <option>Jharkhand</option>
                            <option>Karnataka</option>
                            <option>Kerala</option>
                            <option>Madhya Pradesh</option>
                            <option>Maharashtra</option>
                            <option>Manipur</option>
                            <option>Meghalaya</option>
                            <option>Mizoram</option>
                            <option>Nagaland</option>
                            <option>Odisha</option>
                            <option>Punjab</option>
                            <option>Rajasthan</option>
                            <option>Sikkim</option>
                            <option>Tamil Nadu</option>
                            <option>Telangana</option>
                            <option>Tripura</option>
                            <option>Uttar Pradesh</option>
                            <option>Uttarakhand</option>
                            <option>West Bengal</option>
                            <option>Delhi</option>
                            <option>Puducherry</option>
                        </select>
                    </div>
                </div>

                <div class="text-center mt-4">
                    <button type="submit" class="btn btn-primary">Save Address</button>
                    <a href="bcheckout.jsp" class="btn btn-success">Proceed to Checkout</a>
                </div>
            </form>

        <% } else { %>
            <!-- OLD USER / HAS ADDRESSES -->
            <h5 class="mb-3 fw-bold">Saved Addresses</h5>
            <form method="post" action="bcheckout.jsp">
                <%
                    while (rs.next()) {
                        String addrId = rs.getString("id");
                        String addrName = rs.getString("name");
                        String addrPhone = rs.getString("phonenumber");
                        String addrFull = rs.getString("buildingname") + ", " + rs.getString("area") + ", " + rs.getString("city") + ", " + rs.getString("state") + " - " + rs.getString("pincode");
                %>
                    <div class="border p-3 rounded mb-3">
                        <input type="radio" name="selectedAddress" value="<%= addrId %>" required>
                        <strong><%= addrName %></strong> | <%= addrPhone %><br>
                        <span><%= addrFull %></span>
                    </div>
                <% } %>
                <div class="text-center mb-4">
                    <button type="submit" class="btn btn-success">Proceed with Selected Address</button>
                </div>
            </form>

            <hr>
            <h5 class="fw-bold">Add a New Address</h5>
            <form method="post" action="updateUserDetails.jsp">
                <input type="hidden" name="emailid" value="<%= loggedEmail %>">
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Name</label>
                        <input type="text" class="form-control" name="name" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Phone Number</label>
                        <input type="text" class="form-control" name="phonenumber" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Building Name</label>
                        <input type="text" class="form-control" name="buildingname">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Area</label>
                        <input type="text" class="form-control" name="area">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">City</label>
                        <input type="text" class="form-control" name="city">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Pincode</label>
                        <input type="text" class="form-control" name="pincode">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">State</label>
                        <select class="form-control" name="state">
                            <option value="">-- Select State --</option>
                            <!-- same states as above -->
                        </select>
                    </div>
                </div>
                <div class="text-center mt-3">
                    <button type="submit" class="btn btn-primary">Add Address</button>
                </div>
            </form>
        <% } %>
    </div>
</div>
</main>

<%@include file="footer.jsp" %>

