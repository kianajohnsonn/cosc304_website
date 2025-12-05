<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>
<%@ include file="auth.jsp" %>

<%
    // Server-side validation
    List<String> errors = new ArrayList<>();
    
    // Get form data
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String cardType = request.getParameter("cardType");
    String cardNumber = request.getParameter("cardNumber");
    String expiryDate = request.getParameter("expiryDate");
    String cvv = request.getParameter("cvv");
    String addressLine1 = request.getParameter("addressLine1");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String postalCode = request.getParameter("postalCode");
    String country = request.getParameter("country");
    String shippingMethod = request.getParameter("shippingMethod");
    double subtotal = Double.parseDouble(request.getParameter("subtotal"));
    double taxAmount = Double.parseDouble(request.getParameter("taxAmount"));
    double shippingCost = Double.parseDouble(request.getParameter("shippingCost"));
    double grandTotal = Double.parseDouble(request.getParameter("grandTotal"));
    
    // Validation
    if (firstName == null || firstName.trim().isEmpty()) errors.add("First name is required");
    if (lastName == null || lastName.trim().isEmpty()) errors.add("Last name is required");
    if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) errors.add("Valid email is required");
    if (cardNumber == null || !cardNumber.replace(" ", "").matches("^\\d{13,19}$")) errors.add("Valid card number is required");
    if (expiryDate == null || !expiryDate.matches("^(0[1-9]|1[0-2])/\\d{2}$")) errors.add("Valid expiry date (MM/YY) is required");
    if (cvv == null || !cvv.matches("^\\d{3,4}$")) errors.add("Valid CVV is required");
    if (addressLine1 == null || addressLine1.trim().isEmpty()) errors.add("Address is required");
    
    String userName = (String) session.getAttribute("authenticatedUser");
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!errors.isEmpty()) {
        session.setAttribute("checkoutErrors", errors);
        response.sendRedirect("checkout.jsp");
        return;
    }
    
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        con = DriverManager.getConnection(url, uid, pw);
        con.setAutoCommit(false); // Start transaction
        
        // Get customer ID
        String custSql = "SELECT customerId FROM customer WHERE userid = ?";
        pstmt = con.prepareStatement(custSql);
        pstmt.setString(1, userName);
        rs = pstmt.executeQuery();
        
        if (!rs.next()) {
            errors.add("Customer not found");
            session.setAttribute("checkoutErrors", errors);
            response.sendRedirect("checkout.jsp");
            return;
        }
        
        int customerId = rs.getInt("customerId");
        rs.close();
        pstmt.close();
        
        // Save payment method
        String paymentSql = "INSERT INTO PaymentMethod (customerId, cardType, cardNumber, expiryDate, cvv, billingAddress) " +
                           "VALUES (?, ?, ?, ?, ?, ?)";
        pstmt = con.prepareStatement(paymentSql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setInt(1, customerId);
        pstmt.setString(2, cardType);
        pstmt.setString(3, cardNumber.replace(" ", ""));
        pstmt.setString(4, expiryDate);
        pstmt.setString(5, cvv);
        pstmt.setString(6, addressLine1);
        pstmt.executeUpdate();
        
        ResultSet paymentKeys = pstmt.getGeneratedKeys();
        int paymentMethodId = 0;
        if (paymentKeys.next()) {
            paymentMethodId = paymentKeys.getInt(1);
        }
        paymentKeys.close();
        pstmt.close();
        
        // Save shipping address
        String addressSql = "INSERT INTO ShippingAddress (customerId, fullName, addressLine1, city, state, postalCode, country, phone) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        pstmt = con.prepareStatement(addressSql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setInt(1, customerId);
        pstmt.setString(2, firstName + " " + lastName);
        pstmt.setString(3, addressLine1);
        pstmt.setString(4, city);
        pstmt.setString(5, state);
        pstmt.setString(6, postalCode);
        pstmt.setString(7, country);
        pstmt.setString(8, phone);
        pstmt.executeUpdate();
        
        ResultSet addressKeys = pstmt.getGeneratedKeys();
        int shippingAddressId = 0;
        if (addressKeys.next()) {
            shippingAddressId = addressKeys.getInt(1);
        }
        addressKeys.close();
        pstmt.close();
        
        // Create order summary
        String orderSql = "INSERT INTO ordersummary (orderDate, totalAmount, shiptoAddress, shiptoCity, " +
                         "shiptoState, shiptoPostalCode, shiptoCountry, customerId, shippingAddressId, " +
                         "paymentMethodId, taxAmount, shippingCost) " +
                         "VALUES (GETDATE(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        pstmt = con.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setDouble(1, grandTotal);
        pstmt.setString(2, addressLine1);
        pstmt.setString(3, city);
        pstmt.setString(4, state);
        pstmt.setString(5, postalCode);
        pstmt.setString(6, country);
        pstmt.setInt(7, customerId);
        pstmt.setInt(8, shippingAddressId);
        pstmt.setInt(9, paymentMethodId);
        pstmt.setDouble(10, taxAmount);
        pstmt.setDouble(11, shippingCost);
        pstmt.executeUpdate();
        
        ResultSet orderKeys = pstmt.getGeneratedKeys();
        int orderId = 0;
        if (orderKeys.next()) {
            orderId = orderKeys.getInt(1);
        }
        orderKeys.close();
        pstmt.close();
        
        // Get cart items
        HashMap<String, ArrayList<Object>> cart = null;
        if (session.getAttribute("cart") != null) {
            cart = (HashMap<String, ArrayList<Object>>) session.getAttribute("cart");
        }
        
        if (cart != null && !cart.isEmpty()) {
            // Insert order items
            String itemSql = "INSERT INTO orderproduct (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)";
            pstmt = con.prepareStatement(itemSql);
            
            for (Map.Entry<String, ArrayList<Object>> entry : cart.entrySet()) {
                String productId = entry.getKey();
                ArrayList<Object> item = entry.getValue();
                double price = (Double) item.get(1);
                int quantity = (Integer) item.get(2);
                
                pstmt.setInt(1, orderId);
                pstmt.setInt(2, Integer.parseInt(productId));
                pstmt.setInt(3, quantity);
                pstmt.setDouble(4, price);
                pstmt.executeUpdate();
            }
            pstmt.close();
            
            // Create shipment
            String shipmentSql = "INSERT INTO OrderShipment (orderId, shippingCost, taxAmount, addressId, status) " +
                                "VALUES (?, ?, ?, ?, 'Processing')";
            pstmt = con.prepareStatement(shipmentSql);
            pstmt.setInt(1, orderId);
            pstmt.setDouble(2, shippingCost);
            pstmt.setDouble(3, taxAmount);
            pstmt.setInt(4, shippingAddressId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Check for multiple shipments
            String[] shipmentNames = request.getParameterValues("shipmentName[]");
            if (shipmentNames != null && shipmentNames.length > 0) {
                for (int i = 0; i < shipmentNames.length; i++) {
                    String shipName = shipmentNames[i];
                    String shipAddress = request.getParameterValues("shipmentAddress[]")[i];
                    String shipCity = request.getParameterValues("shipmentCity[]")[i];
                    String shipState = request.getParameterValues("shipmentState[]")[i];
                    String shipPostal = request.getParameterValues("shipmentPostal[]")[i];
                    
                    // Create additional shipment
                    String multiShipSql = "INSERT INTO OrderShipment (orderId, shippingCost, taxAmount, addressId, status) " +
                                         "VALUES (?, ?, ?, ?, 'Processing')";
                    pstmt = con.prepareStatement(multiShipSql);
                    pstmt.setInt(1, orderId);
                    pstmt.setDouble(2, shippingCost / (shipmentNames.length + 1)); // Split cost
                    pstmt.setDouble(3, taxAmount / (shipmentNames.length + 1)); // Split tax
                    // Note: Would need to save additional addresses first
                    pstmt.setInt(4, shippingAddressId); // Using main address for now
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            }
        }
        
        con.commit(); // Commit transaction
        
        // Clear cart
        session.removeAttribute("cart");
        
        // Redirect to confirmation page
        response.sendRedirect("orderConfirmation.jsp?orderId=" + orderId);
        
    } catch (SQLException e) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException ex) {}
        }
        errors.add("Database error: " + e.getMessage());
        session.setAttribute("checkoutErrors", errors);
        response.sendRedirect("checkout.jsp");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>