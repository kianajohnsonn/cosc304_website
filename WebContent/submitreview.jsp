<%@ page import="java.sql.*" %>
<%@ include file="jdbc.jsp"%>
<%@ include file="header.jsp"%>

<%
String user = (String) session.getAttribute("authenticatedUser");

// flag for "one review per product"
boolean alreadyReviewed = false;
String reviewError = null;

// must be logged in
if (user == null) {
    out.println("<p>You must <a href='login.jsp'>log in</a> to leave a review.</p>");
    return;
}

// product ID from button link
String pid = request.getParameter("id");
int productId = Integer.parseInt(pid);

// If the form was submitted
String method = request.getMethod();
if ("POST".equalsIgnoreCase(method)) {

    int rating = Integer.parseInt(request.getParameter("rating"));
    String comment = request.getParameter("comment");

    try {
        getConnection();
        
        // Get customer ID from authenticated user
        String customerSql = "SELECT customerId FROM customer WHERE userid = ?";
        PreparedStatement customerPs = con.prepareStatement(customerSql);
        customerPs.setString(1, user);
        ResultSet rs = customerPs.executeQuery();
        int customerId = 0;
        if (rs.next()) {
            customerId = rs.getInt("customerId");
        }
        rs.close();
        customerPs.close();
        
        // Check if customer already has a review for this product
        String checkSql = "SELECT reviewId FROM Review WHERE productId = ? AND customerId = ?";
        PreparedStatement checkPs = con.prepareStatement(checkSql);
        checkPs.setInt(1, productId);
        checkPs.setInt(2, customerId);
        ResultSet checkRs = checkPs.executeQuery();
        
        if (checkRs.next()) {
            // They already have a review → don't insert/update, just set error
            alreadyReviewed = true;
            reviewError = "Limit one review per product.";
        } else {
            // Insert new review
            String sql = "INSERT INTO Review (productId, customerId, reviewRating, reviewComment, reviewDate) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, productId);
            ps.setInt(2, customerId);
            ps.setInt(3, rating);
            ps.setString(4, comment);
            ps.setDate(5, new java.sql.Date(System.currentTimeMillis()));
            ps.executeUpdate();
            ps.close();

            // only redirect when successful insert (no error)
            checkRs.close();
            checkPs.close();
            closeConnection();

            response.sendRedirect("product.jsp?id=" + productId);
            return;
        }

        checkRs.close();
        checkPs.close();
        closeConnection();

    } catch (Exception e) {
        reviewError = "Error submitting review: " + e.getMessage();
    }
}
%>


<!DOCTYPE html>
<html>
<head>
<title>Leave a Review</title>

<style>
.review-form {
    width: 60%;
    margin: 30px auto;
    padding: 25px;
    background: #FFF7F9;
    border-left: 6px solid #1f3d2b;
    border-radius: 8px;
}
.review-form textarea {
    width: 100%;
    height: 100px;
    padding: 10px;
}
.review-form select, .review-form input[type=submit] {
    padding: 10px;
    margin-top: 10px;
}
</style>

</head>
<body>

<div class="review-form">
<h2>Leave a Review for Product #<%= productId %></h2>

<% if (reviewError != null) { %>
    <p style="color:red; font-weight:bold;"><%= reviewError %></p>
<% } %>

<form method="post" action="submitreview.jsp?id=<%= productId %>">

    <label>Rating:</label><br>
    <select name="rating" required>
        <option value="5">5 Excellent</option>
        <option value="4">4 Good</option>
        <option value="3">3 OK</option>
        <option value="2">2 Poor</option>
        <option value="1">1 Bad</option>
    </select>
    <br><br>

    <label>Comment:</label><br>
    <textarea name="comment" required></textarea>
    <br><br>

    <input type="submit" value="Submit Review">
</form>
</div>

</body>
</html>
