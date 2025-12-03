<!--
A JSP file that encapsulates database connections.

Public methods:
- public void getConnection() throws SQLException
- public void closeConnection() throws SQLException  
-->

<%@ page import="java.sql.*"%>

<%!
	// Connection string from Railway environment variable or local fallback
	private String url;
	private String uid = "";
	private String pw = "";
	
	// Initialize URL from environment variable
	{
		String mysqlUrl = System.getenv("MYSQL_URL");
		if (mysqlUrl != null && !mysqlUrl.isEmpty()) {
			// Using Railway's MYSQL_URL
			url = mysqlUrl;
		} else {
			// Local development fallback to SQL Server
			url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
			uid = "sa";
			pw = "304#sa#pw";
		}
	}
	
	// Do not modify this url
	private String urlForLoadData = url;
	
	// Connection
	private Connection con = null;
%>

<%!
	public void getConnection() throws SQLException 
	{
		try
		{	// Load appropriate driver based on URL
			if (url.contains("mysql")) {
				Class.forName("com.mysql.jdbc.Driver");
			} else if (url.contains("sqlserver")) {
				Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			}
		}
		catch (java.lang.ClassNotFoundException e)
		{
			throw new SQLException("ClassNotFoundException: " +e);
		}
	
		// If uid and pw are set, use them (for SQL Server)
		if (uid != null && !uid.isEmpty() && pw != null && !pw.isEmpty()) {
			con = DriverManager.getConnection(url, uid, pw);
		} else {
			// Railway MYSQL_URL already includes credentials
			con = DriverManager.getConnection(url);
		}
		Statement stmt = con.createStatement();
	}
   
	public void closeConnection() 
	{
		try {
			if (con != null)
				con.close();
			con = null;
		}
		catch (Exception e)
		{ }
	}
%>
