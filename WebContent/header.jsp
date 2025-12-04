<%@ page session="true" %>

<%
    String customer = (String) session.getAttribute("authenticatedUser"); 
%>
<style>
  /* Make nav links look like rounded light-blue buttons */
  nav a {
    display: inline-block;
    padding: 8px 26px;
    margin: 0 10px;
    text-decoration: none;
    font-weight: bold;
    font-size: 20px;

    background-color: #E6F2FF;    /* light blue pill */
    color: #2A61B8 !important;    /* blue text */
    border-radius: 999px;         /* fully rounded */
    border: 2px solid #2A61B8;    /* blue border */
  }

  nav a:hover {
    background-color: #F5FAFF;    /* slightly lighter hover */
  }
</style>

<div style="
  background-color: #05472A;          
  padding: 15px 20px;
  margin-bottom: 25px;
  font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
">
  <h1 style="
    margin: 0;
    color: #f9c0c4;                   
    display: inline-block;
    font-weight: bold;
  ">
    Cafe Nadiana
  </h1>

  <nav style="
    float: right;
    margin-top: 12px;
  ">

   <% if (customer != null) { %>
        <span style="margin: 0 10px; color: #e2f1f7; font-weight: bold; font-size: x-large;">
            Welcome, <%= customer %>!
        </span>
    <% } %>
  
    
    <a href='index.jsp' style='margin: 0 10px; text-decoration: none; font-weight: bold;'>Home</a> |
    <a href='listprod.jsp' style='margin: 0 10px; text-decoration: none; font-weight: bold;'>Products</a> |
    <a href='listorder.jsp' style='margin: 0 10px; text-decoration: none; font-weight: bold;'>Orders</a> |
    <a href='showcart.jsp' style='margin: 0 10px; text-decoration: none; font-weight: bold;'>Cart</a>

    <% if (customer != null) { %>|
        <a href="logout.jsp" style="margin: 0 10px; text-decoration: none; font-weight: bold;">
            Logout
        </a>
    <% } else { %>
        |
        <a href="login.jsp" style="margin: 0 10px; text-decoration: none; font-weight: bold;">
            Login
        </a>
    <% } %>

  </nav>

  <div style="clear: both;"></div>
</div>
