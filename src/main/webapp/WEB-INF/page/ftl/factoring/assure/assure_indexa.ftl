<#assign sec=JspTaglibs["/WEB-INF/security.tld"] />   <#-- 引入security.tld标签-->
<#assign ctx = request.contextPath/>
<#include "../common/macro.ftl"/>
<html>
<head>
<title>担保登记</title>
<link href="${ctx}/factoring/css/bootstrap.min111.css" rel="stylesheet">
<link href="${ctx}/factoring/css/theme.css" rel="stylesheet">
<link href="${ctx}/factoring/css/font-awesome.min.css" rel="stylesheet">
<link rel="stylesheet" type="text/css" media="all" href="${ctx}/factoring/css/daterangepicker-bs3.css" />
<script src="${ctx}/factoring/js/jquery.js"></script>
<script src="${ctx}/factoring/js/jquery.min.js"></script>
<script src="${ctx}/factoring/js/bootstrap.min111.js"></script>
<script src="${ctx}/factoring/js/page/page.js"></script>
<style>
.modal-dialog{width:50%;}
.ipt-form{float:right;margin-right:25px;height:30px;}
.li-wid{float:left;display:block;width:100%}
.fac_c_bot li{margin:5px;}
.fac_c_bot input{width:53%;}
ul li{list-style:none;}
.ipt-form{height:33px;}
</style>
<script type="text/javascript" src="${ctx}/factoring/js/daterangepicker.js"></script>
<script type="text/javascript" src="${ctx}/factoring/js/DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="${ctx}/common/jqueryValidation/js/jquery.validationEngine-zh_CN.js"></script>
<script type="text/javascript" src="${ctx}/common/jqueryValidation/js/jquery.validationEngine.min.js"></script>
<link rel="stylesheet" type="text/css" href="${ctx}/common/jqueryValidation/css/validationEngine.jquery.css" />
<script type="text/javascript" src="${ctx}/factoring/js/moment.js"></script>
<link rel="stylesheet" href="${ctx}/select/css/bootstrap-select.css">
<script src="${ctx}/select/js/bootstrap-select.js"></script>
<script>
   <#--  分页    --> 
   $(function(){
	
		$("#formId").validationEngine('attach',{
		scroll:false,
		autoHidePrompt:true,
		autoHideDelay:2500,
		promptPosition : "bottomLeft"
		 });
	
		var li = $('.pagination li');
		var pageNo =0 ;
		
		pageNo = getactiveIndex(pageNo,li);
		
		//当点击的时候添加样式，获取
		li.click(function(){  
		 	 //取点击的a标签中的值
		 	 var txt = $(this).find("a").html();
		 	 //取点击的下标
		 	 var index = $(this).index();
		 	 
		 	 //取查询条件的值
		    // var change = $("#selecter_basic").val();
		 	 var payerName = $("#payerName").val();
		 	 var payeeName = $("#payeeName").val();
		 	 
		 	 //获取当前页
		 	 pageNo = getPageNo(pageNo,index,txt);
			
			 window.location = "${ctx}/assureController/toAssureNoFiltera.do?page="+pageNo+"&payerName="+payerName+"&payeeName="+payeeName;
		})	
	})
<#--  分页over   -->	


<#-- 全选  -->	
	function checkAllBox(obj){
		$(obj).parent().parent().parent().parent().find("[name = forLowerId]:checkbox").each(function(i,thisElement){
			if($(obj).prop("checked")==true){
		      $(thisElement).prop("checked",'true');
			}else{
				$(thisElement).prop("checked",false);
			}
		})
	}
	
	 function forLowerIdCheck(obj){
 		var forLowerCheckbox;
     $(obj).parent().parent().parent().parent().find("[name = forLowerId]:checkbox").each(function(i,thisElement){
           if($(thisElement).prop("checked")==false){
            // alert($(obj).parent().parent().parent().find("[name = checkAll]").prop("checked"));
                forLowerCheckbox = 0;
				return false;
			}
			forLowerCheckbox = 1;
			return true;
  		});
     if(forLowerCheckbox==0){
        $(obj).parent().parent().parent().parent().find("[name = checkAll]").prop("checked",false);
     }else{
       $(obj).parent().parent().parent().parent().find("[name = checkAll]").prop("checked",true);
     }
 }
