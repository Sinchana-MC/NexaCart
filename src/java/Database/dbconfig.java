/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package Database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author veda1
 */
public class dbconfig {
    public static Connection initializeDatabase() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
     public Connection getConnection() {
        try {
            // Dynamically load the MySQL JDBC driver class
            Class.forName("com.mysql.jdbc.Driver");
            
            // Attempt to establish a connection to the MySQL database
            // URL: jdbc:mysql://localhost:3306/parkinglot
            // Username: root
            // Password: (empty)
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/e_commerce", "root", "");
            
            // Return the established connection
            return con;
        } catch (ClassNotFoundException | SQLException e) {
            // Print the exception details to the console if an error occurs
            System.out.println(e);
        }
        
        // Return null if the connection could not be established
        return null;
    }
    
}
