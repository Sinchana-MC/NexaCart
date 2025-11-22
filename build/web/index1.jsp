<%
    HttpSession hs = request.getSession(false);
    if (hs == null || hs.getAttribute("ausername") == null) {
        response.sendRedirect("admin_login.jsp");
        return;
    }
%>

<%@page import="Database.dbconfig"%>
<%@page import="java.sql.*"%>
<%@page import="java.time.LocalDate"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    Connection con = null;
    Statement st = null;
    ResultSet rs = null;

    double dailySales = 0;
    double monthlySales = 0;
    double yearlySales = 0;
    int totalOrders = 0;
    double[] monthlyData = new double[12]; // for chart data

    try {
        con = new dbconfig().getConnection();
        st = con.createStatement();

        LocalDate today = LocalDate.now();
        String todayStr = today.toString();
        int currentMonth = today.getMonthValue();
        int currentYear = today.getYear();

        // Daily Sales
        rs = st.executeQuery("SELECT SUM(total) AS daily FROM orders WHERE order_date = '" + todayStr + "' AND status != 'Cancelled'");
        if (rs.next()) dailySales = rs.getDouble("daily");

        // Monthly Sales
        rs = st.executeQuery("SELECT SUM(total) AS monthly FROM orders WHERE MONTH(order_date) = " + currentMonth + " AND YEAR(order_date) = " + currentYear + " AND status != 'Cancelled'");
        if (rs.next()) monthlySales = rs.getDouble("monthly");

        // Yearly Sales
        rs = st.executeQuery("SELECT SUM(total) AS yearly FROM orders WHERE YEAR(order_date) = " + currentYear + " AND status != 'Cancelled'");
        if (rs.next()) yearlySales = rs.getDouble("yearly");

        // Total Orders
        rs = st.executeQuery("SELECT COUNT(*) AS total FROM orders");
        if (rs.next()) totalOrders = rs.getInt("total");

        // Monthly data for chart
        rs = st.executeQuery("SELECT MONTH(order_date) AS month, SUM(total) AS total FROM orders WHERE YEAR(order_date) = " + currentYear + " AND status != 'Cancelled' GROUP BY MONTH(order_date)");
        while (rs.next()) {
            int month = rs.getInt("month");
            double total = rs.getDouble("total");
            if (month >= 1 && month <= 12) {
                monthlyData[month - 1] = total;
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (st != null) st.close(); } catch (Exception ex) {}
        try { if (con != null) con.close(); } catch (Exception ex) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<title>Admin Dashboard - Real Data</title>
	<link href="css/app.css" rel="stylesheet">
	<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600&display=swap" rel="stylesheet">
</head>

<body>
	<div class="wrapper">
		<nav id="sidebar" class="sidebar js-sidebar">
			<div class="sidebar-content js-simplebar">
				<a class="sidebar-brand" href="index.html"><span class="align-middle">AdminKit</span></a>
				<ul class="sidebar-nav">
					<li class="sidebar-header">
						Pages
					</li>

					<li class="sidebar-item active">
						<a class="sidebar-link" href="index1.jsp">
              <i class="align-middle" data-feather="sliders"></i> <span class="align-middle">Dashboard</span>
            </a>
					</li>

					<li class="sidebar-item">
						<a class="sidebar-link" href="add_category.jsp">
              <i class="align-middle" data-feather="user"></i> <span class="align-middle">category</span>
            </a>
					</li>
                                        

					<li class="sidebar-item">
						
					</li>

					

					<li class="sidebar-item">
						<a class="sidebar-link" href="home_admin.jsp">
              <i class="align-middle" data-feather="book"></i> <span class="align-middle">product details</span>
            </a>
					</li>
                                        <li class="sidebar-item">
						<a class="sidebar-link" href="product_view.jsp">
              <i class="align-middle" data-feather="book"></i> <span class="align-middle">View products</span>
            </a>
					</li>
                                        <li class="sidebar-item">
						<a class="sidebar-link" href="products_add.jsp">
              <i class="align-middle" data-feather="book"></i> <span class="align-middle">Add products</span>
            </a>
					</li>
                                        <li class="sidebar-item">
						<a class="sidebar-link" href="admin_orders.jsp">
              <i class="align-middle" data-feather="book"></i> <span class="align-middle">track orders</span>
            </a>
					</li>
                                        <li class="sidebar-item">
						<a class="sidebar-link" href="add_loyalty_points.jsp">
              <i class="align-middle" data-feather="book"></i> <span class="align-middle">loyalty points</span>
            </a>
					</li>
                                        <li class="sidebar-item"><a class="sidebar-link" href="ulogout">Logout</a></li>
                                      

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

			</div>
		</nav>

		<div class="main">
			<nav class="navbar navbar-expand navbar-light navbar-bg">
				<a class="sidebar-toggle js-sidebar-toggle"><i class="hamburger align-self-center"></i></a>
			</nav>

			<main class="content">
				<div class="container-fluid p-0">
					<h1 class="h3 mb-3"><strong>Sales Analytics</strong> Dashboard</h1>

					<div class="row">
						<div class="col-sm-6 col-xl-3">
							<div class="card">
								<div class="card-body">
									<h5 class="card-title">Daily Sales</h5>
									<h1 class="mt-1 mb-3">&#8377;<%= String.format("%.2f", dailySales) %></h1>
									<span class="text-success">Updated today</span>
								</div>
							</div>
						</div>

						<div class="col-sm-6 col-xl-3">
							<div class="card">
								<div class="card-body">
									<h5 class="card-title">Monthly Sales</h5>
									<h1 class="mt-1 mb-3">&#8377;<%= String.format("%.2f", monthlySales) %></h1>
									<span class="text-muted">Current Month</span>
								</div>
							</div>
						</div>

						<div class="col-sm-6 col-xl-3">
							<div class="card">
								<div class="card-body">
									<h5 class="card-title">Yearly Sales</h5>
									<h1 class="mt-1 mb-3">&#8377;<%= String.format("%.2f", yearlySales) %></h1>
									<span class="text-success">Year <%= LocalDate.now().getYear() %></span>
								</div>
							</div>
						</div>

						<div class="col-sm-6 col-xl-3">
							<div class="card">
								<div class="card-body">
									<h5 class="card-title">Total Orders</h5>
									<h1 class="mt-1 mb-3"><%= totalOrders %></h1>
									<span class="text-muted">Total Records in DB</span>
								</div>
							</div>
						</div>
					</div>

					<div class="row">
						<div class="col-xl-12">
							<div class="card flex-fill w-100">
								<div class="card-header">
									<h5 class="card-title mb-0">Sales Overview (Monthly)</h5>
								</div>
								<div class="card-body py-3">
									<div class="chart chart-sm">
										<canvas id="chartjs-dashboard-line"></canvas>
									</div>
								</div>
							</div>
						</div>
					</div>

				</div>
			</main>

			<footer class="footer">
				<div class="container-fluid">
					<div class="row text-muted">
						<div class="col-6 text-start">
							<p class="mb-0"><strong>AdminKit</strong> &copy;</p>
						</div>
						<div class="col-6 text-end">
							<ul class="list-inline">
								<li class="list-inline-item"><a class="text-muted" href="#">Support</a></li>
								<li class="list-inline-item"><a class="text-muted" href="#">Help Center</a></li>
								<li class="list-inline-item"><a class="text-muted" href="#">Privacy</a></li>
								<li class="list-inline-item"><a class="text-muted" href="#">Terms</a></li>
							</ul>
						</div>
					</div>
				</div>
			</footer>
		</div>
	</div>

	<script src="js/app.js"></script>
	<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

	<script>
		document.addEventListener("DOMContentLoaded", function() {
			var ctx = document.getElementById("chartjs-dashboard-line").getContext("2d");
			var gradient = ctx.createLinearGradient(0, 0, 0, 225);
			gradient.addColorStop(0, "rgba(215, 227, 244, 1)");
			gradient.addColorStop(1, "rgba(215, 227, 244, 0)");

			new Chart(ctx, {
				type: "line",
				data: {
					labels: ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],
					datasets: [{
						label: "Sales (₹)",
						fill: true,
						backgroundColor: gradient,
						borderColor: "#007bff",
						data: [<%= monthlyData[0] %>, <%= monthlyData[1] %>, <%= monthlyData[2] %>, <%= monthlyData[3] %>, <%= monthlyData[4] %>, <%= monthlyData[5] %>, <%= monthlyData[6] %>, <%= monthlyData[7] %>, <%= monthlyData[8] %>, <%= monthlyData[9] %>, <%= monthlyData[10] %>, <%= monthlyData[11] %>]
					}]
				},
				options: {
					maintainAspectRatio: false,
					plugins: {
						legend: { display: true },
						tooltip: {
							callbacks: {
								label: function(context) {
									return '₹' + context.parsed.y.toLocaleString();
								}
							}
						}
					},
					scales: {
						y: {
							beginAtZero: true,
							ticks: {
								callback: function(value) {
									return '₹' + value;
								}
							}
						}
					}
				}
			});
		});
	</script>
</body>
</html>
