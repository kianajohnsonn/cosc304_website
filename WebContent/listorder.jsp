<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ page import="java.math.BigDecimal" %>

<!DOCTYPE html>
<html>
<head>
<title>Order List</title>
<style>
    body {
        font-family: Arial, Helvetica, sans-serif;
        margin: 0;
        padding: 20px;
        background: #e6f3fa; /* soft light blue */
        color: #1f3d2b;     /* dark green text */
    }

    h1, h2 {
        text-align: center;
        color: #1f3d2b;
        margin-top: 20px;
        margin-bottom: 30px;
        letter-spacing: 0.5px;
    }

    /* Main outer order table */
    table {
        width: 90%;
        margin: 25px auto;
        border-collapse: collapse;
        background: #e6d8de;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 4px 10px rgba(0,0,0,0.08);
    }

    table th {
        background: #9eb7d3;   /* dark green */
        color: #244f7e;        /* light blue text */
        padding: 12px;
        font-size: 1rem;
        text-align: left;
    }

    table td {
        padding: 12px;
        border-bottom: 1px solid #d9e7ef;
    }

    /* Nested product table */
    table table {
        width: 100%;
        margin-top: 10px;
        border-radius: 8px;
        box-shadow: none;
        background: #fdf7fa; /* very light pink */
    }

    table table th {
        background: #a8b9a1;    /* soft pink */
        color: #1f3d2b;
        border-bottom: 1px solid #f6cce0;
    }

    table table td {
        border-bottom: 1px solid #f6cce0;
    }



    .page-wrap {
        max-width: 1100px;
        margin: 0 auto;
    }

</style>


</head>
<body>

<%@ include file="header.jsp" %>

<h1>Order List</h1>

<%
//Note: Forces loading of SQL Server driver
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}

// Useful code for formatting currency values:
// NumberFormat currFormat = NumberFormat.getCurrencyInstance();
// out.printlncurrFormat.format(5.0);  // Prints $5.00

String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid =  "sa";
String pwd = "304#sa#pw";

NumberFormat money = NumberFormat.getCurrencyInstance();

// Write query to retrieve all order summary records


try(Connection con = DriverManager.getConnection(url, uid, pwd)) {
	String sqlOrder = "SELECT o.orderId, o.orderDate, c.customerId, c.firstName, c.lastName, o.totalAmount "
		+ "FROM ordersummary o JOIN customer c ON o.customerId = c.customerId "
		+ "ORDER BY o.OrderId";

	String sqlProducts = "SELECT op.productId, p.productName, op.quantity, op.price "
			+ "FROM orderproduct op JOIN product p ON op.productId = p.productId "
			+ "WHERE op.orderId = ?";

	try(PreparedStatement ps = con.prepareStatement(sqlProducts);
		Statement s = con.createStatement();
		ResultSet rs = s.executeQuery(sqlOrder)) {

		while (rs.next()){

			out.println("<table border='1' cellspacing='0' cellpadding='4'>");
			out.println("<tr>"
			+ "<th>Order Id</th>"
			+ "<th>Order Date</th>"
			+ "<th>Customer Id</th>"
			+ "<th>Customer Name</th>"
			+ "<th>Total Amount</th>"
			+ "</tr>");

			int orderId = rs.getInt("orderId");
			Timestamp orderDate = rs.getTimestamp("orderDate");
			int customerId = rs.getInt("customerId");
			String customerName = rs.getString("firstName") + " " + rs.getString("lastName");
			BigDecimal totalAmount = rs.getBigDecimal("totalAmount");
			
			out.println("<tr>");
			out.println("<td>" + orderId + "</td>");
			out.println("<td>" + orderDate + "</td>");
			out.println("<td>" + customerId + "</td>");
			out.println("<td>" + customerName + "</td>");
			out.println("<td>" + money.format(totalAmount) + "</td>");
			out.println("</tr>");

			ps.setInt(1, orderId);
			try(ResultSet products = ps.executeQuery()){
				out.println("<tr><td colspan='5'>");
				out.println("<table border='1' cellspacing='0' cellpadding='3'>");
				out.println("<tr>"
					+ "<th>Product Id</th>"
					+ "<th>Product Name</th>"
					+ "<th>Quantity</th>"
					+ "<th>Price</th>"
					+ "</tr>");
				
				while(products.next()){
					int productId = products.getInt("productId");
					String productName = products.getString("productName");
					int quantity = products.getInt("quantity");
					BigDecimal price = products.getBigDecimal("price");
				
					out.println("<tr>"
						+ "<td>" + productId + "</td>"
						+ "<td>" + productName + "</td>"
						+ "<td>" + quantity + "</td>"
						+ "<td>" + money.format(price) + "</td>"
						+ "</tr>");
				}

			    out.println("</table>");
        		out.println("</td></tr>");
			}
		}
		out.println("</table>");
	}
		
	} catch(SQLException e){
		out.println("SQLException: " + e);
	}



%>

</body>
</html>


