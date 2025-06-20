<%-- 
    Document   : AdminOrder
    Created on : 7 Jun 2025, 10:22 PM
    Author     : User
--%>

<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Order Management - ON9Shop</title>
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

        .nav-right {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .nav-links {
            display: flex;
            list-style: none;
            margin-right: 1rem;
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

        .nav-links a.active {
            color: #e74c3c;
            font-weight: bold;
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

        .admin-header {
            background-color: #2c3e50;
            color: white;
            padding: 1.5rem 0;
            margin-top: 70px;
        }

        .admin-title {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
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

        .btn {
            padding: 0.6rem 1rem;
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            min-width: 80px;
            line-height: 1;
            font-size: 14px;
        }

        .btn-primary {
            background-color: #3498db;
            color: white;
            border: none;
        }

        .btn-primary:hover {
            background-color: #2980b9;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            overflow: hidden;
        }

        th, td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #eee;
        }

        th {
            background-color: #2c3e50;
            color: white;
        }

        tr:hover {
            background-color: #f9f9f9;
        }

        .error-message {
            color: #e74c3c;
            background-color: #fdecea;
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
            text-align: center;
        }

        .no-data-message {
            text-align: center;
            padding: 2rem;
            background-color: white;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
            color: #2c3e50;
            font-weight: bold;
        }

        footer {
            background-color: #2c3e50;
            color: #ecf0f1;
            padding: 3rem 0;
            margin-top: 3rem;
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

            .nav-right {
                width: 100%;
                justify-content: space-between;
                margin-top: 1rem;
            }

            .nav-links {
                margin-right: 0;
            }

            .nav-links li {
                margin-left: 1rem;
            }

            .admin-header {
                margin-top: 120px;
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
            <div class="nav-right">
                <ul class="nav-links">
                    <li><a href="AdminProduct.jsp">Products</a></li>
                    <li><a href="AdminOrder.jsp" class="active">Orders</a></li>
                </ul>
                <button class="login-btn">Login</button>
            </div>
        </nav>
    </header>

    <div class="admin-header">
        <div class="admin-title">
            <h2>Admin Dashboard</h2>
        </div>
    </div>

    <div class="main-content">
        <h1 class="page-title">Order Management</h1>

        <%-- Display error if any --%>
        <% if (request.getParameter("error") != null) { %>
            <div class="error-message">Error: <%= request.getParameter("error") %></div>
        <% } %>

        <%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/shopping", "root", "");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM orders");

            if (!rs.isBeforeFirst()) { // Check if ResultSet is empty
        %>
                <div class="no-data-message">No orders found</div>
        <%
            } else {
        %>
                <table>
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>User ID</th>
                            <th>Total (RM)</th>
                            <th>Amount</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        while (rs.next()) {
                        %>
                            <tr>
                                <td><%= rs.getString("order_id") %></td>
                                <td><%= rs.getString("user_id") %></td>
                                <td><%= String.format("%.2f", rs.getDouble("total")) %></td>
                                <td><%= rs.getInt("amount") %></td>
                                <td><%= rs.getString("status") %></td>
                            </tr>
                        <%
                        }
                        %>
                    </tbody>
                </table>
        <%
            }
            conn.close();
        } catch (Exception e) {
        %>
            <div class="error-message">Error: <%= e.getMessage() %></div>
        <%
        }
        %>
    </div>

    <footer>
        <div class="copyright">
            <p>© 2025 ON9Shop. All rights reserved.</p>
        </div>
    </footer>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const loginBtn = document.querySelector('.login-btn');
            
            loginBtn.addEventListener('click', function () {
                alert('Login/Signup functionality would go here');
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