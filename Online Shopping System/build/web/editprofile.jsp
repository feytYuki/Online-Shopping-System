<%-- 
    Document   : editprofile
    Created on : 7 Jun 2025, 11:24:29?pm
    Author     : Ameer
--%>

<%@ page import="Model.User" %>
<%@ page session="true" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Profile</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 100px; }
        input, select, textarea {
            width: 300px; padding: 10px; margin: 10px 0;
        }
        button {
            background-color: black; color: white; padding: 10px 30px; border: none;
        }
    </style>
</head>
<body>
    <h2>Edit Profile</h2>
    <form action="UserController" method="post">
        <input type="hidden" name="action" value="edit" />
        <input type="text" name="username" value="<%= user.getUsername() %>" required><br>
        <input type="email" name="email" value="<%= user.getEmail() %>" required><br>
        <input type="password" name="password" value="<%= user.getPassword() %>" required><br>
        <textarea name="shippingAddress" rows="4" placeholder="Shipping Address" required><%= user.getShippingAddress() %></textarea><br>
        <button type="submit">Update</button>
    </form>
    <p><a href="<%= user.getRole().equals("admin") ? "adminDashboard.jsp" : "customerDashboard.jsp" %>">Back to Dashboard</a></p>
</body>
</html>