<#-- 全选结束  -->	


<#--  查询  -->
 function getMassage(){
 	var payerName = $("#payerName").val();
 	var payeeName = $("#payeeName").val();
 	
 	//var type = $("#selecter_basic").val();
 	
 	window.location = "${ctx}/assureController/toAssureNoFiltera.do?payerName="+payerName+"&payeeName="+payeeName;//+"&type="+type;
 }
 <#--  查询结束   -->


<#-- 显示提示框 -->
function myModalTS(){
	
	$("#myModalTS").modal("show");
	$("#myModal").modal("hide");
	
}
<#-- 显示提示框结束 -->


<#-- 进行登记操作 -->
function assureRegister(){
	
	var guaranteetId;
	var discountRate; 
	
	$("#forLowerId").parent().parent().parent().find("[name = forLowerId]:checkbox").each(function(i,element){
		if($(element).prop("checked")==true){
			guaranteetId = $(element).val();
			discountRate = $(element).parent().parent().find("input[name=discountRate]").val();
		}
	})
	
	if(guaranteetId=="undefind" || guaranteetId==null){
		$("#myModalTS").modal("hide");
		alert("请选择登记行！！");
		return;
	}
	
	if(discountRate>0.8){
		alert("贴现率不能大于0.8，请重新输入！！！");
		return;
	}
	
	$.ajax({
		url:'${ctx}/assureController/assureRegisterNoFilter.do',
		dataType:'JSON',
		type:'POST',
		data:{"guaranteetId":guaranteetId,"discountRate":discountRate},
		success:function(data){
			data = eval("("+data+")")
			$("#myModalTS").modal("hide");
			alert(data);
			window.location = "${ctx}/assureController/toAssureNoFiltera.do";
		}
	})
}
<#-- 进行登记操作结束   -->

<#--   驳回      -->
function turnDown(obj){
	
	var guaranteetId="";
	
	$(obj).parent().find("[name = forLowerId]:checkbox").each(function(i,element){
		if($(element).prop("checked")==true){
			guaranteetId += $(element).val()+",";
		}
	})
	
	guaranteetId = guaranteetId.substr(0,guaranteetId.length-1);

   alert(guaranteetId);

	$.ajax({
		url:'${ctx}/assureController/turnDownNoFilter.do',
		dataType:'JSON',
		type:'POST',
		data:{"guaranteetIds":guaranteetId},
		success:function(data){
			data = eval("("+data+")")
			if(data!=""){
				alert(data+"驳回失败！");
			}else{
				alert("已驳回！");
				window.location = "${ctx}/assureController/toAssureNoFiltera.do"
			}
		}
	
	})
} 

<#--   驳回结束      -->

<#--   撤销     -->
function revoke(obj){
	var guaranteetId="";
	
	$(obj).parent().find("[name = forLowerId]:checkbox").each(function(i,element){
		if($(element).prop("checked")==true){
			guaranteetId += $(element).val()+",";
		}
	})
	
	guaranteetId = guaranteetId.substr(0,guaranteetId.length-1);

	$.ajax({
		url:'${ctx}/assureController/revokeNoFilter.do',
		dataType:'JSON',
		type:'POST',
		data:{"guaranteetIds":guaranteetId},
		success:function(data){
			data = eval("("+data+")")
			if(data!=""){
				alert("担保单"+data+"正在使用，不能注销！！！");
			}else{
				alert("已注销！");
				window.location = "${ctx}/assureController/toAssureNoFiltera.do"
			}
		}
	
	})
}
<#--   撤销    -->

<#--   获取guaranteetId   -->
function getguranteeId(obj){
	var guaranteetId="";
	
	$(obj).parent().find("[name = forLowerId]:checkbox").each(function(i,element){
		if($(element).prop("checked")==true){
			guaranteetId += $(element).val()+",";
		}
	})
	
	guaranteetId = guaranteetId.substr(0,guaranteetId.length-1);
}

<#--   获取guaranteetId  over   -->

