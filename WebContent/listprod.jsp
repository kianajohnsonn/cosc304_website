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

  .add-to-cart-btn {
    display: inline-block;
    padding: 5px 10px;
    font-size: 0.9rem;
    border-radius: 50px;
    background: #e2f1f7;
    color: #0c6fb8;
    border: 1px solid #0c6fb8;
    text-decoration: none;
    transition: 0.2s ease;
    margin-left: 75px;
  }

  .add-to-cart-btn:hover {
    background: #0c6fb8;
    color: #ffffff;
  }
  .product-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    justify-content: center;
    padding: 20px;
}
.product-card-link {
    text-decoration: none;
    color: inherit;
    display: block;
}

.product-card-link:hover .product-card {
    transform: translateY(-4px);
    background: #f1f9ff;
    box-shadow: 0 6px 16px rgba(0,0,0,0.15);
}


.product-card {
    width: 220px;
    background: #ffffff;
    border-radius: 10px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.12);
    padding: 10px 10px 15px 10px;
    text-align: center;
    font-family: Arial, Helvetica, sans-serif;
}

.product-image {
    width: 100%;
    height: 160px;
    object-fit: cover;
    border-radius: 8px;
    margin-bottom: 8px;
}

.product-name a {
    background: none !important;
    padding: 0 !important;
    margin: 0 !important;
    border: none !important;
    border-radius: 0 !important;
    display: inline-block;
    font-size: 1rem !important;
    line-height: 1.2;
    color: #1f3d2b !important;
    text-decoration: none;
    white-space: normal; /* allows wrapping */
}

.product-name a:hover {
    text-decoration: underline;
    color: #0c6fb8 !important;
}


.product-price {
    font-size: 1.05rem;
    font-weight: bold;
    margin: 8px 0;
    margin-top: 15px;
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

// IMPORTANT: get context path
String context = request.getContextPath();

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

        out.println("<div class='product-grid'>");

        while (rs.next()) {
            int id = rs.getInt("productId");
            String name = rs.getString("productName");
            double price = rs.getDouble("productPrice");
            String category = rs.getString("categoryName");
            String imageURL;

            if (category == null) {
                category = "Uncategorized";
            }

            // Assign images based on category and product name
            if ("Coffee Beans Whole".equalsIgnoreCase(category)) {
                imageURL = context + "/img/wholebeans.jpg";
            } else if ("Coffee Beans Ground".equalsIgnoreCase(category)) {
                imageURL = context + "/img/groundcoffee.jpg";
            } else if ("Coffee Makers".equalsIgnoreCase(category)) {
                // Assign unique images for each coffee maker based on product name
                if (name.toLowerCase().contains("single")) {
                    imageURL = context + "/img/singleshot.jpeg";
                } else if (name.toLowerCase().contains("dual")) {
                    imageURL = context + "/img/doubleshot.jpeg";
                } else if (name.toLowerCase().contains("french")) {
                    imageURL = context + "/img/frenchpress.jpeg";
                } else if (name.toLowerCase().contains("drip")) {
                    imageURL = context + "/img/drip.jpeg";
                } else if (name.toLowerCase().contains("mokapot") || name.toLowerCase().contains("moka")) {
                    imageURL = context + "/img/mokapot.jpeg";
                } else {
                    imageURL = context + "/img/mokapot.jpeg"; // default coffee maker image
                }
            } else if ("Accessories".equalsIgnoreCase(category)) {
                // Assign unique images for each accessory
                if (name.toLowerCase().contains("frother")) {
                    imageURL = context + "/img/frother.png";
                } else if (name.toLowerCase().contains("scale")) {
                    imageURL = context + "/img/scale.png";
                } else if (name.toLowerCase().contains("filter")) {
                    imageURL = context + "/img/filters.jpeg";
                } else if (name.toLowerCase().contains("travel") || name.toLowerCase().contains("mug")) {
                    imageURL = context + "/img/travelmug.png";
                } else {
                    imageURL = context + "/img/frother.png"; // default accessory image
                }
            } else {
                // Default for unknown categories
                imageURL = context + "/img/wholebeans.jpg";
            }


            // Build Add to Cart URL safely
            String addUrl = "addcart.jsp?id=" + id
                          + "&name=" + URLEncoder.encode(name, "UTF-8")
                          + "&price=" + price;

            String productLink = "product.jsp?id=" + id;

out.println("<div class='product-wrapper'>");  // optional wrapper

// whole card is clickable
out.println("<a href='" + productLink + "' class='product-card-link'>");
out.println("<div class='product-card'>");

out.println("<img src='" + imageURL + "' class='product-image'>");
out.println("<div class='product-name'>" + name + "</div>");
out.println("<div class='product-price'>" + currFormat.format(price) + "</div>");

out.println("</div>");
out.println("</a>");

// Separate Add to Cart button
out.println("<a href='" + addUrl + "' class='add-to-cart-btn'>Add to Cart</a>");

out.println("</div>");

        }

        out.println("</div>"); // end grid

        rs.close();
        pstmt.close();
    }

} catch (Exception e) {
    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
} 
%>

</body>
</html>
