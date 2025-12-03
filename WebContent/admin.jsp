<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="auth.jsp" %>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html>
<head>
<title>Administrator Page</title>
    <style>
      body {
        font-family: Arial, Helvetica, sans-serif;
        margin: 0;
        padding: 20px;
        background: #FFE4E1;
        color: #1f3d2b;
      }
      h1 {
        text-align: center;
        margin-bottom: 30px;
      }
      table {
        border-collapse: collapse;
        margin: 0 auto;
        width: 60%;
        background: #FFF7F9;
      }
      th, td {
        border: 1px solid #ccc;
        padding: 10px 14px;
        text-align: center;
      }
      th {
        background: #1f3d2b;
        color: #FFE4E1;
      }
      tr:nth-child(even) {
        background: #FFEFF2;
      }
    </style>
</head>
<body>
<h1>Administrator Report</h1>


<%
String user = (String) session.getAttribute("authenticatedUser");
if (user == null) {
    String loginMessage = "You must be logged in to access the admin page.";
	out.println("<p><a href='login.jsp'>Go to Login Page</a></p>");
}

String sql = "SELECT YEAR(orderDate) AS year, "
            + "MONTH(orderDate) AS month,  "
            + "DAY(orderDate) AS day, "
            + "SUM(totalAmount) AS totalSales "
        + "FROM ordersummary "
        + "GROUP BY YEAR(orderDate), MONTH(orderDate), DAY(orderDate) "
        + "ORDER BY year, month, day";

NumberFormat currFormat = NumberFormat.getCurrencyInstance();

try {
    getConnection();
    PreparedStatement ps = con.prepareStatement(sql);
    ResultSet rs = ps.executeQuery();
        out.println("<h2>Daily Total Sales</h2>");
        out.println("<table>");
        out.println("<tr><th>Order Date</th><th>Total Sales</th></tr>");
   
    while (rs.next()) {
        int year = rs.getInt("year");
        int month = rs.getInt("month");
        int day = rs.getInt("day");
        double totalSales = rs.getDouble("totalSales");
        String orderDay = String.format("%04d-%02d-%02d", year, month, day);

        out.println("<tr>");
        out.println("<td>" + orderDay + "</td>");
        out.println("<td>" + currFormat.format(totalSales) + "</td>");
        out.println("</tr>");
    }
    out.println("</table>");

    rs.close();
    ps.close();

} catch (SQLException e) {
    out.println("<p>Error retrieving data: " + e.getMessage() + "</p>");
} finally {
    closeConnection();
}

%>

</body>
</html>

