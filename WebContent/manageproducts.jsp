<%@ page import="java.sql.*" %>
<%@ include file="auth.jsp" %>
<%@ include file="jdbc.jsp" %>
<%@ include file="header.jsp" %>

<!DOCTYPE html>
<html>
<head>
<title>Manage Products</title>

<style>
body {
    font-family: Arial, Helvetica, sans-serif;
    background: #FFE4E1;
    padding: 30px;
    color: #1f3d2b;
}

h1 {
    text-align: center;
    margin-bottom: 30px;
}

table {
    border-collapse: collapse;
    width: 80%;
    margin: 20px auto;
    background: #FFF7F9;
}

th, td {
    border: 1px solid #ccc;
    padding: 12px;
    text-align: center;
}

th {
    background: #1f3d2b;
    color: #FFE4E1;
}

tr:nth-child(even) {
    background: #FFEFF2;
}

form.inline {
    display: inline;
}
</style>

</head>
<body>

<%
    // Make sure user is logged in
    String user = (String) session.getAttribute("authenticatedUser");
    if (user == null) {
        out.println("<p>You must be logged in to access this page.</p>");
        out.println("<p><a href='login.jsp'>Go to Login Page</a></p>");
        return;
    }

    String action = request.getParameter("action");
    String message = null;

    // Handle add / update / delete
    if (action != null) {
        try {
            getConnection();

            if ("add".equals(action)) {
                String name = request.getParameter("productName");
                String priceStr = request.getParameter("productPrice");
                String imageURL = request.getParameter("productImageURL");
                String desc = request.getParameter("productDesc");
                String categoryStr = request.getParameter("categoryId");

                if (name != null && priceStr != null && categoryStr != null) {
                    double price = Double.parseDouble(priceStr);
                    int categoryId = Integer.parseInt(categoryStr);

                    String sql = "INSERT INTO product " +
                                 "(productName, productPrice, productDesc, categoryId) " +
                                 "VALUES (?, ?, ?, ?)";
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setString(1, name);
                    ps.setDouble(2, price);
                    ps.setString(3, desc);
                    ps.setInt(4, categoryId);

                    int rows = ps.executeUpdate();
                    ps.close();

                    if (rows > 0) message = "Product added successfully.";
                    else message = "Product was not added.";
                }

            } else if ("delete".equals(action)) {
                String idStr = request.getParameter("productId");
                if (idStr != null) {
                    int productId = Integer.parseInt(idStr);
                    String sql = "DELETE FROM product WHERE productId = ?";
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setInt(1, productId);
                    int rows = ps.executeUpdate();
                    ps.close();

                    if (rows > 0) message = "Product " + productId + " deleted.";
                    else message = "Product " + productId + " not found.";
                }

            } else if ("update".equals(action)) {
                String idStr = request.getParameter("productId");
                String name = request.getParameter("productName");
                String priceStr = request.getParameter("productPrice");
                String imageURL = request.getParameter("productImageURL");
                String desc = request.getParameter("productDesc");
                String categoryStr = request.getParameter("categoryId");

                if (idStr != null && name != null && priceStr != null && categoryStr != null) {
                    int productId = Integer.parseInt(idStr);
                    double price = Double.parseDouble(priceStr);
                    int categoryId = Integer.parseInt(categoryStr);

                    String sql = "UPDATE product SET " +
                                 "productName = ?, productPrice = ?, productImageURL = ?, " +
                                 "productDesc = ?, categoryId = ? " +
                                 "WHERE productId = ?";
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setString(1, name);
                    ps.setDouble(2, price);
                    ps.setString(3, imageURL);
                    ps.setString(4, desc);
                    ps.setInt(5, categoryId);
                    ps.setInt(6, productId);

                    int rows = ps.executeUpdate();
                    ps.close();

                    if (rows > 0) message = "Product " + productId + " updated.";
                    else message = "Product " + productId + " not found.";
                }
            }

        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        } finally {
            closeConnection();
        }
    }

    if (message != null) {
        out.println("<p style='text-align:center; font-weight:bold;'>" + message + "</p>");
    }
%>

<h1>Manage Products</h1>

<%//ADD PRODUCT FORM%>
<h2 style="text-align:left;">Add Product</h2>
<form method="post" action="manageproduct.jsp" style="width:60%; margin:0;">
    <input type="hidden" name="action" value="add">

    <p>
        Product Name:<br>
        <input type="text" name="productName" required>
    </p>

    <p>
        Price:<br>
        <input type="text" name="productPrice" required>
    </p>

    <p>
        Image URL:<br>
        <input type="text" name="productImageURL">
    </p>

    <p>
        Description:<br>
        <textarea name="productDesc" rows="3" cols="40"></textarea>
    </p>

    <p>
        Category ID:<br>
        <input type="number" name="categoryId" required>
    </p>

    <p>
        <input type="submit" value="Add Product">
    </p>
</form>

<%//UPDATE PRODUCT FORM%>
<h2 style="text-align:left;">Update Product</h2>
<form method="post" action="manageproduct.jsp" style="width:60%; margin:0;">
    <input type="hidden" name="action" value="update">

    <p>
        Product ID to Update:<br>
        <input type="number" name="productId" required>
    </p>

    <p>
        New Product Name:<br>
        <input type="text" name="productName" required>
    </p>

    <p>
        New Price:<br>
        <input type="text" name="productPrice" required>
    </p>

    <p>
        New Image URL:<br>
        <input type="text" name="productImageURL">
    </p>

    <p>
        New Description:<br>
        <textarea name="productDesc" rows="3" cols="40"></textarea>
    </p>

    <p>
        New Category ID:<br>
        <input type="number" name="categoryId" required>
    </p>

    <p>
        <input type="submit" value="Update Product">
    </p>
</form>

<h2 style="text-align:center;">Current Products</h2>

<%
    // List current products
    try {
        getConnection();

        String sql = "SELECT productId, productName, productPrice, productDesc, categoryId " +
                     "FROM product ORDER BY productId";
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        out.println("<table>");
        out.println("<tr>"
                  + "<th>ID</th><th>Name</th><th>Price</th>"
                  + "<th>Description</th>"
                  + "<th>Category ID</th><th>Actions</th></tr>");

        while (rs.next()) {
            int pid = rs.getInt("productId");
            out.println("<tr>");
            out.println("<td>" + pid + "</td>");
            out.println("<td>" + rs.getString("productName") + "</td>");
            out.println("<td>" + rs.getDouble("productPrice") + "</td>");
            out.println("<td>" + rs.getString("productDesc") + "</td>");
            out.println("<td>" + rs.getInt("categoryId") + "</td>");

            // delete button form in table
            out.println("<td>");
            out.println("<form class='inline' method='post' action='manageproduct.jsp'>");
            out.println("<input type='hidden' name='action' value='delete'>");
            out.println("<input type='hidden' name='productId' value='" + pid + "'>");
            out.println("<input type='submit' value='Delete' ");
            out.println("onclick=\"return confirm('Delete product " + pid + "?');\">");
            out.println("</form>");
            out.println("</td>");

            out.println("</tr>");
        }

        out.println("</table>");

        rs.close();
        ps.close();
    } catch (Exception e) {
        out.println("<p>Error retrieving products: " + e.getMessage() + "</p>");
    } finally {
        closeConnection();
    }
%>

<p style="text-align:center;"><a href="admin.jsp">Back to Admin</a></p>

</body>
</html>
