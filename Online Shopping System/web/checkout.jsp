<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.sql.Statement"%>

<%
// Check if form was submitted
if ("POST".equalsIgnoreCase(request.getMethod())) {
    // Process the order
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        // Get form data
        String fullname = request.getParameter("fullname");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String postcode = request.getParameter("postcode");
        String state = request.getParameter("state");
        String paymentMethod = request.getParameter("payment");
        double subtotal = Double.parseDouble(request.getParameter("subtotal"));
        double shipping = Double.parseDouble(request.getParameter("shipping"));
        double total = Double.parseDouble(request.getParameter("total"));
        String sessionId = session.getId();
        
        String url = "jdbc:mysql://localhost:3306/shopping";
        String dbUser = "root";
        String dbPassword = "";
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPassword);
        
        conn.setAutoCommit(false);
        
        String orderSql = "INSERT INTO orders (session_id, fullname, email, phone, address, city, postcode, state, " +
                         "payment_method, subtotal, shipping, total, order_date) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        pstmt = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setString(1, sessionId);
        pstmt.setString(2, fullname);
        pstmt.setString(3, email);
        pstmt.setString(4, phone);
        pstmt.setString(5, address);
        pstmt.setString(6, city);
        pstmt.setString(7, postcode);
        pstmt.setString(8, state);
        pstmt.setString(9, paymentMethod);
        pstmt.setDouble(10, subtotal);
        pstmt.setDouble(11, shipping);
        pstmt.setDouble(12, total);
        pstmt.executeUpdate();
        
        int orderId = 0;
        rs = pstmt.getGeneratedKeys();
        if (rs.next()) {
            orderId = rs.getInt(1);
        }
        
        String cartSql = "SELECT ci.product_id, ci.quantity, p.name, p.price " +
                        "FROM cart_items ci " +
                        "JOIN products p ON ci.product_id = p.product_id " +
                        "JOIN carts c ON ci.cart_id = c.cart_id " +
                        "WHERE c.session_id = ?";
        pstmt = conn.prepareStatement(cartSql);
        pstmt.setString(1, sessionId);
        rs = pstmt.executeQuery();
        
        String itemSql = "INSERT INTO order_items (order_id, product_id, product_name, quantity, price) " +
                       "VALUES (?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(itemSql);
        
        while (rs.next()) {
            pstmt.setInt(1, orderId);
            pstmt.setInt(2, rs.getInt("product_id"));
            pstmt.setString(3, rs.getString("name"));
            pstmt.setInt(4, rs.getInt("quantity"));
            pstmt.setDouble(5, rs.getDouble("price"));
            pstmt.addBatch();
        }
        pstmt.executeBatch();
        
        String clearCartSql = "DELETE ci FROM cart_items ci " +
                            "JOIN carts c ON ci.cart_id = c.cart_id " +
                            "WHERE c.session_id = ?";
        pstmt = conn.prepareStatement(clearCartSql);
        pstmt.setString(1, sessionId);
        pstmt.executeUpdate();
        
        conn.commit();
        
        session.setAttribute("order_id", orderId);
        session.setAttribute("order_fullname", fullname);
        session.setAttribute("order_email", email);
        session.setAttribute("order_phone", phone);
        session.setAttribute("order_address", address);
        session.setAttribute("order_city", city);
        session.setAttribute("order_postcode", postcode);
        session.setAttribute("order_state", state);
        session.setAttribute("order_payment", paymentMethod);
        session.setAttribute("order_subtotal", subtotal);
        session.setAttribute("order_shipping", shipping);
        session.setAttribute("order_total", total);
        
        response.sendRedirect("order.jsp?order_id=" + orderId);
        return;
        
    } catch (Exception e) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        e.printStackTrace();
        request.setAttribute("errorMessage", "Error processing your order. Please try again.");
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
}

List<Map<String, Object>> cartItems = new ArrayList<>();
double subtotal = 0.0;
double shipping = 5.00; 
double total = 0.0;

