<%@ page import="java.sql.*" %>
<%@ page import="java.util.Scanner" %>
<%@ page import="java.io.File" %>
<%@ include file="jdbc.jsp" %>

<html>
<head>
<title>Loading Data</title>
</head>
<body>

<%
out.print("<h1>Connecting to database.</h1><br><br>");

try
{	// Load appropriate driver based on URL
	if (url.contains("mysql")) {
		Class.forName("com.mysql.cj.jdbc.Driver");
	} else if (url.contains("sqlserver")) {
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
	}
}
catch (java.lang.ClassNotFoundException e)
{
    throw new SQLException("ClassNotFoundException: " +e);
}

// Determine which DDL file to use
String fileName;
if (url.contains("mysql")) {
	fileName = "/usr/local/tomcat/webapps/shop/ddl/MySQL_orderdb.ddl";
} else {
	fileName = "/usr/local/tomcat/webapps/shop/ddl/SQLServer_orderdb.ddl";
}

Connection con = null;
try
{	
	// Use flexible connection logic
	if (uid != null && !uid.isEmpty() && pw != null && !pw.isEmpty()) {
		con = DriverManager.getConnection(url, uid, pw);
	} else {
		// Railway MYSQL_URL already includes credentials
		con = DriverManager.getConnection(url);
	}
	
    // Create statement
    Statement stmt = con.createStatement();
    
    Scanner scanner = new Scanner(new File(fileName));
    // Read commands separated by ;
    scanner.useDelimiter(";");
    while (scanner.hasNext())
    {
        String command = scanner.next();
        if (command.trim().equals("") || command.trim().equals("go"))
            continue;
        
        if (command.trim().indexOf("go") == 0)
            command = command.substring(3, command.length());

        // Hack to make sure variable is declared (SQL Server specific)
        if (url.contains("sqlserver") && command.contains("INSERT INTO ordersummary") && !command.contains("DECLARE @orderId"))
            command = "DECLARE @orderId int \n"+command;

        out.print(command+"<br>");        // Uncomment if want to see commands executed
        try
        {
            stmt.execute(command);
        }
        catch (Exception e)
        {	// Keep running on exception.  This is mostly for DROP TABLE if table does not exist.
            if (!e.toString().contains("Database 'orders' already exists"))    // Ignore error when database already exists
                out.println(e+"<br>");
        }
    }	 
    scanner.close();
    
    out.print("<br><br><h1>Database loaded.</h1>");
}
catch (Exception e)
{
    out.print(e);
}
finally {
	if (con != null) {
		try { con.close(); } catch (Exception e) { }
	}
}  
%>
</body>
</html> 
