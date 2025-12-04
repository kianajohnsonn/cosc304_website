<%@ include file="header.jsp" %>

<%
String authenticatedUser = (String) session.getAttribute("authenticatedUser");
if (authenticatedUser != null) {
    // User is already logged in → send them where they were trying to go
    String returnUrl = request.getParameter("returnUrl");
    if (returnUrl == null || returnUrl.trim().isEmpty()) {
        returnUrl = "index.jsp";   // default if no returnUrl
    }
    response.sendRedirect(returnUrl);
    return; // stop rendering the rest of login.jsp
}
%>


<!DOCTYPE html>
<html>
<head>
<title>Login Screen</title>
<style>
    body {
        font-family: Arial, Helvetica, sans-serif;

        /* Light pink background */
        background: #ffe6ef;     
        margin: 0;
        padding: 0;

        /* Dark pink text */
        color: #b30059;         
    }

    h3 {
        text-align: center;
        margin-top: 40px;
        font-size: 1.8rem;

        /* Dark pink heading */
        color: #b30059;
    }

    .login-container {
        margin: 60px auto;
        width: 350px;
        background: white;
        padding: 25px 30px;
        border-radius: 15px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        text-align: center;
    }

    table {
        margin: 0 auto;
    }

    input[type="text"],
    input[type="password"] {
        width: 180px;
        padding: 8px;
        margin: 5px 0;
        border: 1px solid #cc6699;   /* Soft pink border */
        border-radius: 6px;
        font-size: 1rem;
    }

    .submit {
        padding: 10px 22px;
        margin-top: 15px;

        /* Dark pink button */
        background: #b30059;
        color: white;

        border: none;
        border-radius: 50px;
        font-size: 1rem;
        cursor: pointer;
        transition: 0.2s ease;
    }

    .submit:hover {
        background: #99004d;    /* Darker hover pink */
    }

    .error-message {
        color: #d4005c;         /* Strong pink-red for errors */
        margin-bottom: 12px;
        font-weight: bold;
    }
</style>


</head>
<body>

<div style="margin:0 auto;text-align:center;display:inline">

<h3>Please Login to System</h3>

<%
// Print prior error login message if present
if (session.getAttribute("loginMessage") != null)
	out.println("<p>"+session.getAttribute("loginMessage").toString()+"</p>");
%>

<br>
<form name="MyForm" method="post" action="validateLogin.jsp">
    <input type="hidden" name="returnUrl"
           value="<%= request.getParameter("returnUrl") == null ? "" : request.getParameter("returnUrl") %>">

    <table style="display:inline">
        <tr>
            <td><div align="right"><font face="Arial, Helvetica, sans-serif" size="2">Username:</font></div></td>
            <td><input type="text" name="userid"  size="10" maxlength="10"></td>
        </tr>
        <tr>
            <td><div align="right"><font face="Arial, Helvetica, sans-serif" size="2">Password:</font></div></td>
            <td><input type="password" name="password" size="10" maxlength="10"></td>
        </tr>
    </table>
    <br/>
    <input class="submit" type="submit" name="Submit2" value="Log In">
</form>


</div>

</body>
</html>

