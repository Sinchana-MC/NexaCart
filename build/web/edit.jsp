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

<%
    String id = request.getParameter("id");
    String name = "", caption = "", quantity = "", price = "", cat_id = "";

    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection con = new dbconfig().getConnection();
        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM products WHERE id='" + id + "'");
        if (rs.next()) {
            name = rs.getString("name");
            caption = rs.getString("caption");
            quantity = rs.getString("quantity");
            price = rs.getString("price");
            cat_id = rs.getString("cat_id");
        }
        con.close();
    } catch (Exception e) {
        out.println("Error: " + e);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@include file="aheader.jsp" %>
    <title>Edit Product</title>
    <link href="css/app.css" rel="stylesheet">
</head>
<body>
<main class="content">
    <div class="container-fluid p-0">
        
            <h1 class="h3 mb-3"><strong>Edit Product</strong></h1>
        
        <div class="card">
            <div class="card-body">
                <form action="edit_product.jsp" method="post">
                    <input type="hidden" name="id" value="<%= id %>">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Name:</label>
                            <input class="form-control form-control-lg" type="text" name="name" value="<%= name %>" required />
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Caption:</label>
                            <input class="form-control form-control-lg" type="text" name="caption" value="<%= caption%>" required />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Quantity:</label>
                            <input class="form-control form-control-lg" type="number" name="quantity" value="<%= quantity %>" required />
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Price:</label>
                            <input class="form-control form-control-lg" type="number" name="price" value="<%= price %>" required />
                        </div>
                    </div>

                    <center>
                                                <div class="col-md-6 mb-3">
                        <label class="form-label">Category:</label>
                        <select class="form-control form-control-lg" name="category_name" required>
                            
                                                </center>
                            <%
                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    Connection con = new dbconfig().getConnection();
                                    Statement stmt = con.createStatement();
                                    ResultSet rs = stmt.executeQuery("SELECT * FROM cat");

                                    while (rs.next()) {
                                        String cid = rs.getString("id");
                                        String cname = rs.getString("name");
                                        String selected = cat_id.equals(cid) ? "selected" : "";
                            %>
                            <option value="<%= cname %>" <%= selected %>><%= cname %></option>
                            <%
                                    }
                                    con.close();
                                } catch (Exception e) {
                                    out.println("Error loading categories: " + e);
                                }
                            %>
                        </select>
                    </div>

                    <div class="text-center mt-3">
                        <button type="submit" class="btn btn-primary">Update Product</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>
<%@include file="footer.jsp" %>
<script src="js/app.js"></script>
</body>
</html>
