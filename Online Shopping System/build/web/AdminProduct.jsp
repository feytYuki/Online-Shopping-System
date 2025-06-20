<%-- 
    Document   : AdminProduct
    Created on : 7 Jun 2025, 3:08:26 PM
    Author     : Amirul
--%>

<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Product Management - ON9Shop</title>
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

        .admin-actions {
            margin-bottom: 2rem;
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

        .btn-warning {
            background-color: #f39c12;
            color: white;
            border: none;
        }

        .btn-warning:hover {
            background-color: #d35400;
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

        .action-btns {
    display: flex;
    gap: 0.5rem;
    align-items: center;
}

.action-btn {
    padding: 0.5rem 1rem;
    min-width: 80px; /* Increased slightly for consistency */
    text-align: center;
    box-sizing: border-box;
    line-height: 1; /* Normalize line height */
    display: inline-block;
    font-size: 14px; /* Ensure consistent font size */
}

/* Ensure form does not add extra spacing */
.action-btns form {
    margin: 0;
    padding: 0;
}

/* Normalize button and link styles */
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
    line-height: 1; /* Normalize line height */
    font-size: 14px; /* Consistent font size */
}

        .error-message {
            color: #e74c3c;
            background-color: #fdecea;
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
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

            .action-btns {
                flex-direction: column;
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
                    <li><a href="AdminProduct.jsp" class="active">Products</a></li>
                    <li><a href="AdminOrder.jsp">Orders</a></li>
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
        <h1 class="page-title">Product Management</h1>
        
        <%-- Display error if any --%>
        <% if (request.getParameter("error") != null) { %>
            <div class="error-message">Error: <%= request.getParameter("error") %></div>
        <% } %>
        
        <div class="admin-actions">
            <a href="addProduct.jsp" class="btn btn-primary">Add New Product</a>
        </div>
        
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Price</th>
                    <th>Stock</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/shopping", "root", "");
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT * FROM products");
                    
                    while (rs.next()) {
                %>
                        <tr>
                            <td><%= rs.getString("product_id") %></td>
                            <td><%= rs.getString("name") %></td>
                            <td>RM <%= String.format("%.2f", rs.getDouble("price")) %></td>
                            <td><%= rs.getInt("stock_quantity") %></td>
                            <td class="action-btns">
    <a href="editProduct.jsp?id=<%= rs.getString("product_id") %>" class="btn btn-warning action-btn">Edit</a>
    <form action="AdminProductServlet" method="post" style="display:inline;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="product_id" value="<%= rs.getString("product_id") %>">
        <button type="submit" class="btn btn-danger action-btn" onclick="return confirm('Are you sure you want to delete this product?')">Delete</button>
    </form>
</td>
                        </tr>
                <%
                    }
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error: " + e.getMessage() + "</div>");
                }
                %>
            </tbody>
        </table>
    </div>

    <footer>
        <div class="copyright">
            <p>&copy; 2025 ON9Shop. All rights reserved.</p>
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