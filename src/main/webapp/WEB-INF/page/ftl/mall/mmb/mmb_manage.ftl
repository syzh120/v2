<#assign sec=JspTaglibs["/WEB-INF/security.tld"] />   <#-- 引入security.tld标签-->
<#assign ctx = request.contextPath/>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
   <link rel="stylesheet" href="${ctx}/mall/css/bootstrap.min.css">
   <link href="${ctx}/mall/css/theme.css" rel="stylesheet">
   <script src="${ctx}/mall/js/jquery.js"></script>
   <script src="${ctx}/mall/js/common/common.js"></script>
   <script src="${ctx}/mall/js/jquery.min.js"></script>

    <script type="text/javascript" src="${ctx}/common/jqueryValidation/js/jquery.validationEngine-zh_CN.js"></script>
    <script type="text/javascript" src="${ctx}/common/jqueryValidation/js/jquery.validationEngine.min.js"></script>
    <link rel="stylesheet" type="text/css" href="${ctx}/common/jqueryValidation/css/validationEngine.jquery.css" />

   <script src="${ctx}/mall/js/bootstrap.min.js" type="text/javascript"></script>
   <script src="${ctx}/mall/js/bootstrap-treeview.js" type="text/javascript"></script>
   <script type="text/javascript" src="${ctx}/mall/js/extendPagination.js"></script>

