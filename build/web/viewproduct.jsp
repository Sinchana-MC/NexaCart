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
<%@page import="java.util.Base64"%>
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@include file="aheader.jsp"%>

<%
    String productId = request.getParameter("id");
    String name = "", caption = "", quantity = "", price = "", category = "", base64Image = "", description = ""; // ?? Added description

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
            "SELECT p.name, p.caption, p.quantity, p.price, p.image, p.description, c.name AS category_name " + // ?? Added p.description
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
            description = rs.getString("description"); // ?? Get description

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

<!-- Styles (unchanged) -->
<style>
    .fade-in {
        animation: fadeInUp 0.7s ease-in-out;
    }
    @keyframes fadeInUp {
        from { transform: translateY(20px); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
    }
    .zoom-hover {
        transition: transform 0.5s ease;
    }
    .zoom-hover:hover {
        transform: scale(1.08);
    }
    .product-image {
        height: 350px;
        object-fit: cover;
        width: 100%;
        border-radius: 0.5rem 0 0 0.5rem;
    }
    @media (max-width: 768px) {
        .product-image {
            height: 250px;
            border-radius: 0.5rem 0.5rem 0 0;
        }
    }
    .product-title {
        font-size: 2.2rem;
        font-weight: bold;
    }
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
                        <p class="mb-2"><strong>Price:</strong> <%= price %> Rs</p>
                        <p class="mb-2"><strong>Available Quantity:</strong> <%= quantity %></p>
                        <hr>
                        <p class="mb-2"><strong>Estimated Delivery:</strong> <%= estimatedFrom %> to <%= estimatedTo %></p>
                        <p class="mb-2"><strong>Return Date:</strong> <%= returnDate %></p>
                        <a href="home_admin.jsp" class="btn btn-secondary mt-3">Back to Products</a>

                        <!-- ?? Product Description Display -->
                        <% if (description != null && !description.trim().isEmpty()) { %>
                            <div class="mt-4">
                                <h5><strong>Product Description:</strong></h5>
                                <p style="text-align: justify;"><%= description %></p>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<%@include file="footer.jsp" %>
