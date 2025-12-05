<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Nadeen and Kiana Main Page</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: Arial, Helvetica, sans-serif;
            margin: 0;
            padding: 0;
            background: #FFE4E1; 
            color: #1f3d2b; 
        }

        h1 {
            text-align: center;
            padding: 30px 0;
            margin: 0;
            background: #1f3d2b; 
            color: #FFE4E1;
            font-size: 3.2rem;
            letter-spacing: 1px;
            font-weight: bold;
        }

        h2 {
            text-align: center;
            margin-top: 30px;
            margin-bottom: 20px;
            color: #1f3d2b;
        }

        a {
            text-decoration: none;
            color: #0c6fb8; 
            background: #e2f1f7;
            padding: 12px 24px;
            border-radius: 50px;    
            font-size: 1.4rem;
            transition: 0.25s ease;
            border: 1px solid #0c6fb8;
        }

        a:hover {
            background: #0c6fb8;
            color: white;
        }

        .small-btn {
            background: #e2f1f7;
            color: #0c6fb8;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.9rem;
            border: 1px solid #0c6fb8;
            text-decoration: none;
            transition: 0.2s ease;
        }

        .small-btn:hover {
            background: #0c6fb8;
            color: white;
        }

        /* Original table styling kept */
        table {
            border-spacing: 0;
            border-collapse: collapse;
            margin: 20px auto;
        }

        th, td {
            padding: 12px;
            border: 1px solid #ccc;
        }

        th {
            background: #1f3d2b;
            color: #FFE4E1;
            text-align: left;
        }

        tr:nth-child(even) {
            background: #FFEFF2;
        }

        /* Recommendation Section - Using your original colors */
        .recommendations-section {
            margin: 40px auto;
            padding: 25px;
            background: #FFF7F9; /* Your soft pink from product page */
            border-radius: 12px;
            max-width: 1200px;
            border-left: 5px solid #1f3d2b; /* Your dark green */
        }

        .recommendations-title {
            color: #1f3d2b; /* Your dark green */
            font-size: 1.8rem;
            margin-bottom: 25px;
            text-align: center;
            padding-bottom: 10px;
            border-bottom: 2px solid #FBC4D8; /* Your pink border */
        }

        .recommendations-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
            justify-items: center;
        }

        .recommendation-card {
            width: 100%;
            max-width: 200px;
            background: #FFF7F9; /* Your soft pink */
            border-radius: 10px;
            padding: 15px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08); /* Your shadow from product page */
            transition: transform 0.2s;
            border: 1px solid #FBC4D8; /* Your pink border */
        }

        .recommendation-card:hover {
            transform: translateY(-4px);
            background: #FFEFF2; /* Your lighter pink on hover */
            box-shadow: 0 6px 16px rgba(0,0,0,0.15); /* Your hover shadow */
        }

        .recommendation-image {
            width: 100%;
            height: 140px;
            object-fit: cover;
            border-radius: 6px;
            margin-bottom: 10px;
        }

        .recommendation-name {
            font-size: 0.95rem;
            font-weight: bold;
            color: #1f3d2b; /* Your dark green */
            margin-bottom: 5px;
            height: 40px;
            overflow: hidden;
        }

        .recommendation-price {
            color: #0c6fb8; /* Your blue */
            font-weight: bold;
            font-size: 1rem;
            margin: 5px 0;
        }

        .welcome-message {
            text-align: center;
            font-size: 1.2rem;
            color: #1f3d2b;
            margin: 20px 0;
            padding: 10px;
            background: #e2f1f7; /* Your light blue */
            border-radius: 8px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
            border: 1px solid #0c6fb8; /* Your blue border */
        }

        .links-container {
            text-align: center;
            margin: 30px 0;
        }

        .links-container a {
            margin: 0 10px;
            display: inline-block;
        }
    </style>
</head>
<body>
<h1 align="center">Welcome to Cafe Nadiana</h1>

