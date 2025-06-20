package DAO;

import java.sql.*;
import Model.User;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class UserDAO {
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/shopping?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("JDBC Driver not found", e);
        }
        return DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
    }
    
    // Hash password using SHA-256
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashedBytes = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hashedBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }
    
    public boolean registerUser(User user) throws SQLException {
        System.out.println("=== REGISTER USER DEBUG ===");
        System.out.println("Username: " + user.getUsername());
        System.out.println("Email: " + user.getEmail());
        System.out.println("Role: " + user.getRole());
        
        if (emailExists(user.getEmail())) {
            System.out.println("Email already exists: " + user.getEmail());
            return false;
        }
        
        String sql = "INSERT INTO users (username, password, email, role) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, hashPassword(user.getPassword())); // Hash the password
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getRole());
            
            System.out.println("Executing SQL: " + sql);
            System.out.println("Hashed password: " + hashPassword(user.getPassword()));
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows == 0) {
                throw new SQLException("Creating user failed, no rows affected.");
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    user.setUserId(generatedKeys.getInt(1));
                    System.out.println("User registered successfully with ID: " + user.getUserId());
                } else {
                    throw new SQLException("Creating user failed, no ID obtained.");
                }
            }
            
            return true;
        } catch (SQLException e) {
            System.out.println("Registration error: " + e.getMessage());
            throw e;
        }
    }
    
    private boolean emailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (Connection conn = getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    boolean exists = rs.getInt(1) > 0;
                    System.out.println("Email " + email + " exists: " + exists);
                    return exists;
                }
            }
        } catch (SQLException e) {
            System.out.println("Error checking email existence: " + e.getMessage());
            throw e;
        }
        return false;
    }
    
    public User login(String email, String password) throws SQLException {
        System.out.println("=== LOGIN DEBUG ===");
        System.out.println("Email: " + email);
        System.out.println("Password: " + password);
        System.out.println("Hashed Password: " + hashPassword(password));
        
        // First, check if user exists with this email
        String checkEmailSql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(checkEmailSql)) {
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    System.out.println("User found with email: " + email);
                    String storedPassword = rs.getString("password");
                    System.out.println("Stored password: " + storedPassword);
                    System.out.println("Stored password length: " + storedPassword.length());
                    System.out.println("Input password hash: " + hashPassword(password));
                    System.out.println("Passwords match: " + storedPassword.equals(hashPassword(password)));
                    
                    // Check if stored password is already hashed (64 characters for SHA-256)
                    if (storedPassword.length() != 64) {
                        System.out.println("WARNING: Stored password appears to be plain text!");
                        // For debugging - check plain text password (REMOVE THIS IN PRODUCTION!)
                        if (storedPassword.equals(password)) {
                            System.out.println("Plain text password matches!");
                            User user = new User();
                            user.setUserId(rs.getInt("user_id")); // Using user_id (underscore)
                            user.setUsername(rs.getString("username"));
                            user.setEmail(rs.getString("email"));
                            user.setPassword(rs.getString("password"));
                            user.setRole(rs.getString("role") != null ? rs.getString("role") : "user");
                            System.out.println("Login successful (plain text)");
                            return user;
                        }
                    } else {
                        // Check hashed password
                        if (storedPassword.equals(hashPassword(password))) {
                            System.out.println("Hashed password matches!");
                            User user = new User();
                            user.setUserId(rs.getInt("user_id")); // Using user_id (underscore)
                            user.setUsername(rs.getString("username"));
                            user.setEmail(rs.getString("email"));
                            user.setPassword(rs.getString("password"));
                            user.setRole(rs.getString("role") != null ? rs.getString("role") : "user");
                            System.out.println("Login successful (hashed)");
                            return user;
                        }
                    }
                } else {
                    System.out.println("No user found with email: " + email);
                }
            }
        } catch (SQLException e) {
            System.out.println("Login error: " + e.getMessage());
            throw e;
        }
        
        System.out.println("Login failed - invalid credentials");
        return null;
    }
    
    public boolean updateUser(User user) throws SQLException {
        System.out.println("=== UPDATE USER DEBUG ===");
        System.out.println("Updating user ID: " + user.getUserId());
        
        String sql = "UPDATE users SET username=?, email=?, password=?, role=? WHERE user_id=?";
        try (Connection conn = getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, hashPassword(user.getPassword())); // Hash the password
            stmt.setString(4, user.getRole());
            stmt.setInt(5, user.getUserId());
            
            int rowsAffected = stmt.executeUpdate();
            boolean success = rowsAffected > 0;
            System.out.println("Update successful: " + success + " (rows affected: " + rowsAffected + ")");
            return success;
        } catch (SQLException e) {
            System.out.println("Update error: " + e.getMessage());
            throw e;
        }
    }
    
    public User getUserById(int userId) throws SQLException {
        System.out.println("=== GET USER BY ID DEBUG ===");
        System.out.println("Looking for user ID: " + userId);
        
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection conn = getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setRole(rs.getString("role") != null ? rs.getString("role") : "user");
                    System.out.println("Found user: " + user.getUsername());
                    return user;
                } else {
                    System.out.println("No user found with ID: " + userId);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error getting user by ID: " + e.getMessage());
            throw e;
        }
        return null;
    }
    
    public boolean deleteUser(int userId) throws SQLException {
        System.out.println("=== DELETE USER DEBUG ===");
        System.out.println("Deleting user ID: " + userId);
        
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            int rowsAffected = stmt.executeUpdate();
            boolean success = rowsAffected > 0;
            System.out.println("Delete successful: " + success + " (rows affected: " + rowsAffected + ")");
            return success;
        } catch (SQLException e) {
            System.out.println("Delete error: " + e.getMessage());
            throw e;
        }
    }
    
    // Utility method to test database connection
    public boolean testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("Database connection successful!");
            System.out.println("Connection URL: " + JDBC_URL);
            return true;
        } catch (SQLException e) {
            System.out.println("Database connection failed: " + e.getMessage());
            return false;
        }
    }
    
    // Method to get all users (for admin purposes)
    public java.util.List<User> getAllUsers() throws SQLException {
        System.out.println("=== GET ALL USERS DEBUG ===");
        java.util.List<User> users = new java.util.ArrayList<>();
        
        String sql = "SELECT * FROM users ORDER BY user_id";
        try (Connection conn = getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role") != null ? rs.getString("role") : "user");
                users.add(user);
            }
            
            System.out.println("Found " + users.size() + " users");
            return users;
        } catch (SQLException e) {
            System.out.println("Error getting all users: " + e.getMessage());
            throw e;
        }
    }
    
    // Method to hash existing plain text passwords (migration utility)
    public void hashExistingPasswords() throws SQLException {
        System.out.println("=== HASHING EXISTING PASSWORDS ===");
        
        String selectSql = "SELECT user_id, password FROM users WHERE LENGTH(password) < 64";
        String updateSql = "UPDATE users SET password = ? WHERE user_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement selectStmt = conn.prepareStatement(selectSql);
             PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
            
            ResultSet rs = selectStmt.executeQuery();
            int count = 0;
            
            while (rs.next()) {
                int userId = rs.getInt("user_id");
                String plainPassword = rs.getString("password");
                String hashedPassword = hashPassword(plainPassword);
                
                updateStmt.setString(1, hashedPassword);
                updateStmt.setInt(2, userId);
                updateStmt.executeUpdate();
                
                count++;
                System.out.println("Hashed password for user ID: " + userId);
            }
            
            System.out.println("Successfully hashed " + count + " passwords");
        } catch (SQLException e) {
            System.out.println("Error hashing passwords: " + e.getMessage());
            throw e;
        }
    }
}