<%@ page session="true" %>
<%@ page import="java.util.*" %>

<%
    String customer = (String) session.getAttribute("authenticatedUser"); 
    
    // Get cart size for badge
    int cartSize = 0;
    if (session.getAttribute("cart") != null) {
        @SuppressWarnings({"unchecked"})
        HashMap<String, ArrayList<Object>> cart = (HashMap<String, ArrayList<Object>>) session.getAttribute("cart");
        cartSize = cart.size();
    }
    
    // Determine current page for active link highlighting
    String currentPage = request.getRequestURI();
    String homeClass = currentPage.contains("index.jsp") ? "active" : "";
    String productsClass = currentPage.contains("listprod.jsp") || currentPage.contains("product.jsp") ? "active" : "";
    String ordersClass = currentPage.contains("listorder.jsp") ? "active" : "";
    String cartClass = currentPage.contains("showcart.jsp") || currentPage.contains("addcart.jsp") ? "active" : "";
    String loginClass = currentPage.contains("login.jsp") ? "active" : "";
    String logoutClass = currentPage.contains("logout.jsp") ? "active" : "";
%>

<style>
  /* Header container */
  .header-container {
    background: linear-gradient(135deg, #05472A 0%, #0a6b3a 100%);          
    padding: 18px 25px;
    margin-bottom: 25px;
    font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    position: relative;
    overflow: hidden;
  }
  
  /* Decorative elements */
  .header-container::before {
    content: '';
    position: absolute;
    top: -50px;
    right: -50px;
    width: 150px;
    height: 150px;
    background: rgba(255,255,255,0.05);
    border-radius: 50%;
    z-index: 1;
  }
  
  .header-container::after {
    content: '';
    position: absolute;
    bottom: -30px;
    left: -30px;
    width: 100px;
    height: 100px;
    background: rgba(255,255,255,0.03);
    border-radius: 50%;
    z-index: 1;
  }

  /* Title */
  .header-title {
    margin: 0;
    color: #f9c0c4;                   
    display: inline-block;
    font-weight: 800;
    font-size: 2.2rem;
    text-shadow: 1px 1px 2px rgba(0,0,0,0.2);
    letter-spacing: 0.5px;
    position: relative;
    z-index: 2;
  }

  /* Navigation container */
  .nav-container {
    float: right;
    margin-top: 10px;
    position: relative;
    z-index: 2;
  }

  /* Navigation links - modern button style */
  nav a {
    display: inline-block;
    padding: 10px 22px;
    margin: 0 6px;
    text-decoration: none;
    font-weight: 600;
    font-size: 16px;
    background-color: #E6F2FF;
    color: #2A61B8 !important;
    border-radius: 25px;
    border: 2px solid #2A61B8;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
  }

  nav a:hover {
    background-color: #2A61B8;
    color: white !important;
    transform: translateY(-2px);
    box-shadow: 0 5px 15px rgba(42, 97, 184, 0.3);
  }

  /* Active page link */
  nav a.active {
    background-color: #2A61B8;
    color: white !important;
    box-shadow: 0 3px 8px rgba(42, 97, 184, 0.4);
  }

  /* Welcome message */
  .welcome-msg {
    background: linear-gradient(135deg, rgba(226, 241, 247, 0.2), rgba(226, 241, 247, 0.1));
    padding: 8px 18px;
    border-radius: 25px;
    border: 1px solid rgba(226, 241, 247, 0.3);
    margin: 0 15px;
    font-weight: 600;
    font-size: 1.1rem;
    color: #e2f1f7;
    backdrop-filter: blur(5px);
    display: inline-block;
  }

  /* Cart badge */
  .cart-badge {
    position: absolute;
    top: -8px;
    right: -5px;
    background: linear-gradient(135deg, #ff4757, #ff3838);
    color: white;
    border-radius: 50%;
    width: 22px;
    height: 22px;
    font-size: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    box-shadow: 0 2px 4px rgba(255, 71, 87, 0.4);
    z-index: 3;
  }

  /* Separator (replaces | characters) */
  .nav-separator {
    display: inline-block;
    width: 1px;
    height: 20px;
    background: rgba(255, 255, 255, 0.2);
    margin: 0 2px;
    vertical-align: middle;
  }

  /* Stats bar */
  .stats-bar {
    margin-top: 15px;
    padding-top: 12px;
    border-top: 1px solid rgba(255, 255, 255, 0.15);
    position: relative;
    z-index: 2;
  }
  
  .stat-item {
    color: #b8e0d2;
    font-size: 0.9rem;
    margin-right: 25px;
    display: inline-block;
  }
  
  .stat-item strong {
    color: #e2f1f7;
  }

  /* Clear fix */
  .clearfix::after {
    content: "";
    clear: both;
    display: table;
  }

  /* Responsive design */
  @media (max-width: 900px) {
    .header-title {
      font-size: 1.8rem;
      display: block;
      text-align: center;
      margin-bottom: 15px;
    }
    
    .nav-container {
      float: none;
      text-align: center;
      margin-top: 15px;
    }
    
    nav a {
      margin: 5px;
      padding: 8px 18px;
      font-size: 15px;
    }
    
    .welcome-msg {
      display: block;
      text-align: center;
      margin: 10px auto;
      max-width: 300px;
    }
    
    .nav-separator {
      display: none;
    }
  }
</style>

<div class="header-container clearfix">
  <h1 class="header-title">Cafe Nadiana</h1>

  <div class="nav-container">
    <% if (customer != null) { %>
        <span class="welcome-msg">Welcome, <%= customer %>!</span>
    <% } %>
    
    <nav>
      <a href='index.jsp' class='<%= homeClass %>'>Home</a>
      <span class="nav-separator"></span>
      <a href='listprod.jsp' class='<%= productsClass %>'>Products</a>
      <span class="nav-separator"></span>
      <a href='listorder.jsp' class='<%= ordersClass %>'>Orders</a>
      <span class="nav-separator"></span>
      
      <!-- Cart link with badge -->
      <a href='showcart.jsp' class='<%= cartClass %>' style="position: relative;">
        Cart
        <% if (cartSize > 0) { %>
          <span class="cart-badge"><%= cartSize %></span>
        <% } %>
      </a>
      
      <span class="nav-separator"></span>
      
      <% if (customer != null) { %>
          <a href="logout.jsp" class='<%= logoutClass %>'>Logout</a>
      <% } else { %>
          <a href="login.jsp" class='<%= loginClass %>'>Login</a>
      <% } %>
    </nav>

    <!-- Stats bar -->
    <div class="stats-bar">
      <span class="stat-item"><strong>25+</strong> Premium Products</span>
      <span class="stat-item"><strong>4.8</strong> Customer Rating</span>
      <span class="stat-item"><strong>Free Shipping</strong> over $50</span>
    </div>
  </div>
</div>

<script>
  // Add subtle animation to cart badge when page loads
  document.addEventListener('DOMContentLoaded', function() {
    const cartBadge = document.querySelector('.cart-badge');
    if (cartBadge) {
      setTimeout(() => {
        cartBadge.style.transform = 'scale(1.2)';
        setTimeout(() => {
          cartBadge.style.transform = 'scale(1)';
        }, 150);
      }, 300);
    }
    
    // Add current page highlighting (fallback)
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('nav a');
    
    navLinks.forEach(link => {
      const href = link.getAttribute('href');
      if (href && (currentPath.includes(href) || 
          (href === 'index.jsp' && currentPath.endsWith('/shop/')))) {
        link.classList.add('active');
      }
    });
  });
</script>