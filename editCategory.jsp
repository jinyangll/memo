<%@ page contentType="text/html; charset=UTF-8" import="java.sql.*" %>
<%
request.setCharacterEncoding("utf-8");
int categoryId = Integer.parseInt(request.getParameter("categoryId"));
%>

<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>카테고리 이름 변경</title></head>
<body>

<h2>카테고리 이름 변경</h2>

<form method="post" action="editCategoryAction.jsp">
    <input type="hidden" name="categoryId" value="<%= categoryId %>">
    새 이름: <input type="text" name="newName" required>
    <input type="submit" value="변경">
</form>

</body>
</html>