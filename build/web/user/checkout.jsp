

<%@page import="java.util.Base64"%>
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@include file="aheader.jsp" %>

<%
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");

    if (loggedEmail == null || loggedEmail.trim().isEmpty()) {
        response.sendRedirect("user_login.jsp?redirect=checkout.jsp");
        return;
    }

    String selectedAddressId = request.getParameter("selectedAddress");
    if(selectedAddressId == null || selectedAddressId.trim().isEmpty()){
        out.println("<div class='alert alert-danger'>No address selected. Please go back and select an address.</div>");
        return;
    }
    sessionUser.setAttribute("selectedAddressId", selectedAddressId);

    String addrFull = "";
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try{
        Class.forName("com.mysql.jdbc.Driver");
        con = new dbconfig().getConnection();
        ps = con.prepareStatement("SELECT buildingname, area, city, state, pincode FROM address WHERE id=?");
        ps.setString(1, selectedAddressId);
        rs = ps.executeQuery();
        if(rs.next()){
            addrFull = rs.getString("buildingname") + ", " + rs.getString("area") + ", " + rs.getString("city") + ", " + rs.getString("state") + " - " + rs.getString("pincode");
        }
    }catch(Exception e){
        out.println("<div class='alert alert-danger'>Error fetching address: "+e.getMessage()+"</div>");
    }finally{
        if(rs!=null) try{ rs.close(); }catch(Exception e){}
        if(ps!=null) try{ ps.close(); }catch(Exception e){}
        if(con!=null) try{ con.close(); }catch(Exception e){}
    }

    String currentDate = new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
%>

<main class="content">
<div class="container-fluid p-0">
    <h1 class="h3 mb-3"><strong>Checkout</strong> Payment</h1>

    <div class="card">
        <div class="card-body">
            <p><strong>Order Date:</strong> <%= currentDate %></p>
            <div class="mb-3">
                <h5>Deliver to:</h5>
                <p><strong><%= addrFull %></strong></p>
            </div>

            <form action="bill.jsp" method="post" onsubmit="return validateForm()" class="row g-3">
                <!-- Payment Type -->
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
                    <label for="cardNumber" class="form-label">Card Number:</label>
                    <input type="text" name="cardNumber" class="form-control form-control-lg" placeholder="Enter card number">

                    <label for="cvv" class="form-label mt-2">CVV:</label>
                    <input type="text" name="cvv" class="form-control form-control-lg" placeholder="Enter CVV">
                </div>

                <div id="upiDetails" class="col-md-6 mb-3" style="display: none;">
                    <label for="upiId" class="form-label">UPI ID:</label>
                    <input type="text" name="upiId" class="form-control form-control-lg" placeholder="Enter UPI ID">
                </div>

                <input type="hidden" name="orderDate" value="<%= currentDate %>">
                <div class="text-center mt-3">
                    <button type="submit" class="btn btn-lg btn-success shadow-sm">Place Order</button>
                    <a href="viewcart.jsp" class="btn btn-warning btn-lg ms-2">Back</a>
                </div>
            </form>
        </div>
    </div>
</div>
</main>

<script>
    const paymentType = document.getElementById("paymentType");
    const cardDetails = document.getElementById("cardDetails");
    const upiDetails = document.getElementById("upiDetails");

    paymentType.addEventListener("change", function () {
        const type = this.value;
        cardDetails.style.display = (type === "Credit Card" || type === "Debit Card") ? "block" : "none";
        upiDetails.style.display = (type === "UPI") ? "block" : "none";
    });

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
