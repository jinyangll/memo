<%@ page contentType="text/html; charset=UTF-8" import="java.sql.*" %>
<%
request.setCharacterEncoding("utf-8");
int id = Integer.parseInt(request.getParameter("id"));

Connection con = null;
PreparedStatement pstmt = null;

try {
    Class.forName("org.mariadb.jdbc.Driver");
    String url = "jdbc:mariadb://localhost:3305/memo?useSSL=false";
    con = DriverManager.getConnection(url, "admin", "1234");

    String sql = "DELETE FROM note WHERE id=?";
    pstmt = con.prepareStatement(sql);
    pstmt.setInt(1, id);
    pstmt.executeUpdate();

    response.sendRedirect("index.jsp"); // 메인 화면으로 이동
} catch (Exception e) {
    out.println( e.getMessage());
} 

%>