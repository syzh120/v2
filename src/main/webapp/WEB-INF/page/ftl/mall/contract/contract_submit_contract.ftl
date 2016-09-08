<!DOCTYPE HTML>
<#assign sec=JspTaglibs["/WEB-INF/security.tld"] />   <#-- 引入security.tld标签-->
<#assign ctx = request.contextPath/>
<html xmlns="http://www.w3.org/1999/xhtml">

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

    <link href="${ctx}/mall/css/bootstrap.min.css" rel="stylesheet" type="text/css">
    <link href="${ctx}/mall/css/theme.css" rel="stylesheet" type="text/css">
	<link href="${ctx}/mall/css/pulic.css" rel="stylesheet" type="text/css">
	<link href="${ctx}/mall/css/SimpleTree.css" rel="stylesheet" type="text/css">
	<link href="${ctx}/mall/css/bootstrap-table.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" media="all" href="${ctx}/factoring/css/daterangepicker-bs3.css" />

	<script src="${ctx}/mall/js/jquery.js"></script>

	<script src="${ctx}/mall/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="${ctx}/mall/js/bootstrap-table.js"></script>
    <script src="${ctx}/mall/js/bootstrap-table-zh-CN.js"></script>

	<script src="${ctx}/mall/js/SimpleTree.js" type="text/javascript"></script>
	<script src="${ctx}/mall/js/bootstrap-treeview.js"></script>

	<script type="text/javascript" src="${ctx}/factoring/js/moment.js"></script>
	<script type="text/javascript" src="${ctx}/factoring/js/daterangepicker.js"></script>
	<script type="text/javascript" src="${ctx}/factoring/js/DatePicker/WdatePicker.js"></script>

    <script src="${ctx}/mall/js/serializeJson.js"></script>
    <!-- 协议详情 js-->
    <script src="${ctx}/mall/js/contractDetail.js"></script>

    <script src="${ctx}/mall/js/common/common.js"></script>

    <script type="text/javascript" src="${ctx}/common/jqueryValidation/js/jquery.validationEngine-zh_CN.js"></script>
	<script type="text/javascript" src="${ctx}/common/jqueryValidation/js/jquery.validationEngine.min.js"></script>
	<link rel="stylesheet" type="text/css" href="${ctx}/common/jqueryValidation/css/validationEngine.jquery.css" />
</head>

<body>
<div class="container-fluid ">
	<div class="row-fluid">
		<div class="col-sm-12 ">
			<div class="panel panel-default article-bj">
				<div class="panel-heading box-shodm">已提交合作协议</div>
				<form id="queryPendingOrderForm">
					<div class="row wrapper form-margin" style="margin:15px;">

						<div class="col-md-4">
							<div class="input-group">
								<div class="input-group-btn">
									<h5 class="h5-margin">协议类型:</h5>
								</div>
								<select id="contractType" name="contractType" tabindex="-1" class="form-control" onchange="changeContract()">
									<option value="1" selected="selected">采购协议</option>
									<option value="2">销售协议</option>
								</select>
							</div>
						</div>

						<div class="col-md-4">
							<div class="input-group">
								<div class="input-group-btn">
									<h5 class="h5-margin">协议对方:</h5>
								</div>
								<input type="text" placeholder="" class="form-control" name="name" id="name"/>
							</div>
						</div>

                       <#-- <div class="col-md-4">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">关系会员:</h5>
                                </div>
                                <select id="relaMmbId" name="relaMmbId" tabindex="-1" class="form-control" onchange="querySubmitContract()">
                                    <option value="">全部</option>
                                    <#if relaMmbList ??>
                                        <#list relaMmbList as relaMmb>
                                            <option value="${relaMmb.memberId!}">${relaMmb.fname!}</option>
                                        </#list>
                                    </#if>

                                </select>
                            </div>
                        </div>-->


						<input type="hidden" name ="mmbId" id="mmbId" value="${(mmbId)!}">

                        <div>
						<input type="button" class="btn btn-info btn-s-md btn-default cx-btn-margin" value="查询"
							   	style="height:35px;width:65px" onclick="querySubmitContract();" id="querySubmitContractButton"/>

                       <#-- <input type="button" class="btn btn-info btn-s-md btn-default float-right cx-btn-margin" value="添加"
                               style="height:35px;width:65px" onclick="addContract();" id="addContractButton"/>-->
                        </div>
					</div>
				</form>
				<div class="table-responsive panel-table-body ">
					<table class="table table-striped table-hover " id="tb_submitContract"></table>
				</div>

			</div>
		</div>
	</div>

    <!-- 协议详情modal-->
    <div class="modal fade" id="contractDetail" role="dialog" aria-labelledby="gridSystemModalLabel" data-backdrop="static"></div>

    <!-- 添加合作协议 end-->

