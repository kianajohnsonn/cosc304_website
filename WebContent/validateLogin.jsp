<%@ page language="java" import="java.io.*,java.sql.*"%>
<%@ page import="java.util.*" %>
<%@ include file="jdbc.jsp" %>
<%-- CHANGED: Don't include cartPersistence.jsp here, include it after we get connection --%>
<%
	String authenticatedUser = null;
	session = request.getSession(true);

String returnUrl = request.getParameter("returnUrl");

try
	{
		authenticatedUser = validateLogin(out,request,session);
	}
	catch(IOException e)
	{	System.err.println(e); }

  if(authenticatedUser != null) {
        if (returnUrl != null && !returnUrl.trim().equals("")) {
            response.sendRedirect(returnUrl);   // go back to original page (e.g., customer.jsp)
        } else {
            response.sendRedirect("index.jsp"); // default: home page
        }
    }
    else {
        response.sendRedirect("login.jsp");     // login failed
    }

%>


<%!
	String validateLogin(JspWriter out,HttpServletRequest request, HttpSession session) throws IOException, SQLException
	{
		String username = request.getParameter("userid");
		String password = request.getParameter("password");
		String retStr = null;

		if(username == null || password == null)
				return null;
		if((username.length() == 0) || (password.length() == 0))
				return null;

		try 
		{
			getConnection();
			
			String sql = "SELECT customerId FROM customer WHERE userid = ? AND password = ?";
			PreparedStatement pstmt = con.prepareStatement(sql);
			pstmt.setString(1, username);
			pstmt.setString(2, password);
			ResultSet rs = pstmt.executeQuery();
			if (rs.next()){
				retStr = username;
				int customerId = rs.getInt("customerId");
				
				// Load cart from database after successful login
				// Create a local instance of cart methods
				HashMap<String, ArrayList<Object>> dbCart = loadCartFromDatabase(con, customerId);
				
				if (!dbCart.isEmpty()) {
					// Replace session cart with database cart
					session.setAttribute("productList", dbCart);
					
					// Set success message with cart info
					session.setAttribute("loginMessage", "Login successful! " + dbCart.size() + " items from your saved cart have been loaded.");
				} else {
					session.setAttribute("loginMessage", "Login successful!");
				}
			}
			rs.close();
			pstmt.close();
		} 
		catch (SQLException ex) {
			out.println(ex);
		}
		finally
		{
			closeConnection();
		}	
		
		if(retStr != null)
		{	session.removeAttribute("loginMessage");
			session.setAttribute("authenticatedUser",username);
		}
		else
			session.setAttribute("loginMessage","Could not connect to the system using that username/password.");

		return retStr;
	}
	
	// Copy the cart methods directly into validateLogin.jsp to avoid include issues
	public HashMap<String, ArrayList<Object>> loadCartFromDatabase(Connection con, int customerId) throws SQLException {
        HashMap<String, ArrayList<Object>> cart = new HashMap<>();
        
        String sql = "SELECT ic.productId, ic.quantity, ic.price, p.productName, p.productImageURL " +
                     "FROM incart ic " +
                     "JOIN product p ON ic.productId = p.productId " +
                     "WHERE ic.orderId = ? " +
                     "ORDER BY ic.productId";
        
        PreparedStatement pstmt = con.prepareStatement(sql);
        pstmt.setInt(1, -customerId);
        ResultSet rs = pstmt.executeQuery();
        
        while (rs.next()) {
            String productId = Integer.toString(rs.getInt("productId"));
            String productName = rs.getString("productName");
            double productPrice = rs.getDouble("price");
            int quantity = rs.getInt("quantity");
            String productImageURL = rs.getString("productImageURL");
            
            ArrayList<Object> item = new ArrayList<>();
            item.add(productId);
            item.add(productName);
            item.add(productPrice);
            item.add(quantity);
            item.add(productImageURL);
            
            cart.put(productId, item);
        }
        
        rs.close();
        pstmt.close();
        
        return cart;
    }
%>