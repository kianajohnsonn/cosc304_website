<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="auth.jsp"%>
<%@ include file="jdbc.jsp" %>

<!DOCTYPE html>
<html>
<head>
<title>Customer Page</title>
<style>
    /* Page Background */
    body {
        margin: 0;
        padding: 0;
        font-family: Arial, Helvetica, sans-serif;

        /* Soft gradient background */
        background: linear-gradient(
            135deg,
            #e2f1f7 0%,
            #b7e3f7 45%,
            #e2f1f7 100%
        );
        background-attachment: fixed;
        color: #1f3d2b;
    }

    /* Top Navigation Header */
    .header {
        width: 100%;
        background: #1f3d2b; /* dark green */
        padding: 20px;
        text-align: center;
        color: #e2f1f7;     /* light blue */
        font-size: 1.8rem;
        letter-spacing: 1px;
        font-weight: bold;
        box-shadow: 0 3px 10px rgba(0,0,0,0.25);
    }

    /* Center Card Container */
    .customer-card {
        width: 65%;
        margin: 40px auto;
        background: #ffffff;
        border-radius: 16px;
        padding: 30px 40px;
        border-left: 10px solid #1f3d2b;
        border-top: 2px solid #b7e3f7;

        box-shadow: 0 8px 24px rgba(0,0,0,0.12);
    }

    /* Card Title */
    .customer-card h2 {
        margin-top: 0;
        padding-bottom: 10px;
        border-bottom: 3px solid #b7e3f7;
        color: #1f3d2b;
    }

    /* Customer field rows */
    .customer-field {
        margin: 18px 0;
        padding: 12px 0;
        border-bottom: 1px solid #e2f1f7;
    }

    .customer-field strong {
        display: inline-block;
        width: 180px;
        color: #0c6fb8; /* nice accent blue */
        font-weight: bold;
    }

    /* Buttons */
    a.btn {
        display: inline-block;
        padding: 12px 26px;
        margin-top: 25px;
        background: #0c6fb8;
        color: white;
        text-decoration: none;
        font-size: 1.05rem;
        border-radius: 40px;
        transition: 0.3s ease;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }

    a.btn:hover {
        background: #074f87;
    }

    /* Error message */
    .error {
        margin-top: 30px;
        text-align: center;
        color: red;
        font-size: 1.4rem;
        font-weight: bold;
    }
</style>

</head>
<body>

<%
	String userName = (String) session.getAttribute("authenticatedUser");

	if(userName == null ) {
		String loginMessage = "You must be logged in to access the customer page.";
		out.println("<p><a href='login.jsp'>Go to Login Page</a></p>");
	} else {
		String sql = "SELECT * FROM customer WHERE userid = ?";

		try {
			getConnection();
			PreparedStatement pstmt = con.prepareStatement(sql);
			pstmt.setString(1, userName);
			ResultSet rs = pstmt.executeQuery();

			if (rs.next()){
				int customerId = rs.getInt("customerId");
				String firstName = rs.getString("firstName");
				String lastName = rs.getString("lastName");
				String email = rs.getString("email");
				String phone = rs.getString("phonenum");
				String address = rs.getString("address");
				String city = rs.getString("city");
				String state = rs.getString("state");
				String postalCode = rs.getString("postalCode");
				String country = rs.getString("country");
				String userid = rs.getString("userid");

				out.println("<h1>Customer Information</h1>");
				out.println("<p><strong>Customer ID:</strong> " + customerId + "</p>");
				out.println("<p><strong>Username:</strong> " + userid + "</p>");
				out.println("<p><strong>Name:</strong> " + firstName + " " + lastName + "</p>");
				out.println("<p><strong>Email:</strong> " + email + "</p>");
				out.println("<p><strong>Phone:</strong> " + phone + "</p>");
				out.println("<p><strong>Address:</strong> " + address + ", " + city + ", " + state + " " + postalCode + ", " + country + "</p>");
			} else {
				out.println("<p>Error: Customer information not found.</p>");
			}
			rs.close();
			pstmt.close();
		} catch (SQLException e) {
			out.println("<p>Error retrieving customer information: " + e.getMessage() + "</p>");
		} finally {
			closeConnection();
		}
	}

%>

</body>
</html>