<title>会员管理</title>
</head>
<script type="text/javascript">

	$(function(){
        //表单验证
        $("#saveMmbInfoForm").validationEngine('attach',{
            scroll:false,
            autoHidePrompt:true,
            autoHideDelay:2500,
            promptPosition : "bottomLeft"
        });

        //表单验证
        $("#updateMmbInfoForm").validationEngine('attach',{
            scroll:false,
            autoHidePrompt:true,
            autoHideDelay:2500,
            promptPosition : "bottomLeft"
        });

        queryMmbByCon();


    });
	    //点击查询会员列表，实现局部分页查询会员列表信息
		function queryMmbByCon() {
			$.ajax({
				url : '${ctx}/mmb/queryMMBListNoFilter.do',// 跳转到 action
				data : {
					mmbFname : $("#mmbFname").val(),
					pageNo : 1,
					pageSize : 10
				},
				type : 'POST',
				cache : false,
				dataType : 'json',
				success : function(data) {
					//先清空table中的数据
					$("#mmbTable  tr:not(:first)").remove();
					if (data.mmbList.length > 0) {
						for ( var i = 0; i < data.mmbList.length; i++) {
							var content = '';
							content += '<tr>';
							content += "<td>"+data.mmbList[i].mmbSname+"</td>";
							content += "<td>"+data.mmbList[i].mmbFname+"</td>";
							content += "<td>"+data.mmbList[i].mmbAddress+"</td>";
							content += "<td>"+data.mmbList[i].createDate+"</td>";
							if (data.mmbList[i].mmbStatus == 0) {
								content += "<td><a href='#' onclick=toEditMmbInfo('"+data.mmbList[i].id+"')>编辑</a>&nbsp;";
								content += "<a href='#' onclick=stopMmb('"+data.mmbList[i].id+"',1)>停用</a>&nbsp;";
								content += "<a href='#' onclick=toManageAreaBiz('"+data.mmbList[i].id+"')>管理地域</a>&nbsp;";
								content += "<a href='#' onclick=toManageMmbRelation('"+data.mmbList[i].id+"')>管理关系</a></td>";
							} else {
								content += "<td><a href='#' onclick=restartMmb('"+data.mmbList[i].id+"',0)>启用</a></td>";
							}
							content += '</tr>';
							addTr('mmbTable', -1, content);
						}
					} else {
					}
					setPagination(1, 10, data.mmbCount);
				},
				error : function() {
					alert("异常！");
				}
			});
		}

		//会员列表分页信息
		function setPagination(curr, limit, totalCount) {
			$('#callBackPager').extendPagination({
				totalCount : totalCount,
				showCount : limit,
				limit : limit,
				callback : function(curr, limit, totalCount) {
					if ($("#keyword").val() == "" && $("#keyProvince").text() == "所在省份" && $("#keyTitle").text() == "") {
						Notify('请至少选择一个条件！', 'bottom-right', '5000', 'info', 'fa-tag', true);
						return;
					}
					$.ajax({
						url : '${ctx}/mmb/queryMMBListNoFilter.do',// 跳转到 action
						data : {
							mmbFname : $("#mmbFname").val(),
							pageNo : curr,
							pageSize : limit
						},
						type : 'POST',
						cache : false,
						dataType : 'json',
						success : function(data) {
							//先清空table中的数据
							$("#mmbTable  tr:not(:first)").remove();
							if (data.mmbList.length > 0) {
								for ( var i = 0; i < data.mmbList.length; i++) {
									var content = '';
									content += '<tr>';
									content += "<td>"+data.mmbList[i].mmbSname+"</td>";
									content += "<td>"+data.mmbList[i].mmbFname+"</td>";
									content += "<td>"+data.mmbList[i].mmbAddress+"</td>";
									content += "<td>"+data.mmbList[i].createDate+"</td>";
									if (data.mmbList[i].mmbStatus == 0) {
										content += "<td><a href='#' onclick=toEditMmbInfo('"+data.mmbList[i].id+"')>编辑</a>&nbsp;";
										content += "<a href='#' onclick=stopMmb('"+data.mmbList[i].id+"',1)>停用</a>&nbsp;";
										content += "<a href='#' onclick=toManageAreaBiz('"+data.mmbList[i].id+"')>管理地域</a>&nbsp;";
										content += "<a href='#' onclick=toManageMmbRelation('"+data.mmbList[i].id+"')>管理关系</a></td>";
									} else {
										content += "<td><a href='#' onclick=restartMmb('"+data.mmbList[i].id+"',0)>启用</a></td>";
									}
									content += '</tr>';
									addTr('mmbTable', -1, content);
								}
								//$('#mmbListBody').html(content);
								//Notify('共查询到'+data.mmbCount+'条数据！', 'bottom-right', '5000', 'info', 'fa-tag', true);
							} else {
								//Notify('Sorry,无数据！', 'bottom-right', '5000', 'info', 'fa-tag', true);
							}
						},
						error : function() {
							alert("异常！");
						}
					});
				}
			});
		}


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
	        alert("指定的table id或行数不存在！");
	        return;
	     }
	     $tr.after(trHtml);
	  }
	  
	  //删除某个table下选中的行
	  function delTr(ckb){
	     //获取选中的复选框，然后循环遍历删除
	     var ckbs=$("input[name="+ckb+"]:checked");
	     if(ckbs.size()==0){
	        alert("要删除指定行，需选中要删除的行！");
	        return;
	     }
	     ckbs.each(function(){
	          $(this).parent().parent().remove();
	     });
	  } 
	   
	  /**
	   * 全选
	   * allCkb 全选复选框的id
	   * items 复选框的name
	   */
	  function allCheck(allCkb, items){
	   $("#"+allCkb).click(function(){
	      $('[name='+items+']:checkbox').attr("checked", this.checked );
	   });
	  }
	   


   //创建会员
	function checkMmbInfo(){
		//校验会员新增信息是否正确
		if(!$("#saveMmbInfoForm").validationEngine("validate")){
			return;
		}

		//验证会员简称 英文简称 和注册全称
		if(!valueIsNull($("#saveMmbInfoForm input[name='mmbSname']"))){
            if(!checkIsUnique($("#saveMmbInfoForm input[name='mmbSname']"),'')){
                alert("会员简称已存在！");
                return ;
            }
		}

        if(!valueIsNull($("#saveMmbInfoForm input[name='mmbEngSname']"))) {
            if (!checkIsUnique($("#saveMmbInfoForm input[name='mmbEngSname']"),'')) {
                alert("英文简称已存在！");
                return;
            }
        }
        if(!valueIsNull($("#saveMmbInfoForm input[name='mmbFname']"))) {
            if (!checkIsUnique($("#saveMmbInfoForm input[name='mmbFname']"),'')) {
                alert("注册全称已存在！");
                return;
            }
        }

        if(!valueIsNull($("#saveMmbInfoForm input[name='operationName']"))) {
            if (!checkIsUnique($("#saveMmbInfoForm input[name='operationName']"),'')) {
                alert("管理员账号已存在！");
                return;
            }
        }


		$.ajax({
				url:'${ctx}/mmb/createMMBNoFilter.do',
				type: "POST",
                dataType: "json",
				data:$('#saveMmbInfoForm').serialize(),
				success:function(data){
				   	 data = eval(data);
				   	 //如果成功
				   	 if(data!=null&&data.successMsg != ""){
				   	 	$("#saveMmbInfoForm input[type=reset]").trigger("click");
				   	 	//隐藏模态框
				   	 	$("#createMember").modal('hide');
				   	 	//重新查询
				   	 	$("#queryMmbButton").click();
				   	 }
				   	 //如果失败
				   	 else if(data!=null&&data.errorMsg != ""){
				   	 	alert(data.errorMsg);
				   	 }
				}
			});
	}

	//验证某个会员属性是否唯一
	//编辑页面需要将自己的ID 传入后台，不能和自己比较
	function checkIsUnique(obj,id){
		var checkType = $(obj).attr("name");
		var checkValue = $(obj).val();
		var checkNum = 0;
		if(checkType != null && $.trim(checkType) != ""){
            $.ajax({
                url : '${ctx}/mmb/getNumByCheckType.do',
                type : "POST",
				async : false,
                dataType : "json",
                data: {"checkType":checkType,"checkValue":checkValue,"id":id},
                error : function(){
                    alert("系统异常！");
                },
                success : function(data){
                    checkNum= data;
                }
            });
		}

		return checkNum == 0 ? true : false;
	}

	function valueIsNull(obj){
		return ($(obj).val()  == null || $.trim($(obj).val()) == '')? true : false;
	}

	//编辑会员
	function updateMmbInfo(){
		if(!$("#updateMmbInfoForm").validationEngine("validate")){
			return;
		}

		var id = $("#id1").val();
        //验证会员简称 英文简称 和注册全称
        if(!valueIsNull($("#updateMmbInfoForm input[name='mmbSname1']"))){
            if(!checkIsUnique($("#updateMmbInfoForm input[name='mmbSname1']"),id)){
                alert("会员简称已存在！");
                return ;
            }
        }

        if(!valueIsNull($("#updateMmbInfoForm input[name='mmbEngSname1']"))) {
            if (!checkIsUnique($("#updateMmbInfoForm input[name='mmbEngSname1']"),id)) {
                alert("英文简称已存在！");
                return;
            }
        }
        if(!valueIsNull($("#updateMmbInfoForm input[name='mmbFname1']"))) {
            if (!checkIsUnique($("#updateMmbInfoForm input[name='mmbFname1']"),id)) {
                alert("注册全称已存在！");
                return;
            }
        }

        $.ajax({
                url:'${ctx}/mmb/updateMMBNoFilter.do',
				type: "POST",
                dataType: "json",
				data:$('#updateMmbInfoForm').serialize(),
				success:function(data){
				   	 data = eval(data);
				   	 //alert(data);
				   	 //如果成功
				   	 if(data!=null&&data.successMsg != ""){
				   	 	alert(data.successMsg);
				   	 	//隐藏模态框
				   	 	$("#editMember").modal('hide');
				   	 	//重新查询
				   	 	$("#queryMmbButton").click();
				   	 }
				   	 //如果失败
				   	 else if(data!=null&&data.errorMsg != ""){
				   	 	alert(data.errorMsg);
				   	 }
				}
			});
	}

	
	//进入会员地域业务页面
	function toManageAreaBiz(id){
	    if(id!=""){
	    	//隐藏域赋值为当前所选会员的id
	    	$("#operationMmbId").val(id);
	    	//清空table中的值
	    	$("#manageAreaTable  tr:not(:first)").remove();
	    	//将全选按钮设置为未选
	    	$("#checkAll").prop("checked",false);
			//暂时省略校验部分，直接提交
			$.ajax({
				url:'${ctx}/mmb/queryAllAreaBizByMIdNoFilter.do',
				type: "POST",
	            dataType: "json",
				data:{"mid":id},
				success:function(data){
				   	 data = eval(data);
				   	 //alert(data);
				   	 //如果成功
				   	 if(data!=null&&data.length>0){
				   	 	//判断获取到的启用业务类型有哪几种，然后分别迭代勾选
				   	 	if(data!=""&&data.length>0){
				   	 		var $tr = "";
				   	 		for(var i=0;i<data.length;i++){
				   	 			var trHtml="<tr><td><input type='checkbox' name='areaCheckBox' value="+data[i].busAreaTree.id+"></input></td><td id='area'>"+data[i].busAreaTree.areaName+"</td>";
				   	 			//处理查询到的多个types
				   	 			var types = data[i].types;
				   	 			if(types!=null&&types!=""){
				   	 				var arr = types.split(",");
				   	 				if(arr!=null&&arr.length>0){
				   	 					//判断买关系是否存在
				   	 					var first = $.inArray("0", arr);
				   	 					if(first!="-1"){
				   	 						trHtml = trHtml+"<td><input type='checkbox' checked='checked' value='0' name='areaType'>买</td>";
				   	 					}
				   	 					else{
				   	 						trHtml = trHtml+"<td><input type='checkbox'  value='0' name='areaType'>买</td>";
				   	 					}
				   	 					//判断卖关系是否存在
				   	 					var second = $.inArray("1", arr);
				   	 					if(second!="-1"){
				   	 						trHtml = trHtml+"<td><input type='checkbox' checked='checked' value='1' name='areaType'>卖</td>";
				   	 					}
				   	 					else{
				   	 						trHtml = trHtml+"<td><input type='checkbox'  value='1' name='areaType'>卖</td>";
				   	 					}
				   	 					//判断借关系是否存在
				   	 					var third = $.inArray("2", arr);
				   	 					if(third!="-1"){
				   	 						trHtml = trHtml+"<td><input type='checkbox' checked='checked' value='2' name='areaType'>借</td>";
				   	 					}
				   	 					else{
				   	 						trHtml = trHtml+"<td><input type='checkbox'  value='2' name='areaType'>借</td>";
				   	 					}
				   	 					//判断贷关系是否存在
				   	 					var fourth = $.inArray("3", arr);
				   	 					if(fourth!="-1"){
				   	 						trHtml = trHtml+"<td><input type='checkbox' checked='checked' value='3' name='areaType'>贷</td>";
				   	 					}
				   	 					else{
				   	 						trHtml = trHtml+"<td><input type='checkbox'  value='3' name='areaType'>贷</td>";
				   	 					}
				   	 				}
				   	 				else{
				   	 					trHtml = trHtml+"<td><input type='checkbox'  value='0' name='areaType'>买</td>";
				   	 					trHtml = trHtml+"<td><input type='checkbox'  value='1' name='areaType'>卖</td>";
				   	 					trHtml = trHtml+"<td><input type='checkbox'  value='2' name='areaType'>借</td>";
				   	 					trHtml = trHtml+"<td><input type='checkbox'  value='3' name='areaType'>贷</td>";
				   	 				}
				   	 			}
				   	 			trHtml = trHtml+"</tr>";
				   	 			addTr('manageAreaTable', -1, trHtml);
				   	 		}
				   	 	}
				   	 	//打开管理地域模态框
				   	 	$("#manageArea").modal('show');
				   	 }
				   	 //如果失败
				   	 else{
				   	 	//打开管理地域模态框
				   	 	$("#manageArea").modal('show');
				   	 }
					}
				});
	    }
	}
	
	//进入会员关系业务页面
	function toManageMmbRelation(id){
	    if(id!=""){
	    	//给隐藏框赋值
	   		$("#mmbId").val(id);
	   		$("#mmbRelationType").val("0");
			//暂时省略校验部分，直接提交
			$.ajax({
				url:'${ctx}/mmbRela/queryMmbRelationshipsByMidNoFilter.do',
				type: "POST",
	            dataType: "json",
				data:{"mmbId":id,"type":0},
				success:function(data){
				   	 data = eval(data);
				   	 //alert(data);
			   	 	 //先清空table中的数据
					 $("#mmbRelaTable  tr:not(:first)").remove();
				   	 //如果成功
				   	 if(data!=null&&data.length>0){
				   	 	if(data!=""&&data.length>0){
				   	 		for(var i=0;i<data.length;i++){
				   	 			var trHtml="<tr id='mmbRelaTable"+i+"' ><td><input type='checkbox' name='relaMmb' value='"+data[i].id+"'/></td><td>"+data[i].sname+"</td><td>"+data[i].fname+"</td></tr>";
				   	 			addTr('mmbRelaTable', -1, trHtml);
				   	 		}

                           /* $("#mmbRelaTable tr:not(:first)").on("click",function(){

                                var flag = $(this).children().eq(0).find("input[type='checkbox']").prop("checked");
                                if(flag){
                                    $(this).children().eq(0).find("input[type='checkbox']").prop("checked",false);
                                }else{
                                    $(this).children().eq(0).find("input[type='checkbox']").prop("checked",true);
                                }
                            });

                            //阻止checkbox的事件冒泡
                            $("#mmbRelaTable tr:not(:first) input[type='checkbox']").on("click",function(event){
                                event.stopPropagation();
                            });*/


				   	 	}
				   	 	//打开管理会员关系模态框
				   	 	$("#manageRelation").modal('show');
				   	 }
				   	 //如果失败
				   	 else{
				   	 	//打开管理会员关系模态框
				   	 	$("#manageRelation").modal('show');
				   	 }
					}
				});
	    }
	}



	//查询卖关系数据
	function queryMmbsInfo(type){
		if(type!=""){
			//暂时省略校验部分，直接提交
			$.ajax({
				url:'${ctx}/mmbRela/queryMmbRelationshipsByMidNoFilter.do',
				type: "POST",
	            dataType: "json",
				data:{
					  "mmbId":$("#mmbId").val(),
				      "type":type
				},
				success:function(data){
				   	 data = eval(data);
			   	 	 //先清空table中的数据
					 $("#mmbRelaTable  tr:not(:first)").remove();
				   	 if(data!=null&&data.length>0){
				   	 	if(data!=""&&data.length>0){
				   	 		for(var i=0;i<data.length;i++){
				   	 			var trHtml="<tr id='mmbRelaTable"+i+"' onclick=bindClick('mmbRelaTable','"+i+"')><td><input type='checkbox' name='relaMmb' value='"+data[i].id+"'/></td><td>"+data[i].sname+"</td><td>"+data[i].fname+"</td></tr>";
				   	 			addTr('mmbRelaTable', -1, trHtml);
				   	 		}
				   	 	}
				   	 }
					}
				});
	    }
	}
	
	//编辑会员信息
	function toEditMmbInfo(id){
	    if(id!=""){
			//暂时省略校验部分，直接提交
			$.ajax({
				url:'${ctx}/mmb/toEditMmbInfoNoFilter.do',
				type: "POST",
	            dataType: "json",
				data:{"id":id},
				success:function(data){
				   	 data = eval(data);
				   	 //如果成功
				   	 if(data!=null){
				   	 	//给编辑框的各个输入框赋值
				   	 	$("#id1").val(data.id);
				   	 	$("#mmbEngSname1").val(data.mmbEngSname);
				   	 	$("#mmbFname1").val(data.mmbFname);
				   	 	//$("#operationName1").val(data.operationName);
				   	 	$("#mmbSname1").val(data.mmbSname);
				   	 	$("#mmbAddress1").val(data.mmbAddress);
				   	 	$("#mmbPhone1").val(data.mmbPhone);
				   	 	$("#mmbEmail1").val(data.mmbEmail);
				   	 	$("#mmbType1").val(data.mmbType);
				   	 	$("#mmbAreaName1").val(data.mmbAreaName);


				   	 	//设置
				   	 	//alert($("#mmbType1").children("option").length);
				   	 	$("#mmbType1").children("option").each(function(){  
				              var temp_value = $(this).val();  
				              if(temp_value == data.mmbType){  
				                    $(this).attr("selected","selected");  
				              }  
				         });  
				   	 	$("#mmbHomepage1").val(data.mmbHomepage);
				   	 	//alert(data.bizTypes.length);
				   	 	//$.each(data.bizTypes, function(index, content)
							//{  
							// alert( content.mmbtype);  
							//});
				   	 	//判断获取到的启用业务类型有哪几种，然后分别迭代勾选
				   	 	if(data.bizTypes!=""&&data.bizTypes.length>0){
				   	 		for(var i=0;i<data.bizTypes.length;i++){
				   	 			var type = data.bizTypes[i].mmbtype;
				   	 			/*if(type!=null&&type=="1"){
				   	 				$("#buy").prop("checked",'true');
				   	 			}
				   	 			else if(type!=null&&type=="2"){
				   	 				$("#sell").prop("checked",'true');
				   	 			}
				   	 			else if(type!=null&&type=="3"){
				   	 				$("#loan").prop("checked",'true');
				   	 			}
				   	 			else if(type!=null&&type=="4"){
				   	 				$("#lending").prop("checked",'true');
				   	 			}
				   	 			else if(type!=null&&type=="5"){
				   	 				$("#crowdfunding").prop("checked",'true');
				   	 			}
				   	 			else if(type!=null&&type=="6"){
				   	 				$("#fund").prop("checked",'true');
				   	 			}
				   	 			else if(type!=null&&type=="7"){
				   	 				$("#service").prop("checked",'true');
				   	 			}*/
								if(type != null && $.trim(type) != ""){
                                    $("#editMember input[name='bizTypes1']").each(function(index,etem){
                                        var inputValue = $(etem).attr("value");
										if(type == inputValue) {
											$(etem).prop("checked" , true);
										}
   	                                 })
								}

				   	 		}
				   	 	}
				   	 	//打开编辑模态框
				   	 	$("#editMember").modal('show');
				   	 }
				   	 //如果失败
				   	 else{
				   	 	alert("系统错误！");
				   	 }
					}
				});
	    }
	}
	
	//停用启用会员状态
	function stopMmb(id,mmbaStatus){
		if(id!=""&&mmbaStatus!=""){
			//暂时省略校验部分，直接提交
			$.ajax({
				url:'${ctx}/mmb/pauseMMBNoFilter.do',
				type: "POST",
	            dataType: "json",
				data:{"id":id},
				success:function(data){
				   	 data = eval(data);
				   	 //如果成功
				   	 if(data!=null&&data== "0"){
				   	 	//提示信息
				   	 	alert("停用会员成功！");
				   	 	//重新查询
				   	 	$("#queryMmbButton").click();
				   	 }
				   	 //如果失败
				   	 else{
				   	 	alert("停用失败！");
				   	 }
					}
				});
	    }
	}
	
	//ajax重启会员
	function restartMmb(id,mmbaStatus){
		if(id!=""){
			//暂时省略校验部分，直接提交
			$.ajax({
				url:'${ctx}/mmb/restartMMBNoFilter.do',
				type: "POST",
	            dataType: "json",
				data:{"id":id},
				success:function(data){
				   	data = eval(data);
				   	 //如果成功
				   	 if(data!=null&&data== "0"){
				   	 	//提示信息
				   	 	alert("重启会员成功！");
				   	 	//重新查询
				   	 	$("#queryMmbButton").click();
				   	 }
				   	 //如果失败
				   	 else{
				   	 	alert("重启失败！");
				   	 }
				   	}
				});
	    }
	}
	
   function checkAllBox(obj){
		$(obj).parent().parent().parent().parent().find("[name = forLowerId]:checkbox").each(function(i,thisElement){
			if($(obj).prop("checked")==true){
		      $(thisElement).prop("checked",'true');
			}else{
				$(thisElement).prop("checked",false);
			}
		})
	}
	
	//全选反选会员
	function checkAllMmbs(obj){
		//alert($("#relaMmbTable1 tr td [name =mmbCheck]:checkbox").length);
		$("#relaMmbTable1 tr td [name =mmbCheck]:checkbox").each(function(i,thisElement){
			if($(obj).prop("checked")==true){
		      $(thisElement).prop("checked",'true');
			}else{
				$(thisElement).prop("checked",false);
			}
		});
	}
	
	//批量提交会员关系数据
	function submitMmbs(){
		var checkedMmbs = $("#relaMmbTable1 tr td input[name=mmbCheck]:checked");
		if(checkedMmbs.length==0){
			alert("请选择需要创建关系会员！");
			return false;
		}
		var stringsId = "";
		checkedMmbs.each(function(i,thisElement){
			if(thisElement.value!=""){
				stringsId+=thisElement.value+",";
			}
		});
		//去掉最后一个逗号
		stringsId = stringsId.substring(0,stringsId.length-1);
		//提交创建买卖关系
		$.ajax({
				url : '${ctx}/mmbRela/batchSaveRelaMMbs.do',// 跳转到 action
				data : {
					type :$("#relatype").val(),
					mmbIds : stringsId,
					mid:$("#mmbId1").val()
				},
				type : 'POST',
				cache : false,
				dataType : 'json',
				success : function(data) {
					//先清空table中的数据
					var result = data;
					if(result!=""&&result=="0"){
						alert("添加会员关系成功！");
						//关闭当前模态框
						$("#addReMem").modal('hide');
						//将父模态框隐藏
						//$("#manageRelation").modal('hide');
						//重新加载数据
						var type = $("#relatype").val();
						//暂时省略校验部分，直接提交
						$.ajax({
							url:'${ctx}/mmbRela/queryMmbRelationshipsByMidNoFilter.do',
							type: "POST",
				            dataType: "json",
							data:{
								"mmbId":$("#mmbId1").val(),
								"type":type
								},
							success:function(data){
							   	 data = eval(data);
							   	 //alert(data);
							   	 //如果成功
							   	 if(data!=null&&data.length>0){
							   	 	$("#mmbRelationType").val(type);
							   	 	//先清空table中的数据
									$("#mmbRelaTable  tr:not(:first)").remove();
							   	 	if(data!=""&&data.length>0){
							   	 		for(var i=0;i<data.length;i++){
							   	 			var trHtml="<tr><td><input type='checkbox' name='relaMmb' value='"+data[i].id+"'/></td><td>"+data[i].sname+"</td><td>"+data[i].fname+"</td></tr>";
							   	 			addTr('mmbRelaTable', -1, trHtml);
							   	 		}
							   	 	}
							   	 }
								}
							});
					}
					else{
						alert("添加会员关系失败！");
					}
				},
				error : function() {
					alert("异常！");
				}
			});
	}
	
	//全选反选会员关系
	function checkAllRelaMmbs(obj){
		//alert($("#mmbRelaTable tr td [name = relaMmb]:checkbox").length);
		$("#mmbRelaTable tr td [name = relaMmb]:checkbox").each(function(i,thisElement){
			if($(obj).prop("checked")==true){
		      $(thisElement).prop("checked",'true');
			}else{
				$(thisElement).prop("checked",false);
			}
		});
	}
	
	//批量删除会员关系数据
	function deleteMmbRela(){
		var checkedMmbs = $("#mmbRelaTable tr td input[name=relaMmb]:checked");
		if(checkedMmbs.length==0){
			alert("请选择需要删除的关系会员！");
			return false;
		}
		var stringsId = "";
		checkedMmbs.each(function(i,thisElement){
			if(thisElement.value!=""){
				stringsId+=thisElement.value+",";
			}
		});
		//去掉最后一个逗号
		stringsId = stringsId.substring(0,stringsId.length-1);
		//提交批量删除信息
		$.ajax({
				url : '${ctx}/mmbRela/batchDeleteRelationShips.do',// 跳转到 action
				data : {
					mmbIds : stringsId
				},
				type : 'POST',
				cache : false,
				dataType : 'json',
				success : function(data) {
					//先清空table中的数据
					var result = data;
					if(result!=""&&result=="0"){
						alert("删除会员关系成功！");
						//将父模态框隐藏
						//$("#manageRelation").modal('hide');
						//重新加载数据
                        var type = $("#mmbRelationType").val();
						//暂时省略校验部分，直接提交
						$.ajax({
							url:'${ctx}/mmbRela/queryMmbRelationshipsByMidNoFilter.do',
							type: "POST",
				            dataType: "json",
							data:{
								"mmbId":$("#mmbId").val(),
								"type":type
								},
							success:function(data1){
							   	 data = eval(data1);
							   	 //如果成功
							   	 if(data!=null&&data.length>0){
							   	 	$("#mmbRelationType").val(type);
							   	 	//先清空table中的数据
									$("#mmbRelaTable  tr:not(:first)").remove();
							   	 	if(data!=""&&data.length>0){
							   	 		for(var i=0;i<data.length;i++){
							   	 			var trHtml="<tr><td><input type='checkbox' name='relaMmb' value='"+data[i].id+"'/></td><td>"+data[i].sname+"</td><td>"+data[i].fname+"</td></tr>";
							   	 			addTr('mmbRelaTable', -1, trHtml);
							   	 		}
							   	 	}
							   	 }else if(data.length == 0){
                                     $("#mmbRelationType").val(type);
                                     //先清空table中的数据
                                     $("#mmbRelaTable  tr:not(:first)").remove();
								 }
								}
							});
					}
					else{
						alert("删除会员关系失败！");
					}
				},
				error : function() {
					alert("异常！");
				}

			});
		$("#mmbRelaAll").attr("checked",false);
	}
	
	
	//点击添加会员
	function addMmbRela(){
		//将当前选中的会员id传入
		$("#mmbId1").val($("#mmbId").val());
		$("#relatype").val($("#mmbRelationType").val());
		//打开编辑模态框
   	 	$("#addReMem").modal('show');

        queryMmbByCon1();//调用查询方法
	}
	
	 //点击查询会员列表，实现局部分页查询会员列表信息
	function queryMmbByCon1() {
			$.ajax({
				url : '${ctx}/mmb/queryMMBListNoFilter.do',// 跳转到 action
				data : {
					mmbFname : $("#mmb_Fname").val(),
					pageNo : 1,
					pageSize : 10
				},
				type : 'POST',
				cache : false,
				dataType : 'json',
				success : function(data) {
					//先清空table中的数据
					$("#relaMmbTable1  tr:not(:first)").remove();
					//获取当前会员id，不在列表中显示
					var curentId = $("#mmbId1").val();
					if (data.mmbList.length > 0) {
						for ( var i = 0; i < data.mmbList.length; i++) {
							if(data.mmbList[i].id!=""&&data.mmbList[i].id!=curentId){
								var content = '';
								content += "<tr>";
                                content += "<td><input type=checkbox name=mmbCheck value='"+data.mmbList[i].id+"'></td>";
                                content += "<td>"+data.mmbList[i].mmbSname+"</td>";
                                content += "<td>"+data.mmbList[i].mmbFname+"</td>";
                                content += "<td>"+data.mmbList[i].mmbAddress+"</td>";
                                content += "<td>"+data.mmbList[i].createDate+"</td>";
                                content += '</tr>';
								addTr('relaMmbTable1', -1, content);


							}
						}

                       /* $("#relaMmbTable1 tr:not(:first)").on("click",function(){
                            var flag = $(this).children().eq(0).find("input[type='checkbox']").prop("checked");
							if(flag){
                                $(this).children().eq(0).find("input[type='checkbox']").prop("checked",false);
							}else{
                                $(this).children().eq(0).find("input[type='checkbox']").prop("checked",true);
							}

                        });

						//阻止 checkbox的事件冒泡
                        $("#relaMmbTable1 tr:not(:first) input[type='checkbox']").on("click",function(event){
                            event.stopPropagation();
						});*/

						//Notify('共查询到'+data.mmbCount+'条数据！', 'bottom-right', '5000', 'info', 'fa-tag', true);
					} else {
						//Notify('Sorry,无数据！', 'bottom-right', '5000', 'info', 'fa-tag', true);
					}
					setPagination1(1, 10, data.mmbCount-1);

				},
				error : function() {
					alert("异常！");
				}
			});

		}

		//查询模态框查询出的会员信息
		function setPagination1(curr, limit, totalCount) {
			$('#callBackPager1').extendPagination({
				totalCount : totalCount,
				showCount : limit,
				limit : limit,
				callback : function(curr, limit, totalCount) {
					$.ajax({
						url : '${ctx}/mmb/queryMMBListNoFilter.do',// 跳转到 action
						data : {
							mmbFname : $("#mmb_Fname").val(),
							pageNo : curr,
							pageSize : limit
						},
						type : 'POST',
						cache : false,
						dataType : 'json',
						success : function(data) {
							//先清空table中的数据
							$("#relaMmbTable1  tr:not(:first)").remove();
							//获取当前会员id，不在列表中显示
							var curentId = $("#mmbId1").val();
							if (data.mmbList.length > 0) {
								for ( var i = 0; i < data.mmbList.length; i++) {
									if(data.mmbList[i].id!=""&&data.mmbList[i].id!=curentId){
										var content = '';
										content += '<tr>';
										content += "<td><input type=checkbox name=mmbCheck value='"+data.mmbList[i].id+"'></td>";
										content += "<td>"+data.mmbList[i].mmbSname+"</td>";
										content += "<td>"+data.mmbList[i].mmbFname+"</td>";
										content += "<td>"+data.mmbList[i].mmbAddress+"</td>";
										content += "<td>"+data.mmbList[i].createDate+"</td>";
										content += '</tr>';
										addTr('relaMmbTable1', -1, content);
									}
								}
								//$('#mmbListBody').html(content);
								//Notify('共查询到'+data.mmbCount+'条数据！', 'bottom-right', '5000', 'info', 'fa-tag', true);
							} else {
								//Notify('Sorry,无数据！', 'bottom-right', '5000', 'info', 'fa-tag', true);
							}
						},
						error : function() {
							alert("异常！");
						}
					});
				}
			});
		}
  </script>
