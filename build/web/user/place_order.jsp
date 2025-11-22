<%@page import="java.sql.*"%>
<%@page import="Database.dbconfig"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Place Order</title>
</head>
<body>
<%
    HttpSession sessionUser = request.getSession();
    String uemail = (String) sessionUser.getAttribute("uemail");

    if (uemail == null || uemail.trim().isEmpty()) {
%>
    <script>
        alert("Please log in to place an order.");
        window.location.href = 'user_login.jsp';
    </script>
<%
    } else {
        Connection con = null;
        PreparedStatement psFetch = null, psOrder = null, psLoyalty = null, psClear = null;
        ResultSet rs = null;
        boolean orderPlaced = false;

        try {
            con = new dbconfig().getConnection();

            // ✅ Get parameters from bill.jsp
            int userId = Integer.parseInt(request.getParameter("userId"));
            double grandTotal = Double.parseDouble(request.getParameter("grandTotal"));
            double finalTotal = Double.parseDouble(request.getParameter("finalTotal"));
            int pointsToRedeem = Integer.parseInt(request.getParameter("pointsToRedeem"));
            int pointsToEarn = Integer.parseInt(request.getParameter("pointsToEarn"));

            // ✅ Fetch cart items
            psFetch = con.prepareStatement(
                "SELECT p.id, p.name, p.price, c.quantity " +
                "FROM cart c INNER JOIN products p ON c.product_id=p.id WHERE c.user_email=?"
            );
            psFetch.setString(1, uemail);
            rs = psFetch.executeQuery();

            // ✅ Insert each item into orders
            psOrder = con.prepareStatement(
                "INSERT INTO orders(username, product_name, quantity, total, order_date, status, cancel_reason) " +
                "VALUES (?, ?, ?, ?, NOW(), 'Pending', NULL)"
            );

            while (rs.next()) {
                orderPlaced = true;
                String pname = rs.getString("name");
                int qty = rs.getInt("quantity");
                double price = rs.getDouble("price");
                double total = price * qty;

                psOrder.setString(1, uemail);
                psOrder.setString(2, pname);
                psOrder.setInt(3, qty);
                psOrder.setDouble(4, total);
                psOrder.executeUpdate();
            }

            if (orderPlaced) {
                // ✅ Record Loyalty Points (Earned & Used)
                psLoyalty = con.prepareStatement(
                    "INSERT INTO loyalty_history (user_id, points_earned, points_used, created_at) VALUES (?, ?, ?, NOW())"
                );
                psLoyalty.setInt(1, userId);
                psLoyalty.setInt(2, pointsToEarn);
                psLoyalty.setInt(3, pointsToRedeem);
                psLoyalty.executeUpdate();

                // ✅ Clear cart after placing order
                psClear = con.prepareStatement("DELETE FROM cart WHERE user_email=?");
                psClear.setString(1, uemail);
                psClear.executeUpdate();

                // ✅ Reset session redeem points
                sessionUser.removeAttribute("redeemPoints");

%>
                <script>
                    alert("Order placed successfully! Loyalty points updated.");
                    window.location.href = 'index.jsp';
                </script>
<%
            } else {
%>
                <script>
                    alert("No items in your cart to place an order.");
                    window.location.href = 'cart.jsp';
                </script>
<%
            }

        } catch (Exception e) {
%>
            <script>
                alert("Error: <%= e.getMessage().replace("\"", "\\\"") %>");
                window.location.href = 'cart.jsp';
            </script>
<%
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (psFetch != null) try { psFetch.close(); } catch (Exception ignored) {}
            if (psOrder != null) try { psOrder.close(); } catch (Exception ignored) {}
            if (psLoyalty != null) try { psLoyalty.close(); } catch (Exception ignored) {}
            if (psClear != null) try { psClear.close(); } catch (Exception ignored) {}
            if (con != null) try { con.close(); } catch (Exception ignored) {}
        }
    }
%>
</body>
</html>
