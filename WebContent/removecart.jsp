<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%
String id = request.getParameter("id");
if (id != null) {
    HashMap<String, ArrayList<Object>> productList = 
        (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
    if (productList != null) {
        productList.remove(id);
        session.setAttribute("productList", productList);
    }
}
response.sendRedirect("showcart.jsp");
%>