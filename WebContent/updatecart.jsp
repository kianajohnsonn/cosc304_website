<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<%@ include file="cartPersistence.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>

<%
// Get the current list of products
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

boolean cartUpdated = false;

if (productList != null) {
    // Iterate through all products in the cart
    Enumeration<String> paramNames = request.getParameterNames();
    
    while (paramNames.hasMoreElements()) {
        String paramName = paramNames.nextElement();
        if (paramName.startsWith("quantity_")) {
            String productId = paramName.substring(9); // Remove "quantity_" prefix
            String newQtyStr = request.getParameter(paramName);
            
            if (newQtyStr != null && !newQtyStr.trim().isEmpty()) {
                try {
                    int newQty = Integer.parseInt(newQtyStr);
                    if (newQty > 0) {
                        // Update the quantity
                        ArrayList<Object> product = productList.get(productId);
                        if (product != null) {
                            product.set(3, newQty);
                            cartUpdated = true;
                        }
                    } else if (newQty <= 0) {
                        // Remove product if quantity is 0 or negative
                        productList.remove(productId);
                        cartUpdated = true;
                    }
                } catch (NumberFormatException e) {
                    // Ignore invalid quantity values
                }
            }
        }
    }
    
    // Update the session
    session.setAttribute("productList", productList);
    
    // Save to database if user is logged in AND cart was updated
    String userName = (String) session.getAttribute("authenticatedUser");
    if (userName != null && cartUpdated) {
        try {
            getConnection();
            
            // Get customer ID
            String userSql = "SELECT customerId FROM customer WHERE userid = ?";
            PreparedStatement userStmt = con.prepareStatement(userSql);
            userStmt.setString(1, userName);
            ResultSet userRs = userStmt.executeQuery();
            
            if (userRs.next()) {
                int customerId = userRs.getInt("customerId");
                
                // Save cart to database
                saveCartToDatabase(con, customerId, productList);
                
                // Optional: Add session message
                session.setAttribute("cartMessage", "Cart updated and saved to database!");
            }
            
            userRs.close();
            userStmt.close();
            closeConnection();
        } catch (Exception e) {
            System.err.println("Error saving cart after update: " + e.getMessage());
            session.setAttribute("cartMessage", "Error saving cart to database: " + e.getMessage());
        }
    }
}

// Redirect back to shopping cart
response.sendRedirect("showcart.jsp");
%>