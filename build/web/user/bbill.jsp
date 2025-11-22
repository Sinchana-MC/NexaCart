
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

    // Selected address
    String selectedAddressId = (String) sessionUser.getAttribute("selectedAddressId");

    // Payment method
    String paymentMethod = request.getParameter("paymentType");
    if(paymentMethod != null && !paymentMethod.trim().equals("")){
        sessionUser.setAttribute("payment", paymentMethod);
    }
    paymentMethod = (String) sessionUser.getAttribute("payment");
    if(paymentMethod == null) paymentMethod = "Not Selected";

    // Address details
    String uname="", phone="", building="", area="", city="", pincode="", state="";
    java.util.List<String[]> cartItems = new java.util.ArrayList<String[]>();

    try {
        con = new dbconfig().getConnection();

        // ? Buy Now session check
        String buyNowId = (String) sessionUser.getAttribute("buyNowId");
        String buyNowQty = (String) sessionUser.getAttribute("buyNowQty");

        if(buyNowId != null && buyNowQty != null){
            ps = con.prepareStatement("SELECT name, price, image FROM products WHERE id=?");
            ps.setString(1, buyNowId);
            rs = ps.executeQuery();
            if(rs.next()){
                String pname = rs.getString("name");
                double price = rs.getDouble("price");
                int qty = Integer.parseInt(buyNowQty);
                double total = price * qty;
                grandTotal += total;

                byte[] img = rs.getBytes("image");
                String imgStr = (img != null && img.length > 0) 
                    ? Base64.getEncoder().encodeToString(img) : "";

                cartItems.add(new String[]{pname, String.valueOf(price), String.valueOf(qty), String.valueOf(total), imgStr});
            }
            rs.close(); ps.close();
        } else {
            // ? Else load cart items
            ps = con.prepareStatement(
                "SELECT p.id, p.name, p.price, p.image, c.quantity " +
                "FROM cart c INNER JOIN products p ON c.product_id=p.id " +
                "WHERE c.user_email=?"
            );
            ps.setString(1, loggedEmail);
            rs = ps.executeQuery();
            while(rs.next()){
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
        }

        // ? Fetch selected address
        if(selectedAddressId != null && !selectedAddressId.trim().equals("")){
            ps = con.prepareStatement(
                "SELECT name, phonenumber, buildingname, area, city, pincode, state " +
                "FROM address WHERE id=? AND emailid=?"
            );
            ps.setInt(1, Integer.parseInt(selectedAddressId));
            ps.setString(2, loggedEmail);
            rs = ps.executeQuery();
            if(rs.next()){
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

    } catch(Exception e){
        out.println("<div class='alert alert-danger'>Error: "+e.getMessage()+"</div>");
    } finally {
        if(rs!=null) try{rs.close();}catch(Exception e){}
        if(ps!=null) try{ps.close();}catch(Exception e){}
        if(con!=null) try{con.close();}catch(Exception e){}
    }
%>

<main class="content">
<div class="container-fluid p-0">
    <h2 class="mb-4">Billing Summary</h2>

    <!-- Cart/Buy Now Details -->
    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-dark text-white">Order Summary</div>
        <div class="card-body">
            <table class="table table-bordered text-center align-middle">
                <thead class="table-secondary">
                    <tr>
                        <th>Image</th>
                        <th>Product</th>
                        <th>Price (Rs)</th>
                        <th>Qty</th>
                        <th>Total (Rs)</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if(cartItems.isEmpty()){
                    %>
                        <tr><td colspan="5" class="text-muted">No items found.</td></tr>
                    <%
                        } else {
                            for(String[] item : cartItems){
                    %>
                        <tr>
                            <td>
                                <% if(item[4] != null && !item[4].isEmpty()){ %>
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
                    <%
                            }
                        }
                    %>
                </tbody>
                <tfoot class="fw-bold">
                    <tr>
                        <td colspan="4" class="text-end">Grand Total</td>
                        <td><%= grandTotal %></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>

    <!-- Address -->
    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-dark text-white">Delivery Address</div>
        <div class="card-body">
            <% if(selectedAddressId != null && !selectedAddressId.trim().equals("") && uname != null && !uname.trim().equals("")) { %>
                <p><strong>Name:</strong> <%= uname %></p>
                <p><strong>Phone:</strong> <%= phone %></p>
                <p><strong>Address:</strong> <%= building %>, <%= area %>, <%= city %>, <%= state %> - <%= pincode %></p>
            <% } else { %>
                <p class="text-warning">No address selected. Please go back and select an address.</p>
            <% } %>
        </div>
    </div>

    <!-- Payment -->
    <div class="card mb-4 shadow-sm">
        <div class="card-header bg-dark text-white">Payment Method</div>
        <div class="card-body">
            <p><%= paymentMethod %></p>
        </div>
    </div>

    <!-- Buttons -->
    <div class="text-center mb-4">
        <form action="bplace_order.jsp" method="post" class="d-inline">
            <input type="hidden" name="emailid" value="<%= loggedEmail %>">
            <input type="hidden" name="payment" value="<%= paymentMethod %>">
            <input type="hidden" name="selectedAddress" value="<%= selectedAddressId %>">
            <button type="submit" class="btn btn-success btn-lg">Place Order</button>
        </form>
        <a href="bcheckout.jsp" class="btn btn-warning btn-lg ms-2">Back</a>
    </div>
</div>
</main>

<%@include file="footer.jsp" %>
