<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>

<%
// Get product details from request
String id = request.getParameter("id");
String name = request.getParameter("name");
String price = request.getParameter("price");
String qty = request.getParameter("quantity");

// Default quantity to 1 if not specified
if (qty == null)
	qty = "1";

// Add item to shopping cart
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

if (productList == null)
{	// No cart, create one
	productList = new HashMap<String, ArrayList<Object>>();
}

// Check if product already exists in cart
ArrayList<Object> product = productList.get(id);
if (product != null)
{	// Product exists, update quantity
	product.set(3, ((Integer)product.get(3)) + Integer.parseInt(qty));
}
else
{	// New product, add to cart
	product = new ArrayList<Object>();
	product.add(id); // id
	product.add(name); // name
	double pr = Double.parseDouble(price);
	product.add(pr); // price
	product.add(Integer.parseInt(qty)); // quantity
	productList.put(id,product);
}

session.setAttribute("productList", productList);

// Save cart to database if user is logged in
String userName = (String) session.getAttribute("authenticatedUser");
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
            
            // Save cart to database
            saveCartToDatabase(con, customerId, productList);
        }
        
        userRs.close();
        userStmt.close();
        con.close();
    } catch (Exception e) {
        // Log error but don't break cart functionality
        System.err.println("Error saving cart to database: " + e.getMessage());
    }
}

// Redirect to showcart.jsp
response.sendRedirect("showcart.jsp");
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