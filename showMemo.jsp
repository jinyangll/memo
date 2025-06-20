<%@ page contentType="text/html; charset=UTF-8" 
 			import="java.sql.*" %>

     
<!DOCTYPE html>
<html>

<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="addMemo.css" type="text/css">
<!-- <script src="addMemo.js"></script> -->

<title>showMemo</title>
</head>

<%
request.setCharacterEncoding("utf-8");
int id = Integer.parseInt(request.getParameter("id"));

Connection con = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

String title = "", content = "", bg_color = "#f8d085", date = "", important = "☆", imgsrc = "./unlock.png";
int w = 30, curCategoryId = 0;
boolean is_favorite = false, is_locked = false;

try {
    Class.forName("org.mariadb.jdbc.Driver");
    String url = "jdbc:mariadb://localhost:3305/memo?useSSL=false";
    con = DriverManager.getConnection(url, "admin", "1234");

    String sql = "SELECT * FROM note WHERE id = ?";
    pstmt = con.prepareStatement(sql);
    pstmt.setInt(1, id);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        title = rs.getString("title");
        content = rs.getString("content");
        bg_color = rs.getString("bg_color");
        Timestamp createdAt = rs.getTimestamp("created_at");
        date = createdAt.toString().substring(0, 16);
        is_favorite = rs.getBoolean("is_favorite");
        is_locked = rs.getBoolean("is_locked");
        curCategoryId = rs.getInt("category_id");
    }

    important = is_favorite ? "★" : "☆";
    
    if (is_locked) {
        imgsrc = "./lock.png";
        w = 25;
    }

} catch (Exception e) {
    out.println(e.getMessage());
} 
%>


<script>
    alert("is_favorite: <%= is_favorite %>\nis_locked: <%= is_locked %>");
</script>



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
            String categorySql = "SELECT id, name FROM category";
            PreparedStatement categoryStmt = con.prepareStatement(categorySql);
            ResultSet categoryRs = categoryStmt.executeQuery();

            while (categoryRs.next()) {
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
			<div><a class="content" href="showMemo.jsp?id=<%=noteId%>"><%= noteTitle %></a></div>
		
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
	
	con.close();
%>

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
		<img class="screenUpper" id="unlock" src="<%=imgsrc %>" 
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
			<input type="button" class="leftButtons" value="Time Stamp">
			<input type="color" class="leftButtons" id='color' value="<%= bg_color%>">
			<input type="file" class="leftButtons" id="photo" value="Photo">
		</div>
		
		
 		<%-- <div id="rightButtons">
			<!-- <button class="rightButtons" id="save" onclick="save()">Save</button> -->
			<!-- <input class="rightButtons" type="submit" value="edit"/> -->
			<button class="rightButtons" type="button" onclick="location.href='editMemo.jsp?id=<%= id %>';">edit</button>
			
			<form action="deleteMemo.jsp" method="post" style="display:inline;">
				<button class="rightButtons">delete</button>
			</form>
			
		</div> --%>
		</div>
	</form>
	
	<div id="rightButtons">
    <form method="get" action="editMemo.jsp" style="display:inline;">
        <input type="hidden" name="id" value="<%= id %>">
        <button class="rightButtons" type="submit">edit</button>
    </form>

    <form method="post" action="deleteMemo.jsp" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
        <input type="hidden" name="id" value="<%= id %>">
        <button class="rightButtons" type="submit">delete</button>
    </form>
	</div>
	
	
	
	
	</div>
</div>



</body>
</html>

