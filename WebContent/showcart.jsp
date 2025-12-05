<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>

<!DOCTYPE html>
<html>
<head>
<title>Your Shopping Cart</title>
<style>
    body {
        font-family: Arial, Helvetica, sans-serif;
        background: #FFE4E1;   /* soft pink */
        margin: 0;
        padding: 0;
        color: #1f3d2b;        /* dark green */
    }

    h1 {
        text-align: center;
        margin-top: 30px;
        margin-bottom: 20px;
        font-size: 2rem;
        color: #1f3d2b;
    }

    /* Cart loaded message */
    .cart-loaded-msg {
        text-align: center;
        background: #d4edda;
        color: #155724;
        padding: 10px;
        margin: 10px auto;
        width: 80%;
        border-radius: 5px;
        border: 1px solid #c3e6cb;
    }

    /* Empty cart message */
    .empty-cart {
        text-align: center;
        margin-top: 100px;
        padding: 20px;
    }

    .empty-cart h1 {
        color: #1f3d2b;
    }

    /* CART TABLE */
    .cart-table {
        width: 85%;
        margin: 20px auto;
        border-collapse: collapse;
        background: #FFF7F9; /* light pink panel */
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    }

    .cart-table th {
        background: #1f3d2b;     /* dark green */
        color: #FFE4E1;          /* light pink */
        padding: 14px;
        font-weight: 500;
    }

    .cart-table td {
        padding: 14px;
        border-bottom: 1px solid #f3dfe4;
    }

    .cart-table tr:nth-child(even) {
        background: #FFEFF2; /* alternating light pink */
    }

    .cart-table tr:nth-child(odd) {
        background: #FFF7F9;
    }

    .cart-table tr:hover {
        background: #E2F1F7; /* soft blue highlight */
    }

    .total-row {
        background: #f9d9e2 !important;
        font-size: 1.1rem;
    }

    /* INPUTS */
    .quantity-input {
        width: 60px;
        padding: 6px;
        border-radius: 6px;
        border: 1px solid #ccc;
        text-align: center;
        font-size: 0.9rem;
    }

    /* BUTTONS */
    .update-btn,
    .continue-btn,
    .checkout-btn,
    .remove-btn {
        display: inline-block;
        padding: 10px 20px;
        margin: 10px 5px;
        text-decoration: none;
        border-radius: 50px;
        font-size: 1rem;
        transition: 0.25s ease;
        border: 1px solid #0c6fb8;
        background: #e2f1f7;
        color: #0c6fb8;
    }

    .update-btn:hover,
    .continue-btn:hover,
    .checkout-btn:hover,
    .remove-btn:hover {
        background: #0c6fb8;
        color: white;
    }

    /* Remove button special style */
    .remove-btn {
        background: #FFD5DD;
        border: 1px solid #d16d7f;
        color: #a83a4c;
        padding: 6px 12px;
        font-size: 0.9rem;
    }

    .remove-btn:hover {
        background: #d16d7f;
        color: white;
    }

    /* Checkout button stands out */
    .checkout-btn {
        background: #1f3d2b;
        border-color: #1f3d2b;
        color: #FFE4E1;
    }

    .checkout-btn:hover {
        background: #14281e;
        color: white;
    }

</style>
</head>
<body>

<%@ include file="header.jsp" %>

<%
// Load cart from database if user is logged in
String userName = (String) session.getAttribute("authenticatedUser");
boolean cartLoadedFromDB = false;

if (userName != null) {
    try {
        // Create local database connection
        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        String uid = "sa";
        String pw = "304#sa#pw";
        
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection con = DriverManager.getConnection(url, uid, pw);
        
        // Get customer ID
        String userSql = "SELECT customerId FROM customer WHERE userid = ?";
        PreparedStatement userStmt = con.prepareStatement(userSql);
        userStmt.setString(1, userName);
        ResultSet userRs = userStmt.executeQuery();
        
        if (userRs.next()) {
            int customerId = userRs.getInt("customerId");
            
            // Load cart from database
            HashMap<String, ArrayList<Object>> dbCart = loadCartFromDatabase(con, customerId);
            
            if (!dbCart.isEmpty()) {
                // Replace session cart with database cart
                session.setAttribute("productList", dbCart);
                cartLoadedFromDB = true;
            }
        }
        
        userRs.close();
        userStmt.close();
        con.close();
    } catch (Exception e) {
        // Log error but don't break cart functionality
        System.err.println("Error loading cart from database: " + e.getMessage());
    }
}

// Get the current list of products
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

