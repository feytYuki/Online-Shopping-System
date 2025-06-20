<%-- 
    Document   : editProduct
    Created on : 7 Jun 2025, 3:10:29 PM
    Author     : User
--%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product - ON9Shop</title>
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
            text-align: center; /* Center the heading */
        }

        .form-container {
            background-color: white;
            padding: 1.5rem; /* Reduced padding */
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            max-width: 400px; /* Reduced width */
            margin: 0 auto;
        }

        .form-group {
            margin-bottom: 0.75rem; /* Reduced spacing */
        }

        .form-group label {
            display: block;
            font-weight: bold;
            margin-bottom: 0.5rem;
            color: #2c3e50;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 0.5rem; /* Reduced padding */
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            border-color: #3498db;
            outline: none;
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px; /* Reduced height */
        }

        .btn {
            padding: 0.5rem 0.8rem; /* Slightly smaller padding */
            border-radius: 4px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            min-width: 70px; /* Slightly smaller min-width */
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

        .btn-danger {
            background-color: #e74c3c;
            color: white;
            border: none;
        }

        .btn-danger:hover {
            background-color: #c0392b;
        }

        .form-actions {
            display: flex;
            gap: 0.75rem; /* Reduced gap */
            justify-content: flex-end;
            margin-top: 1rem; /* Reduced margin */
        }

        .error-message {
            color: #e74c3c;
            background-color: #fdecea;
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
            text-align: center;
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

            .form-container {
                padding: 1rem; /* Further reduced for mobile */
            }

            .form-actions {
                flex-direction: column;
                align-items: stretch;
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
                    <li><a href="products.jsp">Orders</a></li>
                </ul>
                <button class="login-btn">Login</button>
            </div>
        </nav>
    </header>

    <div class="admin-header">
        <div class="admin-title">
            <h2>Admin Dashboard</h2>
            <div>
                <a href="products.jsp" class="btn btn-primary">View Store</a>
            </div>
        </div>
    </div>

    <div class="main-content">
        <h1 class="page-title">Edit Product</h1>

        <div class="form-container">
            <%
            String id = request.getParameter("id");
            if (id == null || id.isEmpty()) {
                response.sendRedirect("products.jsp");
                return;
            }
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/shopping", "root", "");
                PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM products WHERE product_id=?");
                pstmt.setString(1, id);
                ResultSet rs = pstmt.executeQuery();
                
                if (rs.next()) {
            %>
                    <form action="AdminProductServlet" method="post">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="product_id" value="<%= rs.getString("product_id") %>">

                        <div class="form-group">
                            <label for="name">Name</label>
                            <input type="text" id="name" name="name" value="<%= rs.getString("name") %>" required>
                        </div>

                        <div class="form-group">
                            <label for="price">Price (RM)</label>
                            <input type="number" step="0.01" id="price" name="price" value="<%= rs.getDouble("price") %>" required>
                        </div>

                        <div class="form-group">
                            <label for="description">Description</label>
                            <textarea id="description" name="description" required><%= rs.getString("description") %></textarea>
                        </div>

                        <div class="form-group">
                            <label for="image_url">Image URL</label>
                            <input type="text" id="image_url" name="image_url" value="<%= rs.getString("image_url") %>" required>
                        </div>

                        <div class="form-group">
                            <label for="stock_quantity">Stock Quantity</label>
                            <input type="number" id="stock_quantity" name="stock_quantity" value="<%= rs.getInt("stock_quantity") %>" required>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">Update Product</button>
                            <a href="AdminProduct.jsp" class="btn btn-danger">Back to List</a>
                        </div>
                    </form>
            <%
                } else {
            %>
                    <div class="error-message">Product not found</div>
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