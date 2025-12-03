<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
// Get the current list of products
HashMap<String, ArrayList<Object>> productList = 
    (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

if (productList != null) {
    // Iterate through all products in the cart
    for (String productId : productList.keySet()) {
        String qtyParam = "quantity_" + productId;
        String newQtyStr = request.getParameter(qtyParam);
        
        if (newQtyStr != null && !newQtyStr.trim().isEmpty()) {
            try {
                int newQty = Integer.parseInt(newQtyStr);
                if (newQty > 0) {
                    // Update the quantity
                    ArrayList<Object> product = productList.get(productId);
                    product.set(3, newQty);
                } else if (newQty == 0) {
                    // Remove product if quantity is 0
                    productList.remove(productId);
                }
            } catch (NumberFormatException e) {
                // Ignore invalid quantity values
            }
        }
    }
    
    // Update the session
    session.setAttribute("productList", productList);
}

// Redirect back to shopping cart
response.sendRedirect("showcart.jsp");
%>