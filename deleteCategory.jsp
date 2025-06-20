<%@ page contentType="text/html; charset=UTF-8" import="java.sql.*" %>
<%
request.setCharacterEncoding("utf-8");
int categoryId = Integer.parseInt(request.getParameter("categoryId"));

Connection con = null;
PreparedStatement pstmt = null;

try {
    Class.forName("org.mariadb.jdbc.Driver");
    String url = "jdbc:mariadb://localhost:3305/memodb?useSSL=false";
    con = DriverManager.getConnection(url, "admin", "1234");

    // 먼저 해당 카테고리에 속한 메모 삭제 (필요시)
    String deleteNotes = "DELETE FROM note WHERE category_id = ?";
    pstmt = con.prepareStatement(deleteNotes);
    pstmt.setInt(1, categoryId);
    pstmt.executeUpdate();
    pstmt.close();

    // 그 다음 카테고리 삭제
    String deleteCategory = "DELETE FROM category WHERE id = ?";
    pstmt = con.prepareStatement(deleteCategory);
    pstmt.setInt(1, categoryId);
    pstmt.executeUpdate();

    response.sendRedirect("index.jsp");

} catch (Exception e) {
    out.println("오류 발생: " + e.getMessage());
} finally {
    if (pstmt != null) pstmt.close();
    if (con != null) con.close();
}
%>