function getOrderDetail(obj){
    
    var guaranteetId = $(obj).html();
    
	$.ajax({
		url:'${ctx}/assureController/getOrderDetail.do',
		dataType:'JSON',
		type:'POST',
		data:{"guaranteetId":guaranteetId},
		success:function(data){
			data = eval("("+data+")")
			for(var i = 0;i<parseInt(data.length);i++){
				var row = document.getElementById("select_order").insertRow(i+1)
				
				row.insertCell(0).innerHTML='<td></td>';
				row.insertCell(1).innerHTML='<td></td>';
				row.insertCell(2).innerHTML='<td></td>';
				row.insertCell(3).innerHTML='<td></td>';
				row.insertCell(4).innerHTML='<td></td>';
				row.insertCell(5).innerHTML='<td></td>';
				row.insertCell(6).innerHTML='<td></td>';
				row.insertCell(7).innerHTML='<td></td>';
			}
			$("#myModalDD").modal('show');
		}
	})
}

  function now(){
    var date = new Date();
    var year = date.getFullYear();
    var mth = date.getMonth() + 1;
    var day = date.getDate();
    return year+"-"+mth+"-"+day;
  }

function addAssure(){
	$("#add_payerName").val("");
	$("#add_payeeName").val("");
	$("#add_assureMoney").val("");
	$("#add_payBackDate").val("");
	$("#add_discountRate").val("");
	$("#addAssureMyModal").modal('show');
}

function payerOnChange(){
	<#--  根据付款方  收款方 id  查询账号信息  -->
	var mbId = $("#add_payerName").val();
	$("#payerAcc option:not(:first)").remove();
	$.ajax({
		url:'${ctx}/assureController/getBankAccNoFilter.do',
		dataType:'JSON',
		type:'POST',
		data:{"mbId":mbId},
		success:function(data){
			data = eval("("+data+")");
			if(data != null){
				if(data.list!=""){
					for(var i = 0;i<data.list.length;i++){
						if(data.list[i].acctTypeName == "附属户"){
							$("#payerAcc").append('<option value='+data.list[i].bankAcct+' name='+data.list[i].acctName+'>'+data.list[i].bankName+':'+data.list[i].bankAcct+'</option>');
						}
					}
				}else{
					$("#payerAcc option:not(:first)").remove();
				}
				if(data.user!=""){
					$("#add_payerId").val(data.mbId);
				}
			}
		}
	});
}

function payeeOnChange(){
	var mbId = $("#add_payeeName").val();
	$("#payeeAcc option:not(:first)").remove();
	$.ajax({
		url:'${ctx}/assureController/getBankAccNoFilter.do',
		dataType:'JSON',
		type:'POST',
		data:{"mbId":mbId},
		success:function(data){
			data = eval("("+data+")");
			if(data != null){
				if(data.list!=""){
					for(var i = 0;i<data.list.length;i++){
						if(data.list[i].acctTypeName == "附属户"){
							$("#payeeAcc").append('<option value='+data.list[i].bankAcct+' name='+data.list[i].acctName+'>'+data.list[i].bankName+':'+data.list[i].bankAcct+'</option>');
						}
					}
				}else{
					$("#payeeAcc option:not(:first)").remove();
				}
				$("#add_payeeId").val(data.mbId);
				$("#add_Account").val(data.list[0].masterAcct); 
			}
		}
	});
}

function getBankAccPayee(obj){
	var  name = $(obj).val();
	$.ajax({
		url:'${ctx}/assureController/getBankAccNoFilter.do',
		dataType:'JSON',
		type:'POST',
		data:{"name":name},
		success:function(data){
			data = eval("("+data+")");
			if(data != null){
				for(var i = 0;i<data.list.length;i++){
					if(data.list[i].acctTypeName == "附属户"){
						$("#payeeAcc").append('<option value='+data.list[i].bankAcct+' name='+data.list[i].acctName+'>'+data.list[i].bankName+':'+data.list[i].bankAcct+'</option>');
					}
				}
				$("#add_payeeId").val(data.user.id);
				$("#add_Account").val(data.list[0].masterAcct); 
			}
		}
	})
}

