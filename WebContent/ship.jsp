<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ include file="jdbc.jsp" %>
<%@ include file="header.jsp" %>


<html>
<head>
<title>Grocery Shipment Processing</title>
<style>
    body {
        font-family: Arial, Helvetica, sans-serif;
        margin: 0;
        padding: 0;
        background: #e6f3fa; /* light blue background */
        color: #1f3d2b;      /* dark green text */
    }

    h1 {
        text-align: center;
        background: #1f3d2b;  /* dark green */
        color: #e6f3fa;
        padding: 25px 0;
        margin: 0;
        font-size: 2rem;
        letter-spacing: 1px;
    }

    .container {
        max-width: 800px;
        margin: 40px auto;
        background: white;
        border-radius: 12px;
        padding: 30px 40px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        border-left: 6px solid #0c6fb8; /* blue accent */
    }

    .success {
        color: #146c2d; /* green success text */
        background: #d9f3e4;
        border: 1px solid #6bbf88;
        padding: 15px;
        border-radius: 6px;
        margin-bottom: 20px;
    }

    .error {
        color: #8b0d0d;
        background: #f7d4d4;
        border: 1px solid #d38a8a;
        padding: 15px;
        border-radius: 6px;
        margin-bottom: 20px;
    }

    h2 a {
        text-decoration: none;
        color: white;
        background: #0c6fb8;
        padding: 12px 25px;
        border-radius: 50px;
        transition: 0.25s;
        display: inline-block;
        margin-top: 20px;
        border: 2px solid #0c6fb8;
    }

    h2 a:hover {
        background: #e6f3fa;
        color: #0c6fb8;
    }
</style>

</head>
<body>
		
<%@ include file="header.jsp" %>

<%
String orderIdStr = request.getParameter("orderId");
if (orderIdStr == null || orderIdStr.isEmpty()) {
	out.println("<h2 style='color:red;'>Error: No order ID provided.</h2>");
	return;
}

int orderId;
try {
	orderId = Integer.parseInt(orderIdStr);
} catch (NumberFormatException nfe) {
	out.println("<h2 style='color:red;'>Error: Invalid order ID format.</h2>");
	return;
}

try {
	// establish connection (assumes getConnection() initializes 'con' and closeConnection() closes it)
	getConnection();
	con.setAutoCommit(false);

	// verify order exists
	String checkOrderSql = "SELECT * FROM ordersummary WHERE orderId = ?";
	PreparedStatement checkOrderStmt = con.prepareStatement(checkOrderSql);
	checkOrderStmt.setInt(1, orderId);
	ResultSet orderRs = checkOrderStmt.executeQuery();

	if (!orderRs.next()) {
		out.println("<h2 style='color:red;'>Error: Order ID " + orderId + " does not exist.</h2>");
		orderRs.close();
		checkOrderStmt.close();
		con.setAutoCommit(true);
		closeConnection();
		return;
	}
	orderRs.close();
	checkOrderStmt.close();

	// retrieve items for the order
	String itemsSql = "SELECT productId, quantity FROM orderproduct WHERE orderId = ?";
	PreparedStatement itemsStmt = con.prepareStatement(itemsSql);
	itemsStmt.setInt(1, orderId);
	ResultSet itemsRs = itemsStmt.executeQuery();

	class OrderItem {
		int productId;
		int quantity;
		OrderItem(int productId, int quantity) {
			this.productId = productId;
			this.quantity = quantity;
		}
	}
	ArrayList<OrderItem> orderItems = new ArrayList<OrderItem>();

	while (itemsRs.next()) {
		int pid = itemsRs.getInt("productId");
		int qty = itemsRs.getInt("quantity");
		orderItems.add(new OrderItem(pid, qty));
	}

	itemsRs.close();
	itemsStmt.close();

	if (orderItems.isEmpty()) {
		out.println("<h2 style='color:red;'>Error: No items found for Order ID " + orderId + ".</h2>");
		con.setAutoCommit(true);
		closeConnection();
		return;
	}

	// verify inventory for each item in warehouse 1
	boolean sufficientInventory = true;
	String checkInvSql = "SELECT quantity FROM productinventory WHERE productId = ? AND warehouseId = 1";
	PreparedStatement checkInvStmt = con.prepareStatement(checkInvSql);

	for (OrderItem item : orderItems) {
		checkInvStmt.setInt(1, item.productId);
		ResultSet invRs = checkInvStmt.executeQuery();

		if (!invRs.next()) {
			sufficientInventory = false;
			out.println("<h2 style='color:red;'>Error: Product ID " + item.productId + " not found in inventory.</h2>");
		} else {
			int available = invRs.getInt("quantity");
			if (available < item.quantity) {
				sufficientInventory = false;
				out.println("<h2 style='color:red;'>Error: Insufficient inventory for Product ID " + item.productId +
					". Requested: " + item.quantity + ", Available: " + available + ".</h2>");
			}
		}
		invRs.close();

		if (!sufficientInventory) {
			break;
		}
	}
	checkInvStmt.close();

	if (!sufficientInventory) {
		con.rollback();
		con.setAutoCommit(true);
		closeConnection();
		out.println("<h2 style='color:red;'>Shipment processing aborted due to insufficient inventory.</h2>");
		return;
	}

	// create shipment
	String shipSql = "INSERT INTO shipment (shipmentDate, shipmentDesc, warehouseId) VALUES (?, ?, ?)";
	PreparedStatement shipStmt = con.prepareStatement(shipSql, Statement.RETURN_GENERATED_KEYS);
	shipStmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
	shipStmt.setString(2, "Shipment for Order ID " + orderId);
	shipStmt.setInt(3, 1);
	shipStmt.executeUpdate();

	int shipmentId = -1;
	ResultSet genKeys = shipStmt.getGeneratedKeys();
	if (genKeys.next()) {
		shipmentId = genKeys.getInt(1);
	}
	genKeys.close();
	shipStmt.close();

	// update inventory for each item
	String updateInvSql = "UPDATE productinventory SET quantity = quantity - ? WHERE productId = ? AND warehouseId = 1";
	PreparedStatement updateInvStmt = con.prepareStatement(updateInvSql);

	for (OrderItem it : orderItems) {
		updateInvStmt.setInt(1, it.quantity);
		updateInvStmt.setInt(2, it.productId);
		updateInvStmt.executeUpdate();
	}
	updateInvStmt.close();

	con.commit();
	con.setAutoCommit(true);
	closeConnection();

	out.println("<h2 style='color:green;'>Shipment processed successfully for Order ID " + orderId +
		". Shipment ID: " + shipmentId + ".</h2>");

} catch (SQLException e) {
	try {
		if (con != null) {
			con.rollback();
			con.setAutoCommit(true);
		}
	} catch (SQLException e2) {
		// ignore secondary rollback errors
	}
	out.println("<h2 style='color:red;'>Error processing shipment: " + e.getMessage() + "</h2>");
	closeConnection();
}
%>                       				

<h2><a href="shop.html">Back to Main Page</a></h2>

</body>
</html>
