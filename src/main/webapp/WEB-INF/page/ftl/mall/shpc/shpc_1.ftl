<#assign sec=JspTaglibs["/WEB-INF/security.tld"] />   <#-- 引入security.tld标签-->
<#assign ctx = request.contextPath/>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
   <title>销售拣单</title>
   <link rel="stylesheet" href="${ctx}/mall/css/bootstrap.min.css">
   <link href="${ctx}/mall/css/theme.css" rel="stylesheet">
   <link href="${ctx}/mall/css/pulic.css" rel="stylesheet" type="text/css">
   <script src="${ctx}/mall/js/jquery-1.11.1.min.js" type="text/javascript"></script>
   <script type="text/javascript" src="${ctx}/mall/js/extendPagination.js"></script>
   
    <!-- 创建订单导入开始 -->
	<link href="${ctx}/mall/css/bootstrap-table.css" rel="stylesheet">
	<link href="${ctx}/mall/css/bootstrap-datetimepicker.css" rel="stylesheet">
	<script src="${ctx}/mall/js/bootstrap.min.js"></script>
	<script src="${ctx}/mall/js/bootstrap-table.js"></script>
	<script src="${ctx}/mall/js/bootstrap-table-zh-CN.js"></script>
	<script src="${ctx}/mall/js/moment-with-locales.js"></script>
	<script src="${ctx}/mall/js/bootstrap-datetimepicker.js"></script>
	<script src="${ctx}/mall/js/serializeJson.js"></script>
	<script src="${ctx}/mall/js/createOrder.js"></script>
	<script type="text/javascript" src="${ctx}/common/jqueryValidation/js/jquery.validationEngine-zh_CN.js"></script>
	<script type="text/javascript" src="${ctx}/common/jqueryValidation/js/jquery.validationEngine.min.js"></script>
	<link rel="stylesheet" type="text/css" href="${ctx}/common/jqueryValidation/css/validationEngine.jquery.css" />
	<!-- 创建订单导入结束 -->
	 <script src="${ctx}/common/js/common.js"></script>
