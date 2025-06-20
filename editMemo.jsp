<%@ page contentType="text/html; charset=UTF-8" 
 			import="java.sql.*" %>

     
<!DOCTYPE html>
<html>

<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="addMemo.css" type="text/css">

<title>editMemo</title>

<script>
function toggleImportant(btn) {
    const hiddenInput = document.getElementById("is_favorite");
    if (btn.value === "☆") {
        btn.value = "★";
        hiddenInput.value = "★";
    } else {
        btn.value = "☆";
        hiddenInput.value = "☆";
    }
}

function toggleLock() {
    const img = document.getElementById("unlock");
    const isLockedInput = document.getElementById("is_locked");

    if (isLockedInput.value === "1") {
        img.src = "./unlock.png";
        img.style.width = "30px";
        isLockedInput.value = "0";
    } else {
        img.src = "./lock.png";
        img.style.width = "25px";
        isLockedInput.value = "1";
    }
    
/*     alert("is_locked now: " + isLockedInput.value);*/

} 


</script>

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
    String url = "jdbc:mariadb://localhost:3305/memodb?useSSL=false";
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
		<form action="addCategory.jsp" method="post"  id="addCatWrap">
			<button id="addCategory">Add Category</button>
		</form>
	</div>
</div>

<div id="memoscreen" style="background-color: <%= bg_color %>">

	<form method="post" action="afterEditMemo.jsp" >
		<input type="hidden" name="id" value="<%= id %>">
		
		<div id="screenUpper">
			<div class="screenUpper" id="curCategory"><%= categoryName %></div>
			
			
			<input type="hidden" id="is_locked" name="is_locked" value="<%= is_locked ? "1" : "0" %>">
			<img class="screenUpper" id="unlock" src="<%=imgsrc %>" 
				width="<%=w %>px" height="30" style="cursor:pointer;"onclick="toggleLock()" />
		</div>
		
		<div id="curMemo">
			<div class="title">
			<input type="hidden" id="is_favorite" name="important" value="<%= important %>">
				<input type="button" id="important" name="importantBtn" value="<%= important %>" 
					onclick="toggleImportant(this)" style="font-size: 1.5em; width:40px; cursor:pointer;">
				
				<!-- 제목 input -->
				<input type="text" id="memoTitle" name="memoTitle" 
					value="<%= title %>" style="background-color: <%= bg_color %>; width: 80%; font-size: 1.3em;">
			</div>
			
			<div id="curDate"><%= date %></div>
			
			<textarea id="writeMemo" name="memoContent" rows="15" style="width: 100%; font-size:1.1em;"><%= content %></textarea>
			
			
			
			
			<select id="category_id" name="category_id">
			<%
				// 카테고리 목록을 다시 불러와서 select 옵션으로 넣기
				Connection con2 = null;
				PreparedStatement psCat = null;
				ResultSet rsCat = null;
				try {
					Class.forName("org.mariadb.jdbc.Driver");
					String url2 = "jdbc:mariadb://localhost:3305/memo?useSSL=false";
					con2 = DriverManager.getConnection(url2, "admin", "1234");
					String catSql = "SELECT id, name FROM category";
					psCat = con2.prepareStatement(catSql);
					rsCat = psCat.executeQuery();
					while (rsCat.next()) {
						int catId = rsCat.getInt("id");
						String catName = rsCat.getString("name");
			%>
				<option value="<%= catId %>" <%= (catId == curCategoryId) ? "selected" : "" %> ><%= catName %></option>
			<%
					}
				} catch (Exception e) {
					out.println(e.getMessage());
				} 
			%>
			</select>
		</div>
		
			<div class="buttons">
				<div id="leftButtons">
					<input type="color" class="leftButtons" id='color' name="color" value="#f8d085">
					<input type="file" class="leftButtons" id="photo" value="photo" name="photo">
				</div>
				
				<div id="rightButtons">
					
					<input class="rightButtons" type="submit" value="save"/>
					<input type="hidden" name="curCategoryId"  id="curCategoryId" value="<%=curCategoryId %>">
					<button type="button" class="rightButtons" onclick="history.back()">Cancel</button>
				</div>
				
			</div>
				
		
		</form>
	</div>
	</div>
</body>
</html>