<body>
<div class="container-fluid" style="margin-top:15px;">
    <div class="row-fluid">
        <!-- col-sm-12 -->
        <div class="col-sm-12 ">
        	<div class="panel panel-default article-bj">
                <div class="panel-heading box-shodm">
            		    会员管理
                </div>
                	<form id="queryMmbForm" action="${ctx}/mmb/queryMMBListNoFilter.do"　method="post">
        			<div class="row wrapper form-margin">
       					 <div class="col-md-4">
        					<div class="input-group">
       							 <div class="input-group-btn">
       							 	<h5 class="h5-margin">注册全称:</h5>
       							 <!--   <button class="btn" type="button"></button> -->
       							 </div>
       							 <input type="text" placeholder="" name="mmbFname" value="${mmbFname!}" class="form-control"  id="mmbFname">
        					</div>
        				</div>
        				<input type="button" class="btn btn-info btn-s-md btn-default" value="查询" style="height:35px;width:65px" onclick="queryMmbByCon();" id="queryMmbButton"/>
       					<!--<a class="btn btn-info btn-s-md btn-default " href="#"><input type="button" onclick="queryMmb();">查询</input></a>-->
       				</form>
                        <a class="btn btn-info btn-s-md btn-warning float-right cx-btn-margin" href="#" data-toggle="modal" 
                        data-target="#createMember">创建会员</a>
       				 </div>
                    <div class="table-responsive panel-table-body ">
                        <table class="table table-striped table-hover " id="mmbTable">
                            <thead>
                                <tr>
                                	<!--<td><input type="checkbox" name="checkAll" onclick="checkAllBox(this)"></td>-->
                                    <th>简称</th>
                                    <th>注册全称</th>
                                    <th>注册地址</th>
                                    <th>创建时间</th>
                                    <th>操作</th>
                                </tr>
                            </thead>
                            <tbody id="mmbListBody">
				             
				            </tbody>
                        </table>
                    </div> 
                    <footer class="panel-footer text-right bg-light lter">
                       <div id="callBackPager" float="right;"></div>
                    </footer>
        		</div>
       		 </div>
        </div>
    </div> 
