<%@ page contentType="text/html; charset=UTF-8" import="java.sql.*" %>
<%
request.setCharacterEncoding("utf-8");
String keyword = request.getParameter("keyword");

Class.forName("org.mariadb.jdbc.Driver");
String url = "jdbc:mariadb://localhost:3305/memodb?useSSL=false";
Connection con = DriverManager.getConnection(url, "admin", "1234");

String sql = "SELECT id, title, content FROM note WHERE title LIKE ? OR content LIKE ?";
PreparedStatement pstmt = con.prepareStatement(sql);
pstmt.setString(1, "%" + keyword + "%");
pstmt.setString(2, "%" + keyword + "%");

ResultSet rs = pstmt.executeQuery();
%>



    
 <!DOCTYPE html>
<html>

<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="index.css" type="text/css">
<title>afterSearch</title>
</head>



<body>
<div id="box">
<div id="menubar">

	<div style="height: 450px">
		<div class="searching">
			<form method="get" action="searchMemo.jsp" style="margin-bottom: 10px;">
			    <input type="text" id="searchInput" name="keyword" class="search" placeholder="검색어를 입력하세요">
			    <button type="submit" id="searchButton" class="search">검색</button>
			</form>
			
			
		</div>

	<div>
	
		<%-- <div>
		    <form action="editCategory.jsp" method="post" style="display:inline;">
		        <input type="hidden" name="categoryId" value="<%= categoryId %>">
		        <button type="submit" id="catNameEdit">카테고리 이름 변경</button>
		    </form>
		
		    <form action="deleteCategory.jsp" method="post" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
		        <input type="hidden" name="categoryId" value="<%= categoryId %>">
		        <button type="submit" id="catDelete">카테고리 삭제</button>
		    </form>
		</div>
		
		<div>
			<form action="addMemo.jsp" method="post"  id="addMemoWrap">
			<input type="hidden" name="curCategoryId" value="<%= categoryId %>">
			<button id="addMemo" type="submit">Add Memo</button>
			</form>
		</div>
		
		<br> --%>
	

	
	</div>
	
	</div>
	
	<div id="addCatDiv">
<!-- 		<form action="addMemo.jsp" method="post" style="display:inline-block">
		<button id="addMemo">Add Memo</button>
		</form> -->
		
		<form action="addCategory.jsp" method="post"  id="addCatWrap">
		<button id="addCategory">Add Category</button>
		</form>
		
	</div>
	
	
</div>
<div id="memoscreen">
	<div id="curCategory" style="height:21px;">"<%= keyword %>" 검색 결과</div>
	<div id="curMemo">
		 <%
        boolean hasResult = false;
        while (rs.next()) {
            hasResult = true;
            int id = rs.getInt("id");
            String title = rs.getString("title");
            String content = rs.getString("content");
        %>
            <div style="margin-bottom: 10px;">
                <a href="showMemo.jsp?id=<%= id %>" style="font-size: 1.2em; font-weight: bold;"><%= title %></a><br>
                <div style="font-size: 0.9em; color: gray;"><%= content.length() > 100 ? content.substring(0, 100) + "..." : content %></div>
            </div>
        <% 
        }
        if (!hasResult) {
        %>
            <p>검색 결과가 없습니다.</p>
        <%
        }
        rs.close();
        pstmt.close();
        con.close();
        %>
	
	</div>
</div>
</div>



</body>
</html>


