<script type="text/javascript">

	$(function(){
		var oTable = new tableInit();
        oTable.Init();

       // changeContract();

        $("#workerTime").val(new Date().toLocaleString());
        $("#userTime").daterangepicker();

        //用户品类树
        $.ajax({
            url : '${ctx}/GoodController/getUserCategoryByMmbId.do',// 跳转到 action
            type : 'POST',
            cache : false,
            data:{
                relaMmbId :$("#relaMmbId").val()
            },
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
                        nodeIcon: 'glyphicon glyphicon-file'
                    });
                    //点击事件
                    $('#tree').on('nodeSelected', function(event, data) {
                        var goodsflag = true;
                        if(data.nodes==null||data.nodes==""){
                            //赋值
                            $('#goodsTable').children("tbody").find("tr:not(first)").each(function(i,element){
                                if($(element).children().find("[name=goods]").val() == data.id){
                                    alert("已存在的商品，请勿重复提交！");
                                    goodsflag = false;
                                }
                            })
                            if(goodsflag == true){
                                var row2 = document.getElementById("goodsTable").insertRow(goodsTable.rows.length);
                                row2.insertCell(0).innerHTML='<td><input type="text" hidden = "hidden "name ="goods" id="goods" value='+data.id+' />'+data.text+'</td>';
                                row2.insertCell(1).innerHTML='<td><a href="#" onclick="deleteCurrentRow(this)">删除</a></td>';
                            }
                        }
                    });
                }
            },
            error : function() {
                alert("异常！");
            }
        });
	});


	var tableInit = function(){
		var oTableInit = new Object();
		//初始化table
		oTableInit.Init = function(){
			$("#tb_submitContract").bootstrapTable({
				url : "${ctx}/contract/queryContractByPageType.do",
                method : "post",
                dataType : "json",
                classes : "table table-no-bordered",
                contentType : "application/x-www-form-urlencoded",
				striped : true,
				cache : false,
				pagination : true,
				sortable : false,
				sortOrder : "asc",
				queryParams : oTableInit.queryParams, //传递参数（*）
				sidePagination : "server",
				pageNumber : 1,
				pageSize : 10,
				pageList : [10],
				search : false,
                strictSearch : false,
                showColumns : false,
                showRefresh : false,
                showFooter: true,
                minimumCountColumns : 2,
                clickToSelect : false,
                uniqueId : "id",
                showToggle : false,
                cardView : false,
                detailView : false,
                paginationPreText : "«",
                paginationNextText : "»",
				columns : [
					{
						field : "contractTitle",
						title : "标题",
						align : "center",
						valign : "middle",
						sortable : false,
                        formatter : function(value,row,index) {
                            return '<a data-toggle="modal" href="#" onclick="openContractDetail(\'' + row.id + '\')">' + row.contractTitle + '</a>';
                        }
					},
                    {
                        field : "mmbName",
                        title : "协议对方",
                        align : "center",
                        valign : "middle",
                        sortable : false
                    },
					{
						field : "startTime",
						title : "开始时间",
                        align : "center",
                        valign : "middle",
                        sortable : false,
                        formatter : function(value,row,index){
                            return $.changeDate(value);
                        }
					},
                    {
                        field : "endTime",
                        title : "结束时间",
                        align : "center",
                        valign : "middle",
                        sortable : false,
                        formatter : function(value,row,index){
                            return $.changeDate(value);
                        }
                    },
                    {
                        field : "pay_type_",
                        title : "付款期",
                        align : "center",
                        valign : "middle",
                        sortable : false
                    },
                    {
                        field : "flow_type_",
                        title : "运输方式",
                        align : "center",
                        valign : "middle",
                        sortable : false
                    },

                    {
                        field : "contractStatus",
                        title : "协议状态",
                        align : "center",
                        valign : "middle",
                        sortable : false,
                        formatter : function(value,row,index){
                            return changeStatusToName(value);
                        }
                    }
                ]


			});
		};
        //得到查询的参数
        oTableInit.queryParams = function(params) {
            var temp = {
                pageType : "submit",
                pageNo : params.offset,
                pageSize : params.limit,
                name : $("#name").val(),
                mmbId : $("#mmbId").val(),
                contractType : $("#contractType option:selected").val()
            };
            return temp;
        };
        return oTableInit;
	};

    function changeStatusToName(status){
        var name = "";
        if(status == 1) {
            name = "待确认";
        }else if(status == 2){
            name = "待确认";
        }else if(status == 4){
            name = "已拒绝";
        }else if(status == 7){
            name = "已终止";
        }
        return name;
    }


	//查询
	function querySubmitContract(){

        var pageSize = $("#tb_submitContract").bootstrapTable("getOptions").pageSize;
        
		$.ajax({
			url : "${ctx}/contract/queryContractByPageType.do?pageNo=0&pageSize="+pageSize,
			type : "post",
			dataType : "json",
			data: {
				pageType : "submit",
                mmbId : $("#mmbId").val(),
                name : $("#name").val(),
                contractType : $("#contractType option:selected").val()
			},
            cache : false,
			error : function(){
				alert("系统异常！");
			},
            success : function(data){
				$("#tb_submitContract").bootstrapTable("load",data);
			}

		});

	}

    //改变协议类型
    function changeContract(){

        //根据协议类型和当前会员 动态拼接关系会员列表
        $.ajax({
            url : "${ctx}/contract/queryRelaMmbList.do",
            type : "post",
            dataType : "json",
            cache : false,
            async :false,
            data : {
                mmbId : $("#mmbId").val(),
                contractType : $("#contractType option:selected").val()
            },
            error : function(){
                alert("系统异常！");
            },
            success : function(data){
                $("#relaMmbId").empty();
                if(data!=null&&data.length>0){
                    //清空 关系会员下拉框
                    var context = '';
                    for(var i = 0 ;i < data.length ; i++){
                        context += '<option value="'+data[i].memberId+'">'+data[i].fname+'</option>';
                    }
                    $("#relaMmbId").append(context);
                }
                
                querySubmitContract();
            }

        });

       
    }

	// 添加合作协议
	function addContract(){

        var mmbId = $("#mmbId").val();
        var relaMmbId = $("#relaMmbId").val();
        var contractType = $("#contractType option:selected").val();

        if(relaMmbId==null || $.trim(relaMmbId)==""){
            alert("关系会员不能为空!");
            return;
        }

        if(contractType==null || $.trim(contractType)==""){
            alert("协议类型不能为空!");
            return;
        }

        window.location.href="${ctx}/contract/toAddContractPage.do?mmbId="+mmbId+"&relaMmbId="+relaMmbId+"&contractType="+contractType;

	}

    //显示协议详情模态框
    function openContractDetail(id){

        var contractType = $("#contractType").val();
        var url = '${ctx}/contract/toContractDetailPage.do';

        new contractDetail("contractDetail",id,contractType,url);
    }

</script>
</body>

</html>