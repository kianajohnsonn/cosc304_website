<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
        <title>Nadeen and Kiana Grocery Main Page</title>

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
	font-size: 2.2rem;
	letter-spacing: 1px;
  }

  h2 {
	text-align: center;
	margin-top: 40px;
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
  .small-btn {
    background: #e2f1f7;
    color: #0c6fb8;
    padding: 4px 10px;     /* smaller */
    border-radius: 6px;    /* small rounded corners */
    font-size: 0.9rem;     /* smaller text */
    border: 1px solid #0c6fb8;
    text-decoration: none;
    transition: 0.2s ease;
}

.small-btn:hover {
    background: #0c6fb8;
    color: white;
}

</style>
</head>
<body>
<h1 align="center">Welcome to Cafe Nadiana</h1>

<h2 align="center"><a href="login.jsp">Login</a></h2>

<h2 align="center"><a href="listprod.jsp">Begin Shopping</a></h2>

<h2 align="center"><a href="listorder.jsp">List All Orders</a></h2>

<h2 align="center"><a href="login.jsp?returnUrl=customer.jsp">Customer Info</a></h2>

<h2 align="center"><a href="login.jsp?returnUrl=admin.jsp">Administrators</a></h2>

<h2 align="center"><a href="logout.jsp">Log out</a></h2>


<%
	String userName = (String) session.getAttribute("authenticatedUser");
	if (userName != null)
		out.println("<h3 align=\"center\">Signed in as: "+userName+"</h3>");
%>

<%
PreparedStatement ps = null;
ResultSet rs = null;

try {
    // Get a connection from jdbc.jsp (sets the 'con' field declared in jdbc.jsp)
    getConnection();

    // Build DB-specific SQL depending on whether we're using MySQL or SQL Server
    String sql;
    if (url != null && url.toLowerCase().contains("mysql")) {
        // MySQL version (uses LIMIT)
        sql =
            "SELECT p.productId, p.productName, SUM(op.quantity) AS totalSold " +
            "FROM orderproduct op " +
            "JOIN product p ON op.productId = p.productId " +
            "GROUP BY p.productId, p.productName " +
            "ORDER BY totalSold DESC " +
            "LIMIT 5";
    } else {
        // SQL Server version (uses TOP 5, no LIMIT)
        sql =
            "SELECT TOP 5 p.productId, p.productName, SUM(op.quantity) AS totalSold " +
            "FROM orderproduct op " +
            "JOIN product p ON op.productId = p.productId " +
            "GROUP BY p.productId, p.productName " +
            "ORDER BY totalSold DESC";
    }

    ps = con.prepareStatement(sql);
    rs = ps.executeQuery();
%>

<h2 align="center">Top 5 Best-Selling Products</h2>
<table align="center" class="product-table" border="1" cellpadding="4" cellspacing="6">
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
    closeConnection();  // Use the helper method from jdbc.jsp
}
%>
</table>


</body>
</html>



