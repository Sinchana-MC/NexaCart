

<%@page import="java.util.Base64"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="Database.dbconfig"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@include file="aheader.jsp" %>

<%
    // Check login status from session
    HttpSession sessionUser = request.getSession();
    String loggedEmail = (String) sessionUser.getAttribute("uemail");
    boolean isLoggedIn = (loggedEmail != null && !loggedEmail.trim().isEmpty());

    String popupMessage = null; // To store the success message

    // Handle Add to Cart request
    if (request.getParameter("addToCart") != null && isLoggedIn) {
        try {
            String productId = request.getParameter("id");
            int quantity = 1; // default quantity when adding

            Class.forName("com.mysql.jdbc.Driver");
            Connection con = new dbconfig().getConnection();

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO cart(user_email, product_id, quantity) VALUES(?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE quantity = quantity + 1"
            );
            ps.setString(1, loggedEmail);
            ps.setString(2, productId);
            ps.setInt(3, quantity);
            ps.executeUpdate();

            popupMessage = "Product has been added to your cart!";
        } catch (Exception e) {
            popupMessage = "Error adding product to cart: " + e.getMessage();
        }
    }

    // Handle search & filters
    String searchQuery = request.getParameter("search");
    if (searchQuery == null) searchQuery = "";

    String priceFilter = request.getParameter("filter");
    if (priceFilter == null) priceFilter = "";

    String selectedCategoryId = request.getParameter("category");
    if (selectedCategoryId == null) selectedCategoryId = "";
%>

