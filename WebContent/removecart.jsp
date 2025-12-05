<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp" %>
<%@ include file="cartPersistence.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>

<%
String id = request.getParameter("id");

// Remove from session cart
if (id != null) {
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
    
    if (productList != null) {
        productList.remove(id);
        session.setAttribute("productList", productList);
        
        // Save to database if user is logged in
        String userName = (String) session.getAttribute("authenticatedUser");
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
                    
                    // Save cart to database
                    saveCartToDatabase(con, customerId, productList);
                    
                    // Optional: Add session message
                    session.setAttribute("cartMessage", "Item removed and cart saved to database!");
                }
                
                userRs.close();
                userStmt.close();
                closeConnection();
            } catch (Exception e) {
                System.err.println("Error saving cart after removal: " + e.getMessage());
                session.setAttribute("cartMessage", "Error saving cart to database: " + e.getMessage());
            }
        }
    }
}

response.sendRedirect("showcart.jsp");
%>