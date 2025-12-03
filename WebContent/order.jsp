<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>YOUR NAME Grocery Order Processing</title>
  <style>
    /* Page background + typography (site theme) */
    body {
      font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
      background-color: peachpuff;
      color: #05472A;              /* forest green */
      margin: 40px;
    }

    h1, h2, h3 {
      color: #05472A;
      text-align: center;
    }

    /* Messages */
    .error-message, .success-message {
      max-width: 760px;
      margin: 20px auto;
      padding: 16px 20px;
      border: 2px solid purple;
      border-radius: 12px;
      box-shadow: 0 3px 8px rgba(0,0,0,.12);
      text-align: center;
    }
    .error-message {
      background-color: #F9C0C4;  /* blush pink */
      color: #003153;
    }
    .success-message {
      background-color: #FFF4CC;  /* vanilla cream */
      color: #05472A;
    }

    /* Order table */
    .order-table {
      border-collapse: collapse;
      width: 100%;
      max-width: 1000px;
      margin: 25px auto;
      background-color: #FFF8DC;  /* cornsilk butter */
      color: #05472A;
    }
    .order-table th, .order-table td {
      border: 2px solid purple;
      padding: 10px 12px;
      text-align: left;
    }
    .order-table th {
      background-color: #FFF1B5;  /* buttermilk */
      color: #003153;
      font-weight: 700;
    }
    .order-table td:nth-child(3),      /* Quantity */
    .order-table td:nth-child(4) {     /* Price/Subtotal */
      text-align: right;
      font-weight: 600;
      color: #1B2A41;                  /* navy for contrast */
    }

    /* Total line */
    .total-wrap {
      max-width: 1000px;
      margin: 10px auto 30px auto;
      text-align: right;
    }
    .total-wrap h3 {
      display: inline-block;
      background: #FFF4CC;
      border: 2px solid purple;
      border-radius: 10px;
      padding: 10px 16px;
      margin: 0;
      color: #003153;
    }

    /* Small action links */
    .actions {
      text-align: center;
      margin-top: 20px;
    }
    .btn {
      display: inline-block;
      padding: 8px 14px;
      border-radius: 8px;
      text-decoration: none;
      border: 2px solid #004953;
      background-color: #01796F; /* pine green */
      color: #fff;
      margin: 6px;
    }
    .btn:hover { background-color: #026e65; }

    .btn-secondary {
      background-color: #F9C0C4; /* blush */
      border-color: purple;
      color: #003153;
    }
    .btn-secondary:hover {
      background-color: #FFF1B5; /* butter hover */
      color: #05472A;
    }
  </style>
</head>
<body>

<%@ include file="header.jsp" %>

<%
String custIdStr = request.getParameter("customerId");
String password = request.getParameter("password");

@SuppressWarnings("unchecked")
HashMap<String, ArrayList<Object>> cart = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

NumberFormat currFormat = NumberFormat.getCurrencyInstance();

if (custIdStr == null || custIdStr.trim().isEmpty()) {
    out.println("<div class='error-message'><h3>Error: Customer ID not provided!</h3></div>");
} else if (password == null || password.trim().isEmpty()) {
    out.println("<div class='error-message'><h3>Error: Password not provided!</h3></div>");
} else if (cart == null || cart.isEmpty()) {
    out.println("<div class='error-message'><h3>Error: Your shopping cart is empty!</h3></div>");
} else {
    int custId = -1;
    try {
        custId = Integer.parseInt(custIdStr);
    } catch (NumberFormatException nfe) {
        out.println("<div class='error-message'><h3>Error: Customer ID must be a number!</h3></div>");
    }

    if (custId != -1) {
        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        String uid = "sa";
        String pw = "304#sa#pw";

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            try (Connection con = DriverManager.getConnection(url, uid, pw)) {

                // Validate customer exists AND password
                PreparedStatement custStmt = con.prepareStatement("SELECT * FROM customer WHERE customerId = ? AND password = ?");
                custStmt.setInt(1, custId);
                custStmt.setString(2, password);
                ResultSet crs = custStmt.executeQuery();

                if (!crs.next()) {
                    out.println("<div class='error-message'><h3>Error: Invalid Customer ID or Password!</h3></div>");
                } else {
                    // Insert into ordersummary
                    PreparedStatement orderStmt = con.prepareStatement(
                        "INSERT INTO ordersummary (customerId, totalAmount, orderDate) VALUES (?, 0, GETDATE())",
                        Statement.RETURN_GENERATED_KEYS
                    );
                    orderStmt.setInt(1, custId);
                    orderStmt.executeUpdate();

                    ResultSet keys = orderStmt.getGeneratedKeys();
                    keys.next();
                    int orderId = keys.getInt(1);

                    double totalAmount = 0;

                    // Insert each item into orderproduct
                    for (Map.Entry<String, ArrayList<Object>> entry : cart.entrySet()) {
                        ArrayList<Object> prod = entry.getValue();
                        int prodId = (Integer) prod.get(0);
                        double productPrice = (Double) prod.get(2);
                        int qty = (Integer) prod.get(3);

                        PreparedStatement opStmt = con.prepareStatement(
                            "INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)"
                        );
                        opStmt.setInt(1, orderId);
                        opStmt.setInt(2, prodId);
                        opStmt.setInt(3, qty);
                        opStmt.setDouble(4, productPrice);
                        opStmt.executeUpdate();
                        opStmt.close();

                        totalAmount += productPrice * qty;
                    }

                    // Update totalAmount in ordersummary
                    PreparedStatement updateStmt = con.prepareStatement(
                        "UPDATE ordersummary SET totalAmount = ? WHERE orderId = ?"
                    );
                    updateStmt.setDouble(1, totalAmount);
                    updateStmt.setInt(2, orderId);
                    updateStmt.executeUpdate();
                    updateStmt.close();

                    // Display order summary
                    out.println("<div class='success-message'>");
                    out.println("<h2>Order #" + orderId + " for Customer " + custId + "</h2>");
                    out.println("</div>");
                    
                    out.println("<table class='order-table'><tr><th>Product ID</th><th>Name</th><th>Quantity</th><th>Price</th></tr>");
                    for (Map.Entry<String, ArrayList<Object>> entry : cart.entrySet()) {
                        ArrayList<Object> prod = entry.getValue();
                        int prodId = (Integer) prod.get(0);
                        String name = (String) prod.get(1);
                        double productPrice = (Double) prod.get(2);
                        int qty = (Integer) prod.get(3);

                        out.println("<tr>");
                        out.println("<td>" + prodId + "</td>");
                        out.println("<td>" + name + "</td>");
                        out.println("<td>" + qty + "</td>");
                        out.println("<td>" + currFormat.format(productPrice * qty) + "</td>");
                        out.println("</tr>");
                    }
                    out.println("</table>");
                    out.println("<h3>Total: " + currFormat.format(totalAmount) + "</h3>");
					out.println("<div class='total-wrap'><h3>Total: " + currFormat.format(totalAmount) + "</h3></div>");
					out.println("<div class='actions'>"
							+ "<a href='listprod.jsp' class='btn'>Continue Shopping</a>"
							+ "<a href='shop.html' class='btn btn-secondary'>Back to Home</a>"
							+ "</div>");


                    // Clear cart
                    session.removeAttribute("productList");
                    
                    // Close orderStmt inside the else block where it's defined
                    orderStmt.close();
                }

                crs.close();
                custStmt.close();
            }
        } catch (Exception e) {
            out.println("<div class='error-message'><p>Error: " + e.getMessage() + "</p></div>");
        }
    }
}
%>
</BODY>
</HTML>

