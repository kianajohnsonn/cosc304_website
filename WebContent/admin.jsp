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
      .admin-btn {
    font-size: x-large;
    color: #1f3d2b;
    text-decoration: none;
    display: block;
    padding: 12px 20px;
    background: #FFEFF2;
    border-left: 6px solid #1f3d2b;
    border-radius: 8px;
    margin-bottom: 15px;
    transition: 0.25s ease;
}

.admin-btn:hover {
    background: #1f3d2b;
    color: #FFEFF2;
    transform: translateX(5px);
}
    </style>
</head>
<body>

<%@ include file="header.jsp" %>

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

String custSql = "SELECT * FROM customer ORDER BY userid";

String totalSql = "SELECT COUNT(orderId) AS totalOrders, "
                + "SUM(totalAmount) AS totalSales "
            + "FROM ordersummary";
 
PreparedStatement psCust = null;
ResultSet rsCust = null;

PreparedStatement psTotals = null;
ResultSet rsTotals = null;

PreparedStatement ps = null;
ResultSet rs = null;

NumberFormat currFormat = NumberFormat.getCurrencyInstance();
%>

<a href="manageproducts.jsp" class="admin-btn">Manage Products</a>
<a href="manageshipments.jsp" class="admin-btn">Manage Shipments</a>


<%

try {
    getConnection();

    // daily sales report
    ps = con.prepareStatement(sql);
    rs = ps.executeQuery();
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
    rs = null;
    ps = null;

    // total sales summary
  psTotals = con.prepareStatement(totalSql);
rsTotals = psTotals.executeQuery();

if (rsTotals.next()) {
    int orderCount = rsTotals.getInt("totalOrders");
    double grandTotalSales = rsTotals.getDouble("totalSales");

    out.println("<h2>Overall Sales Summary</h2>");
    out.println("<table>");
    out.println("<tr><th>Total Orders</th><th>Total Sales</th></tr>");
    out.println("<tr>");
    out.println("<td>" + orderCount + "</td>");
    out.println("<td>" + currFormat.format(grandTotalSales) + "</td>");
    out.println("</tr>");
    out.println("</table>");
}
rsTotals.close();
psTotals.close();


    // customer list
    out.println("<h2>Customer List</h2>");
        out.println("<table>");
        out.println("<tr>"
                  + "<th>ID</th>"
                  + "<th>Username</th>"
                  + "<th>Name</th>"
                  + "<th>Email</th>"
                  + "<th>Phone</th>"
                  + "<th>Address</th>"
                  + "<th>City</th>"
                  + "<th>State</th>"
                  + "<th>Postal Code</th>"
                  + "<th>Country</th>"
                  + "</tr>");

    psCust = con.prepareStatement(custSql);
    rsCust = psCust.executeQuery();

    while (rsCust.next()) {
        int customerId = rsCust.getInt("customerId");
        String userid = rsCust.getString("userid");
        String firstName = rsCust.getString("firstName");
        String lastName = rsCust.getString("lastName");
        String email = rsCust.getString("email");
        String phone = rsCust.getString("phonenum");
        String address = rsCust.getString("address");
        String city = rsCust.getString("city");
        String state = rsCust.getString("state");
        String postalCode = rsCust.getString("postalCode");
        String country = rsCust.getString("country");

        out.println("<tr>");
        out.println("<td>" + customerId + "</td>");
        out.println("<td>" + userid + "</td>");
        out.println("<td>" + firstName + " " + lastName + "</td>");
        out.println("<td>" + email + "</td>");
        out.println("<td>" + phone + "</td>");
        out.println("<td>" + address + "</td>");
        out.println("<td>" + city + "</td>");
        out.println("<td>" + state + "</td>");
        out.println("<td>" + postalCode + "</td>");
        out.println("<td>" + country + "</td>");
        out.println("</tr>");
    }
    out.println("</table>");

    rsCust.close();
} catch (SQLException e) {
    out.println("<p>Error retrieving data: " + e.getMessage() + "</p>");
} finally {
    try {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (rsCust != null) rsCust.close();
        if (psCust != null) psCust.close();
        if (rsTotals != null) rsTotals.close();
        if (psTotals != null) psTotals.close();
    } catch (SQLException ignore) {}
    closeConnection();
}


%>

</body>
</html>

