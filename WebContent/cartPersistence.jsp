<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%-- REMOVED: <%@ include file="jdbc.jsp" %> --%>

<%!
// Save cart to database using incart table
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

// Load cart from database
public HashMap<String, ArrayList<Object>> loadCartFromDatabase(Connection con, int customerId) throws SQLException {
    HashMap<String, ArrayList<Object>> cart = new HashMap<>();
    
    String sql = "SELECT ic.productId, ic.quantity, ic.price, p.productName, p.productImageURL " +
                 "FROM incart ic " +
                 "JOIN product p ON ic.productId = p.productId " +
                 "WHERE ic.orderId = ? " +
                 "ORDER BY ic.productId";
    
    PreparedStatement pstmt = con.prepareStatement(sql);
    pstmt.setInt(1, -customerId);
    ResultSet rs = pstmt.executeQuery();
    
    while (rs.next()) {
        String productId = Integer.toString(rs.getInt("productId"));
        String productName = rs.getString("productName");
        double productPrice = rs.getDouble("price");
        int quantity = rs.getInt("quantity");
        String productImageURL = rs.getString("productImageURL");
        
        ArrayList<Object> item = new ArrayList<>();
        item.add(productId);
        item.add(productName);
        item.add(productPrice);
        item.add(quantity);
        item.add(productImageURL);
        
        cart.put(productId, item);
    }
    
    rs.close();
    pstmt.close();
    
    return cart;
}

// Get cart count from database
public int getCartCountFromDatabase(Connection con, int customerId) throws SQLException {
    String sql = "SELECT COUNT(*) as cartCount FROM incart WHERE orderId = ?";
    PreparedStatement pstmt = con.prepareStatement(sql);
    pstmt.setInt(1, -customerId);
    ResultSet rs = pstmt.executeQuery();
    
    int count = 0;
    if (rs.next()) {
        count = rs.getInt("cartCount");
    }
    
    rs.close();
    pstmt.close();
    return count;
}
%>