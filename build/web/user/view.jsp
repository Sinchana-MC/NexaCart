

<%@page import="java.util.Base64"%>
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@include file="aheader.jsp"%>

<%
    String productId = request.getParameter("id");
    String name = "", caption = "", quantity = "", price = "", category = "", base64Image = "", description = "";

    // Session check
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");
    boolean isLoggedIn = (loggedEmail != null && !loggedEmail.trim().isEmpty());

    String popupMessage = null;

    // Handle Add to Cart request
    if (request.getParameter("addToCart") != null && isLoggedIn) {
        String selectedQty = request.getParameter("selectedQty");
        int qtyToAdd = (selectedQty != null) ? Integer.parseInt(selectedQty) : 1;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = new dbconfig().getConnection();
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO cart(user_email, product_id, quantity) VALUES(?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE quantity = quantity + ?"
            );
            ps.setString(1, loggedEmail);
            ps.setString(2, productId);
            ps.setInt(3, qtyToAdd);
            ps.setInt(4, qtyToAdd);
            ps.executeUpdate();
            popupMessage = "Product has been added to your cart!";
        } catch (Exception e) {
            popupMessage = "Error adding product to cart: " + e.getMessage();
        }
    }

    // Delivery dates
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
    Calendar calendar = Calendar.getInstance();

    calendar.setTime(new Date());
    calendar.add(Calendar.DATE, 3);
    String estimatedFrom = sdf.format(calendar.getTime());

    calendar.setTime(new Date());
    calendar.add(Calendar.DATE, 5);
    String estimatedTo = sdf.format(calendar.getTime());

    calendar.setTime(new Date());
    calendar.add(Calendar.DATE, 7);
    String returnDate = sdf.format(calendar.getTime());

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = new dbconfig().getConnection();
        PreparedStatement ps = con.prepareStatement(
            "SELECT p.name, p.caption, p.quantity, p.price, p.image, p.description, c.name AS category_name " +
            "FROM products p LEFT JOIN cat c ON p.cat_id = c.id WHERE p.id = ?"
        );
        ps.setString(1, productId);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            name = rs.getString("name");
            caption = rs.getString("caption");
            quantity = rs.getString("quantity");
            price = rs.getString("price");
            category = rs.getString("category_name") != null ? rs.getString("category_name") : "Uncategorized";
            description = rs.getString("description");

            byte[] imageBytes = rs.getBytes("image");
            if (imageBytes != null && imageBytes.length > 0) {
                base64Image = Base64.getEncoder().encodeToString(imageBytes);
            }
        } else {
            out.print("<div class='alert alert-danger'>Product not found!</div>");
        }

    } catch (Exception e) {
        out.print("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }
%>

<style>
    .fade-in { animation: fadeInUp 0.7s ease-in-out; }
    @keyframes fadeInUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    .zoom-hover { transition: transform 0.5s ease; }
    .zoom-hover:hover { transform: scale(1.08); }
    .product-image {
        height: 350px; object-fit: cover; width: 100%;
        border-radius: 0.5rem 0 0 0.5rem;
    }
    @media (max-width: 768px) {
        .product-image { height: 250px; border-radius: 0.5rem 0.5rem 0 0; }
    }
    .product-title { font-size: 2.2rem; font-weight: bold; }
</style>

<main class="content">
    <div class="container py-5">
        <div class="card shadow-lg border-0 mx-auto fade-in" style="max-width: 900px;">
            <div class="row g-0">
                <div class="col-md-6">
                    <% if (!base64Image.isEmpty()) { %>
                        <img src="data:image/jpeg;base64,<%= base64Image %>" class="product-image zoom-hover" alt="<%= name %>">
                    <% } else { %>
                        <div class="d-flex align-items-center justify-content-center bg-light" style="height: 350px;">
                            <span>No Image Available</span>
                        </div>
                    <% } %>
                </div>
                <div class="col-md-6">
                    <div class="card-body">
                        <h2 class="card-title text-primary product-title mb-3"><%= name %></h2>
                        <p class="mb-2"><strong>Caption:</strong> <%= caption %></p>
                        <p class="mb-2"><strong>Category:</strong> <%= category %></p>
                        <p class="mb-2"><strong>Price (per unit):</strong> <%= price %> Rs</p>
                        
                        <hr>
                        <p class="mb-2"><strong>Estimated Delivery:</strong> <%= estimatedFrom %> to <%= estimatedTo %></p>
                        <p class="mb-2"><strong>Return Date:</strong> <%= returnDate %></p>

                        <% if (description != null && !description.trim().isEmpty()) { %>
                            <div class="mt-4">
                                <h5><strong>Product Description:</strong></h5>
                                <p style="text-align: justify;"><%= description %></p>
                            </div>
                        <% } %>

                        <!-- Quantity & Buttons -->
                        <div class="mt-4">
                            <label for="qty"><strong>Quantity:</strong></label>
                            <select id="qty" class="form-select d-inline-block w-auto ms-2" onchange="updateTotal()">
                                <% for (int i = 1; i <= 10; i++) { %>
                                    <option value="<%= i %>"><%= i %></option>
                                <% } %>
                            </select>
                            <p class="mt-2"><strong>Total Price:</strong> <span id="totalPrice"><%= price %></span> Rs</p>
                        </div>

                        <div class="mt-4">
                            <% if (isLoggedIn) { %>
                                <!-- Add to Cart -->
                                <form method="post" action="view.jsp" style="display:inline;" id="addCartForm">
                                    <input type="hidden" name="id" value="<%= productId %>">
                                    <input type="hidden" name="addToCart" value="true">
                                    <input type="hidden" name="selectedQty" id="cartQty" value="1">
                                    <button type="submit" class="btn btn-warning me-2">Add to Cart</button>
                                </form>
                                <!-- Buy Now -->
                                <form action="userdetails.jsp" method="GET" style="display:inline;" id="buyNowForm">
                                    <input type="hidden" name="id" value="<%= productId %>">
                                    <input type="hidden" name="selectedQty" id="buyQty" value="1">
                                    <button type="submit" class="btn btn-success">Buy Now</button>
                                </form>
                            <% } else { %>
                                <!-- If not logged in -->
                                <form action="user_login.jsp" method="GET" style="display:inline;">
                                    <input type="hidden" name="redirect" value="view.jsp?id=<%= productId %>">
                                    <button type="submit" class="btn btn-warning me-2">Add to Cart</button>
                                </form>
                                <form action="user_login.jsp" method="GET" style="display:inline;">
                                    <input type="hidden" name="redirect" value="userdetails.jsp?id=<%= productId %>">
                                    <button type="submit" class="btn btn-success">Buy Now</button>
                                </form>
                            <% } %>

                            <a href="index.jsp" class="btn btn-secondary ms-2">Back to Products</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    let unitPrice = <%= price %>;
    function updateTotal() {
        let qty = document.getElementById("qty").value;
        let total = unitPrice * qty;
        document.getElementById("totalPrice").innerText = total;
        document.getElementById("cartQty").value = qty;
        document.getElementById("buyQty").value = qty;
    }
</script>

<!-- Popup Script -->
<% if (popupMessage != null) { %>
<script>
    alert("<%= popupMessage %>");
    window.location.href = "view.jsp?id=<%= productId %>";
</script>
<% } %>

<%@include file="footer.jsp" %>
