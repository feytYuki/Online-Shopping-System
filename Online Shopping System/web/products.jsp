<%-- 
    Document   : products
    Created on : 6 Jun 2025, 12:33:54 PM
    Author     : User
--%>

<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Catalog - ON9Shop</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Arial', sans-serif;
        }

        body {
            background-color: #f5f5f5;
            color: #333;
            line-height: 1.6;
        }

        header {
            background-color: #fff;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
        }

        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .logo {
            font-size: 1.8rem;
            font-weight: bold;
            color: #2c3e50;
            text-decoration: none;
            display: flex;
            align-items: center;
        }

        .logo img {
            height: 40px;
            margin-right: 10px;
        }

        .nav-links {
            display: flex;
            list-style: none;
        }

        .nav-links li {
            margin-left: 2rem;
        }

        .nav-links a {
            text-decoration: none;
            color: #2c3e50;
            font-weight: 500;
            transition: color 0.3s;
        }

        .nav-links a:hover {
            color: #e74c3c;
        }

        .login-btn {
            background-color: #e74c3c;
            color: white;
            border: none;
            padding: 0.6rem 1.2rem;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .login-btn:hover {
            background-color: #c0392b;
        }

        .search-container {
            background-color: #2c3e50;
            padding: 1.5rem 0;
            margin-top: 70px;
        }

        .search-form {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
            display: flex;
        }

        .search-form input {
            flex: 1;
            padding: 0.8rem 1rem;
            border: none;
            border-radius: 4px 0 0 4px;
            font-size: 1rem;
        }

        .search-form button {
            background-color: #e74c3c;
            color: white;
            border: none;
            padding: 0 1.5rem;
            border-radius: 0 4px 4px 0;
            cursor: pointer;
            font-size: 1rem;
            transition: background-color 0.3s;
        }

        .search-form button:hover {
            background-color: #c0392b;
        }

        .main-content {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 2rem;
        }

        .page-title {
            font-size: 2rem;
            color: #2c3e50;
            margin-bottom: 1.5rem;
            padding-top: 1rem;
        }

        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }

        .product-card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            transition: transform 0.3s;
            padding: 1.5rem;
        }

        .product-card:hover {
            transform: translateY(-5px);
        }

        .product-img {
            height: 200px;
            width: 100%;
            object-fit: cover;
            border-radius: 4px;
            margin-bottom: 1rem;
        }

        .product-title {
            font-size: 1.2rem;
            margin-bottom: 0.5rem;
            color: #2c3e50;
        }

        .product-description {
            color: #7f8c8d;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }

        .product-price {
            font-size: 1.1rem;
            font-weight: bold;
            color: #e74c3c;
            margin-bottom: 0.5rem;
        }

        .product-stock {
            font-size: 0.9rem;
            color: #27ae60;
            margin-bottom: 1rem;
        }

        .product-stock.low {
            color: #e74c3c;
        }

        .add-to-cart {
            background-color: #3498db;
            color: white;
            border: none;
            padding: 0.6rem 1rem;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.3s;
        }

        .add-to-cart:hover {
            background-color: #2980b9;
        }

        .add-to-cart:disabled {
            background-color: #95a5a6;
            cursor: not-allowed;
        }

        footer {
            background-color: #2c3e50;
            color: #ecf0f1;
            padding: 3rem 0;
            margin-top: 3rem;
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 2rem;
        }

        .footer-column h3 {
            font-size: 1.3rem;
            margin-bottom: 1.5rem;
            color: #fff;
        }

        .footer-column ul {
            list-style: none;
        }

        .footer-column ul li {
            margin-bottom: 0.8rem;
        }

        .footer-column ul li a {
            color: #bdc3c7;
            text-decoration: none;
            transition: color 0.3s;
        }

        .footer-column ul li a:hover {
            color: #e74c3c;
        }

        .copyright {
            text-align: center;
            padding-top: 2rem;
            margin-top: 2rem;
            border-top: 1px solid #34495e;
            color: #bdc3c7;
        }

        @media (max-width: 768px) {
            .navbar {
                padding: 1rem;
                flex-direction: column;
                align-items: flex-start;
            }

            .nav-links {
                margin-top: 1rem;
                width: 100%;
                justify-content: space-between;
            }

            .nav-links li {
                margin-left: 0;
            }

            .search-container {
                margin-top: 120px;
            }

            .search-form {
                padding: 0 1rem;
            }
        }
    </style>
</head>
<body>
    <header>
        <nav class="navbar">
            <a href="HomePage.html" class="logo">
                <img src="image/umtlogo.jpg" alt="Logo">
                ON9Shop
            </a>
            <ul class="nav-links">
                <li><a href="HomePage.html">Home</a></li>
                <li><a href="products.jsp">Products</a></li>
                <li><a href="#">Categories</a></li>
                <li><a href="Cart.jsp">Cart</a></li>
                <li><a href="order.jsp">Order</a></li>
            </ul>
            <button class="login-btn" onclick="window.location.href = 'login.jsp'">Login</button>
        </nav>
    </header>

    <div class="search-container">
        <form method="get" action="products.jsp" class="search-form">
            <input type="text" name="search" placeholder="Search products..."/>
            <button type="submit">Search</button>
        </form>
    </div>

    <div class="main-content">
        <h1 class="page-title">Our Products</h1>
        <div class="products-grid">
            <%
                String search = request.getParameter("search");
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/shopping", "root", "");
                    
                    String sql = "SELECT product_id, name, price, description, image_url, stock_quantity FROM products";
                    if (search != null && !search.trim().isEmpty()) {
                        sql += " WHERE name LIKE ? OR description LIKE ?";
                        pstmt = conn.prepareStatement(sql);
                        String likeSearch = "%" + search + "%";
                        pstmt.setString(1, likeSearch);
                        pstmt.setString(2, likeSearch);
                    } else {
                        pstmt = conn.prepareStatement(sql);
                    }
                    
                    rs = pstmt.executeQuery();
                    
                    while (rs.next()) {
                        String productId = rs.getString("product_id");
                        String name = rs.getString("name");
                        double price = rs.getDouble("price");
                        String description = rs.getString("description");
                        String imageUrl = rs.getString("image_url");
                        int stock = rs.getInt("stock_quantity");
            %>
            <div class="product-card">
                <img src="<%= imageUrl %>" alt="<%= name %>" class="product-img"/>
                <h3 class="product-title"><%= name %></h3>
                <p class="product-description"><%= description %></p>
                <p class="product-price">RM <%= String.format("%.2f", price) %></p>
                <p class="product-stock <%= stock < 5 ? "low" : "" %>">
                    Stock: <%= stock %> <%= stock < 5 ? "(Low Stock)" : "" %>
                </p>
                <form method="post" action="AddToCartServlet">
                    <input type="hidden" name="product_id" value="<%= productId %>">
                    <input type="hidden" name="name" value="<%= name %>">
                    <input type="hidden" name="price" value="<%= price %>">
                    <input type="hidden" name="quantity" value="1">
                    <button type="submit" class="add-to-cart" <%= stock == 0 ? "disabled" : "" %>>
                        <%= stock == 0 ? "Out of Stock" : "Add to Cart" %>
                    </button>
                </form>
            </div>
            <%
                    }
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error: " + e.getMessage() + "</div>");
                } finally {
                    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
                    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
                    try { if (conn != null) conn.close(); } catch (Exception ignored) {}
                }
            %>
        </div>
    </div>

    <footer>
        <div class="footer-content">
            <div class="footer-column">
                <h3>ON9Shop</h3>
                <p>Your one-stop shop for all your needs. Quality products at affordable prices.</p>
            </div>
            <div class="footer-column">
                <h3>Quick Links</h3>
                <ul>
                    <li><a href="HomePage.html">Home</a></li>
                    <li><a href="products.jsp">Products</a></li>
                    <li><a href="#">About Us</a></li>
                    <li><a href="#">Contact</a></li>
                </ul>
            </div>
            <div class="footer-column">
                <h3>Customer Service</h3>
                <ul>
                    <li><a href="#">FAQ</a></li>
                    <li><a href="#">Shipping Policy</a></li>
                    <li><a href="#">Returns & Refunds</a></li>
                    <li><a href="#">Track Order</a></li>
                </ul>
            </div>
            <div class="footer-column">
                <h3>Contact Us</h3>
                <ul>
                    <li>Email: info@ON9Shop.com</li>
                    <li>Phone: +60 0123456789</li>
                    <li>Address: Kuala Nerus, Terengganu</li>
                </ul>
            </div>
        </div>
        <div class="copyright">
            <p>&copy; 2025 ON9Shop. All rights reserved.</p>
        </div>
    </footer>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const loginBtn = document.querySelector('.login-btn');
            const addToCartBtns = document.querySelectorAll('.add-to-cart');
            
            loginBtn.addEventListener('click', function () {
                alert('Login/Signup functionality would go here');
            });
            
            addToCartBtns.forEach(btn => {
                btn.addEventListener('click', function (e) {
                    if (this.disabled) {
                        e.preventDefault();
                        return;
                    }
                    // Just show visual feedback without preventing submission
                    const originalText = this.textContent;
                    this.textContent = 'Adding...';
                    setTimeout(() => {
                        this.textContent = originalText;
                    }, 1000);
                });
            });
            
            window.addEventListener('scroll', function () {
                const header = document.querySelector('header');
                if (window.scrollY > 50) {
                    header.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.1)';
                } else {
                    header.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
                }
            });
        });
    </script>
</body>
</html>