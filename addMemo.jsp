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
<link rel="stylesheet" href="addMemo.css" type="text/css">
<!-- <script src="addMemo.js"></script> -->

<title>addMemo</title>
</head>



<body>
<div id="box">
<div id="menubar">

	<div style="height: 450px">
	
	
		<div class="searching">
			<input type="text" id="searchInput" class="search">
			<button id="searchButton" class="search">검색</button>
		</div>

		<div class="categoryBox">
		
		

		
			<%
			while(categoryRs.next()){ 
				int categoryId = categoryRs.getInt("Id");
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
			categoryStmt.close();
			
			%>
		
		</div>

	</div>
	
	<div id="addCatDiv">
<!-- 		<button id="addMemo">Add Memo</button> -->
		<button id="addCategory" type="submit" 
		onclick="location.href='addCategory.jsp'">Add Category</button>
		
	</div>
</div>



<div id="memoscreen">

	<%
		String curCat = request.getParameter("curCategoryId");
		int curCategoryId = Integer.parseInt(curCat);
		
		String catName = "";
		String sql = "SELECT name FROM category WHERE id = ?";
		PreparedStatement stmt = con.prepareStatement(sql);
		stmt.setInt(1, curCategoryId);
		ResultSet rs = stmt.executeQuery();
		if (rs.next()) {
			catName = rs.getString("name");
		}
		rs.close();
		stmt.close();
		con.close();
		
	%>
	<form method="post" action="afterAddMemo.jsp">
	<div id="screenUpper">
		<div class="screenUpper" id="curCategory" ><%= catName %></div>
		<img class="screenUpper" id="unlock" src="./unlock.png" 
		width="30" height="30" onclick="lock()"/>
		<input type="hidden" name="loc" value="false" id="loc">
	</div>
	
	
	<div id="curMemo">
		<div class="title">
			<!-- <input type="button" id="important" value="☆"> -->
			<input type="button" id="important" value="☆">
			<input type="hidden" name="important" id="hiddenImportant" value="☆" />
			
			
			<input type="text" id="memoTitle" name="memoTitle"
			placeholder="제목을 입력하세요" >
		</div>
		
		
		<div id="curDate"></div>
		<input type="hidden" name="curDate" id="hiddenCurDate">
		
		<input type="text" id="writeMemo" name="writeMemo"
		placeholder="메모를 입력하세요"
		style="width: 95%; height:70%;">
	
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



<script>


// save 버튼을 눌렀을 때 제목, 내용, 사진파일, 중요여부, 배경색, 날짜, 메모번호를 알림창으로 출력
function save(){
	
	var t = document.getElementById('memoTitle');
	var title = t.value;
	
	var c = document.getElementById('writeMemo');
	var cont = c.value;
	
	var p = document.getElementById('photo');
	var photo = p.value;
	
	var bc = document.getElementById('color');
	var backColor = bc.value;
	/* var date = document.getElementById('curDate') */
	var starMemo = "";
	
	if (importantMemo == false) starMemo = "중요하지 않음";
	else starMemo = "중요함";
	
	var num = addMemoNum(title);
	
	alert(
			'메모 번호: ' + num + '\n'
			+ 'title: ' + title + '\n' + 'content: ' + cont
			+ '\n' + '중요 여부: ' + starMemo
			+ '\n' + 'photo: ' + photo 
			+ '\n' + '배경색: ' + backColor
			+ '\n' + '날짜: ' + date
			);
	
	t.value = '';
	c.value = '';
	importantMemo = true;
	important();
	p.value= '';
	bc.value = '#f8d085';
	
}



// 중요여부 체크
var star = document.getElementById('important');
var hiddenStar = document.getElementById("hiddenImportant");

var importantMemo = false;
star.addEventListener("click", important)

function important(){
	if (importantMemo == true) {
		importantMemo = false;
		star.value = "☆";
		hiddenStar.value= "☆";
		// alert(hiddenStar.value);
		
	}
	else {
		importantMemo = true;
		star.value = "★";
		hiddenStar.value= "★";
		// alert(hiddenStar.value);
	}
}

/* function important(){
	var star = document.getElementById()
} */


// 현재 날짜 title 밑의 div에 표기함 

var curdate = document.getElementById('curDate');
var date = new Date();

window.onload = function(){
	
	/* curdate.innerHTML = date; */
	var year = String(date.getFullYear());
	var month = String(date.getMonth() + 1);
	var day = String(date.getDate());
	
	var d = year +'.' + month +'.' + day;	

	curdate.innerHTML = d;
	
	document.getElementById("hiddenCurDate").value = d;
}



// 메모에 입력받은 임의의 번호를 부여함
function addMemoNum(){
	var cat1 = document.getElementById('cat1');
	
	var memonumber = prompt("부여할 메모번호를 입력해주세요: ", 0)
	
    while (isNaN(memonumber)) {
    	
    	if (memonumber == null) return;
       	alert("숫자를 입력해주세요.");
       	memonumber = prompt("부여할 메모번호를 입력해주세요: ", 0)
    }
	
	var memo = document.createElement("div");
	memo.style.paddingLeft = "20px";
	memo.innerText = title + memonumber;
	cat1.appendChild(memo);
	
	return memonumber;
}


// unlock 이미지 클릭 시 prompt를 띄워서 암호를 받고 lock 상태로 바꿈
function lock(){
	pwd = prompt("4자 이상의 비밀번호를 입력하세요: ");
	
	if (pwd === null) return;
	
	while (pwd.length < 4){
		alert("비밀번호는 4자 이상이어야 합니다.");
		pwd = prompt("4자 이상의 비밀번호를 입력하세요: ");
	}
	
	document.getElementById("unlock").src = "./lock.png";
	document.getElementById("unlock").style.width = "24px";
	document.getElementById("loc").value = "true";
/* 	alert(document.getElementById("loc").value); */
 }

function timeStamp(){
	now = new Date();
	hour = String(now.getHours()).padStart(2,'0');
	min = String(now.getMinutes()).padStart(2,'0');
	timestamp = hour + ":" + minute;
	
	
}


</script>

</body>
</html>