function addAssureMassege(){
	
	var add_payerName = $("#add_payerName").find("option:selected").text();
	var add_payeeName = $("#add_payeeName").find("option:selected").text();
	var add_assureMoney = $("#add_assureMoney").val();
	var add_payBackDate = $("#add_payBackDate").val();
	var add_discountRate = $("#add_discountRate").val();
	if(add_payerName == null || add_payerName == ""){
		alert("付款方不能为空！！");
		return;
	}
	if(add_payeeName == null || add_payeeName == ""){
		alert("收款方不能为空！！");
		return;
	}
	if(add_assureMoney == null || add_assureMoney == ""){
		alert("应收账款金额不能为空！！");
		return;
	}
	if(add_payBackDate == null || add_payBackDate == ""){
		alert("预计还款时间不能为空！！");
		return;
	}
	if($("#payerAcc").val() == "请选择"){
		alert("请选择付款方账号！！");
		return ;
	}
	if($("#payeeAcc").val() == "请选择"){
		alert("请选择收款方账号！！");
		return ;
	}
	
	if(add_discountRate>1){
		alert("贴现率不能大于1，请修改贴现率！！");
		return;
	}
	
	var jsonStr = "[";
		jsonStr += "{" 
				  +"\"payerName\":\""+add_payerName
				  +"\",\"payeeName\":\""+add_payeeName
				  +"\",\"guaranteeAmount\":\""+add_assureMoney
				  +"\",\"expireDate\":\""+add_payBackDate
				  +"\",\"schoolTheoreticalAccount\":\""+$("#payerAcc").val()
				  +"\",\"distributorName\":\""+$("#payeeAcc option:selected").attr("name")
				  +"\",\"distributorTheoreticalBank\":\""+$("#payeeAcc").val()
				  +"\",\"payerId\":\""+$("#add_payerId").val()
				  +"\",\"payeeId\":\""+$("#add_payeeId").val()
				  +"\",\"blocAccount\":\""+$("#add_Account").val()
				  +"\",\"discountRate\":\""+add_discountRate
				  +"\"},";
		jsonStr = jsonStr.substring(0,jsonStr.length-1);
		jsonStr += "]"
	
	$.ajax({
		url:'${ctx}/assureController/addAssureMassageNoFilter.do',
		dataType:'JSON',
		type:'POST',
		data:{"jsonStr":jsonStr},
		success:function(data){
			data = eval("("+data+")");
			alert(data)
		}
	})
	$("#addAssureMyModal").modal('hide');
}

</script>

