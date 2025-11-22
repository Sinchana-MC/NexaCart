
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
<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="aheader.jsp" %>


<%
    String id = request.getParameter("id");
    String name = "";
    boolean isEdit = false;

    if (id != null && !id.trim().isEmpty()) {
        isEdit = true;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = new dbconfig().getConnection();
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM cat WHERE id='" + id + "'");

            if (rs.next()) {
                name = rs.getString("name");
            }
            con.close();
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    }
%>

<main class="content">
    <div class="container-fluid p-0">
        <h1 class="h3 mb-3"><strong>Category</strong> Dashboard</h1>

        <!-- Add/Edit Category Form -->
        <div class="card mb-4 shadow">
            <div class="card-body">
                <form action="<%= isEdit ? "updatecategory.jsp" : "addproducts" %>" method="POST">
                    <% if (isEdit) { %>
                        <input type="hidden" name="id" value="<%= id %>">
                    <% } %>
                    <div class="row mb-3 align-items-center">
                        <label class="form-label">Category Name</label>
                        <div class="col-md-8">
                            <input class="form-control form-control-lg" type="text" name="name" placeholder="Enter category name" value="<%= name %>" required />
                        </div>
                        <div class="col-md-2">
                            <button type="submit" class="btn btn-lg btn-primary">
                                <%= isEdit ? "Update" : "OK" %>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- Category Table -->
        <div class="card shadow">
            <div class="card-body">
                <table class="table table-bordered table-hover table-striped">
                    <thead class="table-primary">
                        <tr>
                            <th scope="col">Sl. No</th>
                            <th scope="col">Name</th>
                            <th scope="col">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.jdbc.Driver");
                                Connection con = new dbconfig().getConnection();
                                Statement stat = con.createStatement();
                                ResultSet res = stat.executeQuery("SELECT * FROM `cat`");

                                int slno = 0;
                                while (res.next()) {
                                    slno++;
                                    String catName = res.getString("name");
                                    String catId = res.getString("id");
                        %>
                        <tr>
                            <td><%= slno %></td>
                            <td><%= catName %></td>
                            <td>
                                <form action="add_category.jsp" method="GET" style="display:inline;">
    <input type="hidden" name="id" value="<%= catId %>">
    <button type="submit" class="btn btn-warning btn-sm rounded-2 px-4 py-2">Edit</button>
</form>

<form action="delete" method="GET" style="display:inline;">
    <input type="hidden" name="id" value="<%= catId %>">
    <button type="submit" class="btn btn-danger btn-sm rounded-2 px-4 py-2">Delete</button>
</form>
                            </td>
                        </tr>
                        <%
                                }
                                con.close();
                            } catch (Exception e) {
                                out.print("<tr><td colspan='3' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<script src="js/app.js"></script>
<%@include file="footer.jsp" %>
