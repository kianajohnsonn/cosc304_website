<%@ page import="java.sql.*" %>
<%
// Track product view for recommendations
String productId = request.getParameter("id");
String userName = (String) session.getAttribute("authenticatedUser");

if (productId != null && userName != null) {
    try {
        // Get database connection from jdbc.jsp
        Connection con = null;
        String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
        String uid = "sa";
        String pw = "304#sa#pw";
        
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        con = DriverManager.getConnection(url, uid, pw);
        
        // Get customer ID
        String sql = "SELECT customerId FROM customer WHERE userid = ?";
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, userName);
        ResultSet rs = pstmt.executeQuery();
        
        if (rs.next()) {
            int customerId = rs.getInt("customerId");
            int pid = Integer.parseInt(productId);
            
            // Check if this view already exists today
            String checkSql = "SELECT interactionId FROM UserInteraction WHERE customerId = ? AND productId = ? AND interactionType = 'view' AND CONVERT(DATE, interactionDate) = CONVERT(DATE, GETDATE())";
            PreparedStatement checkStmt = con.prepareStatement(checkSql);
            checkStmt.setInt(1, customerId);
            checkStmt.setInt(2, pid);
            ResultSet checkRs = checkStmt.executeQuery();
            
            // Only insert if not viewed today (to avoid spam)
            if (!checkRs.next()) {
                String insertSql = "INSERT INTO UserInteraction (customerId, productId, interactionType) VALUES (?, ?, 'view')";
                PreparedStatement insertStmt = con.prepareStatement(insertSql);
                insertStmt.setInt(1, customerId);
                insertStmt.setInt(2, pid);
                insertStmt.executeUpdate();
                insertStmt.close();
            }
            
            checkRs.close();
            checkStmt.close();
        }
        
        rs.close();
        pstmt.close();
        con.close();
    } catch (Exception e) {
        // Silently fail - recommendations are optional
        System.err.println("Error tracking product view: " + e.getMessage());
    }
}
%>