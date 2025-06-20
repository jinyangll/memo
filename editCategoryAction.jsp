<%@ page contentType="text/html; charset=UTF-8" import="java.sql.*" %>
<%
request.setCharacterEncoding("utf-8");
int categoryId = Integer.parseInt(request.getParameter("categoryId"));
String newName = request.getParameter("newName");

Connection con = null;
PreparedStatement pstmt = null;

try {
    Class.forName("org.mariadb.jdbc.Driver");
    String url = "jdbc:mariadb://localhost:3305/memodb?useSSL=false";
    con = DriverManager.getConnection(url, "admin", "1234");

    String sql = "UPDATE category SET name = ? WHERE id = ?";
    pstmt = con.prepareStatement(sql);
    pstmt.setString(1, newName);
    pstmt.setInt(2, categoryId);
    pstmt.executeUpdate();

    response.sendRedirect("index.jsp");

} catch (Exception e) {
    out.println("오류 발생: " + e.getMessage());
}
%>