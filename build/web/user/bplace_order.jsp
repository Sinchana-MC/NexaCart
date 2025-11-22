<%-- 
    Document   : place_order
    Created on : 23 Jul, 2025, 12:39:28 PM
    Author     : veda1
--%>

<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Place Order</title>
</head>
<body>
<%
    String uemail = (String) session.getAttribute("uemail");

    if (uemail == null || uemail.isEmpty()) {
%>
        <script>alert("Please log in to place an order."); window.location.href = 'login.jsp';</script>
<%
    } else {
        Connection con = null;
        PreparedStatement ps = null, ps2 = null;
        ResultSet rs = null;
        boolean orderPlaced = false;

        try {
            Class.forName("com.mysql.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/e_commerce", "root", "");

            // ✅ Check Buy Now session
            String buyNowId = (String) session.getAttribute("buyNowId");
            String buyNowQty = (String) session.getAttribute("buyNowQty");
            String buyNowPrice = (String) session.getAttribute("buyNowPrice");

            if(buyNowId != null && buyNowQty != null && buyNowPrice != null){
                // ✅ Place single Buy Now order
                ps = con.prepareStatement("SELECT name FROM products WHERE id=?");
                ps.setString(1, buyNowId);
                rs = ps.executeQuery();
                if(rs.next()){
                    String pname = rs.getString("name");
                    int qty = Integer.parseInt(buyNowQty);
                    double price = Double.parseDouble(buyNowPrice);
                    double total = price * qty;

                    ps2 = con.prepareStatement(
                        "INSERT INTO orders(username, product_name, quantity, total, order_date, status, cancel_reason) " +
                        "VALUES (?, ?, ?, ?, NOW(), 'Pending', NULL)"
                    );
                    ps2.setString(1, uemail);
                    ps2.setString(2, pname);
                    ps2.setInt(3, qty);
                    ps2.setDouble(4, total);
                    ps2.executeUpdate();
                    orderPlaced = true;
                }

                // ✅ Clear Buy Now session
                session.removeAttribute("buyNowId");
                session.removeAttribute("buyNowQty");
                session.removeAttribute("buyNowPrice");

            } else {
                // ✅ Cart checkout logic
                ps = con.prepareStatement(
                    "SELECT p.id, p.name, p.price, c.quantity " +
                    "FROM cart c INNER JOIN products p ON c.product_id=p.id " +
                    "WHERE c.user_email=?"
                );
                ps.setString(1, uemail);
                rs = ps.executeQuery();

                // ✅ Insert into orders (cancel_reason default NULL)
                String sql = "INSERT INTO orders(username, product_name, quantity, total, order_date, status, cancel_reason) VALUES (?, ?, ?, ?, NOW(), 'Pending', NULL)";
                ps2 = con.prepareStatement(sql);

                while(rs.next()){
                    orderPlaced = true;
                    String pname = rs.getString("name");
                    int qty = rs.getInt("quantity");
                    double price = rs.getDouble("price");
                    double total = price * qty;

                    ps2.setString(1, uemail);
                    ps2.setString(2, pname);
                    ps2.setInt(3, qty);
                    ps2.setDouble(4, total);
                    ps2.executeUpdate();
                }

                if(orderPlaced){
                    // ✅ Clear cart after placing order
                    PreparedStatement clearCart = con.prepareStatement("DELETE FROM cart WHERE user_email=?");
                    clearCart.setString(1, uemail);
                    clearCart.executeUpdate();
                    clearCart.close();
                }
            }

            if(orderPlaced){
%>
                <script>alert("Order Placed Successfully!"); window.location.href = 'index.jsp';</script>
<%
            } else {
%>
                <script>alert("No items to place an order."); window.location.href = 'index.jsp';</script>
<%
            }
        } catch (Exception e) {
%>
            <script>alert("Error: <%= e.getMessage().replace("\"", "\\\"") %>"); window.location.href = 'index.jsp';</script>
<%
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (ps != null) try { ps.close(); } catch (Exception ignored) {}
            if (ps2 != null) try { ps2.close(); } catch (Exception ignored) {}
            if (con != null) try { con.close(); } catch (Exception ignored) {}
        }
    }
%>
</body>
</html>