<script type="text/javascript">
		/**
	   * 为table指定行添加一行
	   * tab 表id
	   * row 行数，如：0->第一行 1->第二行 -2->倒数第二行 -1->最后一行
	   * trHtml 添加行的html代码
	   */
	  function addTr(tab, row, trHtml){
	     //获取table最后一行 $("#tab tr:last")
	     //获取table第一行 $("#tab tr").eq(0)
	     //获取table倒数第二行 $("#tab tr").eq(-2)
	     var $tr=$("#"+tab+" tr").eq(row);
	     if($tr.size()==0){
	        alert("指定的table id或行数不存在!");
	        return;
	     }
	     $tr.after(trHtml);
	  }
	  //校验数量
	function jiaoyanNum(obj){
		$(obj).validateNumber();
	} 
	//查询商品
	function showGood(){
		//alert("查询");
		$.ajax({
				url : '${ctx}/GoodController/serachGood.do',// 跳转到 action
				data : {
							categoryId:$("#showCategory").val(),
							pageNo : 1,
							pageSize : 2,
							goodStatus:00
				},
				type : 'POST',
				cache : false,
				dataType : 'json',
				success : function(data) {
					data = eval(data);
					//先清空table中的数据
					$("#showTable  tr:not(:first)").remove();
					if(data.mtList.length>0){
						for ( var i = 0; i < data.mtList.length; i++) {
					
							var content = '';
							
							var path = "${ctx}"+data.mtList[i].imgPath;
							var idName = data.mtList[i].goodsId+","+data.mtList[i].name;
							content += "<tr>";
							content += "<td style='vertical-align:middle'><input type='checkbox' name='goodCheckbox' value='"+idName+"' onclick='checkRedio(this);' /></td>";
							content += "<td><img src='"+path+"' style='height:50px; width:50px;'></td>";
							content += "<td style='vertical-align:middle'>"+data.mtList[i].name+"</td>";
							content += "<td style='vertical-align:middle'>"+data.mtList[i].minPrice+"--"+data.mtList[i].maxPrice+"</td>";
							
						
							content += "<td style='vertical-align:middle'>"+data.mtList[i].productNum+"</td>";
							content += "<td style='vertical-align:middle'>"+data.mtList[i].factory+"</td>";
							
							content += '</tr>';
							addTr('showTable', -1, content);
							
						}
						var mm ='';
						mm += "<tr><td class='text-right' colspan='6'>";
						mm += "<a class='btn btn-info' href='#' onclick='checkSub();' >确定</a>";                                   
					    mm += "<a class='btn btn-warning' href='#' onclick='checkClose();' >取消</a></td>";
						mm += "</tr>";
						addTr('showTable', -1, mm);
						setPagination(1, 2, data.mtCount);
						$("#selectGoods").modal('show');
					}else{
						alert("对不起，您没有该品类商品");
						$("#showCategory").val("");
						$("#goodIndex").val("");
						$("#selectGoods").modal('hide');
					}
					
				},
				error : function() {
					alert("异常！");
				}
		});		
	}
	function setPagination(curr, limit, totalCount) {
			//alert("分页");
			$('#callBackPager1').extendPagination({
				totalCount : totalCount,
				showCount : limit,
				limit : limit,
				callback : function(curr, limit, totalCount) {
					
					$.ajax({
						url : '${ctx}/GoodController/serachGood.do',// 跳转到 action
						data : {
									categoryId:$("#showCategory").val(),
									pageNo : curr,
									pageSize : limit,
									goodStatus:0
						},
						type : 'POST',
						cache : false,
						dataType : 'json',
						success : function(data) {
							data = eval(data);
							//先清空table中的数据
									$("#showTable  tr:not(:first)").remove();
									if(data.mtList.length>0){
											for ( var i = 0; i < data.mtList.length; i++) {
								
													var content = '';
												
													var path = "${ctx}"+data.mtList[i].imgPath;
													var idName = data.mtList[i].goodsId+","+data.mtList[i].name;
													content += "<tr>";
													content += "<td style='vertical-align:middle'><input type='checkbox' name='goodCheckbox' value='"+idName+"' onclick='checkRedio(this);' /></td>";
													content += "<td><img src='"+path+"' style='height:50px; width:50px;'></td>";
													content += "<td style='vertical-align:middle'>"+data.mtList[i].name+"</td>";
													content += "<td style='vertical-align:middle'>"+data.mtList[i].minPrice+"--"+data.mtList[i].maxPrice+"</td>";
													content += "<td style='vertical-align:middle'>"+data.mtList[i].productNum+"</td>";
													content += "<td style='vertical-align:middle'>"+data.mtList[i].factory+"</td>";
													
													content += '</tr>';
									
													addTr('showTable', -1, content);
										
											}
											var mm = '';
											mm += "<tr><td>";
											mm += "<a class='btn btn-info' href='#' onclick='checkSub();' >确定</a>";                                   
					                        mm += "<a class='btn btn-warning' href='#' onclick='checkClose();' >取消</a></td>";
											mm += "</tr>";
											addTr('showTable', -1, mm);
											$("#selectGoods").modal('show');
											
									}else{
											//alert("无数据");
											$("#showCategory").val("");
											$("#goodIndex").val("");
										
											$("#selectGoods").modal('hide');
									}
						},
						error : function() {
							alert("异常！");
						}
				});
				}
			});
	}
	//多选框实现单选
	function checkRedio(obj){
 
		if($(obj).prop('checked')==true){
			$("#showTable tr td [name = goodCheckbox]:checkbox").removeAttr('checked');
			$(obj).prop('checked','true');
		}				
	} 
	//确认按钮
	function checkSub(){
		//获取选中的值
		//获取选中的多选框按钮的值
	  	var checkedGroups = $("#showTable tr td [name = goodCheckbox]:checked");
		var stringsId = "";
		checkedGroups.each(function(i,thisElement){
			if(thisElement.value!=""){
				stringsId+=thisElement.value;
			}
		});
		//alert(stringsId);
		if(stringsId.length==0){
			alert("请先选择商品!");
			return false;
		}
		//alert(stringsId);
		var index = $("#goodIndex").val();
		//alert(index);
		//修改购物车信息
		$.ajax({
				url : '${ctx}/shpc/updateQuoteSHPC.do',// 跳转到 action
				data : {
							type : 0,
							stringsId : stringsId,
							index : index
				},
				type : 'POST',
				cache : false,
				dataType : 'json',
				success : function(data) {
					if(data=="0"){
						alert("选择商品成功");
						//重新查询
						checkClose();
						showShpc();
					}else{
						alert("失败");
					}
				}
		});
		
		
	}
	//取消按钮
	function checkClose(){
		$("#showCategory").val("");
		$("#goodIndex").val("");								
		$("#selectGoods").modal('hide');
	}
	 //选择商品 showCategory   categery 品类Id  index 捡单车位置
	function appointGood(categery,index){
		
		//childBase.$("#showCategory").val(categery);
		//alert(childBase.$("#showCategory").val());
		$("#showCategory").val(categery);
		$("#goodIndex").val(index);
		//alert($("#showCategory").val());
		showGood();
		
	}
	 
	//全选反选  showShpcTable
	function checkAllShpc(obj,index){	
		$("#showShpcTable tr td [name ='"+index+"']:checkbox").each(function(i,thisElement){
			if($(obj).prop("checked")==true){
		      $(thisElement).prop("checked",'true');
			}else{
				$(thisElement).prop("checked",false);
			}
		});
	}
	
	//删除
	function delShpc(index){
		//获取选中的报价在捡单车中的位置
		//alert(index);
		$.ajax({
				url : '${ctx}/shpc/deleteQuoteSHPC.do',// 跳转到 action
				data : {
							type : 0,
							index : index
				},
				type : 'POST',
				cache : false,
				dataType : 'json',
				success : function(data) {
					if(data==0){
						alert("删除成功");
						//重新查询
						showShpc();
					}else{
						alert("删除失败");
					}
				}
		});
	}
	//自动加载
	var createOrder;
	var pp = "";
		$(function(){
			//alert("自动加载");
			showShpc();
			createOrder = new createOrder("changeChar",'${Session.user.getMuser().getMmbId()}','${Request.basePath}',delMany);
			$("#shopForm").validationEngine('attach',{
					scroll:false,
					autoHidePrompt:true,
					autoHideDelay:2500,
					promptPosition : "bottomLeft"
			 });
			 $("#showShpcTable tr td [name='num']").on("input propertychange", function() {
				$(this).validateNumber();
				
			});
			$("#showShpcTable tr td [name='num']").addClass("validate[required,custom[integer]]");
			
		});
		
	//显示页面    获取采购报价
	function showShpc(){
		$.ajax({
				url : '${ctx}/shpc/serachSHPC.do',// 跳转到 action
				data : {
							type : 0,
				},
				type : 'POST',
				cache : false,
				dataType : 'json',
				success : function(data) {
					data = eval(data);
					
					//先清空table中的数据
					$("#showShpcTable  tr:not(:first)").remove();
					if(data!=null&&data!=""){
						//遍历Map key值为id+name
						for(var key in data) { 
   							 var nn= new Array(); 
   							 //添加用户
   							 if(key!=null&&key!=""){
   							 	
	   							 nn = key.split(",");
	   							 var user = "";
								 user += "<tr>"
								 user += "<td><input type='checkbox' id='"+nn[0]+"' onclick=checkAllShpc(this,'"+nn[0]+"') /></td>";
								 user += "<td colspan='8'>采购方："+nn[1]+"</td></tr>";
								 addTr('showShpcTable', -1, user);
   							  
   							 
							 //遍历报价
							 if(data[key]!=null&&data[key].length>0){
							 		for ( var i = 0; i < data[key].length; i++) {
										var content = "";
										content +=" <tr class='success'>";
										//拼接传值顺序   商品Name  最小值  最大值 会员名称  顺序
										var aa = data[key][i].goodsName+","+data[key][i].minPrice+","+data[key][i].maxPrice+","+data[key][i].mmbName+","+data[key][i].index;
										content +="<td><input type='checkbox' name='"+nn[0]+"' id='"+data[key][i].index+"' value='"+aa+"'></td>"
										if(data[key][i].mateId!=""&&data[key][i].mateId!="null"&&data[key][i].mateId!=null){
											content +="<td>"+data[key][i].goodsName+"</td>";
										}else {
											content +="<td><span style='color:red;'>"+data[key][i].goodsName+"</span></td>";
										}
										content +="<td>"+data[key][i].minPrice+"---"+data[key][i].maxPrice+"</td>";
										content +="<td><input type='text' class='input-size validate[required,custom[integer]]' name='num' onpropertychange=jiaoyanNum(this) oninput=jiaoyanNum(this) /></td>";
										content +="<td>"+data[key][i].mmbName+"</td>";
										content +="<td><a href='#' class='cx-btn-margin' onclick=appointGood('"+data[key][i].categoryId+"','"+data[key][i].index+"')>指定商品</a>";
										content +="<a href='#'   onclick=delShpc('"+data[key][i].index+"')>删除</a>";
										content +="<input type= 'hidden' name='goodCheck' value='"+data[key][i].mateId+"'  />"
										
										content += '</td>';
										content += '</tr>';
										addTr('showShpcTable', -1, content);
									}	
							 }
							 //添加下单
							 var xiadan ="";
							 xiadan +="<tr class='text-right'>";
							 xiadan +="<td colspan='5' style='vertical-align: middle;'></td>";
							 xiadan +="<td colspan='1' ><button class='btn btn-warning cx-btn-margin' type='button' onclick=showOrder('"+nn[0]+"')>下单</button></td>";
							 xiadan +="</tr>";
							 addTr('showShpcTable', -1, xiadan);	 
						} 
						}
					}else{
						//alert("该用户没有数据!");
					}
				},
				error : function() {
					alert("异常！");
				}
		});		
	};
	//下单  采购报价登陆人座位买家
	function showOrder(mmbId){
		
		
		//获取选中的多选框按钮的值
	  	var checkedGroups = $("#showShpcTable tr td [name = '"+mmbId+"']:checked");
		var stringsId = "";
		checkedGroups.each(function(i,thisElement){
			if(thisElement.value!=""){
				stringsId+=thisElement.value+":";
			}
		});
		
		if(stringsId.length==0){
			alert("请先勾选报价!");
			return false;
		}
		//alert(mmbId);
		//获取登录人Id 以及name 作为卖家
		var sellersId = "${Session.user.getMuser().getMmbId()}";
		var sellersName = "${Session.user.getMuser().getMmbName()}";
		//mmbId 作为买家Id
		var buyersId = mmbId;
		var buyersName ="";
		//alert(buyersId+"=============="+buyersName)
		//赋值的参数
		var dataOrder = new Object();
		//商品编号字符串
		var indexs ="";
		//商品行集合
		var list = new Array();
		var i = 0;
		
		$('#showShpcTable').find("tr:not(first)").each(function(i,element){
			var check = $(element).find("input[name='"+mmbId+"']:checkbox").prop("checked");
			if(check == true){
				//var goodName = document.getElementById("showShpcTable").rows[i].cells[1].innerHTML;
				//是否指定商品
				var goodId = $(element).find("input[name=goodCheck]").val();
				//alert(goodId);
				if(goodId==""||goodId=="null"||goodId==null){
					
					alert("请先匹配商品");
					$("#changeChar").modal("hide");
					return fasle;
				}
				//获取输入的数量
				var number = $(element).find("input[name='num']").val();
				if(number==null||number==""){
					alert("数量不能为空");
					$("#changeChar").modal("hide");
					return fasle;
				}
				//获取数据
				var goods = $(element).find("input[name='"+mmbId+"']").val();
				//alert(goods);
				 if(goods!=null&&goods!=""){
				 	 var nn = new Array();
					//  0name 1min 2man 3mmbName 4index
					 nn = goods.split(",");
					 var good = new Object;
					 good.id = "";
					 good.goodsId = goodId;
					 good.goodsName = nn[0];
					 good.goodsNum = number;
					 good.price ="";
					 good.money ="";
					 good.buyersId = buyersId;
					 buyersName = nn[3];
					 good.buyersName = buyersName;
					 good.sellersId = sellersId
					 
					 good.sellersName = sellersName;
					 good.min = nn[1];
					 good.max = nn[2];
				 	 list.push(good);
					 indexs += nn[4]+","; 
					 i += 1;
					 
				 }else{
				    alert("请先选择一个报价");
				    return false;
				 }
				 
			}
		});
		dataOrder.data = list;
		dataOrder.total = list.length;
		if(dataOrder.total>100){
			alert("商品数量不能超过100条");
			$("#changeChar").modal("hide");
			return fasle;
		}
		//ajax 获取地址银行
		$.ajax({
				url : '${ctx}/order/queryAddressAccount.do',// 跳转到 action
				data : {
							buyersId : buyersId,
							sellersId : sellersId
				},
				async: false,
				type : 'POST',
				cache : false,
				dataType : 'json',
				success : function(data) {
					data = eval(data);
					if(data!=null&&data!=""){
						dataOrder.buyersAddressList = data.buyersAddressList;
						dataOrder.sellersAddressList = data.sellersAddressList;
						dataOrder.buyersAccountList = data.buyersAccountList;
						dataOrder.sellersAccountList = data.sellersAccountList;
						
					}
				}
		});
		//alert(indexs);
		//订单头对象
		var title = new Object();
		title.buyersId = buyersId;
		title.buyersName = buyersName;
		title.sellersId = sellersId;
		title.sellersName = sellersName;
		title.totalMoney = "";
		title.payBank = "";
		title.payAccount = "";
		title.getBank = "";
		title.getAccount = "";
		dataOrder.ordertitle = title;
		//alert(dataOrder.total);
		//alert(indexs);
		$("#changeChar").modal("show");
		createOrder.initOrder(dataOrder);
		//将下单的报价移除
		indexs = indexs.substring(0,indexs.length-1);
		pp = indexs;
			
	}
	//批量删除
	function delMany(){
	   //alert("====="+pp);
	   
		
			$.ajax({
					url : '${ctx}/shpc/deleteMoreSHPC.do',// 跳转到 action
					data : {
								type : 0,
								index : pp
					},
					type : 'POST',
					cache : false,
					dataType : 'json',
					success : function(data) {
						if(data=="0"){
							//重新显示
							showShpc();
						}
						
					}
			});
	}
	