<div class="links-container">
    <a href="login.jsp">Login</a>
    <a href="listprod.jsp">Begin Shopping</a>
    <a href="listorder.jsp">List All Orders</a>
    <a href="login.jsp?returnUrl=customer.jsp">Customer Info</a>
    <a href="login.jsp?returnUrl=admin.jsp">Administrators</a>
    <a href="logout.jsp">Log out</a>
</div>

<%
    String userName = (String) session.getAttribute("authenticatedUser");
    if (userName != null)
        out.println("<div class='welcome-message'>Signed in as: "+userName+"</div>");
%>

<!-- Original Best-Selling Products Table (Kept as you had it) -->
<%
    PreparedStatement ps = null;
    ResultSet rs = null;
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();

    try {
        getConnection();
        String sql;
        if (url != null && url.toLowerCase().contains("mysql")) {
            sql = "SELECT p.productId, p.productName, SUM(op.quantity) AS totalSold " +
                  "FROM orderproduct op " +
                  "JOIN product p ON op.productId = p.productId " +
                  "GROUP BY p.productId, p.productName " +
                  "ORDER BY totalSold DESC " +
                  "LIMIT 5";
        } else {
            sql = "SELECT TOP 5 p.productId, p.productName, SUM(op.quantity) AS totalSold " +
                  "FROM orderproduct op " +
                  "JOIN product p ON op.productId = p.productId " +
                  "GROUP BY p.productId, p.productName " +
                  "ORDER BY totalSold DESC";
        }

        ps = con.prepareStatement(sql);
        rs = ps.executeQuery();
%>

<h2 align="center">Top 5 Best-Selling Products</h2>
<table align="center" border="1" cellpadding="4" cellspacing="6">
    <tr>
        <th>Product Name</th>
        <th>Total Sold</th>
    </tr>
<%
    boolean hasRows = false;
    while (rs.next()) {
        hasRows = true;
%>
    <tr>
        <td>
            <a class="small-btn" href="product.jsp?id=<%= rs.getInt("productId") %>">
                <%= rs.getString("productName") %>
            </a>
        </td>
        <td><%= rs.getInt("totalSold") %></td>
    </tr>
<%
    }
    if (!hasRows) {
%>
    <tr>
        <td colspan="2" align="center">No sales yet.</td>
    </tr>
<%
    }
} catch (Exception e) {
    out.println("<p style='text-align:center;color:red;'>Error loading best sellers: " + e.getMessage() + "</p>");
} finally {
    try { if (rs != null) rs.close(); } catch (SQLException e) {}
    try { if (ps != null) ps.close(); } catch (SQLException e) {}
    closeConnection();
}
%>
</table>

