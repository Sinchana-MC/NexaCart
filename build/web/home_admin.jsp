<%-- 
    Document   : home_admin
    Created on : 3 Aug, 2025, 1:18:12 PM
    Author     : veda1
--%>
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
<%@page import="java.sql.ResultSet"%>
<%@page import="Database.dbconfig"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@include file="aheader.jsp" %>


<main class="content">
    <div class="container-fluid p-0">
        <h2 class="text-center mb-4">Top Products Collection</h2>
        <div class="row">
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = new dbconfig().getConnection();
                    Statement stat = con.createStatement();

                    ResultSet res = stat.executeQuery(
                        "SELECT p.id, p.name, p.caption, p.quantity, p.price, p.image, c.name AS category_name " +
                        "FROM products p LEFT JOIN cat c ON p.cat_id = c.id"
                    );

                    while (res.next()) {
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
                <div class="card h-100 border-0 shadow-sm transition transform hover-shadow scale-hover" 
                     style="transition: transform 0.3s ease, box-shadow 0.3s ease;"
                     onmouseover="this.style.transform='scale(1.05)'; this.style.boxShadow='0 10px 20px rgba(0,0,0,0.2)'; this.querySelector('.card-title').style.color='darkblue';" 
                     onmouseout="this.style.transform='scale(1)'; this.style.boxShadow=''; this.querySelector('.card-title').style.color='';">
                     
                    <% if (!base64Image.isEmpty()) { %>
                        <img src="data:image/jpeg;base64,<%= base64Image %>" 
                             class="card-img-top img-fluid rounded-top" 
                             alt="<%= name %>" 
                             style="height: 240px; object-fit: cover;">
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
                        <form action="viewproduct.jsp" method="GET" style="display:inline;">
                            <input type="hidden" name="id" value="<%= id %>">
                            <button type="submit" class="btn btn-info btn-sm rounded-pill px-3 py-1">View</button>
                        </form>

                        <form action="edit.jsp" method="GET" style="display:inline;">
                            <input type="hidden" name="id" value="<%= id %>">
                            <button type="submit" class="btn btn-primary btn-sm rounded-pill px-3 py-1">Edit</button>
                        </form>

                        <form action="deleteproduct" method="GET" style="display:inline;">
                            <input type="hidden" name="id" value="<%= id %>">
                            <button type="submit" class="btn btn-danger btn-sm rounded-pill px-3 py-1">Delete</button>
                        </form>
                    </div>
                </div>
            </div>
            <%
                    }
                } catch (Exception e) {
                    out.print("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
</main>

<%@include file="footer.jsp" %>
