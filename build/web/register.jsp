
<%@include file="aheader.jsp" %>

<main class="content">
	<div class="container-fluid p-0">
		<h1 class="h3 mb-3"><strong>Analytics</strong> Dashboard</h1>

                    <div class="card">
			<div class="card-body">
				<form action="u_register" method="POST">
					<div class="row">
						<div class="col-md-6 mb-3">
							<label class="form-label">Name</label>
							<input class="form-control form-control-lg" type="text" name="name" placeholder="Enter your name" />
						</div>
						<div class="col-md-6 mb-3">
							<label class="form-label">Phone Number</label>
							<input class="form-control form-control-lg" type="number" name="phonenumber" placeholder="Enter your phone number" />
						</div>
					</div>
					<div class="row">
						<div class="col-md-6 mb-3">
							<label class="form-label">EmailID</label>
							<input class="form-control form-control-lg" type="email" name="emailid" placeholder="Enter your emailid" />
						</div>
						<div class="col-md-6 mb-3">
							<label class="form-label">Password</label>
							<input class="form-control form-control-lg" type="password" name="password" placeholder="Enter password" />
						</div>
                                            <center>
                                            <div class="col-md-6 mb-3">
							<label class="form-label">Confrm Password</label>
							<input class="form-control form-control-lg" type="password" name="password" placeholder="Enter confrmpassword" />
						</div>
                                            </center>
					</div>
					<div class="text-center mt-3">
						<button type="submit" class="btn btn-lg btn-primary">Sign in</button>
						<!-- <button type="submit" class="btn btn-lg btn-primary">Sign up</button> -->
					</div>
				</form>
			</div>
                    </div>
        </div>
</main>
<script src="js/app.js"></script>

<%@include file="footer.jsp" %>