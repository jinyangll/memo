<%@ page language="java" contentType="text/html; charset=UTF-8"
    import="java.sql.*" %>

<%

request.setCharacterEncoding("utf-8");

Class.forName("org.mariadb.jdbc.Driver");

String url = "jdbc:mariadb://localhost:3305/memodb?useSSL=false";

Connection con = DriverManager.getConnection(url, "admin", "1234");

String categorySql = "SELECT id, name FROM category";
PreparedStatement categoryStmt = con.prepareStatement(categorySql);
ResultSet categoryRs = categoryStmt.executeQuery();


%>



    
 <!DOCTYPE html>
<html>

<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="index.css" type="text/css">
<title>Memo</title>
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
	<%
	while(categoryRs.next()){ 
		int categoryId = categoryRs.getInt("id");
		String categoryName = categoryRs.getString("name");
	%>
		<details class="categoryDetails" data-category-id="<%= categoryId %>">
			<summary class="category"><%=categoryName %></summary>
		
		<%
		String noteSql = "SELECT id, title FROM note WHERE category_id=?";
		PreparedStatement noteStmt = con.prepareStatement(noteSql);
		noteStmt.setInt(1, categoryId);
		ResultSet noteRs = noteStmt.executeQuery();

		while (noteRs.next()) {
		    int noteId = noteRs.getInt("id");
		    String noteTitle = noteRs.getString("title");
		%>
		    <div><a class="content" href="showMemo.jsp?id=<%= noteId %>"><%= noteTitle %></a></div>
		<%
		}
			noteRs.close();
			noteStmt.close();
	%>
		<div id="catEdit">
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
		
		<br>

	</details>
<%

	}
	categoryRs.close();
	categoryStmt.close();
	con.close();
%>
	
	
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
	<div id="curCategory" style="height:21px;"></div>
	<div id="curMemo">
		메모 관리 프로그램에 오신 것을 환영합니다. <br>
		메모를 추가하시려면 카테고리를 먼저 선택해주세요.
	
	</div>
</div>
</div>



</body>
</html>


