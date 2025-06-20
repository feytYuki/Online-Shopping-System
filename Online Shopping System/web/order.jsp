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

<%
Map<String, Object> order = new HashMap<>();
List<Map<String, Object>> orderItems = new ArrayList<>();
String errorMessage = null;

// First check if we have order details in session (from the checkout process)
if (session.getAttribute("order_id") != null) {
    // Use session data
    order.put("order_id", session.getAttribute("order_id"));
    order.put("fullname", session.getAttribute("order_fullname"));
    order.put("email", session.getAttribute("order_email"));
    order.put("phone", session.getAttribute("order_phone"));
    order.put("address", session.getAttribute("order_address"));
    order.put("city", session.getAttribute("order_city"));
    order.put("postcode", session.getAttribute("order_postcode"));
    order.put("state", session.getAttribute("order_state"));
    order.put("payment_method", session.getAttribute("order_payment"));
    order.put("subtotal", session.getAttribute("order_subtotal"));
    order.put("shipping", session.getAttribute("order_shipping"));
    order.put("total", session.getAttribute("order_total"));
    order.put("order_date", new java.util.Date()); // Current date/time
    
    // Clear session attributes after using them
    session.removeAttribute("order_id");
    session.removeAttribute("order_fullname");
    session.removeAttribute("order_email");
    session.removeAttribute("order_phone");
    session.removeAttribute("order_address");
    session.removeAttribute("order_city");
    session.removeAttribute("order_postcode");
    session.removeAttribute("order_state");
    session.removeAttribute("order_payment");
    session.removeAttribute("order_subtotal");
    session.removeAttribute("order_shipping");
    session.removeAttribute("order_total");
} 
// Otherwise check if order_id parameter exists (direct link or refresh)
else {
    String orderIdParam = request.getParameter("order_id");
    if (orderIdParam != null && !orderIdParam.isEmpty()) {
        try {
            int orderId = Integer.parseInt(orderIdParam);
            
            String url = "jdbc:mysql://localhost:3306/shopping";
            String dbUser = "root";
            String dbPassword = "";
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, dbUser, dbPassword);
            
            String orderSql = "SELECT * FROM orders WHERE order_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(orderSql);
            pstmt.setInt(1, orderId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                order.put("order_id", rs.getInt("order_id"));
                order.put("fullname", rs.getString("fullname"));
                order.put("email", rs.getString("email"));
                order.put("phone", rs.getString("phone"));
                order.put("address", rs.getString("address"));
                order.put("city", rs.getString("city"));
                order.put("postcode", rs.getString("postcode"));
                order.put("state", rs.getString("state"));
                order.put("payment_method", rs.getString("payment_method"));
                order.put("subtotal", rs.getDouble("subtotal"));
                order.put("shipping", rs.getDouble("shipping"));
                order.put("total", rs.getDouble("total"));
                order.put("order_date", rs.getTimestamp("order_date"));
            }
            
            String itemsSql = "SELECT * FROM order_items WHERE order_id = ?";
            pstmt = conn.prepareStatement(itemsSql);
            pstmt.setInt(1, orderId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("product_id", rs.getInt("product_id"));
                item.put("product_name", rs.getString("product_name"));
                item.put("quantity", rs.getInt("quantity"));
                item.put("price", rs.getDouble("price"));
                orderItems.add(item);
            }
            
            rs.close();
            pstmt.close();
            conn.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "Error retrieving order details. Please try again later.";
        }
    } else {
        errorMessage = "No order ID provided. Please check your order confirmation email.";
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmation - ON9Shop</title>
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

        .confirmation-message {
            background-color: #e8f5e9;
            color: #2e7d32;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 30px;
            border-left: 5px solid #4caf50;
        }

        .error-message {
            background-color: #ffebee;
            color: #c62828;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 30px;
            border-left: 5px solid #f44336;
        }

        .order-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }

        .order-section {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .order-section h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 1.5rem;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }

        .detail-row {
            display: flex;
            margin-bottom: 15px;
        }

        .detail-label {
            font-weight: 600;
            color: #2c3e50;
            width: 150px;
        }

        .detail-value {
            flex: 1;
        }

        .order-items {
            margin-top: 30px;
        }

        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .items-table th {
            background-color: #2c3e50;
            color: white;
            text-align: left;
            padding: 12px;
        }

        .items-table td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }

        .items-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .items-table tr:hover {
            background-color: #f1f1f1;
        }

        .total-section {
            margin-top: 30px;
            text-align: right;
        }

        .total-row {
            display: inline-block;
            margin-top: 10px;
            font-size: 1.1rem;
        }

        .grand-total {
            font-size: 1.3rem;
            font-weight: bold;
            color: #e74c3c;
            margin-top: 15px;
            border-top: 2px solid #e74c3c;
            padding-top: 10px;
        }

        .action-buttons {
            margin-top: 30px;
            display: flex;
            justify-content: space-between;
        }

        .btn {
            padding: 12px 20px;
            border-radius: 4px;
            font-weight: bold;
            text-decoration: none;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .btn-primary {
            background-color: #e74c3c;
            color: white;
            border: none;
        }

        .btn-primary:hover {
            background-color: #c0392b;
        }

        .btn-secondary {
            background-color: #3498db;
            color: white;
            border: none;
        }

        .btn-secondary:hover {
            background-color: #2980b9;
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
                padding: 15px;
            }

            .order-details {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            
            .action-buttons {
                flex-direction: column;
                gap: 10px;
            }
            
            .btn {
                width: 100%;
                text-align: center;
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
        <% if (errorMessage != null) { %>
            <div class="error-message">
                <%= errorMessage %>
            </div>
        <% } else { %>
            <h1>Order Confirmation</h1>
            
            <div class="confirmation-message">
                <h2>Thank you for your order!</h2>
                <p>Your order #<%= order.get("order_id") %> has been placed successfully.</p>
                <p>A confirmation email has been sent to <%= order.get("email") %>.</p>
            </div>
            
            <div class="order-details">
                <div class="order-section">
                    <h2>Order Information</h2>
                    <div class="detail-row">
                        <div class="detail-label">Order Number:</div>
                        <div class="detail-value">#<%= order.get("order_id") %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Order Date:</div>
                        <div class="detail-value"><%= order.get("order_date") %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Payment Method:</div>
                        <div class="detail-value">
                            <% 
                            String paymentMethod = (String) order.get("payment_method");
                            if ("credit_card".equals(paymentMethod)) {
                                out.print("Credit Card");
                            } else if ("online_banking".equals(paymentMethod)) {
                                out.print("Online Banking");
                            } else if ("touch_n_go".equals(paymentMethod)) {
                                out.print("Touch 'n Go");
                            } else {
                                out.print(paymentMethod);
                            }
                            %>
                        </div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Order Status:</div>
                        <div class="detail-value">Processing</div>
                    </div>
                </div>
                
                <div class="order-section">
                    <h2>Shipping Information</h2>
                    <div class="detail-row">
                        <div class="detail-label">Name:</div>
                        <div class="detail-value"><%= order.get("fullname") %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Email:</div>
                        <div class="detail-value"><%= order.get("email") %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Phone:</div>
                        <div class="detail-value"><%= order.get("phone") %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Address:</div>
                        <div class="detail-value">
                            <%= order.get("address") %><br>
                            <%= order.get("postcode") %> <%= order.get("city") %><br>
                            <%= order.get("state") %>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="order-items">
                <h2>Order Items</h2>
                <table class="items-table">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Price</th>
                            <th>Quantity</th>
                            <th>Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        for (Map<String, Object> item : orderItems) {
                            double price = (Double) item.get("price");
                            int quantity = (Integer) item.get("quantity");
                            double total = price * quantity;
                        %>
                        <tr>
                            <td><%= item.get("product_name") %></td>
                            <td>RM <%= String.format("%.2f", price) %></td>
                            <td><%= quantity %></td>
                            <td>RM <%= String.format("%.2f", total) %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <div class="total-section">
                    <div class="total-row">
                        <span>Subtotal: </span>
                        <span>RM <%= String.format("%.2f", order.get("subtotal")) %></span>
                    </div>
                    <div class="total-row">
                        <span>Shipping: </span>
                        <span>RM <%= String.format("%.2f", order.get("shipping")) %></span>
                    </div>
                    <div class="total-row grand-total">
                        <span>Grand Total: </span>
                        <span>RM <%= String.format("%.2f", order.get("total")) %></span>
                    </div>
                </div>
            </div>
            
            <div class="action-buttons">
                <a href="products.jsp" class="btn btn-secondary">Continue Shopping</a>
                <a href="#" class="btn btn-primary">Track Order</a>
            </div>
        <% } %>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const printBtn = document.createElement('button');
            printBtn.className = 'btn btn-secondary';
            printBtn.textContent = 'Print Order';
            printBtn.onclick = function() {
                window.print();
            };
            
            const actionButtons = document.querySelector('.action-buttons');
            if (actionButtons) {
                actionButtons.appendChild(printBtn);
            }
            
            const trackBtn = document.querySelector('.btn-primary');
            if (trackBtn) {
                trackBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    alert('Order tracking will be available once your order is shipped. We will send you an email with tracking information.');
                });
            }
        });
    </script>
</body>
</html>