<%@ page import="java.util.HashMap" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="jdbc.jsp" %>

<%!
// Helper methods for recommendations - DECLARATIONS MUST BE AT TOP
public List<Map<String, Object>> getProductRecommendations(Connection con, int userId, int currentProductId, int currentCategoryId) throws SQLException {
    List<Map<String, Object>> recommendations = new ArrayList<>();
    
    // Strategy 1: Based on purchase history
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
                      "ORDER BY NEWID()";
        
        PreparedStatement pstmt2 = con.prepareStatement(sql2);
        pstmt2.setInt(1, currentCategoryId);
        pstmt2.setInt(2, currentProductId);
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
    
    return recommendations;
}

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

/* Recommendation Section Styles */
.recommendations-section {
    margin-top: 40px;
    padding: 20px;
    background: #f8f9fa;
    border-radius: 10px;
    border-left: 5px solid #1f3d2b;
}

.recommendations-title {
    color: #1f3d2b;
    font-size: 1.5rem;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 2px solid #e2f1f7;
}

.recommendations-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    justify-content: center;
}

.recommendation-card {
    width: 180px;
    background: white;
    border-radius: 8px;
    padding: 15px;
    text-align: center;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    transition: transform 0.2s;
}

.recommendation-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 4px 10px rgba(0,0,0,0.15);
}

.recommendation-image {
    width: 100%;
    height: 120px;
    object-fit: cover;
    border-radius: 5px;
    margin-bottom: 10px;
}

.recommendation-name {
    font-size: 0.9rem;
    font-weight: bold;
    color: #1f3d2b;
    margin-bottom: 5px;
}

.recommendation-price {
    color: #0c6fb8;
    font-weight: bold;
}

.recommendation-reason {
    font-size: 0.8rem;
    color: #666;
    font-style: italic;
    margin-top: 5px;
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
String context = request.getContextPath();
if (productId == null || productId.isEmpty()) {
    out.println("<p>No product ID provided.</p>");
} else {
    int id = Integer.parseInt(productId);
    String sql = "SELECT productName, productDesc, productPrice, productImageURL, categoryId FROM product WHERE productId = ?";
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();
    try (Connection con = DriverManager.getConnection(url, uid, pw);
         PreparedStatement pstmt = con.prepareStatement(sql)) {
        
        pstmt.setInt(1, id);
        ResultSet rs = pstmt.executeQuery();
        
        if (rs.next()) {
            String name = rs.getString("productName");
            String desc = rs.getString("productDesc");
            double price = rs.getDouble("productPrice");
            String imageURL = rs.getString("productImageURL");
            int categoryId = rs.getInt("categoryId");

            // Get user recommendations
            String userName = (String) session.getAttribute("authenticatedUser");
            List<Map<String, Object>> recommendations = new ArrayList<>();

            if (userName != null && !userName.isEmpty()) {
                // Get user ID
                String userSql = "SELECT customerId FROM customer WHERE userid = ?";
                PreparedStatement userStmt = con.prepareStatement(userSql);
                userStmt.setString(1, userName);
                ResultSet userRs = userStmt.executeQuery();
                
                if (userRs.next()) {
                    int userId = userRs.getInt("customerId");
                    recommendations = getProductRecommendations(con, userId, id, categoryId);
                }
                userRs.close();
                userStmt.close();
            }

            // If no user-specific recommendations, show popular products in same category
            if (recommendations.isEmpty()) {
                recommendations = getPopularProductsInCategory(con, categoryId, id);
            }

            out.println("<div class='product-box'>");
            out.println("<h2>" + name + "</h2>");
            out.println("<p><strong>Description:</strong> " + desc + "</p>");
            out.println("<p class='unit-price'><strong>Price per bag:</strong> " + currFormat.format(price) + "</p>");

            // Hidden fields for JavaScript
            out.println("<input type='hidden' id='productId' value='" + id + "'>");
            out.println("<input type='hidden' id='productName' value='" + name + "'>");
            out.println("<input type='hidden' id='unitPrice' value='" + price + "'>");

            // Quantity selector
            out.println("<div class='quantity-selector'>");
            out.println("<label for='quantity'>Quantity:</label>");
            out.println("<select id='quantity' name='quantity' onchange='updatePrice()'>");
            for (int i = 1; i <= 10; i++) {
                out.println("<option value='" + i + "'>" + i + " bag" + (i > 1 ? "s" : "") + "</option>");
            }
            out.println("</select>");
            out.println("</div>");
            
            // Dynamic price display
            out.println("<div class='price-display'>");
            out.println("<strong>Total: </strong><span id='totalPrice'>" + currFormat.format(price) + "</span>");
            out.println("</div>");
            
            if (imageURL != null && !imageURL.isEmpty()) {
                out.println("<img src='" + imageURL + "' alt='" + name + "' style='max-width:600px;'/>");
            } else {
                out.println("<p>No image available.</p>");
            }
            
            out.println("<p><a id='addToCartBtn' href='addcart.jsp?id=" + id + "&name=" + URLEncoder.encode(name, "UTF-8") + "&price=" + price + "&quantity=1' class='btn btn-primary'>Add to Cart</a></p>");
            out.println("<p><a href='listprod.jsp' class='btn btn-secondary'>Continue Shopping</a></p>");

            // Display recommendations
            if (!recommendations.isEmpty()) {
                out.println("<div class='recommendations-section'>");
                out.println("<h3 class='recommendations-title'>Recommended For You</h3>");
                out.println("<div class='recommendations-grid'>");
                
                for (Map<String, Object> rec : recommendations) {
                    int recId = (int) rec.get("productId");
                    String recName = (String) rec.get("productName");
                    double recPrice = (double) rec.get("productPrice");
                    String recImage = (String) rec.get("productImageURL");
                    String recReason = (String) rec.get("reason");
                    
                    // Handle missing images
                    if (recImage == null || recImage.isEmpty()) {
                        // Assign default image based on category
                        if (categoryId == 1) {
                            recImage = context + "/img/wholebeans.jpg";
                        } else if (categoryId == 2) {
                            recImage = context + "/img/groundcoffee.jpg";
                        } else if (categoryId == 3) {
                            recImage = context + "/img/drip.jpeg";
                        } else if (categoryId == 4) {
                            recImage = context + "/img/frother.png";
                        } else {
                            recImage = context + "/img/wholebeans.jpg";
                        }
                    }
                    
                    out.println("<div class='recommendation-card'>");
                    out.println("<a href='product.jsp?id=" + recId + "'>");
                    out.println("<img src='" + recImage + "' alt='" + recName + "' class='recommendation-image'>");
                    out.println("<div class='recommendation-name'>" + recName + "</div>");
                    out.println("<div class='recommendation-price'>" + currFormat.format(recPrice) + "</div>");
                    if (recReason != null) {
                        out.println("<div class='recommendation-reason'>" + recReason + "</div>");
                    }
                    out.println("</a>");
                    out.println("</div>");
                }
                
                out.println("</div>"); // end recommendations-grid
                out.println("</div>"); // end recommendations-section
            }

            out.println("</div>"); // end product-box
        } else {
            out.println("<p>Product not found.</p>");
        }
        
        rs.close();
    } catch (Exception e) {
        out.println("<p>Error retrieving product: " + e.getClass().getName() + " - " + e.getMessage() + "</p>");
        e.printStackTrace(); // goes to server logs
    }
}
%>
</body>
</html>