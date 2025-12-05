<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>
<%@ include file="auth.jsp" %>
<!DOCTYPE html>
<html>
<head>
<title>Checkout</title>
<style>
    body {
        font-family: Arial, Helvetica, sans-serif;
        background: #FFE4E1; 
        margin: 0;
        padding: 0;
    }

    .checkout-container {
        width: 90%;
        max-width: 1200px;
        margin: 40px auto;
        padding: 20px;
        display: flex;
        flex-wrap: wrap;
        gap: 30px;
    }

    .checkout-form {
        flex: 1;
        min-width: 300px;
        padding: 30px;
        background: #FFF7F9; 
        border-radius: 16px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }

    .order-summary {
        flex: 1;
        min-width: 300px;
        padding: 30px;
        background: #FFF7F9; 
        border-radius: 16px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }

    h1, h2, h3 {
        color: #1f3d2b;
        margin-bottom: 20px;
    }

    h1 {
        font-size: 1.8rem;
        text-align: center;
        width: 100%;
    }

    .form-section {
        margin-bottom: 30px;
        padding-bottom: 20px;
        border-bottom: 1px solid #e2f1f7;
    }

    .form-row {
        display: flex;
        gap: 15px;
        margin-bottom: 15px;
    }

    .form-group {
        flex: 1;
        display: flex;
        flex-direction: column;
    }

    label {
        margin-bottom: 5px;
        font-weight: bold;
        color: #1f3d2b;
    }

    input[type="text"],
    input[type="password"],
    input[type="email"],
    input[type="tel"],
    select,
    textarea {
        padding: 10px 14px;
        border-radius: 10px;
        border: 1px solid #ccc;
        font-size: 1rem;
        outline: none;
        background: white;
        width: 100%;
        box-sizing: border-box;
    }

    input[type="text"]:focus,
    input[type="password"]:focus,
    select:focus,
    textarea:focus {
        border-color: #0c6fb8;
    }

    .error {
        color: #ff4757;
        font-size: 0.9rem;
        margin-top: 5px;
        display: none;
    }

    .card-icons {
        display: flex;
        gap: 10px;
        margin-top: 10px;
    }

    .card-icon {
        width: 40px;
        height: 25px;
        border: 1px solid #ccc;
        border-radius: 4px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        color: #666;
    }

    /* Buttons */
    .btn {
        padding: 12px 25px;
        font-size: 1rem;
        border-radius: 50px;
        border: none;
        cursor: pointer;
        transition: 0.25s ease;
        margin: 5px;
        text-decoration: none;
        display: inline-block;
        text-align: center;
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

    .order-item {
        display: flex;
        justify-content: space-between;
        padding: 10px 0;
        border-bottom: 1px solid #eee;
    }

    .order-total {
        margin-top: 20px;
        padding-top: 20px;
        border-top: 2px solid #1f3d2b;
    }

    .total-row {
        display: flex;
        justify-content: space-between;
        margin: 10px 0;
        font-size: 1.1rem;
    }

    .grand-total {
        font-size: 1.3rem;
        font-weight: bold;
        color: #1f3d2b;
    }

    .shipping-option {
        border: 1px solid #ccc;
        border-radius: 8px;
        padding: 15px;
        margin: 10px 0;
        cursor: pointer;
        transition: all 0.3s;
    }

    .shipping-option.selected {
        border-color: #0c6fb8;
        background-color: #e2f1f7;
    }

    .shipping-option:hover {
        border-color: #0c6fb8;
    }

    .multiple-shipment {
        background: #f8f9fa;
        padding: 15px;
        border-radius: 8px;
        margin: 15px 0;
    }

    .shipment-group {
        margin-bottom: 15px;
        padding: 10px;
        border: 1px dashed #ccc;
        border-radius: 6px;
    }

    .form-actions {
        text-align: center;
        margin-top: 30px;
    }
</style>

<script>
// Client-side validation
function validateForm() {
    let isValid = true;
    
    // Clear previous errors
    document.querySelectorAll('.error').forEach(el => el.style.display = 'none');
    
    // Validate card number
    const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
    if (!/^\d{13,19}$/.test(cardNumber)) {
        showError('cardNumberError', 'Please enter a valid card number (13-19 digits)');
        isValid = false;
    }
    
    // Validate expiry date
    const expiry = document.getElementById('expiryDate').value;
    if (!/^(0[1-9]|1[0-2])\/\d{2}$/.test(expiry)) {
        showError('expiryError', 'Please enter expiry date in MM/YY format');
        isValid = false;
    }
    
    // Validate CVV
    const cvv = document.getElementById('cvv').value;
    if (!/^\d{3,4}$/.test(cvv)) {
        showError('cvvError', 'Please enter a valid CVV (3-4 digits)');
        isValid = false;
    }
    
    // Validate phone
    const phone = document.getElementById('phone').value;
    if (!/^[\d\s\-\+\(\)]{10,15}$/.test(phone)) {
        showError('phoneError', 'Please enter a valid phone number');
        isValid = false;
    }
    
    // Validate shipping address
    const address1 = document.getElementById('addressLine1').value;
    const city = document.getElementById('city').value;
    const state = document.getElementById('state').value;
    const postalCode = document.getElementById('postalCode').value;
    
    if (!address1.trim()) {
        showError('addressError', 'Address line 1 is required');
        isValid = false;
    }
    if (!city.trim()) {
        showError('cityError', 'City is required');
        isValid = false;
    }
    if (!state) {
        showError('stateError', 'State/Province is required');
        isValid = false;
    }
    if (!postalCode.trim()) {
        showError('postalError', 'Postal/ZIP code is required');
        isValid = false;
    }
    
    return isValid;
}

function showError(elementId, message) {
    const errorEl = document.getElementById(elementId);
    errorEl.textContent = message;
    errorEl.style.display = 'block';
}

function calculateTotals() {
    // Get subtotal from server or calculate from cart
    const subtotal = parseFloat(document.getElementById('subtotal').value) || 0;
    const state = document.getElementById('state').value;
    const shippingMethod = document.querySelector('input[name="shippingMethod"]:checked').value;
    
    // Calculate tax (fetch from server via AJAX would be better)
    let taxRate = 0.07; // Default
    if (state === 'CA') taxRate = 0.0725;
    else if (state === 'NY') taxRate = 0.04;
    else if (state === 'TX') taxRate = 0.0625;
    else if (state === 'ON') taxRate = 0.13;
    else if (state === 'BC') taxRate = 0.12;
    
    // Calculate shipping
    let shippingCost = 5.99; // Default standard
    if (shippingMethod === 'express') shippingCost = 12.99;
    else if (shippingMethod === 'expedited') shippingCost = 8.99;
    else if (shippingMethod === 'free') shippingCost = 0;
    
    // Apply free shipping over $100
    if (subtotal >= 100 && shippingMethod !== 'express') {
        shippingCost = 0;
    }
    
    const taxAmount = subtotal * taxRate;
    const grandTotal = subtotal + taxAmount + shippingCost;
    
    // Update display
    document.getElementById('taxDisplay').textContent = '$' + taxAmount.toFixed(2);
    document.getElementById('shippingDisplay').textContent = '$' + shippingCost.toFixed(2);
    document.getElementById('grandTotalDisplay').textContent = '$' + grandTotal.toFixed(2);
    
    // Update hidden fields
    document.getElementById('taxAmount').value = taxAmount.toFixed(2);
    document.getElementById('shippingCost').value = shippingCost.toFixed(2);
    document.getElementById('grandTotal').value = grandTotal.toFixed(2);
}

function toggleMultipleShipments() {
    const multipleShip = document.getElementById('multipleShipments');
    const shipmentContainer = document.getElementById('multipleShipmentContainer');
    
    if (multipleShip.checked) {
        shipmentContainer.style.display = 'block';
        // Add first additional shipment
        addShipment();
    } else {
        shipmentContainer.style.display = 'none';
        // Remove all additional shipments
        const shipmentGroups = document.querySelectorAll('.shipment-group');
        shipmentGroups.forEach((group, index) => {
            if (index > 0) group.remove();
        });
    }
}

function addShipment() {
    const container = document.getElementById('shipmentGroups');
    const newGroup = document.createElement('div');
    newGroup.className = 'shipment-group';
    newGroup.innerHTML = `
        <h4>Additional Shipment</h4>
        <div class="form-row">
            <div class="form-group">
                <label>Recipient Name:</label>
                <input type="text" name="shipmentName[]" required>
            </div>
            <div class="form-group">
                <label>Phone:</label>
                <input type="tel" name="shipmentPhone[]">
            </div>
        </div>
        <div class="form-group">
            <label>Address:</label>
            <input type="text" name="shipmentAddress[]" required>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>City:</label>
                <input type="text" name="shipmentCity[]" required>
            </div>
            <div class="form-group">
                <label>State/Province:</label>
                <input type="text" name="shipmentState[]" required>
            </div>
            <div class="form-group">
                <label>Postal Code:</label>
                <input type="text" name="shipmentPostal[]" required>
            </div>
        </div>
        <button type="button" class="btn-secondary" onclick="removeShipment(this)">Remove Shipment</button>
    `;
    container.appendChild(newGroup);
}

function removeShipment(button) {
    button.closest('.shipment-group').remove();
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    // Add event listeners for real-time calculation
    document.getElementById('state').addEventListener('change', calculateTotals);
    document.querySelectorAll('input[name="shippingMethod"]').forEach(radio => {
        radio.addEventListener('change', calculateTotals);
    });
    
    // Initialize totals
    calculateTotals();
});

