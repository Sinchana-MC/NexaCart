

<%@page import="java.util.Base64"%>
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@include file="aheader.jsp" %>

<%
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");

    if (loggedEmail == null || loggedEmail.trim().isEmpty()) {
        response.sendRedirect("user_login.jsp?redirect=buynow.jsp?id=" + request.getParameter("id"));
        return;
    }

    String id = request.getParameter("id");
    String name = "", caption = "", price = "", category = "", quantity = "";
    String base64Image = "";
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = new dbconfig().getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT p.id, p.name, p.caption, p.price, p.quantity, p.image, c.name AS category_name " +
            "FROM products p LEFT JOIN cat c ON p.cat_id = c.id WHERE p.id=?"
        );
        ps.setString(1, id);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            name = rs.getString("name");
            caption = rs.getString("caption");
            price = rs.getString("price");
            quantity = rs.getString("quantity");
            category = rs.getString("category_name") != null ? rs.getString("category_name") : "Uncategorized";

            byte[] imageBytes = rs.getBytes("image");
            if (imageBytes != null && imageBytes.length > 0) {
                base64Image = Base64.getEncoder().encodeToString(imageBytes);
            }
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }
%>

<main class="content">
    <div class="container p-4">
        <h2 class="text-center mb-4">Buy Now</h2>

        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow-lg border-0">
                    <% if (!base64Image.isEmpty()) { %>
                        <img src="data:image/jpeg;base64,<%= base64Image %>" 
                             class="card-img-top img-fluid" 
                             alt="<%= name %>" 
                             style="height: 300px; object-fit: cover;">
                    <% } else { %>
                        <div class="card-img-top d-flex align-items-center justify-content-center bg-light" style="height: 300px;">
                            <span>No Image</span>
                        </div>
                    <% } %>

                    <div class="card-body">
                        <h4 class="fw-bold text-primary"><%= name %></h4>
                        <p class="text-muted"><%= caption %></p>
                        <p><strong>Category:</strong> <%= category %></p>
                        <p><strong>Available Quantity:</strong> <%= quantity %></p>
                        <p><strong>Price per unit:</strong> <%= price %> Rs</p>

                        <!-- Buy Form -->
                        <form action="buserdetails.jsp" method="POST">
                            <input type="hidden" name="id" value="<%= id %>">
                            <input type="hidden" name="price" value="<%= price %>" id="basePrice">

                            <div class="mb-3">
                                <label for="qty" class="form-label"><strong>Select Quantity:</strong></label>
                                <select name="quantity" id="qty" class="form-select rounded-pill" onchange="updatePrice()">
                                    <% for (int i = 1; i <= 10; i++) { %>
                                        <option value="<%= i %>"><%= i %></option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="mb-3">
                                <p><strong>Total Price:</strong> <span id="totalPrice"><%= price %></span> Rs</p>
                            </div>

                            <button type="submit" class="btn btn-success w-100 rounded-pill">Proceed to Checkout</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    function updatePrice() {
        let qty = document.getElementById("qty").value;
        let basePrice = document.getElementById("basePrice").value;
        let total = qty * basePrice;
        document.getElementById("totalPrice").innerText = total;
    }
</script>

<%@include file="footer.jsp" %>
