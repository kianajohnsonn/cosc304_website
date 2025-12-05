<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>
<%@ include file="auth.jsp" %>
<!DOCTYPE html>
<html>
<head>
<title>Order Confirmation</title>
<style>
    body {
        font-family: Arial, Helvetica, sans-serif;
        background: #FFE4E1; 
        margin: 0;
        padding: 0;
    }

    .confirmation-container {
        width: 80%;
        max-width: 800px;
        margin: 60px auto;
        padding: 40px;
        background: #FFF7F9; 
        border-radius: 16px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        text-align: center;
        border-left: 8px solid #1f3d2b;
    }

    .success-icon {
        font-size: 4rem;
        color: #1f3d2b;
        margin-bottom: 20px;
    }

    h1 {
        font-size: 2rem;
        margin-bottom: 20px;
        color: #1f3d2b;
    }

    .order-details {
        text-align: left;
        margin: 30px 0;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 10px;
    }

    .detail-row {
        display: flex;
        justify-content: space-between;
        margin: 10px 0;
        padding: 8px 0;
        border-bottom: 1px solid #eee;
    }

    .total-row {
        font-weight: bold;
        font-size: 1.1rem;
        margin-top: 15px;
        padding-top: 15px;
        border-top: 2px solid #1f3d2b;
    }

    .btn {
        padding: 12px 30px;
        font-size: 1rem;
        border-radius: 50px;
        border: none;
        cursor: pointer;
        transition: 0.25s ease;
        margin: 15px;
        text-decoration: none;
        display: inline-block;
    }

    .btn-primary {
        background: #0c6fb8;
        color: white;
    }

    .btn-primary:hover {
        background: #084a7d;
    }

    .btn-secondary {
        background: #e2f1f7;
        color: #0c6fb8;
        border: 1px solid #0c6fb8;
    }

    .btn-secondary:hover {
        background: #0c6fb8;
        color: white;
    }

    .shipment-info {
        background: #e2f1f7;
        padding: 15px;
        border-radius: 8px;
        margin: 20px 0;
        text-align: left;
    }

    .shipment-item {
        margin: 10px 0;
        padding: 10px;
        border: 1px solid #b7e3f7;
        border-radius: 6px;
        background: white;
    }
</style>
</head>
<body>

<%@ include file="header.jsp" %>

<%
    String orderId = request.getParameter("orderId");
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();
    
    if (orderId == null) {
        response.sendRedirect("listprod.jsp");
        return;
    }
    
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        con = DriverManager.getConnection(url, uid, pw);
        
        // Get order details
        String orderSql = "SELECT os.*, c.firstName, c.lastName, c.email, sa.* " +
                         "FROM ordersummary os " +
                         "JOIN customer c ON os.customerId = c.customerId " +
                         "JOIN ShippingAddress sa ON os.shippingAddressId = sa.addressId " +
                         "WHERE os.orderId = ?";
        pstmt = con.prepareStatement(orderSql);
        pstmt.setInt(1, Integer.parseInt(orderId));
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            double totalAmount = rs.getDouble("totalAmount");
            double taxAmount = rs.getDouble("taxAmount");
            double shippingCost = rs.getDouble("shippingCost");
            double subtotal = totalAmount - taxAmount - shippingCost;
            String orderDate = rs.getTimestamp("orderDate").toString();
            String address = rs.getString("addressLine1");
            String city = rs.getString("city");
            String state = rs.getString("state");
            String postalCode = rs.getString("postalCode");
            String fullName = rs.getString("firstName") + " " + rs.getString("lastName");
%>

<div class="confirmation-container">
    <div class="success-icon">✓</div>
    <h1>Order Confirmed!</h1>
    <p style="font-size: 1.2rem; color: #666; margin-bottom: 30px;">
        Thank you for your order. Your order number is <strong>#<%= orderId %></strong>
    </p>
    
    <div class="order-details">
        <h3>Order Summary</h3>
        <div class="detail-row">
            <span>Order Date:</span>
            <span><%= orderDate %></span>
        </div>
        <div class="detail-row">
            <span>Order Number:</span>
            <span>#<%= orderId %></span>
        </div>
        <div class="detail-row">
            <span>Customer:</span>
            <span><%= fullName %></span>
        </div>
        
        <div class="detail-row">
            <span>Subtotal:</span>
            <span><%= currFormat.format(subtotal) %></span>
        </div>
        <div class="detail-row">
            <span>Tax:</span>
            <span><%= currFormat.format(taxAmount) %></span>
        </div>
        <div class="detail-row">
            <span>Shipping:</span>
            <span><%= currFormat.format(shippingCost) %></span>
        </div>
        <div class="detail-row total-row">
            <span>Total Amount:</span>
            <span><%= currFormat.format(totalAmount) %></span>
        </div>
    </div>
    
    <div class="shipment-info">
        <h3>Shipping Information</h3>
        <p><strong>Shipping to:</strong> <%= fullName %></p>
        <p><%= address %><br>
           <%= city %>, <%= state %> <%= postalCode %></p>
        <p><strong>Estimated Delivery:</strong> 3-5 business days</p>
    </div>
    
    <div style="margin-top: 30px;">
        <a href="listprod.jsp" class="btn btn-primary">Continue Shopping</a>
        <a href="listorder.jsp" class="btn btn-secondary">View My Orders</a>
    </div>
    
    <p style="margin-top: 30px; font-size: 0.9rem; color: #666;">
        A confirmation email has been sent to your registered email address.<br>
        You will receive tracking information once your order ships.
    </p>
</div>

<%
        } else {
            out.println("<div class='confirmation-container'><h1>Order not found</h1></div>");
        }
        
    } catch (SQLException e) {
        out.println("<div class='confirmation-container'><h1>Error retrieving order</h1><p>" + e.getMessage() + "</p></div>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>

</body>
</html>