// Format card number as user types
function formatCardNumber(input) {
    let value = input.value.replace(/\D/g, '');
    value = value.replace(/(\d{4})/g, '$1 ').trim();
    input.value = value.substring(0, 19);
}

// Format expiry date
function formatExpiryDate(input) {
    let value = input.value.replace(/\D/g, '');
    if (value.length >= 2) {
        value = value.substring(0, 2) + '/' + value.substring(2, 4);
    }
    input.value = value.substring(0, 5);
}
</script>
</head>
<body>

<%@ include file="header.jsp" %>

<div class="checkout-container">
    <h1>Checkout</h1>
    
    <div class="checkout-form">
        <form method="post" action="processOrder.jsp" onsubmit="return validateForm()">
        
        <!-- Billing Information -->
        <div class="form-section">
            <h2>Billing Information</h2>
            
            <div class="form-row">
                <div class="form-group">
                    <label>First Name:</label>
                    <input type="text" name="firstName" value="<%= session.getAttribute("firstName") != null ? session.getAttribute("firstName") : "" %>" required>
                </div>
                <div class="form-group">
                    <label>Last Name:</label>
                    <input type="text" name="lastName" value="<%= session.getAttribute("lastName") != null ? session.getAttribute("lastName") : "" %>" required>
                </div>
            </div>
            
            <div class="form-group">
                <label>Email:</label>
                <input type="email" name="email" value="<%= session.getAttribute("email") != null ? session.getAttribute("email") : "" %>" required>
            </div>
            
            <div class="form-group">
                <label>Phone:</label>
                <input type="tel" id="phone" name="phone" required>
                <div class="error" id="phoneError"></div>
            </div>
        </div>
        
        <!-- Payment Method -->
        <div class="form-section">
            <h2>Payment Method</h2>
            
            <div class="form-group">
                <label>Card Type:</label>
                <select name="cardType" required>
                    <option value="">Select Card Type</option>
                    <option value="Visa">Visa</option>
                    <option value="Mastercard">Mastercard</option>
                    <option value="American Express">American Express</option>
                    <option value="Discover">Discover</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Card Number:</label>
                <input type="text" id="cardNumber" name="cardNumber" oninput="formatCardNumber(this)" placeholder="1234 5678 9012 3456" required>
                <div class="error" id="cardNumberError"></div>
                <div class="card-icons">
                    <div class="card-icon">Visa</div>
                    <div class="card-icon">MC</div>
                    <div class="card-icon">AmEx</div>
                    <div class="card-icon">Discover</div>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label>Expiry Date (MM/YY):</label>
                    <input type="text" id="expiryDate" name="expiryDate" oninput="formatExpiryDate(this)" placeholder="MM/YY" required>
                    <div class="error" id="expiryError"></div>
                </div>
                <div class="form-group">
                    <label>CVV:</label>
                    <input type="text" id="cvv" name="cvv" maxlength="4" required>
                    <div class="error" id="cvvError"></div>
                </div>
            </div>
            
            <div class="form-group">
                <label>Billing Address:</label>
                <textarea name="billingAddress" rows="3"></textarea>
            </div>
        </div>
        
        <!-- Shipping Information -->
        <div class="form-section">
            <h2>Shipping Information</h2>
            
            <div class="form-group">
                <label>Address Line 1:</label>
                <input type="text" id="addressLine1" name="addressLine1" required>
                <div class="error" id="addressError"></div>
            </div>
            
            <div class="form-group">
                <label>Address Line 2 (Optional):</label>
                <input type="text" name="addressLine2">
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label>City:</label>
                    <input type="text" id="city" name="city" required>
                    <div class="error" id="cityError"></div>
                </div>
                <div class="form-group">
                    <label>State/Province:</label>
                    <select id="state" name="state" required>
                        <option value="">Select State/Province</option>
                        <option value="CA">California</option>
                        <option value="NY">New York</option>
                        <option value="TX">Texas</option>
                        <option value="WA">Washington</option>
                        <option value="FL">Florida</option>
                        <option value="ON">Ontario</option>
                        <option value="BC">British Columbia</option>
                        <option value="AB">Alberta</option>
                    </select>
                    <div class="error" id="stateError"></div>
                </div>
                <div class="form-group">
                    <label>Postal/ZIP Code:</label>
                    <input type="text" id="postalCode" name="postalCode" required>
                    <div class="error" id="postalError"></div>
                </div>
            </div>
            
            <div class="form-group">
                <label>Country:</label>
                <select name="country" required>
                    <option value="US">United States</option>
                    <option value="CA">Canada</option>
                </select>
            </div>
        </div>
        
        <!-- Shipping Options -->
        <div class="form-section">
            <h2>Shipping Options</h2>
            
            <div class="shipping-option" onclick="document.getElementById('standard').click()">
                <input type="radio" id="standard" name="shippingMethod" value="standard" checked onclick="calculateTotals()">
                <label for="standard">
                    <strong>Standard Shipping</strong> (5-7 business days) - $5.99
                </label>
            </div>
            
            <div class="shipping-option" onclick="document.getElementById('expedited').click()">
                <input type="radio" id="expedited" name="shippingMethod" value="expedited" onclick="calculateTotals()">
                <label for="expedited">
                    <strong>Expedited Shipping</strong> (3-4 business days) - $8.99
                </label>
            </div>
            
            <div class="shipping-option" onclick="document.getElementById('express').click()">
                <input type="radio" id="express" name="shippingMethod" value="express" onclick="calculateTotals()">
                <label for="express">
                    <strong>Express Shipping</strong> (1-2 business days) - $12.99
                </label>
            </div>
        </div>
        
        <!-- Multiple Shipments -->
        <div class="form-section">
            <h2>Multiple Shipments</h2>
            
            <div class="form-group">
                <label>
                    <input type="checkbox" id="multipleShipments" name="multipleShipments" onchange="toggleMultipleShipments()">
                    Ship items to multiple addresses
                </label>
            </div>
            
            <div id="multipleShipmentContainer" style="display: none;" class="multiple-shipment">
                <p>Add additional shipping addresses for different items in your order.</p>
                <div id="shipmentGroups">
                    <!-- Additional shipments will be added here -->
                </div>
                <button type="button" class="btn-secondary" onclick="addShipment()">Add Another Shipment</button>
            </div>
        </div>
        
        <!-- Hidden fields for calculations -->
        <input type="hidden" id="subtotal" name="subtotal" value="<%
            // Calculate subtotal from cart
            double subtotal = 0.0;
            if (session.getAttribute("cart") != null) {
                @SuppressWarnings("unchecked")
                HashMap<String, ArrayList<Object>> cart = (HashMap<String, ArrayList<Object>>) session.getAttribute("cart");
                for (ArrayList<Object> item : cart.values()) {
                    double price = (Double) item.get(1);
                    int quantity = (Integer) item.get(2);
                    subtotal += price * quantity;
                }
            }
            out.print(subtotal);
        %>">
        <input type="hidden" id="taxAmount" name="taxAmount">
        <input type="hidden" id="shippingCost" name="shippingCost">
        <input type="hidden" id="grandTotal" name="grandTotal">
        
        <!-- Submit Buttons -->
        <div class="form-actions">
            <input type="submit" class="btn btn-primary" value="Place Order">
            <a href="showcart.jsp" class="btn btn-secondary">Return to Cart</a>
        </div>
        
        </form>
    </div>
    
    <!-- Order Summary -->
    <div class="order-summary">
        <h2>Order Summary</h2>
        
        <%
            NumberFormat currFormat = NumberFormat.getCurrencyInstance();
            double cartSubtotal = 0.0;
            
            if (session.getAttribute("cart") != null) {
                @SuppressWarnings("unchecked")
                HashMap<String, ArrayList<Object>> cart = (HashMap<String, ArrayList<Object>>) session.getAttribute("cart");
                
                for (Map.Entry<String, ArrayList<Object>> entry : cart.entrySet()) {
                    String productId = entry.getKey();
                    ArrayList<Object> item = entry.getValue();
                    String productName = (String) item.get(0);
                    double price = (Double) item.get(1);
                    int quantity = (Integer) item.get(2);
                    double itemTotal = price * quantity;
                    cartSubtotal += itemTotal;
                    
                    out.println("<div class='order-item'>");
                    out.println("<span>" + productName + " x " + quantity + "</span>");
                    out.println("<span>" + currFormat.format(itemTotal) + "</span>");
                    out.println("</div>");
                }
            }
        %>
        
        <div class="order-total">
            <div class="total-row">
                <span>Subtotal:</span>
                <span><%= currFormat.format(cartSubtotal) %></span>
            </div>
            
            <div class="total-row">
                <span>Tax:</span>
                <span id="taxDisplay">$0.00</span>
            </div>
            
            <div class="total-row">
                <span>Shipping:</span>
                <span id="shippingDisplay">$0.00</span>
            </div>
            
            <div class="total-row grand-total">
                <span>Grand Total:</span>
                <span id="grandTotalDisplay">$0.00</span>
            </div>
        </div>
        
        <div style="margin-top: 30px; padding: 15px; background: #f8f9fa; border-radius: 8px;">
            <h3>Shipping Policy</h3>
            <ul style="font-size: 0.9rem; color: #666;">
                <li>Free shipping on orders over $100</li>
                <li>Taxes calculated based on shipping address</li>
                <li>Orders ship within 1-2 business days</li>
                <li>Multiple shipments available for different addresses</li>
            </ul>
        </div>
    </div>
</div>

</body>
</html>