</head>
<body>
<!-- head -->
<div class="container-fluid">
	<div class="row-fluid ">

		
		<div class="fs">
		    
			<div class="panel panel-default article-bj">
			  <div class="panel-heading box-shodm">待登记担保</div>
			  <!-- 查询条件 -->
			  <div class="row wrapper form-margin">
				<form id="formId" action ="${ctx}/assureController/toAssureNoFiltera.do" method="post">
				  <div class="col-md-3">
					<div class="input-group">
					  <div class="input-group-btn">
						<h5 class="h5-margin">付款方:</h5>
					  </div>
					  <input type="text" placeholder="" class="form-control validate[custom[chinese]]" name="payerName" id="payerName" value="${payerName!}"></div>
				  </div>
				  <div class="col-md-3">
					<div class="input-group">
					  <div class="input-group-btn">
						<h5 class="h5-margin">收款方:</h5>

					  </div>
					  <input type="text" placeholder="" class="form-control validate[custom[chinese]]" name="payeeName" id="payeeName" value = "${payeeName!}"></div>
				  </div>
				 <#-- <div class="col-md-3">
					<div class="input-group">
					  <div class="input-group-btn">
						<h5 class="h5-margin">担保资源状态:</h5>
					  </div>
					  <@select name="type" class="form-control" id="selecter_basic" datas={'1':'待登记','2':'已登记','3':'已驳回','5':'已注销','4':'全部'}  value="${status!}"/>
					  
					<#-- <select name="type" value="${status!}" class="form-control" id="selecter_basic">
	                  <option value="1">待登记</option>
	                  <option value="2">已登记</option>
	                  <option value="3">已驳回</option>
	                  <option value="4">全部</option>
	                </select>
					  
					</div>
				  </div>-->
				  <input type="submit" class="btn btn-info btn-s-md btn-default float-right cx-btn-margin" value="查询"  style="height:35px;width:65px"/>
				</form>
            </div>
	          <!-- 查询条件 over-->
	
			<div class="table-responsive panel-table-body " style="padding-top:15px">
				<table class="table table-striped table-hover ">
	
					<thead>
							<tr>
							  <th>
								<input type="checkbox" class="uniform" name="checkAll" onclick="checkAllBox(this)"></th>
							  <th>结款单号</th>
							  <th>结款金额</th>
							  <th>未支付金额</th>
							  <th>贴现率</th>
							  <th>到期时间</th>
							  <th>付款方</th>
							  <th>收款方</th>
							  <th>是否托管</th>
							</tr>
					</thead>
					<tbody>
						<#if list ??>
							<#list list as li>
								<tr>
									<td><input type="checkbox" id="forLowerId"  name="forLowerId" onclick="forLowerIdCheck(this)" value="${li.guaranteeId!}"/></td>
									<td class="tab_xhline"><a onclick="getOrderDetail(this)">${li.guaranteeId!}</a></td>
									<td>￥${li.guaranteeAmount!}</td>
									<td>￥${li.nonPayAmount!}</td>
									<td><input type="text" name = "discountRate" value="" style = "width:100px;" /></td>
									<td>${li.expireDate?datetime?string}</td>
									<td>${li.payerName}</td>
									<td>${li.payeeName}</td>
									<td>
									    <#if li.status == 1>
											<a target="_top" style=" border-bottom:1px #000 solid;" data-toggle="modal" data-target="#myModal">登记</a>
										<#else>
										</#if>
									</td>
								</tr>
							</#list>
						</#if>
						
					</tbody>
					
				</table>
			</div>
	         <#if status ??>
	         	<#if status == "2">
	         		<button class="btn btn-success btn-s-xs" id="turnDown" type="submit" style ="float:right;margin-top:20px;margin-right:15px;" onclick = "revoke(this)">注销</button>
	         	</#if>
	         	<#if status == "1">
	         		<button class="btn btn-success btn-s-xs" id="turnDown" type="submit" style ="float:right;margin-top:20px;margin-right:15px;" onclick = "turnDown(this)">驳回</button>
	         	</#if>
	         	<#if status == "4">
	         		<button class="btn btn-success btn-s-xs" id="turnDown" type="submit" style ="float:right;margin-top:20px;margin-right:15px;" onclick = "turnDown(this)">驳回</button>
	         		<button class="btn btn-success btn-s-xs" id="turnDown" type="submit" style ="float:right;margin-top:20px;margin-right:15px;" onclick = "revoke(this)">注销</button>
	         	</#if>
	         </#if>
				<button class="btn btn-success btn-s-xs" id="addAssure" type="submit" style ="float:right;margin-top:20px;margin-right:15px;" onclick = "addAssure()">添加担保</button>
			<center><div class = "page">
				<ul class="pagination">
				  <li class="prev disabled">
		              <a href="#"><<</a>
		            </li>
				   <#if length ??>
		            	<#list 0..length as len>
			            	<#if len gt 0 && len lt len+1>
			            		<#if clas ??>
				            		<#if clas != len>
				            			<li>
				            		<#else>
				            			<li  class = "active">
				            		</#if>
			            		</#if>
						         	<a href="#">${len}</a>
						         </li>
					         </#if>
				         </#list>
		            </#if>
				  <li class="next">
		              <a href="#" >>></a>
		            </li>
				</ul>
			</div></center>
	
			</div>
	</div>

<!-- 模态框（Modal） -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
   <div class="modal-dialog">
      <div class="modal-content">
         <div class="modal-header">
            <button type="button" class="close" 
               data-dismiss="modal" aria-hidden="true">
                  &times;
            </button>
         </div>
         <div class="modal-body">
            	请确定是否所有法律文件都已完备？
         </div>
         <div class="modal-footer">
			<button type="button" class="btn btn-primary" onclick="myModalTS()">确认</button>
            <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
         </div>
      </div><!-- /.modal-content -->
</div><!-- /.modal -->
</div>


<!-- 模态框（Modal） -->
<div class="modal fade" id="myModalTS" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
   <div class="modal-dialog">
      <div class="modal-content">
         <div class="modal-header">
            <button type="button" class="close" 
               data-dismiss="modal" aria-hidden="true">
                  &times;
            </button>
         </div>
         <div class="modal-body" style="color:red;">
            	您是否确定要将此结款单登记为担保资源(注：此操作不能撤销)？
         </div>
         <div class="modal-footer">
			<button type="button" class="btn btn-primary" onclick="assureRegister()">确认</button>
            <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
         </div>
      </div><!-- /.modal-content -->
