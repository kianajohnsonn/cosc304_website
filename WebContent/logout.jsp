<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
String userName = (String) session.getAttribute("authenticatedUser");

// Save cart to database before logout
if (userName != null) {
    try {
        // Create local database connection
        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        String uid = "sa";
        String pw = "304#sa#pw";
        
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection con = DriverManager.getConnection(url, uid, pw);
        
        // Get customer ID
        String userSql = "SELECT customerId FROM customer WHERE userid = ?";
        PreparedStatement userStmt = con.prepareStatement(userSql);
        userStmt.setString(1, userName);
        ResultSet userRs = userStmt.executeQuery();
        
        if (userRs.next()) {
            int customerId = userRs.getInt("customerId");
            
            @SuppressWarnings({"unchecked"})
            HashMap<String, ArrayList<Object>> cart = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
            
            if (cart != null) {
                // Save cart to database
                saveCartToDatabase(con, customerId, cart);
            }
        }
        
        userRs.close();
        userStmt.close();
        con.close();
    } catch (Exception e) {
        System.err.println("Error saving cart on logout: " + e.getMessage());
    }
}

// Clear session
session.invalidate();

// Redirect to login page
response.sendRedirect("login.jsp"); 
%>

<%!
// Cart persistence method (copied locally to avoid include issues)
public void saveCartToDatabase(Connection con, int customerId, HashMap<String, ArrayList<Object>> cart) throws SQLException {
    if (cart == null || cart.isEmpty()) {
        // Clear cart if empty
        String clearSql = "DELETE FROM incart WHERE orderId = ?";
        PreparedStatement clearStmt = con.prepareStatement(clearSql);
        clearStmt.setInt(1, -customerId); // Negative orderId for cart
        clearStmt.executeUpdate();
        clearStmt.close();
        return;
    }
    
    // First, clear existing cart for this user
    String clearSql = "DELETE FROM incart WHERE orderId = ?";
    PreparedStatement clearStmt = con.prepareStatement(clearSql);
    clearStmt.setInt(1, -customerId);
    clearStmt.executeUpdate();
    clearStmt.close();
    
    // Insert all cart items
    String insertSql = "INSERT INTO incart (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)";
    PreparedStatement insertStmt = con.prepareStatement(insertSql);
    
    for (Map.Entry<String, ArrayList<Object>> entry : cart.entrySet()) {
        String productId = entry.getKey();
        ArrayList<Object> item = entry.getValue();
        int quantity = (Integer) item.get(3);
        double price = (Double) item.get(2);
        
        insertStmt.setInt(1, -customerId);
        insertStmt.setInt(2, Integer.parseInt(productId));
        insertStmt.setInt(3, quantity);
        insertStmt.setDouble(4, price);
        insertStmt.addBatch();
    }
    
    insertStmt.executeBatch();
    insertStmt.close();
}
%>