<%
     HttpSession hs=request.getSession();
     String uemail=null;
     String upass=null;
     try
     {
         uemail=hs.getAttribute("uemail").toString();
         upass=hs.getAttribute("upass").toString();
         if(uemail==null || upass==null ||uemail=="" || upass=="")
         {
             //out.println("<meta http-equiv = \"refresh\" content = \"0;ulogout\" />");
         }
     }
     catch(Exception e)
     {
        // out.println("<meta http-equiv = \"refresh\" content = \"0;ulogout\" />");
     }
         
    %>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<meta name="description" content="Responsive Admin &amp; Dashboard Template based on Bootstrap 5">
	<meta name="author" content="AdminKit">
	<meta name="keywords" content="adminkit, bootstrap, bootstrap 5, admin, dashboard, template, responsive, css, sass, html, theme, front-end, ui kit, web">

	<link rel="preconnect" href="https://fonts.gstatic.com">
	<link rel="shortcut icon" href="img/icons/icon-48x48.png" />

	<link rel="canonical" href="https://demo-basic.adminkit.io/" />

	<title>AdminKit Demo - Bootstrap 5 Admin Template</title>

	<link href="../css/app.css" rel="stylesheet">
	<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600&display=swap" rel="stylesheet">
</head>

<body>
	<div class="wrapper">
		<nav id="sidebar" class="sidebar js-sidebar">
			<div class="sidebar-content js-simplebar">
				<a class="sidebar-brand" href="index.html">
          <span class="align-middle">AdminKit</span>
        </a>

				<ul class="sidebar-nav">
					<li class="sidebar-header">
						Pages
					</li>

					<li class="sidebar-item active">
						<a class="sidebar-link" href="index.jsp">
              <i class="align-middle" data-feather="sliders"></i> <span class="align-middle">Home</span>
            </a>
					</li>



					<li class="sidebar-item">
						<a class="sidebar-link" href="viewcart.jsp">
              <i class="align-middle" data-feather="book"></i> <span class="align-middle">Cart</span>
            </a>
					</li>
                                        <li class="sidebar-item">
						<a class="sidebar-link" href="my_orders.jsp">
              <i class="align-middle" data-feather="book"></i> <span class="align-middle">My Orders</span>
            </a>
					</li>
                                        <li class="sidebar-item">
						
					</li>
                                        <li class="sidebar-item">
						<a class="sidebar-link" href="track_order_user.jsp">
              <i class="align-middle" data-feather="book"></i> <span class="align-middle">track orders</span>
            </a>
					</li>
                                                    <% 
        if(uemail==null || upass==null ||uemail=="" || upass=="")
         { %>
                                                    <li class="sidebar-item">
						<a class="sidebar-link" href="user_login.jsp">
              <i class="align-middle" data-feather="log-in"></i> <span class="align-middle">Sign In</span>
            </a>
					</li>

					<li class="sidebar-item">
						
					</li><% }
        else{%> 
         <li class="sidebar-item">
						<a class="sidebar-link" href="../uulogout">
              <i class="align-middle" data-feather="book"></i> <span class="align-middle">Logout</span>
            </a>
					</li>
         
         <% } %>
                                        <li class="sidebar-item">
						
					</li>

					<li class="sidebar-header">
						
					</li>

					<li 
					</li>

					<li 
					</li>

					<li 
					</li>

					<li 
					</li>

					<li
					</li>

					<li class="sidebar-header">
						
					</li>

					<li 
					</li>

					<li 
					</li>
				</ul>

				<div class="sidebar-cta">
					<div class="sidebar-cta-content">
						<strong class="d-inline-block mb-2"></strong>
						<div class="mb-3 text-sm">
							
						</div>
						<div class="d-grid">
							
						</div>
					</div>
				</div>
			</div>
		</nav>

		<div class="main">
			<nav class="navbar navbar-expand navbar-light navbar-bg">
				<a class="sidebar-toggle js-sidebar-toggle">
                                    <i class="hamburger align-self-center"></i>
                                  </a>

				<div class="navbar-collapse collapse">
					<ul class="navbar-nav navbar-align">
                                            
                                            
                                            
                                                
                                                
                                                
                                                
						
				</div>
			</nav>