</div><!-- /.modal -->
</div>

<!-- 模态框（Modal） -->
<div class="modal fade" id="myModalDD" tabindex="-1" role="dialog" 
   aria-labelledby="myModalLabel" aria-hidden="true">
   <div class="modal-dialog">
      <div class="modal-content">
         <div class="modal-header">
            <button type="button" class="close" 
               data-dismiss="modal" aria-hidden="true">
                  &times;
            </button>
         </div>
         <div class="modal-body">
				<!--10002内页开始-->
				 <div id="db_inner_warp">
						<table class="table table-striped select_order" cellspacing="0"  cellpadding="5">
							<tr class="fac_tr_tab">
								<td width="6%">订单号</td>
								<td width="7%">订单行号</td>
								<td width="8%">商品名</td>
								<td width="7%">发货数量</td>
								<td width="7%">收货数量</td>
								<td width="8%">已支付金额</td>
								<td width="10%">剩余支付金额</td>
								<td width="8%">已担保金额</td>
							</tr>
						</table>
				</div>
				 <!--10002内页结束-->
         </div>
         </div>
      </div><!-- /.modal-content -->
</div><!-- /.modal -->
</div>

<!--  添加担保资源   -->
<div class="modal fade" id="addAssureMyModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog" style="width:35%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" 
				   data-dismiss="modal" aria-hidden="true">
					  &times;
				</button>
			</div>
			<div class="modal-body">
				<div id="db_inner_warp">
					<input type="hidden" id="add_payerId" value=""/>
					<input type="hidden" id="add_payeeId" value=""/>
					<input type="hidden" id="add_Account" value=""/>
						<ul class="fac_c_bot">
							<li class="li-wid"><label style="padding-left:40px;float:left">付款方：</label>
								<select id="add_payerName" class="selectpicker" data-live-search="true"  onchange="payerOnChange();">
									<option>请选择</option>
							  		<#if mebers ??>
										<#list mebers as meber>
											<option value="${meber.id!}" name="${meber.mmbFname!}">${meber.mmbFname!}</option>
										</#list>
									</#if>
							  	</select>
							</li>
							<li class="li-wid"><label style="padding-left:40px;float:left">收款方：</label>
								<select id="add_payeeName" class="selectpicker" data-hide-disabled="true" data-live-search="true" onchange="payeeOnChange();">
									<option>请选择</option>
							  		<#if mebers ??>
										<#list mebers as meber>
											<option value="${meber.id!}" name="${meber.mmbFname!}">${meber.mmbFname!}</option>
										</#list>
									</#if>
								</select> 
							</li>
							<li class="li-wid"><label style="float:left">应收账款金额：</label>
								<input id = "add_assureMoney" type="text" class="form-control ipt-form" value="" style="float:left;"/>
							</li>
							<li class="li-wid"><label style="float:left">预计还款时间：</label>
								<input class="Wdate form-control ipt-form" id="add_payBackDate" type="text" onfocus="javascript:WdatePicker({readOnly:true,isShowClear:false,dateFmt:'yyyy-MM-dd HH:mm:ss',minDate:now()})"  style="float:left;height:24px;"/>
							</li>
							<li class="li-wid"><label style="padding-left:15px;float:left">付款方账号：</label>
								<select class="form-control ipt-form" style="width:53%;float:left" id="payerAcc">
									<option>请选择</option>
								</select>
							</li>
							<li class="li-wid"><label style="padding-left:15px;float:left">收款方账号：</label>
								<select class="form-control ipt-form" style="width:53%;float:left" id="payeeAcc">
									<option>请选择</option>
								</select> 
							</li>
							
							<li class="li-wid"><label style="padding-left:43px;float:left">贴现率：</label>
								<input class = "form-control" type="text" id = "add_discountRate" value="" />
							</li>
						</ul>
					
					<button type="button" class="btn btn-success btn-s-xs"  style="float:right" onclick = "addAssureMassege()">确定</button>
				</div>
				<div class="clearfix"></div>
				
			</div>
	    </div><!-- /.modal-content -->
	</div><!-- /.modal -->
</div>


	</div>
</div>
<!-- head结束-->
</body>
</html>