<%@ page contentType="text/html; charset=UTF-8" 
 			import="java.sql.*" %>

     
<!DOCTYPE html>
<html>

<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="addMemo.css" type="text/css">
<!-- <script src="addMemo.js"></script> -->

<title>afterAddMemo</title>
</head>

<script>

<%

request.setCharacterEncoding("utf-8");

String title = request.getParameter("memoTitle");
String content = request.getParameter("writeMemo");
String bg_color = request.getParameter("color");

String important = request.getParameter("important");
Boolean is_favorite = "★".equals(request.getParameter("important"));

String date = request.getParameter("curDate"); 
String loc = request.getParameter("loc");
Boolean is_locked = "true".equals(loc);
String password = is_locked  ? "lock1234" : null;

// 비밀번호 받아서 db에 저장해야함

int curCategoryId = Integer.parseInt(request.getParameter("curCategoryId"));

Connection con = null;
PreparedStatement pstmt = null;

try {
	Class.forName("org.mariadb.jdbc.Driver");
	String url = "jdbc:mariadb://localhost:3305/memo?useSSL=false";

	con = DriverManager.getConnection(url, "admin", "1234");
	
	String sql = "INSERT INTO note (category_id, title, content, is_favorite, is_locked, lock_password, bg_color)"+
			"VALUES (?, ?, ?, ?, ?, ?, ?)";
	pstmt = con.prepareStatement(sql);
	
	pstmt.setInt(1, curCategoryId);
	pstmt.setString(2, title);
	pstmt.setString(3, content);
	pstmt.setBoolean(4, is_favorite);
	pstmt.setBoolean(5, is_locked);
	pstmt.setString(6, password);
	pstmt.setString(7, bg_color);
	
	
	pstmt.executeUpdate();
	
/* 	response.sendRedirect("index.jsp");   */
 
} catch (Exception e) {
	out.println(e.getMessage());
}

//////////////////////////////////////////

String imgsrc = "";
int w = 0;

if ("true".equals(loc)){
imgsrc = "./lock.png";
w = 25;
} 
else {
imgsrc = "./unlock.png";
w=30;
}


%>

</script>


<%

String categorySql = "SELECT id, name FROM category";
PreparedStatement categoryStmt = con.prepareStatement(categorySql);
ResultSet categoryRs = categoryStmt.executeQuery();

%>


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
			
			while (noteRs.next()){
				
		%>
			<div><a class="content" href="showMemo.jsp?id=<%= noteRs.getInt("id") %>">
    <%= noteRs.getString("title") %></a></div>
		
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
	
	String categoryName = "";
	String getCategoryNameSql = "SELECT name FROM category WHERE id=?";
	PreparedStatement getCategoryNameStmt = con.prepareStatement(getCategoryNameSql);
	getCategoryNameStmt.setInt(1, curCategoryId);
	ResultSet getCategoryNameRs = getCategoryNameStmt.executeQuery();

	if (getCategoryNameRs.next()) {
	    categoryName = getCategoryNameRs.getString("name");
	}

	getCategoryNameRs.close();
	getCategoryNameStmt.close();
	
	categoryStmt.close();
	con.close();
%>

	<!-- <div class="categoryBox">
	<details id="cat1" open>
	<summary class="category" style="padding-left: 20px;">카테고리 1</summary>
	<div><a class="content">메모1</a></div>
	<div><a class="content">메모2</a></div>
	
	</details>
	
	<br>
	
	<details>
	<summary class="category" style="padding-left: 20px;">카테고리 2</summary>
	<div style="margin-left: 20px;"><a class="content">메모3</a></div>
	<div style="margin-left: 20px;"><a class="content">메모4</a></div>
	</details> -->
	</div>


	</div>
	
	<div id="addCatDiv">
	
<!-- 		<form action="addMemo.jsp" method="post" style="display:inline-block">
		<button id="addMemo">Add Memo</button>
		</form> -->
		
		<button id="addCategory">Add Category</button>
	</div>
</div>



<div id="memoscreen" style="background-color: <%= bg_color %>">



	<form method="post" action="afterAddMemo.jsp">
	<div id="screenUpper">
		<div class="screenUpper" id="curCategory"><%= categoryName %></div>
		<img class="screenUpper" id="unlock" src=<%=imgsrc %> 
		width="<%=w %>px" height="30" style="cursor:auto;"/>
	</div>
	
	<div id="curMemo">
		<div class="title">
			<!-- <input type="button" id="important" value="☆"> -->
			<input type="button" id="important" 
			value="<%= important %>">
			<input type="text" id="memoTitle" name="memoTitle" readonly
			value="<%=title %>" style="background-color: <%= bg_color %>">

			
		</div>
		<div id="curDate"><%=date %></div>
		
		<%=content %>
		
	</div>
	
	<div class="buttons">
		<div id="leftButtons" style="visibility:hidden;">
			
			<input type="color" class="leftButtons" id='color' value="#f8d085">
			<input type="file" class="leftButtons" id="photo" value="Photo">
		</div>
		
		
 		<div id="rightButtons">
			<!-- <button class="rightButtons" id="save" onclick="save()">Save</button> -->
			<input class="rightButtons" type="submit" value="edit"/>
			<button class="rightButtons">delete</button>
		
		
		</div>
		</div>
	</form>
	</div>
</div>



</body>
</html>

