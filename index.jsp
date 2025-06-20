<%@ page language="java" contentType="text/html; charset=UTF-8"
    import="java.sql.*" %>

<%

request.setCharacterEncoding("utf-8");

Class.forName("org.mariadb.jdbc.Driver");

String url = "jdbc:mariadb://localhost:3305/memo?useSSL=false";

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
			<input type="text" id="searchInput" class="search">
			<button id="searchButton" class="search">검색</button>
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
		<form action="addMemo.jsp" method="post"  id="addMemoWrap">
		<input type="hidden" name="curCategoryId" value="<%= categoryId %>">
		<button id="addMemo" type="submit">Add Memo</button>
		</form>
		<br>
	
	</details>
<%

	}
	categoryRs.close();
	categoryStmt.close();
	con.close();
%>
	
	
<!-- 	<details>
	<summary class="category">카테고리 1</summary>
	<div><a class="content">메모1</a></div>
	<div><a class="content">메모2</a></div>
	</details>
	
	<br>
	
	<details>
	<summary class="category">카테고리 2</summary>
	<div><a class="content">메모3</a></div>
	<div><a class="content">메모4</a></div>
	</details> -->
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


