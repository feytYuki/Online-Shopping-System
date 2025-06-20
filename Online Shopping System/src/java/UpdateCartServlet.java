import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/UpdateCartServlet")
public class UpdateCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Get database connection using direct method (same as in Cart.jsp)
    private Connection getConnection() throws SQLException, ClassNotFoundException {
        String myUrl = "jdbc:mysql://localhost:3306/shopping";
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(myUrl, "root", "");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("Cart.jsp");
            return;
        }
        
        String sessionId = session.getId();
        String action = request.getParameter("action");
        String productId = request.getParameter("productId");
        
        try {
            Connection conn = getConnection();
            
            // Get the cart ID for this session
            int cartId = getCartId(conn, sessionId);
            if (cartId == 0) {
                // No cart found
                conn.close();
                response.sendRedirect("Cart.jsp");
                return;
            }
            
            switch (action) {
                case "increase":
                    incrementQuantity(conn, cartId, productId);
                    break;
                case "decrease":
                    decrementQuantity(conn, cartId, productId);
                    break;
                case "remove":
                    removeItem(conn, cartId, productId);
                    break;
            }
            
            conn.close();
            
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        
        response.sendRedirect("Cart.jsp");
    }
    
    private int getCartId(Connection conn, String sessionId) throws SQLException {
        PreparedStatement stmt = conn.prepareStatement(
            "SELECT cart_id FROM carts WHERE session_id = ?");
        stmt.setString(1, sessionId);
        ResultSet rs = stmt.executeQuery();
        
        int cartId = 0;
        if (rs.next()) {
            cartId = rs.getInt("cart_id");
        }
        
        rs.close();
        stmt.close();
        
        return cartId;
    }
    
    private void incrementQuantity(Connection conn, int cartId, String productId) throws SQLException {
        PreparedStatement stmt = conn.prepareStatement(
            "UPDATE cart_items SET quantity = quantity + 1 WHERE cart_id = ? AND product_id = ?");
        stmt.setInt(1, cartId);
        stmt.setString(2, productId);
        stmt.executeUpdate();
        stmt.close();
    }
    
    private void decrementQuantity(Connection conn, int cartId, String productId) throws SQLException {
        // First check the current quantity
        PreparedStatement checkStmt = conn.prepareStatement(
            "SELECT quantity FROM cart_items WHERE cart_id = ? AND product_id = ?");
        checkStmt.setInt(1, cartId);
        checkStmt.setString(2, productId);
        ResultSet rs = checkStmt.executeQuery();
        
        if (rs.next()) {
            int quantity = rs.getInt("quantity");
            
            if (quantity > 1) {
                // Decrease quantity
                PreparedStatement updateStmt = conn.prepareStatement(
                    "UPDATE cart_items SET quantity = quantity - 1 WHERE cart_id = ? AND product_id = ?");
                updateStmt.setInt(1, cartId);
                updateStmt.setString(2, productId);
                updateStmt.executeUpdate();
                updateStmt.close();
            }
        }
        
        rs.close();
        checkStmt.close();
    }
    
    private void removeItem(Connection conn, int cartId, String productId) throws SQLException {
        PreparedStatement stmt = conn.prepareStatement(
            "DELETE FROM cart_items WHERE cart_id = ? AND product_id = ?");
        stmt.setInt(1, cartId);
        stmt.setString(2, productId);
        stmt.executeUpdate();
        stmt.close();
    }
}