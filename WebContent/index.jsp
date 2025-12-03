<!DOCTYPE html>
<html>
<head>
        <title>Nadeen and Kiana Grocery Main Page</title>

<style>
  body {
	font-family: Arial, Helvetica, sans-serif;
	margin: 0;
	padding: 0;
	background: #FFE4E1; 
	color: #1f3d2b; 
  }

  h1 {
	text-align: center;
	padding: 30px 0;
	margin: 0;
	background: #1f3d2b; 
	color: #FFE4E1;
	font-size: 2.2rem;
	letter-spacing: 1px;
  }

  h2 {
	text-align: center;
	margin-top: 40px;
  }

  a {
	text-decoration: none;
	color: #0c6fb8; 
	background: #e2f1f7;
	padding: 12px 24px;
	border-radius: 50px;    
	font-size: 1.4rem;
	transition: 0.25s ease;
	border: 1px solid #0c6fb8;
  }
</style>
</head>
<body>
<h1 align="center">Welcome to Cafe Nadiana</h1>

<h2 align="center"><a href="login.jsp">Login</a></h2>

<h2 align="center"><a href="listprod.jsp">Begin Shopping</a></h2>

<h2 align="center"><a href="listorder.jsp">List All Orders</a></h2>

<h2 align="center"><a href="customer.jsp">Customer Info</a></h2>

<h2 align="center"><a href="admin.jsp">Administrators</a></h2>

<h2 align="center"><a href="logout.jsp">Log out</a></h2>


<%
	String userName = (String) session.getAttribute("authenticatedUser");
	if (userName != null)
		out.println("<h3 align=\"center\">Signed in as: "+userName+"</h3>");
%>
</body>
</html>



