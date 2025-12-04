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

    .checkout-form {
        width: 60%;
        margin: 60px auto;
        padding: 30px;
        background: #FFF7F9; 
        border-radius: 16px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        text-align: center;
    }

    h1 {
        font-size: 1.8rem;
        margin-bottom: 30px;
        color: #1f3d2b;
    }

    form {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 18px;
    }

    input[type="text"],
    input[type="password"] {
        width: 60%;
        padding: 10px 14px;
        border-radius: 10px;
        border: 1px solid #ccc;
        font-size: 1rem;
        outline: none;
        background: white;
    }

    input[type="text"]:focus,
    input[type="password"]:focus {
        border-color: #0c6fb8;
    }

    /* Buttons */
    input[type="submit"],
    input[type="reset"] {
        padding: 10px 25px;
        font-size: 1rem;
        border-radius: 50px;
        border: 1px solid #0c6fb8;
        background: #e2f1f7;
        color: #0c6fb8;
        cursor: pointer;
        transition: 0.25s ease;
        margin: 5px;
    }

    input[type="submit"]:hover,
    input[type="reset"]:hover {
        background: #0c6fb8;
        color: white;
    }
</style>

</head>
<body>

<div class="checkout-form">
    <h1>Enter your customer id and password to complete the transaction:</h1>

    <form method="post" action="order.jsp">
        Customer ID: <input type="text" name="customerId" size="50" required>
        Password: <input type="password" name="password" size="50" required>
        <br><br>
        <input type="submit" value="Submit">
        <input type="reset" value="Reset">
    </form>
</div>

</body>
</html>

