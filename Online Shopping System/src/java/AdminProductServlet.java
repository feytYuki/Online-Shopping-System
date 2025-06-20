/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;
import javax.servlet.annotation.*;

/**
 *
 * @author Amirul
 */

@WebServlet("/AdminProductServlet")
public class AdminProductServlet extends HttpServlet {
    
    // Database connection details
    private static final String DB_URL = "jdbc:mysql://localhost:3306/shopping";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    /**
     *
     * @param request
     * @param response
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                if (null != action) switch (action) {
                    case "add":{
                        // Add new product
                        String sql = "INSERT INTO products (product_id, name, price, description, image_url, stock_quantity) VALUES (?, ?, ?, ?, ?, ?)";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, request.getParameter("product_id"));
                        pstmt.setString(2, request.getParameter("name"));
                        pstmt.setDouble(3, Double.parseDouble(request.getParameter("price")));
                        pstmt.setString(4, request.getParameter("description"));
                        pstmt.setString(5, request.getParameter("image_url"));
                        pstmt.setInt(6, Integer.parseInt(request.getParameter("stock_quantity")));
                        pstmt.executeUpdate();
                        break;
                    }
                    case "update":{
                        // Update product
                        String sql = "UPDATE products SET name=?, price=?, description=?, image_url=?, stock_quantity=? WHERE product_id=?";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, request.getParameter("name"));
                        pstmt.setDouble(2, Double.parseDouble(request.getParameter("price")));
                        pstmt.setString(3, request.getParameter("description"));
                        pstmt.setString(4, request.getParameter("image_url"));
                        pstmt.setInt(5, Integer.parseInt(request.getParameter("stock_quantity")));
                        pstmt.setString(6, request.getParameter("product_id"));
                        pstmt.executeUpdate();
                        break;
                    }
                    case "delete":{
                        // Delete product
                        String sql = "DELETE FROM products WHERE product_id=?";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, request.getParameter("product_id"));
                        pstmt.executeUpdate();
                        break;
                    }
                    default:
                        break;
                }
            }
            response.sendRedirect("AdminProduct.jsp"); //tukar
            
        } catch (IOException | ClassNotFoundException | NumberFormatException | SQLException e) {
            response.sendRedirect("AdminProduct.jsp?error=" + e.getMessage()); // tukar
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