</script>
</head>

<body>
<div class="container-fluid" style="margin-top:15px;">
	<div class="modal fade" id="changeChar" role="dialog" aria-labelledby="gridSystemModalLabel"></div>
    <div class="row-fluid">
        <!-- col-sm-12 -->
        <div class="col-sm-12 ">
        	<div class="panel panel-default article-bj">
                <div class="panel-heading box-shodm">
                销售拣单车
                </div>
                    <div class="table-responsive panel-table-body ">
                    	<form id="shopForm" 　method="post">
                        <table class="table table-striped table-hover" id="showShpcTable">
                            <thead>
                                <tr>
                               
                                    <th colspan="2">商品信息</th>
                                    <th>单价（元）</th>
                                    <th>数量（pcs）</th>
                                    <th>所属商家</th> 
                                    <th>操作</th>
                                </tr>
                                </tr>
                            </thead>
                            <tbody>
                          
                            </tbody>
                        </table>
                        </form>
                    </div> 
                    <footer class="panel-footer text-right bg-light lter">
                    	 <div id="callBackPager" float="right;"></div>
                    </footer>
        		</div>
       		 </div>
        </div>
    </div> 
</div>
<!--弹出指定商品页面-->
<script>
$(document).ready(function(e) {
    $('.A_b_2_nav_left>li').click(function(){
		$('.A_b_2_subnav').slideUp()
		$(this).next('ul').stop().slideDown()
		})
	$('.A_b_2_subnav li a').click(function(){
		$('.A_b_2_subnav li a').css('color','#333')
		$(this).css('color','#4aa3df')
		$($(this).attr('href')).show()
		})
});
</script>
<div class="modal fade" id="selectGoods" role="dialog" aria-labelledby="gridSystemModalLabel">
	<!-- 商品嵌入资料库
	<div class="modal-dialog " role="document" style="width:1000px;"> 
		<iframe  name="childBase"  src="${ctx}/GoodController/toshowAppointGoodNoFilter.do" width="100%" height="100%" frameborder="0"  scrolling="auto" />
	</div>
	-->
		<div class="panel panel-default article-bj" style="width:1000px;margin-left:400px;" >
		 	<input type="hidden" id="showCategory" />
		 	<input type="hidden" id="goodIndex" />
		    <div class="panel-heading box-shodm  modal-draggable">
		    商品信息
		    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		    </div>
		    <div class="row wrapper form-margin">
		         <div class="col-md-6">
		            <div class="input-group">
		                 <div class="input-group-btn">
		                    <h5 class="h5-margin" style="margin-left:20px;">名称:</h5>
		                 <!--   <button class="btn" type="button"></button> -->
		                 </div>
		                 <input type="text" placeholder="" class="form-control" name="input1-group3" id="input1-group3">
		            </div>
		        </div>
		        <a id="searchGood" class="btn btn-info btn-s-md btn-default " href="#" onclick="showGood();">查询</a>
		     </div>
		    <div class="table-responsive panel-table-body ">
		        <table class="table table-striped table-hover" id = "showTable">
		            <thead>
		                <tr>
		                	<td>选择</td>
		                    <th>图片</th>
		                    <th>商品名称</th>
		                    <th>价格范围</th> 
		                    <th>生产编号</th>
		                    <th>生产厂家</th>
		                </tr>
		            </thead>
		            <tbody>
		               
		            </tbody>
		        </table>
		    </div> 
		    <footer class="panel-footer text-right bg-light lter">
		        <div id="callBackPager1" float="right;"></div>
		    </footer>
		 </div>
</div>
</div>
</body>
</html>
