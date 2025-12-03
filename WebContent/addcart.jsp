<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
// Fetch product ID from request
String idStr = request.getParameter("id");
String name = request.getParameter("name");
String priceStr = request.getParameter("price");
String quantityStr = request.getParameter("quantity");
if (idStr == null || name == null || priceStr == null) {
out.println("<h3>Error: Invalid product data!</h3>");
return;
}
int id = Integer.parseInt(idStr);
double price = 0.0;
int quantity = 1; // Default quantity
try {
price = Double.parseDouble(priceStr);
} catch (NumberFormatException e) {

out.println("<h3>Error: Invalid price for product!</h3>");
return;
}
// Get quantity from parameter if provided
if (quantityStr != null && !quantityStr.trim().isEmpty()) {

try {
quantity = Integer.parseInt(quantityStr);
if (quantity < 1) quantity = 1;
} catch (NumberFormatException e) {
// Use default quantity if invalid
quantity = 1;
}
}
// Get existing cart or create new
@SuppressWarnings("unchecked")
HashMap<String, ArrayList<Object>> productList =
(HashMap<String, ArrayList<Object>>)

session.getAttribute("productList");
if (productList == null) {
productList = new HashMap<>();
}
// Add or update product
if (productList.containsKey(idStr)) {
// Update quantity - add the new quantity to existing quantity

ArrayList<Object> prod = productList.get(idStr);
int curQty = (Integer) prod.get(3);
prod.set(3, curQty + quantity);
} else {
// Add new product with specified quantity
ArrayList<Object> prod = new ArrayList<>();
prod.add(id); // product ID
prod.add(name); // product name
prod.add(price); // product price
prod.add(quantity); // quantity from selector
productList.put(idStr, prod);

}
// Save cart back to session
session.setAttribute("productList", productList);
// Redirect to showcart.jsp
response.sendRedirect("showcart.jsp");
%>