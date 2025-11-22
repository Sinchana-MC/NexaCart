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
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@include file="aheader.jsp" %>


<main class="content">
	<div class="container-fluid p-0">
		<h1 class="h3 mb-3"><strong>Analytics</strong> Dashboard</h1>

		<div class="card">
			<div class="card-body">
				<form action="productsservlet" method="POST" enctype="multipart/form-data">

					<div class="row">
						<div class="col-md-6 mb-3">
							<label class="form-label">Name</label>
							<input class="form-control form-control-lg" type="text" name="name" placeholder="Enter your name" />
						</div>
						<div class="col-md-6 mb-3">
							<label class="form-label">Caption</label>
							<input class="form-control form-control-lg" type="text" name="caption" placeholder="Enter Caption" />
						</div>
					</div>

					<div class="row">
						<div class="col-md-6 mb-3">
							<label class="form-label">Quantity</label>
							<input class="form-control form-control-lg" type="number" name="quantity" placeholder="Enter quantity" />
						</div>
						<div class="col-md-6 mb-3">
							<label class="form-label">Price</label>
							<input class="form-control form-control-lg" type="number" name="price" placeholder="Enter price" />
						</div>
					</div>

					<div class="row">
						<div class="col-md-6 mb-3">
							<label class="form-label">Category</label>
							<select class="form-control form-control-lg" name="cat_id" required>
								<%
									try {
										Connection con = new dbconfig().getConnection();
										Statement stmt = con.createStatement();
										ResultSet rs = stmt.executeQuery("SELECT * FROM cat");
										while (rs.next()) {
								%>
									<option value="<%= rs.getInt("id") %>"><%= rs.getString("name") %></option>
								<%
										}
										con.close();
									} catch (Exception e) {
										out.print("Error fetching categories: " + e);
									}
								%>
							</select>
						</div>

						<div class="col-md-6 mb-3">
							<label class="form-label">Product Image</label>
							<input class="form-control form-control-lg" type="file" name="image" accept="image/*" required />
						</div>
					</div>

					<div class="row">
						<div class="col-md-12 mb-3">
							<label class="form-label">Description</label>
							<textarea class="form-control form-control-lg" name="description" rows="5" placeholder="Write a detailed description (10-15 sentences)..." required></textarea>
						</div>
					</div>

					<div class="text-center mt-3">
						<button type="submit" class="btn btn-lg btn-primary">OK</button>
					</div>

				</form>
			</div>
		</div>
	</div>
</main>

<%@include file="footer.jsp" %>
