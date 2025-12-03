<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Grocery Product List</title>
<style>
  body {
    font-family: Arial, Helvetica, sans-serif;
    margin: 0;
    padding: 0;
    background: #b5cce4; 
    color: #1f3d2b;      
  }

  h1 {
    text-align: center;
    margin: 20px 0;
    color: #1f3d2b;
    letter-spacing: 0.5px;
  }

  a {
    text-decoration: none;
    color: #0c6fb8; 
    background: #e2f1f7;
    padding: 12px 24px;
    border-radius: 50px;    
    font-size: 1.1rem;
    transition: 0.25s ease;
    border: 1px solid #0c6fb8;
  }

  a:hover {
    background: #0c6fb8;
    color: white;
  }

  /* Search area */
  .search-form {
    text-align: center;
    margin: 30px 0 10px;
  }

  .search-form form {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    padding: 10px 18px;
    background: #FDEDEF;          
    border-radius: 999px;
    border: 1px solid #FBC4D8;    
  }

  .search-form input[type="text"] {
    padding: 8px 12px;
    border-radius: 20px;
    border: 1px solid #ccc;
    outline: none;
    min-width: 220px;
    font-size: 0.95rem;
  }

  .search-form input[type="text"]:focus {
    border-color: #0c6fb8;
  }

  .search-form input[type="submit"] {
    border: none;
    cursor: pointer;
    padding: 8px 18px;
    border-radius: 50px;
    background: #0c6fb8;
    color: white;
    font-size: 0.95rem;
    transition: 0.25s ease;
  }

  .search-form input[type="submit"]:hover {
    background: #084a7d;
  }

  /* Product table */
  .product-table {
    width: 80%;
    margin: 20px auto 50px;
    border-collapse: collapse;
    background: #738db4;        
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.06);
    border-radius: 12px;
    overflow: hidden;           
  }

  .product-table th,
  .product-table td {
    padding: 12px 16px;
    text-align: left;
  }

  .product-table th {
    background: #1f3d2b;        
    color: #e1f1ff;            
    font-weight: normal;
    font-size: 1rem;
  }

  .product-table tr:nth-child(even) {
    background: #FFF7F9;        
  }

  .product-table tr:nth-child(odd) {
    background: #FFF7F9;
  }

  .product-table tr:hover {
    background: #E2F1F7;        
  }

  .add-to-cart-btn {
    display: inline-block;
    padding: 6px 14px;
    font-size: 0.9rem;
    border-radius: 50px;
    background: #e2f1f7;
    color: #0c6fb8;
    border: 1px solid #0c6fb8;
    text-decoration: none;
    transition: 0.2s ease;
  }

  .add-to-cart-btn:hover {
    background: #0c6fb8;
    color: #ffffff;
  }
</style>

</head>
<body>


<%@ include file="header.jsp" %>

<h1>Product List</h1>

<div class="search-form">
    <form method="get" action="listprod.jsp">
        Search Product: <input type="text" name="productName" value="<%= request.getParameter("productName") != null ? request.getParameter("productName") : "" %>" />
        Category: 
        <select name="categoryId">
            <option value="">All Categories</option>
            <%
            String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
            String uid = "sa";
            String pw = "304#sa#pw";
            
            String selectedCategory = request.getParameter("categoryId");
            
            try {
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                try (Connection con = DriverManager.getConnection(url, uid, pw)) {
                    PreparedStatement catStmt = con.prepareStatement("SELECT categoryId, categoryName FROM category");
                    ResultSet catRs = catStmt.executeQuery();
                    while (catRs.next()) {
                        int catId = catRs.getInt("categoryId");
                        String catName = catRs.getString("categoryName");
                        String selected = selectedCategory != null && selectedCategory.equals(String.valueOf(catId)) ? "selected" : "";
                        out.println("<option value='" + catId + "' " + selected + ">" + catName + "</option>");
                    }
                    catRs.close();
                    catStmt.close();
                }
            } catch (Exception e) {
                out.println("<!-- Error loading categories: " + e.getMessage() + " -->");
            }
            %>
        </select>
        <input type="submit" value="Search" style="padding: 8px 15px; background-color: #007bff; color: white; border: none; border-radius: 3px; cursor: pointer;" />
    </form>
</div>

<%
String productNameParam = request.getParameter("productName");
if (productNameParam == null) productNameParam = "";

String categoryIdParam = request.getParameter("categoryId");

NumberFormat currFormat = NumberFormat.getCurrencyInstance();

try {
    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

    try (Connection con = DriverManager.getConnection(url, uid, pw)) {
        String sql = "SELECT p.productId, p.productName, p.productPrice, c.categoryName " +
                     "FROM product p LEFT JOIN category c ON p.categoryId = c.categoryId " +
                     "WHERE p.productName LIKE ? ";
        
        if (categoryIdParam != null && !categoryIdParam.isEmpty()) {
            sql += "AND p.categoryId = ? ";
        }
        sql += "ORDER BY c.categoryName, p.productName";
        
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setString(1, "%" + productNameParam + "%");
        if (categoryIdParam != null && !categoryIdParam.isEmpty()) {
            pstmt.setInt(2, Integer.parseInt(categoryIdParam));
        }

        ResultSet rs = pstmt.executeQuery();

        out.println("<table class='product-table'>");
        out.println("<tr><th>Product ID</th><th>Name</th><th>Category</th><th>Price</th><th>Action</th></tr>");

        String currentCategory = "";
        while (rs.next()) {
            int id = rs.getInt("productId");
            String name = rs.getString("productName");
            double price = rs.getDouble("productPrice");
            String category = rs.getString("categoryName");
            if (category == null) {
                category = "Uncategorized";
            }

            if (!category.equals(currentCategory)) {
                currentCategory = category;
                out.println("<tr><td colspan='5' class='category-header'>" + currentCategory + "</td></tr>");
            }

            // Build Add to Cart URL safely
            String addUrl = "addcart.jsp?id=" + id
                          + "&name=" + URLEncoder.encode(name, "UTF-8")
                          + "&price=" + price;

            out.println("<tr>");
            out.println("<td>" + id + "</td>");
            // Click name to go to product.jsp
            out.println("<td><a href='product.jsp?id=" + id + "'>" + name + "</a></td>");
            out.println("<td>" + category + "</td>");
            out.println("<td>" + currFormat.format(price) + "</td>");
            out.println("<td><a href='" + addUrl + "' class='add-to-cart-btn'>Add to Cart</a></td>");
            out.println("</tr>");
        }

        out.println("</table>");

        rs.close();
        pstmt.close();
    }

} catch (Exception e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
}
%>

</body>
</html>