</div>
<!--添加会员-->
<!--弹出层--> 
<form id="saveMmbInfoForm" 　method="post">
<div class="modal fade" id="createMember" role="dialog" aria-labelledby="gridSystemModalLabel" data-backdrop="static">
	<div class="modal-dialog m-tanchu-box" role="document"> 
        <div class="container-fluid" style=" margin-top:15px;">
            <div class="row-fluid">
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading box-shodm modal-draggable">
                     		   创建会员
                            <button class="close" aria-hidden="true" data-dismiss="modal" type="button">×</button>
                        </div>
                            <div class="row wrapper form-margin">
                                 <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">简称:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" class="form-control validate[required,maxSize[50]]" name="mmbSname" id="mmbSname" >
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                        <div class="input-group-btn">
                                            <h5 class="h5-margin">管理员账号:</h5>
                                        <!--   <button class="btn" type="button"></button> -->
                                        </div>
                                        <input type="text" class="form-control validate[required,minSize[3],maxSize[30]]" name="operationName" id="operationName">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">英文简称:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" class="form-control validate[required,maxSize[50]]" name="mmbEngSname" id="mmbEngSname">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">管理员密码:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="password" class="form-control validate[required,minSize[6],maxSize[16]]" name="operationPassWord" id="operationPassWord">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">注册全称:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" placeholder="" class="form-control validate[required,maxSize[100]]" name="mmbFname" id="mmbFname">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">确认密码:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="password" class="form-control validate[required,minSize[6],maxSize[16],equals[operationPassWord]]" name="operationPassWord1" id="operationPassWord1">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">注册地址:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text"  class="form-control validate[maxSize[50]]" name="mmbAddress" id="mmbAddress">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">管理员手机:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" class="form-control validate[custom[mobile]]" name="mmbPhone" id="mmbPhone">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">所属地域:</h5>
                                         </div>
                                        <input  name="mmbAreaId" id="mmbAreaId" type="hidden">
                                        <input type="text" onclick="openTreeModal2(this)" readonly="readonly"  class="form-control validate[required]" />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">管理员邮箱:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" class="form-control validate[custom[email],maxSize[50]]" name="mmbEmail" id="mmbEmail">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">会员类型:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <select name="mmbType" tabindex="-1" class="form-control">
                                            <option value="1">高校</option>
                                            <option value="2">供应商</option>
                                            <option value="3">龙头企业</option>
                                         </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">会员主页:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" placeholder="" class="form-control validate[maxSize[50]]" name="mmbHomepage" id="mmbHomepage">
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="input-group">
                                        <div class="input-group-btn">
                                            <h5 class="h5-margin">启用业务:</h5>
                                        <!--   <button class="btn" type="button"></button> -->
                                        </div>
                                        <div class="checkbox">
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes" value="1002" class="validate[minCheckbox[1]]"> 交易
                                            </label>
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes" value="1003" class="validate[minCheckbox[1]]"> 借款
                                            </label>
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes" value="1004" class="validate[minCheckbox[1]]"> 贷款
                                            </label>
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes" value="1005" class="validate[minCheckbox[1]]"> 投资
                                            </label>
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes" value="1006" class="validate[minCheckbox[1]]"> 筹款
                                            </label>
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes" value="1001" class="validate[minCheckbox[1]]"> 服务支持
                                            </label>
                                        </div>
                                    </div>
                                </div>
                             </div>
                            <footer class="panel-footer text-right bg-light lter">
                            <button class="btn btn-warning btn-s-xs" type="button" onclick="checkMmbInfo();">创建</button>
                            <input type="reset" style="display:none;" />
                            </footer>
                        </div>
                     </div>
                </div>
            </div>
        </div>
	</div>
