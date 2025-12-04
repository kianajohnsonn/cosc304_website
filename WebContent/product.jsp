<%@ page import="java.util.HashMap" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="jdbc.jsp" %>

<html>
<head>
<title>Product Information</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
<style>
body {
font-family: Arial, Helvetica, sans-serif;
margin: 0;
padding: 0;
background: #FFE4E1; /* light pink */
color: #1f3d2b; /* dark green text */
}
h1 {
text-align: center;
margin-top: 20px;
color: #1f3d2b;
font-size: 2rem;
letter-spacing: 1px;
}
/* Product container */
.product-box {
width: 90%;
background: #FFF7F9; /* soft pink card */
margin: 30px auto;
padding: 25px 35px;
border-radius: 14px;
box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}

.product-box h2 {
margin-top: 0;
font-size: 1.8rem;
color: #1f3d2b;
text-align: center;
}
.product-box p {
font-size: 1.1rem;
line-height: 1.5;
}
/* Center the product image */
.product-box img {
display: block;
margin: 20px auto;
max-width: 500px;
border-radius: 8px;
box-shadow: 0 1px 4px rgba(0,0,0,0.15);
}
/* Quantity selector */
.quantity-selector {
margin: 20px 0;
text-align: center;
}
.quantity-selector label {
font-weight: bold;
margin-right: 10px;
color: #1f3d2b;
}
.quantity-selector select {
padding: 8px 12px;
border-radius: 6px;
border: 1px solid #ccc;
font-size: 1rem;
background: white;
}
.price-display {

text-align: center;
margin: 15px 0;
font-size: 1.3rem;
font-weight: bold;
color: #1f3d2b;
}
.unit-price {
color: #666;
font-size: 1rem;
font-weight: normal;
}
/* Styled action buttons */
.btn-primary,
.btn-secondary {
text-decoration: none;
padding: 12px 24px;
border-radius: 50px;
font-size: 1.1rem;
transition: 0.25s ease;
display: inline-block;
margin: 8px 4px;
cursor: pointer;
}
/* Light blue button */
.btn-primary {
background: #e2f1f7;
color: #0c6fb8;
border: 1px solid #0c6fb8;
}
.btn-primary:hover {
background: #0c6fb8;
color: white;
}
/* Neutral soft pink button */
.btn-secondary {
background: #FDEDEF;
color: #1f3d2b;

border: 1px solid #FBC4D8;
}
.btn-secondary:hover {
background: #FBC4D8;
color: white;
}
</style>
<script>
function updatePrice() {
const quantity =
parseInt(document.getElementById('quantity').value);
const unitPrice =
parseFloat(document.getElementById('unitPrice').value);
const totalPrice = quantity * unitPrice;
document.getElementById('totalPrice').textContent =
formatCurrency(totalPrice);
document.getElementById('addToCartBtn').href =
'addcart.jsp?id=' +

document.getElementById('productId').value +
'&name=' +

encodeURIComponent(document.getElementById('productName').value) +

'&price=' + unitPrice +
'&quantity=' + quantity;

}
function formatCurrency(amount) {
return '$' +
amount.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
}
// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
updatePrice();
});
</script>
</head>
<body>

<%@ include file="header.jsp"%>
<h1>Product Details</h1>
<%
String productId = request.getParameter("id");
if (productId == null || productId.isEmpty()) {
out.println("<p>No product ID provided.</p>");
} else {
int id = Integer.parseInt(productId);
String sql = "SELECT productName, productDesc, productPrice, productImageURL FROM product WHERE productId = ?";
NumberFormat currFormat =
NumberFormat.getCurrencyInstance();
try (Connection con = DriverManager.getConnection(url,
uid, pw);

PreparedStatement pstmt =
con.prepareStatement(sql)) {
pstmt.setInt(1, id);
ResultSet rs = pstmt.executeQuery();
if (rs.next()) {
String name = rs.getString("productName");
String desc = rs.getString("productDesc");
double price = rs.getDouble("productPrice");
String imageURL =
rs.getString("productImageURL");

out.println("<div class='product-box'>");
out.println("<h2>" + name + "</h2>");
out.println("<p><strong>Description:</strong> "

+ desc + "</p>");

out.println("<p class='unit-price'><strong>Price per bag:</strong> " + currFormat.format(price) + "</p>");

// Hidden fields for JavaScript
out.println("<input type='hidden' id='productId' value='" + id + "'>");

out.println("<input type='hidden' id='productName' value='" + name + "'>");

out.println("<input type='hidden' id='unitPrice' value='" + price + "'>");

// Quantity selector - placeholder kept for readability
// Insert a blank line in the generated HTML for spacing
out.println();
out.println("<div class='quantity-selector'>");
out.println("<label for='quantity'>Quantity:</label>");

out.println("<select id='quantity' name='quantity' onchange='updatePrice()'>");
for (int i = 1; i <= 10; i++) {
out.println("<option value='" + i + "'>" + i

+ " bag" + (i > 1 ? "s" : "") + "</option>");

}
out.println("</select>");
out.println("</div>");
// Dynamic price display
out.println("<div class='price-display'>");
out.println("<strong>Total: </strong><span id='totalPrice'>" + currFormat.format(price) + "</span>");

out.println("</div>");
if (imageURL != null && !imageURL.isEmpty()) {
  out.println("<img src='" + imageURL + "'alt='" + name + "' style='max-width:600px;'/>");

} else {
out.println("<p>No image available.</p>");
}
out.println("<p><a id='addToCartBtn' href='addcart.jsp?id=" + id + "&name=" + URLEncoder.encode(name) + "&price=" + price + "&quantity=1' class='btn btn-primary'>Add to Cart</a></p>");
out.println("<p><a href='listprod.jsp' class='btn btn-secondary'>Continue Shopping</a></p>");

out.println("</div>");
} else {
out.println("<p>Product not found.</p>");
}

rs.close();
} catch (Exception e) {
out.println("<p>Error retrieving product: " +
e.getClass().getName() + " - " + e.getMessage() + "</p>");

e.printStackTrace(); // goes to server logs
}
}
%>
</body>
</html>