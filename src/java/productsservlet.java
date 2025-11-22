import Database.dbconfig;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@MultipartConfig
public class productsservlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String name = request.getParameter("name");
            String caption = request.getParameter("caption");
            String quantity = request.getParameter("quantity");
            String price = request.getParameter("price");
            String catId = request.getParameter("cat_id");
            String description = request.getParameter("description"); // <-- Added line

            // Get the uploaded image
            Part filePart = request.getPart("image");
            InputStream imageInputStream = null;

            if (filePart != null) {
                imageInputStream = filePart.getInputStream();
            }

            // Insert into database using PreparedStatement
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = new dbconfig().getConnection();

            // Updated query with description column
            String sql = "INSERT INTO products(name, caption, quantity, price, cat_id, description, image) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement stmt = con.prepareStatement(sql);

            stmt.setString(1, name);
            stmt.setString(2, caption);
            stmt.setInt(3, Integer.parseInt(quantity));
            stmt.setDouble(4, Double.parseDouble(price));
            stmt.setInt(5, Integer.parseInt(catId));
            stmt.setString(6, description); // <-- Bind description
            if (imageInputStream != null) {
                stmt.setBlob(7, imageInputStream);
            } else {
                stmt.setNull(7, java.sql.Types.BLOB);
            }

            stmt.executeUpdate();

            out.print("<script>alert('Product successfully added with image and description')</script>");
            out.println("<meta http-equiv='refresh' content='0;products_add.jsp' />");

        } catch (Exception e) {
            e.printStackTrace(out);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Stores product with image and description directly into DB";
    }
}