</div>
</form>
<!--编辑会员-->
<!--弹出层-->
<form id="updateMmbInfoForm" 　method="post">
<div class="modal fade" id="editMember" role="dialog" aria-labelledby="gridSystemModalLabel" data-backdrop="static">
	<div class="modal-dialog m-tanchu-box" role="document">
        <div class="container-fluid" style=" margin-top:15px;">
            <div class="row-fluid">
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading box-shodm modal-draggable">
                     		  编辑会员
                            <button class="close" aria-hidden="true" data-dismiss="modal" type="button">×</button>
                        </div>
                            <div class="row wrapper form-margin">
                                 <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">简称:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="hidden" id="id1" name="id1"/>
                                        <input type="text" class="form-control validate[required,maxSize[50]]" name="mmbSname1" id="mmbSname1">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">英文简称:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                        <input type="text"  class="form-control validate[required,maxSize[50]]" name="mmbEngSname1" id="mmbEngSname1" >
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">注册全称:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" placeholder="" class="form-control validate[maxSize[100]]" name="mmbFname1" id="mmbFname1">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">注册地址:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" placeholder="" class="form-control validate[maxSize[50]" name="mmbAddress1" id="mmbAddress1">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">管理员手机:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" class="form-control validate[custom[mobile]]" name="mmbPhone1" id="mmbPhone1">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">所属地域:</h5>
                                         </div>
                                        <input  name="mmbAreaId1" id="mmbAreaId1" type="hidden">
                                        <input type="text" onclick="openTreeModal2(this)" readonly="readonly" id="mmbAreaName1" class="form-control " />
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">管理员邮箱:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" class="form-control validate[custom[email,maxSize[50]]]" class="form-control" name="mmbEmail1" id="mmbEmail1">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">会员类型:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <select name="mmbType1" id="mmbType1" tabindex="-1" class="form-control">
                                            <option value=1>高校</option>
                                            <option value=2>供应商</option>
                                            <option value=3>龙头企业</option>
                                         </select>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">会员主页:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" placeholder="" class="form-control validate[maxSize[50]]" name="mmbHomepage1" id="mmbHomepage1">
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="input-group">
                                        <div class="input-group-btn">
                                            <h5 class="h5-margin">启用业务:</h5>
                                        <!--   <button class="btn" type="button"></button> -->
                                        </div>
                                        <div class="checkbox">
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes1" value="1002" class="validate[minCheckbox[1]]"> 交易
                                            </label>
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes1" value="1003" class="validate[minCheckbox[1]]"> 借款
                                            </label>
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes1" value="1004" class="validate[minCheckbox[1]]"> 贷款
                                            </label>
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes1" value="1005" class="validate[minCheckbox[1]]"> 投资
                                            </label>
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes1" value="1006" class="validate[minCheckbox[1]]"> 筹款
                                            </label>
                                            <label style="margin-left:15px;">
                                                <input type="checkbox" name="bizTypes1" value="1001" class="validate[minCheckbox[1]]"> 服务支持
                                            </label>
                                        </div>
                                    </div>
                                </div>
                             </div>
                            <footer class="panel-footer text-right bg-light lter">
                            <button class="btn btn-warning btn-s-xs" type="button" onclick="updateMmbInfo();">修改</button>
                            </footer>
                        </div>
                     </div>
                </div>
            </div>
        </div>
	</div>