<!-- Personalized Recommendations Section (NEW FEATURE) -->
<%
    // Get personalized recommendations for homepage
    List<Map<String, Object>> homepageRecs = new ArrayList<>();
    
    if (userName != null) {
        try {
            getConnection();
            
            // Get customer ID
            String userSql = "SELECT customerId FROM customer WHERE userid = ?";
            PreparedStatement userStmt = con.prepareStatement(userSql);
            userStmt.setString(1, userName);
            ResultSet userRs = userStmt.executeQuery();
            
            if (userRs.next()) {
                int customerId = userRs.getInt("customerId");
                
                // Get recommendations based on purchase history
                String recSql = "SELECT TOP 6 p.productId, p.productName, p.productPrice, p.productImageURL, " +
                               "'Based on your purchases' as reason " +
                               "FROM product p " +
                               "WHERE p.categoryId IN ( " +
                               "    SELECT DISTINCT p2.categoryId " +
                               "    FROM ordersummary os " +
                               "    JOIN orderproduct op ON os.orderId = op.orderId " +
                               "    JOIN product p2 ON op.productId = p2.productId " +
                               "    WHERE os.customerId = ? " +
                               ") " +
                               "AND p.productId NOT IN ( " +
                               "    SELECT op2.productId " +
                               "    FROM ordersummary os2 " +
                               "    JOIN orderproduct op2 ON os2.orderId = op2.orderId " +
                               "    WHERE os2.customerId = ? " +
                               ") " +
                               "ORDER BY NEWID()";
                
                PreparedStatement recStmt = con.prepareStatement(recSql);
                recStmt.setInt(1, customerId);
                recStmt.setInt(2, customerId);
                ResultSet recRs = recStmt.executeQuery();
                
                while (recRs.next()) {
                    Map<String, Object> rec = new HashMap<>();
                    rec.put("productId", recRs.getInt("productId"));
                    rec.put("productName", recRs.getString("productName"));
                    rec.put("productPrice", recRs.getDouble("productPrice"));
                    rec.put("productImageURL", recRs.getString("productImageURL"));
                    rec.put("reason", recRs.getString("reason"));
                    homepageRecs.add(rec);
                }
                
                recRs.close();
                recStmt.close();
            }
            
            userRs.close();
            userStmt.close();
        } catch (Exception e) {
            // Silently fail - recommendations are optional
        } finally {
            closeConnection();
        }
    }
    
    // If no personalized recommendations, show general popular products
    if (homepageRecs.isEmpty()) {
        try {
            getConnection();
            String popularSql = "SELECT TOP 6 p.productId, p.productName, p.productPrice, p.productImageURL, " +
                               "'Popular choice' as reason " +
                               "FROM product p " +
                               "WHERE p.productId IN ( " +
                               "    SELECT TOP 6 op.productId " +
                               "    FROM orderproduct op " +
                               "    GROUP BY op.productId " +
                               "    ORDER BY SUM(op.quantity) DESC " +
                               ") " +
                               "ORDER BY NEWID()";
            
            PreparedStatement popularStmt = con.prepareStatement(popularSql);
            ResultSet popularRs = popularStmt.executeQuery();
            
            while (popularRs.next()) {
                Map<String, Object> rec = new HashMap<>();
                rec.put("productId", popularRs.getInt("productId"));
                rec.put("productName", popularRs.getString("productName"));
                rec.put("productPrice", popularRs.getDouble("productPrice"));
                rec.put("productImageURL", popularRs.getString("productImageURL"));
                rec.put("reason", popularRs.getString("reason"));
                homepageRecs.add(rec);
            }
            
            popularRs.close();
            popularStmt.close();
        } catch (Exception e) {
            // Silently fail
        } finally {
            closeConnection();
        }
    }
    
    // Display personalized recommendations if available
    if (!homepageRecs.isEmpty()) {
%>
<div class="recommendations-section">
    <%
        if (userName != null) {
            out.println("<h2 class='recommendations-title'>Personalized Recommendations for " + userName + "</h2>");
        } else {
            out.println("<h2 class='recommendations-title'>Featured Products You Might Like</h2>");
        }
    %>
    <div class="recommendations-grid">
    <%
        for (Map<String, Object> rec : homepageRecs) {
            int recId = (int) rec.get("productId");
            String recName = (String) rec.get("productName");
            double recPrice = (double) rec.get("productPrice");
            String recImage = (String) rec.get("productImageURL");
            String recReason = (String) rec.get("reason");
            
            // Set default image if none
            if (recImage == null || recImage.isEmpty()) {
                recImage = "img/wholebeans.jpg";
            }
    %>
        <div class="recommendation-card">
            <a href="product.jsp?id=<%= recId %>" style="text-decoration:none; color:inherit; display:block;">
                <img src="<%= recImage %>" alt="<%= recName %>" class="recommendation-image">
                <div class="recommendation-name"><%= recName %></div>
                <div class="recommendation-price"><%= currFormat.format(recPrice) %></div>
                <% if (recReason != null && userName != null) { %>
                    <div style="font-size:0.8rem; color:#666; margin-top:5px; font-style:italic;">
                        <%= recReason %>
                    </div>
                <% } %>
            </a>
        </div>
    <%
        }
    %>
    </div>
    <% if (userName == null) { %>
        <div style="text-align:center; margin-top:20px; font-size:0.9rem; color:#666;">
            <a href="login.jsp" style="color:#0c6fb8; text-decoration:underline;">Log in</a> for personalized recommendations based on your purchase history!
        </div>
    <% } %>
</div>
<%
    }
%>

</body>
</html>