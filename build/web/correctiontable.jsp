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
<%@page import="Database.dbconfig"%>
<%@page import="java.sql.*"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="UTF-8">
	<title>Edit Category</title>
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
	<%@include file="aheader.jsp" %>
</head>

<body>
<main class="content">
	<div class="container mt-5">
		<div class="row justify-content-center">
			<div class="col-md-6">
				<div class="card shadow-lg">
					<div class="card-body">
						<h3 class="card-title text-center mb-4">Edit Category</h3>

						<%
							String id = request.getParameter("id");
							String name = "";

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
						%>

						<form method="post" action="updatecategory.jsp">
							<input type="hidden" name="id" value="<%= id %>">
							<div class="mb-3">
								<label for="name" class="form-label">Category Name</label>
								<input type="text" name="name" class="form-control" id="name" value="<%= name %>" required>
							</div>
							<button type="submit" class="btn btn-primary w-100">Update Category</button>
						</form>

					</div>
				</div>
			</div>
		</div>
	</div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<%@include file="footer.jsp" %>
</body>

</html>