</div>
</form>
<!--管理区域-->
<!--弹出层-->
<div class="modal fade" id="manageArea" role="dialog" aria-labelledby="gridSystemModalLabel" data-backdrop="static">
	<div class="modal-dialog m-tanchu-box" role="document">
        <div class="container-fluid" style=" margin-top:15px;">
            <div class="row-fluid">
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading box-shodm modal-draggable">
                        	管理区域
                            <button class="close" aria-hidden="true" data-dismiss="modal" type="button">×</button>
                        </div>
                            <div class="table-responsive panel-table-body ">
                                <table class="table table-striped table-hover " id="manageAreaTable">
                                    <thead>
                                        <tr>
                                            <th><input type="checkbox" id="checkAll" onclick="checkAllAreaBizs(this)"><input type="hidden" id="operationMmbId"></th>
                                            <th>地域</th>
                                            <th colspan="4">业务类型</th>
                                        </tr>
                                    </thead>
                                    <tbody id="areaBody">

                                    </tbody>
                                </table>
                            </div>
                            <footer class="panel-footer text-right bg-light lter">
                            <button class="btn btn-success btn-s-xs" type="button"  onclick="openTreeModel();">添加</button>
                            <button class="btn btn-info btn-s-xs" type="button" onclick="deleteAreaBizs();">删除</button>
                            <button class="btn btn-warning btn-s-xs" type="button" onclick="submitAreaBizs();">提交</button>
                            <button class="btn btn-warning btn-s-xs" type="submit" data-dismiss="modal">关闭</button>
                            </footer>
                        </div>
                     </div>
                </div>
            </div>
        </div>
	</div>
