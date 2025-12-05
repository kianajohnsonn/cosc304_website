<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>

<%!
// Method to get product recommendations for a user
public List<Map<String, Object>> getProductRecommendations(Connection con, int userId, int currentProductId, int currentCategoryId) throws SQLException {
    List<Map<String, Object>> recommendations = new ArrayList<>();
    
    // Strategy 1: Based on purchase history (same category as previously purchased items)
    String sql1 = "SELECT TOP 5 p.productId, p.productName, p.productPrice, p.productImageURL, " +
                  "'Based on your purchase history' as reason " +
                  "FROM product p " +
                  "WHERE p.categoryId IN ( " +
                  "    SELECT DISTINCT p2.categoryId " +
                  "    FROM orderproduct op " +
                  "    JOIN ordersummary os ON op.orderId = os.orderId " +
                  "    JOIN product p2 ON op.productId = p2.productId " +
                  "    WHERE os.customerId = ? " +
                  ") " +
                  "AND p.productId != ? " +
                  "AND p.productId NOT IN ( " +
                  "    SELECT op2.productId FROM orderproduct op2 " +
                  "    JOIN ordersummary os2 ON op2.orderId = os2.orderId " +
                  "    WHERE os2.customerId = ? " +
                  ") " +
                  "ORDER BY NEWID()";
    
    PreparedStatement pstmt1 = con.prepareStatement(sql1);
    pstmt1.setInt(1, userId);
    pstmt1.setInt(2, currentProductId);
    pstmt1.setInt(3, userId);
    ResultSet rs1 = pstmt1.executeQuery();
    
    while (rs1.next() && recommendations.size() < 5) {
        Map<String, Object> rec = new HashMap<>();
        rec.put("productId", rs1.getInt("productId"));
        rec.put("productName", rs1.getString("productName"));
        rec.put("productPrice", rs1.getDouble("productPrice"));
        rec.put("productImageURL", rs1.getString("productImageURL"));
        rec.put("reason", rs1.getString("reason"));
        recommendations.add(rec);
    }
    rs1.close();
    pstmt1.close();
    
    // Strategy 2: Products in same category
    if (recommendations.size() < 5) {
        String sql2 = "SELECT TOP 5 p.productId, p.productName, p.productPrice, p.productImageURL, " +
                      "'Similar products' as reason " +
                      "FROM product p " +
                      "WHERE p.categoryId = ? " +
                      "AND p.productId != ? " +
                      "AND p.productId NOT IN ( " +
                  "    SELECT op2.productId FROM orderproduct op2 " +
                  "    JOIN ordersummary os2 ON op2.orderId = os2.orderId " +
                  "    WHERE os2.customerId = ? " +
                  ") " +
                      "ORDER BY NEWID()";
        
        PreparedStatement pstmt2 = con.prepareStatement(sql2);
        pstmt2.setInt(1, currentCategoryId);
        pstmt2.setInt(2, currentProductId);
        pstmt2.setInt(3, userId);
        ResultSet rs2 = pstmt2.executeQuery();
        
        while (rs2.next() && recommendations.size() < 5) {
            Map<String, Object> rec = new HashMap<>();
            rec.put("productId", rs2.getInt("productId"));
            rec.put("productName", rs2.getString("productName"));
            rec.put("productPrice", rs2.getDouble("productPrice"));
            rec.put("productImageURL", rs2.getString("productImageURL"));
            rec.put("reason", rs2.getString("reason"));
            recommendations.add(rec);
        }
        rs2.close();
        pstmt2.close();
    }
    
    // Strategy 3: Top selling products
    if (recommendations.size() < 5) {
        String sql3 = "SELECT TOP 5 p.productId, p.productName, p.productPrice, p.productImageURL, " +
                      "'Popular products' as reason " +
                      "FROM product p " +
                      "LEFT JOIN orderproduct op ON p.productId = op.productId " +
                      "WHERE p.productId != ? " +
                      "GROUP BY p.productId, p.productName, p.productPrice, p.productImageURL " +
                      "ORDER BY COUNT(op.productId) DESC";
        
        PreparedStatement pstmt3 = con.prepareStatement(sql3);
        pstmt3.setInt(1, currentProductId);
        ResultSet rs3 = pstmt3.executeQuery();
        
        while (rs3.next() && recommendations.size() < 5) {
            Map<String, Object> rec = new HashMap<>();
            rec.put("productId", rs3.getInt("productId"));
            rec.put("productName", rs3.getString("productName"));
            rec.put("productPrice", rs3.getDouble("productPrice"));
            rec.put("productImageURL", rs3.getString("productImageURL"));
            rec.put("reason", rs3.getString("reason"));
            recommendations.add(rec);
        }
        rs3.close();
        pstmt3.close();
    }
    
    return recommendations;
}

// Method to get popular products in a category (for non-logged in users)
public List<Map<String, Object>> getPopularProductsInCategory(Connection con, int categoryId, int excludeProductId) throws SQLException {
    List<Map<String, Object>> recommendations = new ArrayList<>();
    
    String sql = "SELECT TOP 5 p.productId, p.productName, p.productPrice, p.productImageURL, " +
                 "'Popular in this category' as reason " +
                 "FROM product p " +
                 "LEFT JOIN orderproduct oi ON p.productId = oi.productId " +
                 "WHERE p.categoryId = ? " +
                 "AND p.productId != ? " +
                 "GROUP BY p.productId, p.productName, p.productPrice, p.productImageURL " +
                 "ORDER BY COUNT(oi.productId) DESC, p.productName";
    
    PreparedStatement pstmt = con.prepareStatement(sql);
    pstmt.setInt(1, categoryId);
    pstmt.setInt(2, excludeProductId);
    ResultSet rs = pstmt.executeQuery();
    
    while (rs.next()) {
        Map<String, Object> rec = new HashMap<>();
        rec.put("productId", rs.getInt("productId"));
        rec.put("productName", rs.getString("productName"));
        rec.put("productPrice", rs.getDouble("productPrice"));
        rec.put("productImageURL", rs.getString("productImageURL"));
        rec.put("reason", rs.getString("reason"));
        recommendations.add(rec);
    }
    rs.close();
    pstmt.close();
    
    return recommendations;
}
%>