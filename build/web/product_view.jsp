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
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="Database.dbconfig"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.util.Base64"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

    <%@include file="aheader.jsp" %>
   
<main class="content">
	<div class="container-fluid p-0">
		<h1 class="h3 mb-3"><strong>Analytics</strong> Dashboard</h1>

    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-12 col-lg-8 col-xxl-12 d-flex">
                    <table class="table table-hover my-0">
                        <thead>
                            <tr> 
                                <th>Sl No</th>
                                <th>Name</th>
                                <th class="d-none d-xl-table-cell">Caption</th>
                                <th class="d-none d-xl-table-cell">Quantity</th>
                                <th class="d-none d-xl-table-cell">Price</th>
                                <th class="d-none d-xl-table-cell">Category</th>
                                <th class="d-none d-xl-table-cell">Image</th>
                                <th class="d-none d-md-table-cell">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.jdbc.Driver");
                                Connection con = new dbconfig().getConnection();
                                Statement stat = con.createStatement();

                                ResultSet res = stat.executeQuery(
                                    "SELECT p.id, p.name, p.caption, p.quantity, p.price, p.image, c.name AS category_name " +
                                    "FROM products p LEFT JOIN cat c ON p.cat_id = c.id"
                                );

                                int slno = 0;
                                while (res.next()) {
                                    slno++;
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
                            <tr>
                                <td><%= slno %></td>
                                <td><%= name %></td>
                                <td class="d-none d-xl-table-cell"><%= caption %></td>
                                <td class="d-none d-xl-table-cell"><%= quantity %></td>
                                <td class="d-none d-xl-table-cell"><%= price %></td>
                                <td class="d-none d-xl-table-cell"><%= category %></td>
                                <td class="d-none d-xl-table-cell">
                                    <% if (!base64Image.isEmpty()) { %>
                                        <img src="data:image/jpeg;base64,<%= base64Image %>" width="100" height="100" />
                                    <% } else { %>
                                        No Image
                                    <% } %>
                                </td>
                                <td class="d-none d-md-table-cell">
                                    <a href="deleteproduct?id=<%= id %>" class="btn btn-danger btn-sm mb-1">Delete</a><br>
                                    <a href="edit.jsp?id=<%= id %>" class="btn btn-primary">Edit</a>
                                </td>
                            </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.print("<tr><td colspan='8'>Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    </div>
</main>

    <%@include file="footer.jsp" %>