if (productList == null || productList.isEmpty())
{	
    out.println("<div class='empty-cart'>");
    out.println("<H1>Your shopping cart is empty!</H1>");
    out.println("<p><a href='listprod.jsp' class='continue-btn'>Continue Shopping</a></p>");
    out.println("</div>");
    productList = new HashMap<String, ArrayList<Object>>();
}
else
{
    // Show cart loaded message if applicable
    if (cartLoadedFromDB && userName != null) {
        out.println("<div class='cart-loaded-msg'>");
        out.println("✓ Your saved cart has been loaded from the database!");
        out.println("</div>");
    }
    
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();

    out.println("<h1>Your Shopping Cart</h1>");
    out.println("<form method='post' action='updatecart.jsp'>");
    out.print("<table class='cart-table'><tr><th>Product Id</th><th>Product Name</th><th>Quantity</th>");
    out.println("<th>Price</th><th>Subtotal</th><th>Action</th></tr>");

    double total = 0;
    Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
    while (iterator.hasNext()) 
    {	
        Map.Entry<String, ArrayList<Object>> entry = iterator.next();
        ArrayList<Object> product = (ArrayList<Object>) entry.getValue();
        if (product.size() < 4)
        {
            out.println("Expected product with four entries. Got: "+product);
            continue;
        }
        
        out.print("<tr><td>"+product.get(0)+"</td>");
        out.print("<td>"+product.get(1)+"</td>");

        out.print("<td align=\"center\">");
        out.print("<input type='number' class='quantity-input' name='quantity_"+entry.getKey()+"' value='"+product.get(3)+"' min='1'>");
        out.print("</td>");
        
        Object price = product.get(2);
        Object itemqty = product.get(3);
        double pr = 0;
        int qty = 0;
        
        try
        {
            pr = Double.parseDouble(price.toString());
        }
        catch (Exception e)
        {
            out.println("Invalid price for product: "+product.get(0)+" price: "+price);
        }
        try
        {
            qty = Integer.parseInt(itemqty.toString());
        }
        catch (Exception e)
        {
            out.println("Invalid quantity for product: "+product.get(0)+" quantity: "+qty);
        }        

        out.print("<td align=\"right\">"+currFormat.format(pr)+"</td>");
        out.print("<td align=\"right\">"+currFormat.format(pr*qty)+"</td>");
        out.print("<td><a href='removecart.jsp?id="+entry.getKey()+"' class='remove-btn'>Remove</a></td></tr>");
        total = total + pr*qty;
    }
    out.println("<tr class='total-row'><td colspan=\"4\" align=\"right\"><b>Order Total</b></td>"
            +"<td align=\"right\">"+currFormat.format(total)+"</td><td></td></tr>");
    out.println("</table>");

    out.println("<br>");
    out.println("<input type='submit' value='Update Cart' class='update-btn'>");
    out.println("<a href=\"listprod.jsp\" class='continue-btn'>Continue Shopping</a>");
    out.println("<a href=\"checkout.jsp\" class='checkout-btn'>Check Out</a>");
    
    // Add save cart note for logged in users
    if (userName != null) {
        out.println("<br><br><div style='text-align:center;font-size:0.9rem;color:#666;'>");
        out.println("✓ Your cart is automatically saved to the database.");
        out.println("</div>");
    } else {
        out.println("<br><br><div style='text-align:center;font-size:0.9rem;color:#666;'>");
        out.println("<a href='login.jsp' style='color:#0c6fb8;'>Log in</a> to save your cart between sessions.");
        out.println("</div>");
    }
    
    out.println("</form>");
}
%>

</body>
</html>

<%!
// Cart persistence methods (copied locally to avoid include issues)
public HashMap<String, ArrayList<Object>> loadCartFromDatabase(Connection con, int customerId) throws SQLException {
    HashMap<String, ArrayList<Object>> cart = new HashMap<>();
    
    String sql = "SELECT ic.productId, ic.quantity, ic.price, p.productName, p.productImageURL " +
                 "FROM incart ic " +
                 "JOIN product p ON ic.productId = p.productId " +
                 "WHERE ic.orderId = ? " +
                 "ORDER BY ic.productId";
    
    PreparedStatement pstmt = con.prepareStatement(sql);
    pstmt.setInt(1, -customerId);
    ResultSet rs = pstmt.executeQuery();
    
    while (rs.next()) {
        String productId = Integer.toString(rs.getInt("productId"));
        String productName = rs.getString("productName");
        double productPrice = rs.getDouble("price");
        int quantity = rs.getInt("quantity");
        String productImageURL = rs.getString("productImageURL");
        
        ArrayList<Object> item = new ArrayList<>();
        item.add(productId);
        item.add(productName);
        item.add(productPrice);
        item.add(quantity);
        item.add(productImageURL);
        
        cart.put(productId, item);
    }
    
    rs.close();
    pstmt.close();
    
    return cart;
}
%>