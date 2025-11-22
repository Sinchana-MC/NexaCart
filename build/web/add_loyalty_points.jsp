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
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="aheader.jsp" %>


<main class="content">
    <div class="container-fluid p-0">
        <h1 class="h3 mb-3"><strong>Loyalty Points</strong> Entry</h1>

        <!-- Form to Add Loyalty Points -->
        <div class="card">
            <div class="card-body">
                <form action="add_loyalty_point" method="post">
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Base Constant (Rs)</label>
                            <input type="text" class="form-control" value="1000" readonly />
                        </div>
                        <div class="col-md-4">
                            <label for="points" class="form-label fw-bold">Loyalty Points</label>
                            <input type="number" class="form-control" name="points" id="points" placeholder="Enter loyalty points" required />
                        </div>
                    </div>
                    <button type="submit" class="btn btn-success">Update</button>
                </form>
            </div>
        </div>

        <!-- Loyalty Points Table -->
        <h3 class="mt-4">Loyalty Points Table</h3>
        <div class="card">
            <div class="card-body">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Points</th>
                            <th>Status</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection con = new Database.dbconfig().getConnection();
                            Statement stmt = con.createStatement();

                            // Order by date ASC, then ID ASC
                            ResultSet rs = stmt.executeQuery("SELECT * FROM loyalty_points ORDER BY update_date ASC, id ASC");

                            java.text.SimpleDateFormat dbFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
                            java.text.SimpleDateFormat displayFormat = new java.text.SimpleDateFormat("dd/MM/yyyy");

                            while (rs.next()) {
                                String rawDate = rs.getString("update_date");
                                String formattedDate = "";
                                if (rawDate != null && !rawDate.isEmpty()) {
                                    java.util.Date parsedDate = dbFormat.parse(rawDate);
                                    formattedDate = displayFormat.format(parsedDate);
                                }

                                String status = rs.getString("status");
                                String rowClass = "table-warning"; // default for "old"
                                if ("latest".equalsIgnoreCase(status)) {
                                    rowClass = "table-success";
                                }
                        %>
                            <tr class="<%= rowClass %>">
                                <td><%= rs.getInt("id") %></td>
                                <td><%= rs.getInt("points") %></td>
                                <td><%= status %></td>
                                <td><%= formattedDate %></td>
                            </tr>
                        <%
                            }
                            rs.close();
                            stmt.close();
                            con.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='4'>Error: " + e.getMessage() + "</td></tr>");
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<%@include file="footer.jsp" %>
