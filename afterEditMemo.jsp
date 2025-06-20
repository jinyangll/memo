<%@ page contentType="text/html; charset=UTF-8" 
 			import="java.sql.*" %>

     
<!DOCTYPE html>
<html>

<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="addMemo.css" type="text/css">
<!-- <script src="addMemo.js"></script> -->

<title>afterEditMemo</title>
</head>

<script>

<%
request.setCharacterEncoding("utf-8");






int id = Integer.parseInt(request.getParameter("id"));  // 수정할 메모 id
String title = request.getParameter("memoTitle");
String content = request.getParameter("memoContent");  // writeMemo → memoContent
String bg_color = request.getParameter("color");

String important = request.getParameter("important");
boolean is_favorite = "★".equals(important);
String loc = request.getParameter("loc");
boolean is_locked = "1".equals(loc);
String password = is_locked ? "lock1234" : null;

String date = request.getParameter("curDate"); 



String imgsrc = "";
int w = 0;

if ("1".equals(loc)){
imgsrc = "./lock.png";
w = 25;
} 
else {
imgsrc = "./unlock.png";
w=30;
}




int categoryId = Integer.parseInt(request.getParameter("category_id"));
Connection con = null;
PreparedStatement pstmt = null;

try {
	Class.forName("org.mariadb.jdbc.Driver");
	String url = "jdbc:mariadb://localhost:3305/memodb?useSSL=false";
	con = DriverManager.getConnection(url, "admin", "1234");

	String sql = "UPDATE note SET title=?, content=?, bg_color=?, category_id=?, is_locked=?, is_favorite=? WHERE id=?";
	pstmt = con.prepareStatement(sql);
	pstmt.setString(1, title);
	pstmt.setString(2, content);
	pstmt.setString(3, bg_color);
	pstmt.setInt(4, categoryId);
	pstmt.setBoolean(5, is_locked);
	pstmt.setBoolean(6, is_favorite);
	pstmt.setInt(7, id);

	pstmt.executeUpdate();

	response.sendRedirect("showMemo.jsp?id=" + id);

} catch (Exception e) {
	out.println( e.getMessage());
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
		<form method="get" action="searchMemo.jsp" style="margin-bottom: 10px;">
		    <input type="text" id="searchInput" name="keyword" class="search" placeholder="검색어를 입력하세요">
		    <button type="submit" id="searchButton" class="search">검색</button>
		</form>
	</div>
	
		<div>
	<%
	while(categoryRs.next()){ 
		int catId = categoryRs.getInt("id");
		String categoryName = categoryRs.getString("name");
	%>
		<details class="categoryDetails" data-category-id="<%= catId %>">
			<summary class="category"><%=categoryName %></summary>
		
		<%
			String noteSql = "SELECT id, title FROM note WHERE category_id=?";
			
			PreparedStatement noteStmt = con.prepareStatement(noteSql);
			noteStmt.setInt(1, catId);
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
		<input type="hidden" name="curCategoryId" value="<%= catId %>">
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
	getCategoryNameStmt.setInt(1, categoryId);
	ResultSet getCategoryNameRs = getCategoryNameStmt.executeQuery();

	if (getCategoryNameRs.next()) {
	    categoryName = getCategoryNameRs.getString("name");
	}

	getCategoryNameRs.close();
	getCategoryNameStmt.close();
	
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



<div id="memoscreen" style="background-color: <%= bg_color %>">



	<form method="post" action="afterEditMemo.jsp" >
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
		

		
 		<div id="rightButtons">
			<!-- <button class="rightButtons" id="save" onclick="save()">Save</button> -->
			<input class="rightButtons" type="submit" value="edit"/>
			<button class="rightButtons">delete</button>
		
		
		</div>
		
	</form>
	</div>
</div>	



</body>
</html>

