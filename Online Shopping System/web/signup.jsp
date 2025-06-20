<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background-color: #f5f5f5;
        }
        .title {
            font-size: 40px;
            margin-bottom: 30px;
            font-weight: bold;
            color: #333;
        }
        .container {
            border: 1px solid #ddd;
            padding: 30px;
            width: 400px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .form-group {
            text-align: left;
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-size: 16px;
            font-weight: 500;
        }
        input, select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            box-sizing: border-box;
            font-size: 14px;
            border-radius: 4px;
        }
        input:focus, select:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 0 2px rgba(0,123,255,0.25);
        }
        button {
            padding: 15px;
            background: #007bff;
            color: #fff;
            border: none;
            cursor: pointer;
            width: 100%;
            margin-top: 15px;
            font-size: 16px;
            border-radius: 4px;
            transition: background-color 0.3s;
        }
        button:hover {
            background: #0056b3;
        }
        .login-link {
            margin-bottom: 20px;
            text-align: center;
        }
        .login-link a {
            text-decoration: none;
            color: #007bff;
            font-size: 14px;
            font-weight: bold;
        }
        .login-link a:hover {
            text-decoration: underline;
        }
        .error-message {
            color: #dc3545;
            margin-bottom: 15px;
            text-align: center;
            padding: 10px;
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="title">Create New Account</div>
    <div class="login-link">
        <a href="login.jsp">Already Registered? Login</a>
    </div>
    <div class="container">
        <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="error-message">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>
        
        <form action="UserController" method="post">
            <input type="hidden" name="action" value="signup" />
            <div class="form-group">
                <label for="username">Name</label>
                <input type="text" id="username" name="username" placeholder="Enter your name" 
                       value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>" required>
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" placeholder="Enter your email" 
                       value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Enter your password" required>
            </div>
            <button type="submit">Sign Up</button>
        </form>
    </div>
</body>
</html>