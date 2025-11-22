
<%@include file="aheader.jsp" %>
<main class="d-flex w-100">
    <div class="container d-flex flex-column">
        <div class="row vh-100">
            <div class="col-sm-10 col-md-8 col-lg-6 mx-auto d-table h-100">
                <div class="d-table-cell align-middle">

                    <div class="text-center mt-4">
                        <h1 class="h2">Create Your Account</h1>
                        <p class="lead">
                            Fill in the details below to register
                        </p>
                    </div>

                    <div class="card">
                        <div class="card-body">
                            <div class="m-sm-4">
                                
                                <form action="../uregister" method="post">
                                    
                                    <div class="mb-3">
                                        <label class="form-label">Name</label>
                                        <input class="form-control form-control-lg" type="text" name="name" placeholder="Enter name" required />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Email ID</label>
                                        <input class="form-control form-control-lg" type="email" name="emailid" placeholder="Enter Email ID" required />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Phone Number</label>
                                        <input class="form-control form-control-lg" type="number" name="phonenumber" placeholder="Enter phone number" required />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Password</label>
                                        <input class="form-control form-control-lg" type="password" name="password" placeholder="Enter password" required />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Confirm Password</label>
                                        <input class="form-control form-control-lg" type="password" name="confrmpassword" placeholder="Enter confirm password" required />
                                    </div>

                                    <div class="text-center mt-3">
                                        <button type="submit" class="btn btn-lg btn-primary">Register</button>
                                    </div>

                                </form>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</main>
<script src="../js/app.js"></script>
<%@include file="footer.jsp" %>

