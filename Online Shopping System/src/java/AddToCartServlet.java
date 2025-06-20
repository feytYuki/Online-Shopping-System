import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database connection parameters
    private static final String DB_URL = "jdbc:mysql://localhost:3306/shopping";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            // Verify database connectivity on servlet initialization
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                setupDatabase(conn);
            }
        } catch (ClassNotFoundException | SQLException e) {
            getServletContext().log("Database initialization error: " + e.getMessage());
        }
    }
    
    // Setup database tables if they don't exist
    private void setupDatabase(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            // Create products table if it doesn't exist
            stmt.execute(
                "CREATE TABLE IF NOT EXISTS products (" +
                "product_id VARCHAR(50) PRIMARY KEY, " + // Changed from "id" to "product_id"
                "name VARCHAR(255) NOT NULL, " +
                "price DECIMAL(10,2) NOT NULL" +
                ")"
            );
            
            // Create carts table if it doesn't exist
            stmt.execute(
                "CREATE TABLE IF NOT EXISTS carts (" +
                "cart_id INT AUTO_INCREMENT PRIMARY KEY, " +
                "session_id VARCHAR(255) NOT NULL, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "INDEX (session_id)" +
                ")"
            );
            
            // Create cart_items table if it doesn't exist
            stmt.execute(
                "CREATE TABLE IF NOT EXISTS cart_items (" +
                "item_id INT AUTO_INCREMENT PRIMARY KEY, " +
                "cart_id INT NOT NULL, " +
                "product_id VARCHAR(50) NOT NULL, " +
                "quantity INT NOT NULL DEFAULT 1, " +
                "FOREIGN KEY (cart_id) REFERENCES carts(cart_id) ON DELETE CASCADE, " +
                "FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE, " + // Changed to reference products.product_id
                "UNIQUE KEY (cart_id, product_id)" +
                ")"
            );
        }
    }
    
    // Get database connection
    private Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        
        // Get request parameters
        String productId = request.getParameter("product_id");
        String productName = request.getParameter("name");
        String productPrice = request.getParameter("price");
        String quantityStr = request.getParameter("quantity");
        int quantity = 1;  // Default
        
        // Basic validation
        if (productId == null || productId.trim().isEmpty() || 
            productName == null || productName.trim().isEmpty() ||
            productPrice == null || productPrice.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("Missing required product information");
            return;
        }
        
        // Parse quantity if provided
        if (quantityStr != null && !quantityStr.trim().isEmpty()) {
            try {
                quantity = Integer.parseInt(quantityStr);
                if (quantity < 1) quantity = 1;
            } catch (NumberFormatException e) {
                // Use default quantity
            }
        }
        
        // Parse price
        double price;
        try {
            price = Double.parseDouble(productPrice);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("Invalid price format");
            return;
        }
        
        HttpSession session = request.getSession(true);
        String sessionId = session.getId();
        
        try (Connection conn = getConnection()) {
            // Ensure product exists in products table
            ensureProductExists(conn, productId, productName, price);
            
            // Get or create cart for this session
            int cartId = getOrCreateCart(conn, sessionId);
            
            // Add product to cart or update quantity if it already exists
            addToCart(conn, cartId, productId, quantity);
            
            response.setStatus(HttpServletResponse.SC_OK);
            out.write("Product added to cart successfully");
            
        } catch (SQLException | ClassNotFoundException e) {
            getServletContext().log("Database error in AddToCartServlet: " + e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("Database error: " + e.getMessage());
        }
    }
    
    private void ensureProductExists(Connection conn, String productId, String productName, double price) 
        throws SQLException {
        // Check if product exists
        String checkSql = "SELECT product_id FROM products WHERE product_id = ?";
        String insertSql = "INSERT INTO products (product_id, name, price) VALUES (?, ?, ?)";
        
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setString(1, productId);
            
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (!rs.next()) {
                    // Product doesn't exist, insert it
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                        insertStmt.setString(1, productId);
                        insertStmt.setString(2, productName);
                        insertStmt.setDouble(3, price);
                        
                        int rowsAffected = insertStmt.executeUpdate();
                        if (rowsAffected != 1) {
                            throw new SQLException("Failed to insert product");
                        }
                    }
                }
            }
        } catch (SQLException e) {
            getServletContext().log("Error ensuring product exists: " + e.getMessage(), e);
            throw e;
        }
    }
    
    private int getOrCreateCart(Connection conn, String sessionId) throws SQLException {
        // Try to get existing cart for this session
        String checkSql = "SELECT cart_id FROM carts WHERE session_id = ?";
        String insertSql = "INSERT INTO carts (session_id) VALUES (?)";
        
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setString(1, sessionId);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cart_id");
                }
            }
        }
        
        // No cart exists, create one
        try (PreparedStatement insertStmt = conn.prepareStatement(insertSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            insertStmt.setString(1, sessionId);
            insertStmt.executeUpdate();
            
            try (ResultSet generatedKeys = insertStmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating cart failed, no ID obtained.");
                }
            }
        }
    }
    
    private void addToCart(Connection conn, int cartId, String productId, int quantity) throws SQLException {
        // Check if item already exists in cart
        String checkSql = "SELECT item_id, quantity FROM cart_items WHERE cart_id = ? AND product_id = ?";
        String updateSql = "UPDATE cart_items SET quantity = ? WHERE item_id = ?";
        String insertSql = "INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?)";
        
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, cartId);
            checkStmt.setString(2, productId);
            
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    // Product is already in cart, update quantity
                    int itemId = rs.getInt("item_id");
                    int currentQty = rs.getInt("quantity");
                    
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                        updateStmt.setInt(1, currentQty + quantity);
                        updateStmt.setInt(2, itemId);
                        updateStmt.executeUpdate();
                    }
                } else {
                    // Product is not in cart, add it
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                        insertStmt.setInt(1, cartId);
                        insertStmt.setString(2, productId);
                        insertStmt.setInt(3, quantity);
                        insertStmt.executeUpdate();
                    }
                }
            }
        }
    }
}