</div>
<!--添加区域-->
<!--弹出层-->
<div class="modal fade" id="addArea" role="dialog" aria-labelledby="gridSystemModalLabel">
	<div class="modal-dialog s-tanchu-box" role="document" style="margin-left:35%; margin-top:85px;">
        <div class="row wrapper ">
            <div class="col-md-12 tree-bg">
                <h4><strong>地域名称</strong></h4>
                <hr>
                <div id="tree"></div>
            </div>
        </div>
	</div>
</div>

<!--树数据-->
<script type="text/javascript">
	var defaultData = "";
	function openTreeModel(){
		$.ajax({
					url : '${ctx}/mmb/getTreeModel.do',// 跳转到 action
					type : 'POST',
					cache : false,
					dataType : 'json',
					success : function(data) {
						//alert(data.length);
						if(data!=""&&data.length>0){
							$('#tree').treeview({
							  color: "#428bca",
							  enableLinks: true,
							  data: data,
							  showBorder: false,
							  expandIcon: 'glyphicon glyphicon-chevron-right',
							  collapseIcon: 'glyphicon glyphicon-chevron-down',
							  nodeIcon: 'glyphicon glyphicon-send'
							});
							//节点点击事件,给表格中的地方赋值
							$('#tree').on('nodeSelected', function(event, data) {
								var content = '';
								content += '<tr>';
								content += "<td><input type=checkbox name=areaCheckBox value="+data.id+"></td>";
								content += "<td>"+data.text+"</td>";
								content += "<td><input type=checkbox name=areaType value=0>买</td>";
								content += "<td><input type=checkbox name=areaType value=1>卖</td>";
								content += "<td><input type=checkbox name=areaType value=2>借</td>";
								content += "<td><input type=checkbox name=areaType value=3>贷</td>";
								content += '</tr>';
								addTr('manageAreaTable', -1, content);
							 //alert(data.text);
							 //alert(data.id);
							  $('#addArea').modal('hide');
							 });
						}
						//defaultData = data;
						$("#addArea").modal('show');
					},
					error : function() {
						alert("异常！");
					}
		});
	}

	//添加、编辑会员 所属地域--弹出地域树
	function openTreeModal2(obj){
        $.ajax({
            url : "${ctx}/mmbWarehouse/getTreeModal.do",
            dataType : "json",
            cache : false,
            type : "POST",
            error : function(){
                alert("异常");
            },
            success : function(data){
                if(data != "" && data.length > 0){
                    $("#tree").treeview({
                        color :  "#428bca",
                        enableLinks : false,
                        data : data,
                        showBorder : false,
                        expandIcon: 'glyphicon glyphicon-plus',
                        collapseIcon: 'glyphicon glyphicon-minus',
                        nodeIcon: 'glyphicon glyphicon-send'

                    });

					//折叠所有父节点
                    $('#tree').treeview('collapseAll', { silent: true });

                    //显示地域树 模态框
                    $("#addArea").modal("show");

                    //节点点击事件 给表格中对应的位置 赋值
                    $("#tree").on("nodeSelected",function(event,data){

                        $(obj).val(data.text);
                        $(obj).parent().children("input").first().val(data.id);
                        $("#addArea").modal("hide");
                    });
                }
            }


        });

	}

	//批量删除会员关系数据
	function deleteAreaBizs(){
		var checkedMmbs = $("#manageAreaTable tr td input[name=areaCheckBox]:checked");
		if(checkedMmbs.length==0){
			alert("请选择需要删除的地域业务信息！");
			return false;
		}
		//迭代移除tr
		checkedMmbs.each(function(){
			$(this).parent().parent().remove();
		});
	}

	//批量提交地域信息
	function submitAreaBizs(){
		var flag = true;
		var mmbid = $("#operationMmbId").val();
		//首先校验是否有勾选的提交信息
		var checkedMmbs = $("#manageAreaTable tr td input[name=areaCheckBox]:checked");
		if(checkedMmbs.length==0){
			alert("请选择需要提交的地域业务信息！");
			return false;
		}
		//迭代判断每条下的地域业务是否选择
		//拼接json串
		var jsonArr = "[";
		checkedMmbs.each(function(i,thisElement){
			jsonArr+="{";
			jsonArr+="\"id\":"+$(thisElement).val()+",";
			var bizTypes = $(thisElement).parent().parent().find("input[name=areaType]:checked");
			var type = "";
			if(bizTypes!=""&&bizTypes.length>0){
				bizTypes.each(function(i,thisElement){
					type+=$(thisElement).val()+",";
				});
			}
			else{
				flag = false;
				alert("第"+(i+1)+"行未选中业务类型！");
				return false;
			}
			if(type!=""){
				//再截取一个逗号
				type = type.substring(0,type.length-1);
			}
			jsonArr+="\"bizType\":" + "\""+type+"\"}";
			jsonArr+=",";
		});
		//再截取一个逗号
		jsonArr = jsonArr.substring(0,jsonArr.length-1);
		jsonArr+="]";
		if(flag){
				//提交保存
				$.ajax({
						url : '${ctx}/mmb/batchAddMMBAreaBiz.do',// 跳转到 action
						type : 'POST',
						cache : false,
						data :{
							jsonArry :jsonArr,
							mmbId :mmbid
						},
						dataType : 'json',
						success : function(data) {
							if(data!=""&&data=="0"){
								alert("提交成功！");
								$('#manageArea').modal('hide');
							}
							else{
								alert("提交失败！");
							}
						},
						error : function() {
							alert("异常！");
						}
			});
		}
		else{
			return false;
		}
	}

	//全选反选地域类型关系
	function checkAllAreaBizs(obj){
		//alert($("#manageAreaTable tr td [name = areaCheckBox]:checkbox").length);
		$("#manageAreaTable tr td [name = areaCheckBox]:checkbox").each(function(i,thisElement){
			if($(obj).prop("checked")==true){
		      $(thisElement).prop("checked",'true');
			}else{
				$(thisElement).prop("checked",false);
			}
		});
	}