<main class="content">
    <div class="container-fluid p-0">
        <h2 class="text-center mb-4">Top Products Collection</h2>

        <!-- Search + Price + Category Filter Bar -->
        <form method="get" action="index.jsp" class="row justify-content-center mb-4 g-2">
            <div class="col-md-4">
                <input type="text" name="search" value="<%= searchQuery %>" 
                       class="form-control rounded-pill" placeholder="Search products...">
            </div>
            <div class="col-md-3">
                <select name="filter" class="form-select rounded-pill">
                    <option value="">Sort by Price</option>
                    <option value="low" <%= "low".equals(priceFilter) ? "selected" : "" %>>Low to High</option>
                    <option value="high" <%= "high".equals(priceFilter) ? "selected" : "" %>>High to Low</option>
                </select>
            </div>
            <div class="col-md-3">
                <select name="category" id="category" class="form-select rounded-pill">
                    <option value="">-- All Categories --</option>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection con = new dbconfig().getConnection();
                            PreparedStatement catStmt = con.prepareStatement("SELECT id, name FROM cat ORDER BY name ASC");
                            ResultSet catRs = catStmt.executeQuery();

                            while (catRs.next()) {
                                String catId = catRs.getString("id");
                                String catName = catRs.getString("name");
                                String selected = (catId.equals(selectedCategoryId)) ? "selected" : "";
                    %>
                        <option value="<%= catId %>" <%= selected %>><%= catName %></option>
                    <%
                            }
                            catRs.close();
                            catStmt.close();
                        } catch (Exception e) {
                            out.println("<option disabled>Error loading categories</option>");
                        }
                    %>
                </select>
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-primary w-100 rounded-pill">Apply</button>
            </div>
        </form>

        <!-- Product Display -->
        <div class="row">
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = new dbconfig().getConnection();

                    String sql = "SELECT p.id, p.name, p.caption, p.quantity, p.price, p.image, c.name AS category_name " +
                                 "FROM products p LEFT JOIN cat c ON p.cat_id = c.id WHERE 1=1";

                    // Search filter
                    if (!searchQuery.trim().isEmpty()) {
                        sql += " AND (p.name LIKE ? OR p.caption LIKE ? OR c.name LIKE ?)";
                    }

                    // Category filter
                    if (!selectedCategoryId.trim().isEmpty()) {
                        sql += " AND p.cat_id = ?";
                    }

                    // Price filter
                    if ("low".equals(priceFilter)) {
                        sql += " ORDER BY p.price ASC";
                    } else if ("high".equals(priceFilter)) {
                        sql += " ORDER BY p.price DESC";
                    } else {
                        sql += " ORDER BY p.name ASC";
                    }

                    PreparedStatement ps = con.prepareStatement(sql);

                    int paramIndex = 1;
                    if (!searchQuery.trim().isEmpty()) {
                        String searchPattern = "%" + searchQuery + "%";
                        ps.setString(paramIndex++, searchPattern);
                        ps.setString(paramIndex++, searchPattern);
                        ps.setString(paramIndex++, searchPattern);
                    }

                    if (!selectedCategoryId.trim().isEmpty()) {
                        ps.setInt(paramIndex++, Integer.parseInt(selectedCategoryId));
                    }

                    ResultSet res = ps.executeQuery();

                    boolean hasResults = false;
                    while (res.next()) {
                        hasResults = true;
                        String id = res.getString("id");
                        String name = res.getString("name");
                        String caption = res.getString("caption");
                        String quantity = res.getString("quantity");
                        String price = res.getString("price");
                        String category = res.getString("category_name") != null ? res.getString("category_name") : "Uncategorized";

                        byte[] imageBytes = res.getBytes("image");
                        String base64Image = "";
                        if (imageBytes != null && imageBytes.length > 0) {
                            base64Image = Base64.getEncoder().encodeToString(imageBytes);
                        }
            %>
            <div class="col-md-6 col-lg-4 col-xl-3 mb-4">
                <div class="card h-100 border-0 shadow-sm"
                     style="transition: transform 0.3s ease, box-shadow 0.3s ease;"
                     onmouseover="this.style.transform='scale(1.05)'; this.style.boxShadow='0 10px 20px rgba(0,0,0,0.2)';" 
                     onmouseout="this.style.transform='scale(1)'; this.style.boxShadow='';">

                    <% if (!base64Image.isEmpty()) { %>
                        <a href="view.jsp?id=<%=id%>"> 
                            <img src="data:image/jpeg;base64,<%= base64Image %>" 
                                 class="card-img-top img-fluid rounded-top" 
                                 alt="<%= name %>" 
                                 style="height: 240px; object-fit: cover;"> 
                        </a>
                    <% } else { %>
                        <div class="card-img-top d-flex align-items-center justify-content-center bg-light" style="height: 240px;">
                            <span>No Image</span>
                        </div>
                    <% } %>

                    <div class="card-body text-center">
                        <h5 class="card-title fw-bold text-primary" style="font-size: 1.6rem;"><%= name %></h5>
                        <p class="text-muted mb-1"><%= caption %></p>
                        <p class="mb-1">Category: <strong><%= category %></strong></p>
                        <p class="mb-1">Price: <%= price %> Rs</p>
                        <p class="mb-0">Available Quantity: <%= quantity %></p>
                    </div>

                    <div class="card-footer d-flex justify-content-center gap-2 bg-white">
                        <% if (isLoggedIn) { %>
                            <form method="post" action="index.jsp" style="display:inline;">
                                <input type="hidden" name="id" value="<%= id %>">
                                <input type="hidden" name="addToCart" value="true">
                                <button type="submit" class="btn btn-info btn-sm rounded-pill px-3 py-1">Add To Cart</button>
                            </form>

                            <form action="buynow.jsp" method="GET" style="display:inline;">
                                <input type="hidden" name="id" value="<%= id %>">
                                <button type="submit" class="btn btn-primary btn-sm rounded-pill px-3 py-1">Buy Now</button>
                            </form>
                        <% } else { %>
                            <form action="user_login.jsp" method="GET" style="display:inline;">
                                <input type="hidden" name="redirect" value="cart.jsp?id=<%= id %>">
                                <button type="submit" class="btn btn-info btn-sm rounded-pill px-3 py-1">Add To Cart</button>
                            </form>

                            <form action="user_login.jsp" method="GET" style="display:inline;">
                                <input type="hidden" name="redirect" value="buynow.jsp?id=<%= id %>">
                                <button type="submit" class="btn btn-primary btn-sm rounded-pill px-3 py-1">Buy Now</button>
                            </form>
                        <% } %>
                    </div>
                </div>
            </div>
            <%
                    } // end while

                    if (!hasResults) {
                        out.print("<div class='col-12 text-center'><div class='alert alert-warning'>No products found for your filters.</div></div>");
                    }

                } catch (Exception e) {
                    out.print("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
</main>

<!-- Popup Script -->
<% if (popupMessage != null) { %>
<script>
    alert("<%= popupMessage %>");
    window.location.href = "index.jsp";
</script>
<% } %>

<%@include file="footer.jsp" %>