try {
    String myUrl = "jdbc:mysql://localhost:3306/shopping";
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(myUrl, "root", "");

    String sessionId = session.getId();

    PreparedStatement cartStmt = conn.prepareStatement(
            "SELECT cart_id FROM carts WHERE session_id = ?");
    cartStmt.setString(1, sessionId);
    ResultSet cartRs = cartStmt.executeQuery();

    if (cartRs.next()) {
        int cartId = cartRs.getInt("cart_id");

        PreparedStatement itemStmt = conn.prepareStatement(
                "SELECT ci.product_id, ci.quantity, p.name, p.price "
                + "FROM cart_items ci "
                + "JOIN products p ON ci.product_id = p.product_id "
                + "WHERE ci.cart_id = ?");
        itemStmt.setInt(1, cartId);
        ResultSet itemRs = itemStmt.executeQuery();

        while (itemRs.next()) {
            Map<String, Object> item = new HashMap<>();
            item.put("product_id", itemRs.getString("product_id"));
            item.put("name", itemRs.getString("name"));
            item.put("price", itemRs.getDouble("price"));
            item.put("quantity", itemRs.getInt("quantity"));
            cartItems.add(item);

            subtotal += itemRs.getDouble("price") * itemRs.getInt("quantity");
        }

        itemRs.close();
        itemStmt.close();
    }

    cartRs.close();
    cartStmt.close();
    conn.close();

    total = subtotal + shipping;

} catch (Exception e) {
    e.printStackTrace();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - ON9Shop</title>
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

        .checkout-form {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }

        .form-section {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .form-section h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 1.5rem;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #2c3e50;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: #3498db;
            outline: none;
        }

        .order-summary {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .order-items {
            margin-bottom: 25px;
        }

        .order-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
            font-size: 1rem;
        }

        .order-item:last-child {
            border-bottom: none;
        }

        .total-row {
            font-weight: bold;
            font-size: 1.2rem;
            margin-top: 20px;
            padding-top: 15px;
            border-top: 2px solid #e74c3c;
        }

        .place-order-btn {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 14px 20px;
            font-size: 1.1rem;
            font-weight: bold;
            cursor: pointer;
            border-radius: 4px;
            width: 100%;
            margin-top: 20px;
            transition: background-color 0.3s;
        }

        .place-order-btn:hover {
            background-color: #c0392b;
        }

        .payment-methods {
            margin-top: 20px;
        }

        .payment-option {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .payment-option:hover {
            border-color: #3498db;
        }

        .payment-option input {
            margin-right: 15px;
        }

        .payment-icon {
            width: 40px;
            margin-right: 15px;
        }

        .payment-details {
            display: none;
            padding: 15px;
            margin-top: 15px;
            background: #f8f9fa;
            border-radius: 4px;
        }

        .error-message {
            color: #e74c3c;
            background-color: #fdecea;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            border: 1px solid #e74c3c;
        }

        /* Responsive Styles */
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
                padding: 15px;
            }

            .checkout-form {
                grid-template-columns: 1fr;
                gap: 20px;
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
        <h1>Checkout</h1>
        
        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="error-message">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>
        
        <form method="post" action="checkout.jsp">
            <div class="checkout-form">
                <div class="form-section">
                    <h2>Shipping Information</h2>
                    <div class="form-group">
                        <label for="fullname">Full Name</label>
                        <input type="text" id="fullname" name="fullname" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" required>
                    </div>
                    <div class="form-group">
                        <label for="address">Address</label>
                        <textarea id="address" name="address" rows="3" required></textarea>
                    </div>
                    <div class="form-group">
                        <label for="city">City</label>
                        <input type="text" id="city" name="city" required>
                    </div>
                    <div class="form-group">
                        <label for="postcode">Postal Code</label>
                        <input type="text" id="postcode" name="postcode" required>
                    </div>
                    <div class="form-group">
                        <label for="state">State</label>
                        <select id="state" name="state" required>
                            <option value="">Select State</option>
                            <option value="Johor">Johor</option>
                            <option value="Kedah">Kedah</option>
                            <option value="Kelantan">Kelantan</option>
                            <option value="Malacca">Malacca</option>
                            <option value="Negeri Sembilan">Negeri Sembilan</option>
                            <option value="Pahang">Pahang</option>
                            <option value="Penang">Penang</option>
                            <option value="Perak">Perak</option>
                            <option value="Perlis">Perlis</option>
                            <option value="Sabah">Sabah</option>
                            <option value="Sarawak">Sarawak</option>
                            <option value="Selangor">Selangor</option>
                            <option value="Terengganu">Terengganu</option>
                            <option value="Kuala Lumpur">Kuala Lumpur</option>
                            <option value="Labuan">Labuan</option>
                            <option value="Putrajaya">Putrajaya</option>
                        </select>
                    </div>
                    
                    <div class="payment-methods">
                        <h3>Payment Method</h3>
                        <div class="form-group">
                            <div class="payment-option">
                                <input type="radio" id="credit_card" name="payment" value="credit_card" required>
                                <img src="image/cc.png" alt="Credit Card" class="payment-icon">
                                <label for="credit_card">Credit Card</label>
                            </div>
                            <div class="payment-option">
                                <input type="radio" id="online_banking" name="payment" value="online_banking">
                                <img src="image/ob.png" alt="Online Banking" class="payment-icon">
                                <label for="online_banking">Online Banking</label>
                            </div>
                            <div class="payment-option">
                                <input type="radio" id="touch_n_go" name="payment" value="touch_n_go">
                                <img src="image/tng.png" alt="Touch 'n Go" class="payment-icon">
                                <label for="touch_n_go">Touch 'n Go</label>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-section order-summary">
                    <h2>Order Summary</h2>
                    <div class="order-items">
                        <% if (cartItems.isEmpty()) { %>
                        <div class="order-item">
                            <span>Your cart is empty</span>
                        </div>
                        <% } else {
                            for (Map<String, Object> item : cartItems) {
                                double itemPrice = (Double) item.get("price");
                                int quantity = (Integer) item.get("quantity");
                                double itemTotal = itemPrice * quantity;
                        %>
                        <div class="order-item">
                            <span><%= item.get("name") %></span>
                            <span>RM <%= String.format("%.2f", itemPrice) %> × <%= quantity %></span>
                        </div>
                        <%   }
                            }%>
                    </div>
                    <div class="order-item">
                        <span>Subtotal</span>
                        <span>RM <%= String.format("%.2f", subtotal) %></span>
                    </div>
                    <div class="order-item">
                        <span>Shipping</span>
                        <span>RM <%= String.format("%.2f", shipping) %></span>
                    </div>
                    <div class="order-item total-row">
                        <span>Total</span>
                        <span>RM <%= String.format("%.2f", total) %></span>
                    </div>

                    <!-- Hidden fields to pass these values to the servlet -->
                    <input type="hidden" name="subtotal" value="<%= subtotal %>">
                    <input type="hidden" name="shipping" value="<%= shipping %>">
                    <input type="hidden" name="total" value="<%= total %>">
                </div>
            </div>
            
            <button type="submit" class="place-order-btn">Place Order</button>
        </form>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const loginBtn = document.querySelector('.login-btn');
            loginBtn.addEventListener('click', function () {
                alert('Login/Signup page would appear here');
            });

            const paymentOptions = document.querySelectorAll('.payment-option input');
            paymentOptions.forEach(option => {
                option.addEventListener('change', function () {
                    // Hide all payment details first
                    document.querySelectorAll('.payment-details').forEach(detail => {
                        detail.style.display = 'none';
                    });

                    const detailsId = this.id + '-details';
                    const detailsElement = document.getElementById(detailsId);
                    if (detailsElement) {
                        detailsElement.style.display = 'block';
                    }
                });
            });
        });
    </script>
</body>
</html>