</script>
<!--管理关系-->
<!--弹出层-->
<div class="modal fade" id="manageRelation" role="dialog" aria-labelledby="gridSystemModalLabel" data-backdrop="static">
	<div class="modal-dialog m-tanchu-box" role="document">
        <div class="container-fluid" style=" margin-top:15px;">
            <div class="row-fluid">
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading box-shodm modal-draggable">
                      	  	  会员关系管理
                            <button class="close" aria-hidden="true" data-dismiss="modal" type="button">×</button>
                        </div>
                        	<div class="row wrapper form-margin">
                                <div class="col-md-8">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">关系类型:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="hidden" id="mmbId">
                                         <select name="mmbRelationType" id="mmbRelationType" tabindex="-1"class="form-control" onchange="queryMmbsInfo(this.value)">
                                            <option value="0">买</option>
                                            <option value="1">卖</option>
                                        </select>
                                    </div>
                                </div>
                             </div>
                            <div class="table-responsive panel-table-body ">
                                <table class="table table-striped table-hover " id="mmbRelaTable">
                                    <thead>
                                        <tr>
                                            <th><input type="checkbox" id="mmbRelaAll" onclick="checkAllRelaMmbs(this)"></th>
                                            <th>简称</th>
                                            <th>全称</th>
                                        </tr>
                                    </thead>
                                    <tbody>

                                    </tbody>
                                </table>
                            </div>
                            <footer class="panel-footer text-right bg-light lter">
                            <button class="btn btn-success btn-s-xs" type="button" onclick="addMmbRela();">添加</button>
                            <button class="btn btn-info btn-s-xs" type="button" onclick="deleteMmbRela();">删除</button>
                            <button class="btn btn-warning btn-s-xs" type="submit" data-dismiss="modal">退出</button>
                            </footer>
                        </div>
                     </div>
                </div>
            </div>
        </div>
	</div>
</div>
<!--管理关系-添加会员-->
<!--弹出层-->
<div class="modal fade" id="addReMem" role="dialog" aria-labelledby="gridSystemModalLabel" data-backdrop="static">
	<div class="modal-dialog m-tanchu-box" role="document">
        <div class="container-fluid" style=" margin-top:15px;">
            <div class="row-fluid">
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading box-shodm modal-draggable">
                        	添加关系会员
                            <button class="close" aria-hidden="true" data-dismiss="modal" type="button">×</button>
                        </div>
                        	<div class="row wrapper form-margin">
                                <div class="col-md-8">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">注册全称:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" placeholder="" class="form-control" name="mmbFname1" id="mmb_Fname">
                                         <!--隐藏从会员关系传入的值-->
                                         <input type="hidden" id="mmbId1">
                                         <input type="hidden" id="relatype">
                                    </div>
                                </div>
                                <a class="btn btn-info btn-s-md btn-default float-right cx-btn-margin" href="#" onclick="queryMmbByCon1();">查询</a>	
                             </div>
                            <div class="table-responsive panel-table-body ">
                                <table class="table table-striped table-hover " id="relaMmbTable1">
                                    <thead>
                                        <tr>
                                            <th><input type="checkbox" onclick="checkAllMmbs(this)"></th>
                                            <th>简称</th>
                                            <th>全称</th>
                                            <th>注册地址</th>
                                            <th>创建时间</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                       
                                    </tbody>
                                </table>
                            </div> 
                             <footer class="panel-footer text-right bg-light lter">
		                       <div id="callBackPager1" float="right;"></div>
		                    </footer>
                            <footer class="panel-footer text-right bg-light lter">
                            <button class="btn btn-warning btn-s-xs" type="button" onclick="submitMmbs()">确定</button>
                            <button class="btn btn-warning btn-s-xs" type="submit" data-dismiss="modal">取消</button>
                            </footer>
                        </div>
                     </div>
                </div>
            </div> 
        </div>
	</div> 
</div>
</body>
</html>
