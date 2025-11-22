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
<%@include file="aheader.jsp" %>


<main class="content">
	<div class="container-fluid p-0">
		<h1 class="h3 mb-3"><strong>Analytics</strong> Dashboard</h1>

                    <div class="card">
			<div class="card-body">
				<form>
					<div class="row">
						<div class="col-md-2 mb-3">
							<label class="form-label">Name</label>
							<input class="form-control form-control-lg" type="text" name="name" placeholder="Enter your name" />
						</div>
						<div class="col-md-6 mb-3">
							<label class="form-label">Company</label>
							<input class="form-control form-control-lg" type="text" name="company" placeholder="Enter your company name" />
						</div>
					</div>
					<div class="row">
						<div class="col-md-6 mb-3">
							<label class="form-label">Email</label>
							<input class="form-control form-control-lg" type="email" name="email" placeholder="Enter your email" />
						</div>
						<div class="col-md-6 mb-3">
							<label class="form-label">Password</label>
							<input class="form-control form-control-lg" type="password" name="password" placeholder="Enter password" />
						</div>
					</div>
					<div class="text-center mt-3">
						<a href="index.html" class="btn btn-lg btn-primary">Sign up</a>
						<!-- <button type="submit" class="btn btn-lg btn-primary">Sign up</button> -->
					</div>
				</form>
			</div>
                    </div>
                
                
                
                
                
		<div class="card">
			<div class="card-body">
					<div class="row">
						<div class="col-12 col-lg-8 col-xxl-12 d-flex">
								<table class="table table-hover my-0">
									<thead>
										<tr>
											<th>Name</th>
											<th class="d-none d-xl-table-cell">Start Date</th>
											<th class="d-none d-xl-table-cell">End Date</th>
											<th>Status</th>
											<th class="d-none d-md-table-cell">Assignee</th>
										</tr>
									</thead>
									<tbody>
										<tr>
											<td>Project Apollo</td>
											<td class="d-none d-xl-table-cell">01/01/2021</td>
											<td class="d-none d-xl-table-cell">31/06/2021</td>
											<td><span class="badge bg-success">Done</span></td>
											<td class="d-none d-md-table-cell">Vanessa Tucker</td>
										</tr>
										<tr>
											<td>Project Fireball</td>
											<td class="d-none d-xl-table-cell">01/01/2021</td>
											<td class="d-none d-xl-table-cell">31/06/2021</td>
											<td><span class="badge bg-danger">Cancelled</span></td>
											<td class="d-none d-md-table-cell">William Harris</td>
										</tr>
										<tr>
											<td>Project Hades</td>
											<td class="d-none d-xl-table-cell">01/01/2021</td>
											<td class="d-none d-xl-table-cell">31/06/2021</td>
											<td><span class="badge bg-success">Done</span></td>
											<td class="d-none d-md-table-cell">Sharon Lessman</td>
										</tr>
										<tr>
											<td>Project Nitro</td>
											<td class="d-none d-xl-table-cell">01/01/2021</td>
											<td class="d-none d-xl-table-cell">31/06/2021</td>
											<td><span class="badge bg-warning">In progress</span></td>
											<td class="d-none d-md-table-cell">Vanessa Tucker</td>
										</tr>
										<tr>
											<td>Project Phoenix</td>
											<td class="d-none d-xl-table-cell">01/01/2021</td>
											<td class="d-none d-xl-table-cell">31/06/2021</td>
											<td><span class="badge bg-success">Done</span></td>
											<td class="d-none d-md-table-cell">William Harris</td>
										</tr>
										<tr>
											<td>Project X</td>
											<td class="d-none d-xl-table-cell">01/01/2021</td>
											<td class="d-none d-xl-table-cell">31/06/2021</td>
											<td><span class="badge bg-success">Done</span></td>
											<td class="d-none d-md-table-cell">Sharon Lessman</td>
										</tr>
										<tr>
											<td>Project Romeo</td>
											<td class="d-none d-xl-table-cell">01/01/2021</td>
											<td class="d-none d-xl-table-cell">31/06/2021</td>
											<td><span class="badge bg-success">Done</span></td>
											<td class="d-none d-md-table-cell">Christina Mason</td>
										</tr>
										<tr>
											<td>Project Wombat</td>
											<td class="d-none d-xl-table-cell">01/01/2021</td>
											<td class="d-none d-xl-table-cell">31/06/2021</td>
											<td><span class="badge bg-warning">In progress</span></td>
											<td class="d-none d-md-table-cell">William Harris</td>
										</tr>
									</tbody>
								</table>
						
					</div>
                                </div>
                        </div>
                    </div>
                
                
                
                
        </div>
</main>

<%@include file="footer.jsp" %>
