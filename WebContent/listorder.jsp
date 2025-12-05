<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ include file="auth.jsp" %>

<!DOCTYPE html>
<html>
<head>
<title>Order List</title>
<style>
    body {
        font-family: Arial, Helvetica, sans-serif;
        margin: 0;
        padding: 20px;
        background: #e6f3fa; /* soft light blue */
        color: #1f3d2b;     /* dark green text */
    }

    h1, h2 {
        text-align: center;
        color: #1f3d2b;
        margin-top: 20px;
        margin-bottom: 30px;
        letter-spacing: 0.5px;
    }

    /* Filter section */
    .filter-container {
        width: 90%;
        margin: 20px auto;
        padding: 20px;
        background: #FFF7F9;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }

    .filter-form {
        display: flex;
        gap: 20px;
        align-items: center;
        flex-wrap: wrap;
    }

    .filter-group {
        display: flex;
        flex-direction: column;
    }

    .filter-group label {
        margin-bottom: 5px;
        font-weight: bold;
        color: #1f3d2b;
    }

    select, input[type="date"] {
        padding: 8px 12px;
        border-radius: 8px;
        border: 1px solid #ccc;
        font-size: 1rem;
    }

    .btn {
        padding: 8px 20px;
        border-radius: 50px;
        border: none;
        cursor: pointer;
        font-size: 1rem;
        transition: 0.25s ease;
    }

    .btn-primary {
        background: #0c6fb8;
        color: white;
    }

    .btn-primary:hover {
        background: #084a7d;
    }

    .btn-secondary {
        background: #e2f1f7;
        color: #0c6fb8;
        border: 1px solid #0c6fb8;
    }

    .btn-secondary:hover {
        background: #0c6fb8;
        color: white;
    }

    /* Main outer order table */
    .orders-table {
        width: 90%;
        margin: 25px auto;
        border-collapse: collapse;
        background: #e6d8de;
        border-radius: 12px;
        overflow: hidden;
        box-shadow: 0 4px 10px rgba(0,0,0,0.08);
    }

    .orders-table th {
        background: #9eb7d3;   /* blue */
        color: #244f7e;        /* dark blue text */
        padding: 12px;
        font-size: 1rem;
        text-align: left;
    }

    .orders-table td {
        padding: 12px;
        border-bottom: 1px solid #d9e7ef;
    }

    /* Order summary row */
    .order-summary-row {
        cursor: pointer;
        transition: background 0.3s;
    }

    .order-summary-row:hover {
        background: #f0e6ea;
    }

    /* Order details section */
    .order-details {
        background: #fdf7fa;
        padding: 20px;
        border-left: 4px solid #1f3d2b;
        margin: 10px 0;
        border-radius: 8px;
    }

    .order-details h3 {
        margin-top: 0;
        color: #1f3d2b;
        border-bottom: 2px solid #e2f1f7;
        padding-bottom: 10px;
    }

    /* Products table inside order details */
    .products-table {
        width: 100%;
        margin-top: 15px;
        border-collapse: collapse;
        background: white;
        border-radius: 8px;
        overflow: hidden;
    }

    .products-table th {
        background: #a8b9a1;    /* soft green */
        color: #1f3d2b;
        padding: 10px;
        border-bottom: 1px solid #f6cce0;
    }

    .products-table td {
        padding: 10px;
        border-bottom: 1px solid #f6cce0;
    }

    /* Financial breakdown */
    .financial-breakdown {
        margin-top: 20px;
        padding: 15px;
        background: #f8f9fa;
        border-radius: 8px;
        border-left: 3px solid #0c6fb8;
    }

    .breakdown-row {
        display: flex;
        justify-content: space-between;
        margin: 8px 0;
    }

    .total-row {
        font-weight: bold;
        font-size: 1.1rem;
        border-top: 2px solid #1f3d2b;
        padding-top: 10px;
        margin-top: 10px;
    }

    /* Shipment info */
    .shipment-info {
        background: #e2f1f7;
        padding: 15px;
        border-radius: 8px;
        margin: 15px 0;
    }

    .shipment-item {
        margin: 10px 0;
        padding: 10px;
        border: 1px solid #b7e3f7;
        border-radius: 6px;
        background: white;
    }

    .status-badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.85rem;
        font-weight: bold;
    }

    .status-pending { background: #ffd166; color: #7a5900; }
    .status-processing { background: #06d6a0; color: #00573a; }
    .status-shipped { background: #118ab2; color: white; }
    .status-delivered { background: #1f3d2b; color: white; }

    /* Toggle button */
    .toggle-details {
        background: none;
        border: none;
        color: #0c6fb8;
        cursor: pointer;
        font-size: 0.9rem;
        padding: 5px 10px;
        text-decoration: underline;
    }

    .toggle-details:hover {
        color: #084a7d;
    }

    .page-wrap {
        max-width: 1100px;
        margin: 0 auto;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .filter-form {
            flex-direction: column;
            align-items: stretch;
        }
        
        .orders-table, .filter-container {
            width: 95%;
        }
        
        .orders-table th, .orders-table td {
            padding: 8px 5px;
            font-size: 0.9rem;
        }
    }
</style>

<script>
// Toggle order details visibility
function toggleOrderDetails(orderId) {
    const details = document.getElementById('details-' + orderId);
    const toggleBtn = document.getElementById('toggle-' + orderId);
    
    if (details.style.display === 'none' || details.style.display === '') {
        details.style.display = 'block';
        toggleBtn.textContent = 'Hide Details';
    } else {
        details.style.display = 'none';
        toggleBtn.textContent = 'Show Details';
    }
}

// Filter orders by date range
function filterOrders() {
    const startDate = document.getElementById('startDate').value;
    const endDate = document.getElementById('endDate').value;
    const status = document.getElementById('statusFilter').value;
    
    // In a real implementation, this would submit to server
    // For now, just show alert
    if (startDate || endDate || status) {
        alert('Filtering orders... This would reload with filtered results.');
    }
}
</script>
</head>
<body>

<%@ include file="header.jsp" %>

<h1>Order List</h1>

<%
// Check if user is logged in
String userName = (String) session.getAttribute("authenticatedUser");
if (userName == null) {
    response.sendRedirect("login.jsp");
    return;
}

//Note: Forces loading of SQL Server driver
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}

String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid =  "sa";
String pwd = "304#sa#pw";

NumberFormat money = NumberFormat.getCurrencyInstance();

// Get filter parameters
String startDate = request.getParameter("startDate");
String endDate = request.getParameter("endDate");
String statusFilter = request.getParameter("status");

// Display filter form
out.println("<div class='filter-container'>");
out.println("<h3>Filter Orders</h3>");
out.println("<form method='get' action='listorder.jsp' class='filter-form'>");
out.println("<div class='filter-group'>");
out.println("<label>From Date:</label>");
out.println("<input type='date' id='startDate' name='startDate' value='" + (startDate != null ? startDate : "") + "'>");
out.println("</div>");
out.println("<div class='filter-group'>");
out.println("<label>To Date:</label>");
out.println("<input type='date' id='endDate' name='endDate' value='" + (endDate != null ? endDate : "") + "'>");
out.println("</div>");
out.println("<div class='filter-group'>");
out.println("<label>Status:</label>");
out.println("<select id='statusFilter' name='status'>");
out.println("<option value=''>All Status</option>");
out.println("<option value='pending'" + ("pending".equals(statusFilter) ? " selected" : "") + ">Pending</option>");
out.println("<option value='processing'" + ("processing".equals(statusFilter) ? " selected" : "") + ">Processing</option>");
out.println("<option value='shipped'" + ("shipped".equals(statusFilter) ? " selected" : "") + ">Shipped</option>");
out.println("<option value='delivered'" + ("delivered".equals(statusFilter) ? " selected" : "") + ">Delivered</option>");
out.println("</select>");
out.println("</div>");
out.println("<button type='submit' class='btn btn-primary'>Apply Filters</button>");
out.println("<a href='listorder.jsp' class='btn btn-secondary'>Clear Filters</a>");
out.println("</form>");
out.println("</div>");

// Write query to retrieve all order summary records
try(Connection con = DriverManager.getConnection(url, uid, pwd)) {
    // Build query based on filters
    StringBuilder sqlOrder = new StringBuilder();
    sqlOrder.append("SELECT o.orderId, o.orderDate, c.customerId, c.firstName, c.lastName, ");
    sqlOrder.append("o.totalAmount, o.taxAmount, o.shippingCost ");
    sqlOrder.append("FROM ordersummary o ");
    sqlOrder.append("JOIN customer c ON o.customerId = c.customerId ");
    sqlOrder.append("WHERE 1=1 ");
    
    if (startDate != null && !startDate.isEmpty()) {
        sqlOrder.append("AND o.orderDate >= ? ");
    }
    if (endDate != null && !endDate.isEmpty()) {
        sqlOrder.append("AND o.orderDate <= ? ");
    }
    sqlOrder.append("ORDER BY o.orderDate DESC");

    String sqlProducts = "SELECT op.productId, p.productName, op.quantity, op.price, p.productImageURL "
            + "FROM orderproduct op JOIN product p ON op.productId = p.productId "
            + "WHERE op.orderId = ?";

    String sqlShipments = "SELECT os.shipmentId, os.shipmentDate, os.trackingNumber, os.carrier, "
            + "os.shippingCost, os.taxAmount, os.status "
            + "FROM OrderShipment os "
            + "WHERE os.orderId = ?";

    try(PreparedStatement psProducts = con.prepareStatement(sqlProducts);
        PreparedStatement psShipments = con.prepareStatement(sqlShipments);
        PreparedStatement psOrders = con.prepareStatement(sqlOrder.toString())) {
        
        // Set parameters for filters
        int paramIndex = 1;
        if (startDate != null && !startDate.isEmpty()) {
            psOrders.setString(paramIndex++, startDate + " 00:00:00");
        }
        if (endDate != null && !endDate.isEmpty()) {
            psOrders.setString(paramIndex++, endDate + " 23:59:59");
        }
        
        ResultSet rs = psOrders.executeQuery();
        
        out.println("<table class='orders-table'>");
        out.println("<thead>");
        out.println("<tr>");
        out.println("<th>Order ID</th>");
        out.println("<th>Order Date</th>");
        out.println("<th>Customer</th>");
        out.println("<th>Shipping To</th>");
        out.println("<th>Total Amount</th>");
        out.println("<th>Actions</th>");
        out.println("</tr>");
        out.println("</thead>");
        out.println("<tbody>");
        
        boolean hasOrders = false;
        while (rs.next()){
            hasOrders = true;
            int orderId = rs.getInt("orderId");
            Timestamp orderDate = rs.getTimestamp("orderDate");
            int customerId = rs.getInt("customerId");
            String customerName = rs.getString("firstName") + " " + rs.getString("lastName");
            BigDecimal totalAmount = rs.getBigDecimal("totalAmount");
            BigDecimal taxAmount = rs.getBigDecimal("taxAmount");
            BigDecimal shippingCost = rs.getBigDecimal("shippingCost");
            
            String shippingAddress = "View in shipment details";
            
            out.println("<tr class='order-summary-row'>");
            out.println("<td><strong>#" + orderId + "</strong></td>");
            out.println("<td>" + orderDate + "</td>");
            out.println("<td>" + customerName + "<br><small>ID: " + customerId + "</small></td>");
            out.println("<td>" + shippingAddress + "</td>");
            out.println("<td><strong>" + money.format(totalAmount) + "</strong></td>");
            out.println("<td><button class='toggle-details' id='toggle-" + orderId + "' onclick='toggleOrderDetails(" + orderId + ")'>Show Details</button></td>");
            out.println("</tr>");
            
            // Hidden details row
            out.println("<tr id='details-" + orderId + "' style='display: none;'>");
            out.println("<td colspan='6'>");
            out.println("<div class='order-details'>");
            
            // Order Financial Breakdown
            out.println("<div class='financial-breakdown'>");
            out.println("<h3>Order Breakdown</h3>");
            
            // Calculate subtotal
            BigDecimal subtotal = totalAmount;
            if (taxAmount != null && shippingCost != null) {
                subtotal = totalAmount.subtract(taxAmount).subtract(shippingCost);
            }
            
            out.println("<div class='breakdown-row'><span>Subtotal:</span><span>" + money.format(subtotal) + "</span></div>");
            
            if (taxAmount != null && taxAmount.doubleValue() > 0) {
                out.println("<div class='breakdown-row'><span>Tax:</span><span>" + money.format(taxAmount) + "</span></div>");
            }
            
            if (shippingCost != null && shippingCost.doubleValue() > 0) {
                out.println("<div class='breakdown-row'><span>Shipping:</span><span>" + money.format(shippingCost) + "</span></div>");
            } else if (shippingCost != null && shippingCost.doubleValue() == 0) {
                out.println("<div class='breakdown-row'><span>Shipping:</span><span>FREE</span></div>");
            }
            
            out.println("<div class='breakdown-row total-row'><span>Grand Total:</span><span><strong>" + money.format(totalAmount) + "</strong></span></div>");
            out.println("</div>");
            
            // Products in this order
            psProducts.setInt(1, orderId);
            try(ResultSet products = psProducts.executeQuery()){
                out.println("<h3>Products Ordered</h3>");
                out.println("<table class='products-table'>");
                out.println("<tr>");
                out.println("<th>Product ID</th>");
                out.println("<th>Product Name</th>");
                out.println("<th>Quantity</th>");
                out.println("<th>Unit Price</th>");
                out.println("<th>Total</th>");
                out.println("</tr>");
                
                while(products.next()){
                    int productId = products.getInt("productId");
                    String productName = products.getString("productName");
                    int quantity = products.getInt("quantity");
                    BigDecimal price = products.getBigDecimal("price");
                    BigDecimal itemTotal = price.multiply(new BigDecimal(quantity));
                    
                    out.println("<tr>");
                    out.println("<td>" + productId + "</td>");
                    out.println("<td>" + productName + "</td>");
                    out.println("<td>" + quantity + "</td>");
                    out.println("<td>" + money.format(price) + "</td>");
                    out.println("<td>" + money.format(itemTotal) + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }
            
            // Shipment information
            psShipments.setInt(1, orderId);
            try(ResultSet shipments = psShipments.executeQuery()){
                boolean hasShipments = false;
                while(shipments.next()) {
                    if (!hasShipments) {
                        out.println("<h3>Shipment Information</h3>");
                        out.println("<div class='shipment-info'>");
                        hasShipments = true;
                    }
                    
                    int shipmentId = shipments.getInt("shipmentId");
                    Timestamp shipmentDate = shipments.getTimestamp("shipmentDate");
                    String trackingNumber = shipments.getString("trackingNumber");
                    String carrier = shipments.getString("carrier");
                    BigDecimal shipCost = shipments.getBigDecimal("shippingCost");
                    BigDecimal shipTax = shipments.getBigDecimal("taxAmount");
                    String status = shipments.getString("status");
                    
                    out.println("<div class='shipment-item'>");
                    out.println("<h4>Shipment #" + shipmentId + "</h4>");
                    
                    // Status badge
                    String statusClass = "status-pending";
                    if ("processing".equalsIgnoreCase(status)) statusClass = "status-processing";
                    else if ("shipped".equalsIgnoreCase(status)) statusClass = "status-shipped";
                    else if ("delivered".equalsIgnoreCase(status)) statusClass = "status-delivered";
                    
                    out.println("<p><strong>Status:</strong> <span class='status-badge " + statusClass + "'>" + status + "</span></p>");
                    
                    if (shipmentDate != null) {
                        out.println("<p><strong>Shipment Date:</strong> " + shipmentDate + "</p>");
                    }
                    if (trackingNumber != null && !trackingNumber.isEmpty()) {
                        out.println("<p><strong>Tracking Number:</strong> " + trackingNumber + "</p>");
                    }
                    if (carrier != null && !carrier.isEmpty()) {
                        out.println("<p><strong>Carrier:</strong> " + carrier + "</p>");
                    }
                    
                    out.println("</div>");
                }
                if (hasShipments) {
                    out.println("</div>");
                } else {
                    out.println("<p><em>No shipment information available.</em></p>");
                }
            }
            
            out.println("</div>"); // Close order-details
            out.println("</td>");
            out.println("</tr>");
        }
        
        if (!hasOrders) {
            out.println("<tr><td colspan='6' style='text-align: center; padding: 40px;'>");
            out.println("<h3>No orders found</h3>");
            out.println("<p>Try adjusting your filters or place your first order!</p>");
            out.println("</td></tr>");
        }
        
        out.println("</tbody>");
        out.println("</table>");
    }
        
} catch(SQLException e){
    out.println("<div style='color: red; padding: 20px; text-align: center;'>");
    out.println("<h3>Database Error</h3>");
    out.println("<p>" + e.getMessage() + "</p>");
    out.println("<p>Please make sure the checkout tables have been created.</p>");
    out.println("</div>");
    e.printStackTrace();
}

%>

<script>
// Initialize - hide all details on page load
document.addEventListener('DOMContentLoaded', function() {
    // All details sections start hidden
    const details = document.querySelectorAll('[id^="details-"]');
    details.forEach(detail => {
        detail.style.display = 'none';
    });
});
</script>

</body>
</html>
