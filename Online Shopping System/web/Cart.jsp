<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Your Shopping Cart - ON9Shop</title>
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

            .container {
                max-width: 1200px;
                margin: 120px auto 20px;
                padding: 20px;
                background: #fff;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
                border-radius: 8px;
            }

            h1 {
                color: #2c3e50;
                border-bottom: 2px solid #e74c3c;
                padding-bottom: 10px;
                margin-bottom: 20px;
            }

            .cart-items {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
            }

            .cart-items th {
                background-color: #2c3e50;
                color: white;
                padding: 12px;
                text-align: left;
            }

            .cart-items td {
                padding: 12px;
                border-bottom: 1px solid #ddd;
            }

            .cart-items tr:hover {
                background-color: #f9f9f9;
            }

            .quantity-control {
                display: flex;
                align-items: center;
            }

            .quantity-btn {
                background: #e74c3c;
                color: white;
                border: none;
                width: 25px;
                height: 25px;
                font-size: 16px;
                cursor: pointer;
                border-radius: 3px;
            }

            .quantity-input {
                width: 40px;
                text-align: center;
                margin: 0 5px;
                border: 1px solid #ddd;
                padding: 3px 0;
            }

            .remove-btn {
                background: #e74c3c;
                color: white;
                border: none;
                padding: 5px 10px;
                cursor: pointer;
                border-radius: 3px;
            }

            .cart-summary {
                margin-top: 20px;
                text-align: right;
                padding: 15px;
                background-color: #f8f9fa;
                border-radius: 4px;
            }

            .checkout-btn {
                background: #e74c3c;
                color: white;
                border: none;
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
                border-radius: 4px;
                margin-top: 10px;
                text-decoration: none;
                display: inline-block;
            }

            .checkout-btn:hover {
                background-color: #c0392b;
            }

            .empty-cart {
                text-align: center;
                padding: 40px;
                color: #777;
            }

            .error-message {
                color: #e74c3c;
                background-color: #fde2e0;
                padding: 10px;
                border-radius: 4px;
                margin-bottom: 20px;
                font-size: 14px;
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

                .container {
                    margin-top: 150px;
                    padding: 10px;
                }

                .cart-items th,
                .cart-items td {
                    padding: 8px;
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
        <div class="container">
            <h1>Your Shopping Cart</h1>

            <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                String errorMessage = null;

                try {
                    String myUrl = "jdbc:mysql://localhost:3306/shopping";
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(myUrl, "root", "");

                    String sessionId = session.getId();

                    Statement createStmt = conn.createStatement();

                    createStmt.execute(
                            "CREATE TABLE IF NOT EXISTS carts ("
                            + "cart_id INT AUTO_INCREMENT PRIMARY KEY, "
                            + "session_id VARCHAR(255) NOT NULL, "
                            + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                            + "INDEX (session_id)"
                            + ")"
                    );

                    createStmt.execute(
                            "CREATE TABLE IF NOT EXISTS products ("
                            + "product_id VARCHAR(50) PRIMARY KEY, "
                            + "name VARCHAR(255) NOT NULL, "
                            + "price DECIMAL(10,2) NOT NULL"
                            + ")"
                    );

                    createStmt.execute(
                            "CREATE TABLE IF NOT EXISTS cart_items ("
                            + "item_id INT AUTO_INCREMENT PRIMARY KEY, "
                            + "cart_id INT NOT NULL, "
                            + "product_id VARCHAR(50) NOT NULL, "
                            + "quantity INT NOT NULL DEFAULT 1, "
                            + "FOREIGN KEY (cart_id) REFERENCES carts(cart_id) ON DELETE CASCADE, "
                            + "FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE, "
                            + "UNIQUE KEY (cart_id, product_id)"
                            + ")"
                    );

                    createStmt.close();

                    int cartId = 0;
                    pstmt = conn.prepareStatement("SELECT cart_id FROM carts WHERE session_id = ?");
                    pstmt.setString(1, sessionId);
                    rs = pstmt.executeQuery();

                    if (rs.next()) {
                        cartId = rs.getInt("cart_id");
                    }

                    rs.close();
                    pstmt.close();

                    if (cartId > 0) {
                        pstmt = conn.prepareStatement(
                                "SELECT ci.product_id, ci.quantity, p.name, p.price "
                                + "FROM cart_items ci "
                                + "JOIN products p ON ci.product_id = p.product_id "
                                + "WHERE ci.cart_id = ?");
                        pstmt.setInt(1, cartId);
                        rs = pstmt.executeQuery();

                        List<Map<String, Object>> cartItems = new ArrayList<>();
                        boolean hasItems = false;

                        while (rs.next()) {
                            hasItems = true;
                            Map<String, Object> item = new HashMap<>();
                            item.put("product_id", rs.getString("product_id"));
                            item.put("name", rs.getString("name"));
                            item.put("price", rs.getDouble("price"));
                            item.put("quantity", rs.getInt("quantity"));
                            cartItems.add(item);
                        }

                        rs.close();
                        pstmt.close();

                        if (!hasItems) {
            %>
            <div class="empty-cart">
                <h2>Your cart is empty</h2>
                <p>Continue shopping to add items to your cart</p>
                <a href="HomePage.html" class="checkout-btn">Continue Shopping</a>
            </div>
            <%
            } else {
                double total = 0;
            %>
            <table class="cart-items">
                <thead>
                    <tr>
                        <th>Product</th>
                        <th>Price</th>
                        <th>Quantity</th>
                        <th>Subtotal</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (Map<String, Object> item : cartItems) {
                            double price = (Double) item.get("price");
                            int quantity = (Integer) item.get("quantity");
                            double subtotal = price * quantity;
                            total += subtotal;
                    %>
                    <tr>
                        <td><%= item.get("name")%></td>
                        <td>RM <%= String.format("%.2f", price)%></td>
                        <td>
                            <div class="quantity-control">
                                <form action="UpdateCartServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="decrease">
                                    <input type="hidden" name="productId" value="<%= item.get("product_id")%>">
                                    <button type="submit" class="quantity-btn">-</button>
                                </form>
                                <input type="text" class="quantity-input" value="<%= quantity%>" readonly>
                                <form action="UpdateCartServlet" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="increase">
                                    <input type="hidden" name="productId" value="<%= item.get("product_id")%>">
                                    <button type="submit" class="quantity-btn">+</button>
                                </form>
                            </div>
                        </td>
                        <td>RM <%= String.format("%.2f", subtotal)%></td>
                        <td>
                            <form action="UpdateCartServlet" method="post">
                                <input type="hidden" name="action" value="remove">
                                <input type="hidden" name="productId" value="<%= item.get("product_id")%>">
                                <button type="submit" class="remove-btn">Remove</button>
                            </form>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>

            <div class="cart-summary">
                <h3>Total: RM <%= String.format("%.2f", total)%></h3>
                <a href="checkout.jsp" class="checkout-btn">Proceed to Checkout</a>
            </div>
            <%
                }
            } else {
            %>
            <div class="empty-cart">
                <h2>Your cart is empty</h2>
                <p>Continue shopping to add items to your cart</p>
                <a href="HomePage.html" class="checkout-btn">Continue Shopping</a>
            </div>
            <%
                }
            } catch (Exception e) {
                errorMessage = "Database error: " + e.getMessage();
                e.printStackTrace();
            %>
            <div class="error-message">
                <p><strong>Error:</strong> <%= errorMessage%></p>
            </div>
            <div class="empty-cart">
                <h2>Error loading your cart</h2>
                <p>There was a problem retrieving your cart. Please try again later.</p>
                <a href="HomePage.html" class="checkout-btn">Return to Homepage</a>
            </div>
            <%
                } finally {
                    try {
                        if (rs != null) {
                            rs.close();
                        }
                        if (pstmt != null) {
                            pstmt.close();
                        }
                        if (conn != null) {
                            conn.close();
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const loginBtn = document.querySelector('.login-btn');
                loginBtn.addEventListener('click', function () {
                    alert('Login/Signup page would appear here');
                });

                const checkoutBtn = document.querySelector('.checkout-btn');
                if (checkoutBtn) {
                    checkoutBtn.addEventListener('click', function () {
                        if (!this.closest('.empty-cart')) {
                            alert('Proceeding to checkout...');
                            // Redirect to checkout page or show checkout modal
                        }
                    });
                }
            });

            window.addEventListener('scroll', function () {
                const header = document.querySelector('header');
                if (window.scrollY > 50) {
                    header.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.1)';
                } else {
                    header.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
                }
            });
        </script>
    </body>
</html>