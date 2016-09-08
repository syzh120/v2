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
	<script src="${ctx}/mall/js/jquery-1.11.1.min.js" type="text/javascript"></script>
	<script src="${ctx}/mall/js/bootstrap.min.js" type="text/javascript"></script>
	<script src="${ctx}/mall/js/SimpleTree.js" type="text/javascript"></script>
	<script src="${ctx}/mall/js/bootstrap-treeview.js"></script>
	<link rel="stylesheet" type="text/css" media="all" href="${ctx}/factoring/css/daterangepicker-bs3.css" />
	<script type="text/javascript" src="${ctx}/factoring/js/moment.js"></script>
	<script type="text/javascript" src="${ctx}/factoring/js/daterangepicker.js"></script>
	<script type="text/javascript" src="${ctx}/factoring/js/DatePicker/WdatePicker.js"></script>
	<script src="${ctx}/mall/js/bootstrap-table.js"></script>
	<script src="${ctx}/mall/js/bootstrap-table-zh-CN.js"></script>

    <script src="${ctx}/mall/js/serializeJson.js"></script>
    <!-- 协议详情 js-->
    <script src="${ctx}/mall/js/contractDetail.js"></script>



    <script type="text/javascript" src="${ctx}/common/jqueryValidation/js/jquery.validationEngine-zh_CN.js"></script>
	<script type="text/javascript" src="${ctx}/common/jqueryValidation/js/jquery.validationEngine.min.js"></script>
	<link rel="stylesheet" type="text/css" href="${ctx}/common/jqueryValidation/css/validationEngine.jquery.css" />

    <script src="${ctx}/mall/js/common/common.js"></script>

</head>

<body>
<div class="container-fluid ">
	<div class="row-fluid">
		<div class="col-sm-12 ">
			<div class="panel panel-default article-bj">
				<div class="panel-heading box-shodm">待审批合作协议</div>
				<form id="queryPendingOrderForm">
					<div class="row wrapper form-margin" style="margin:15px;">

						<div class="col-md-4">
							<div class="input-group">
								<div class="input-group-btn">
									<h5 class="h5-margin">协议类型:</h5>
								</div>
								<select id="contractType" name="contractType" tabindex="-1" class="form-control"  onchange="queryPendingContract()">
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

						<input type="hidden" name ="mmbId" id="mmbId" value="${mmbId!}">

						<input type="button" class="btn btn-info btn-s-md btn-default  cx-btn-margin" value="查询" onclick="queryPendingContract();" id="queryPendingContractButton"/>
					</div>
				</form>
				<div class="table-responsive panel-table-body ">
					<table class="table table-striped table-hover " id="tb_pendingContract"></table>
				</div>

			</div>
		</div>
	</div>

    <!--同意 start------>
    <div class="modal fade" id="agreeModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
         aria-hidden="true" data-backdrop="static">
        <div class="modal-dialog" style="">
            <div class="modal-content">

                <div class="modal-header">
                    <input type="hidden" name="type" id ="type" />
                    <input type="hidden" name="ctrId" id="ctrId" />

                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>

                </div>
                <form class="form-horizontal" role="form" style="padding:5% 0 0 4%;" id="agreeForm">

                </form>
                <div class="form-group">
                    <input style="margin:5% 0 5% 30%; padding:6px 24px;" class="btn btn-primary"  data-dismiss="modal" type="button" value="确认" onclick="agreeContract();">
                    <input style="margin:5% 0 5% 10%; padding:6px 24px;" class="btn btn-primary"    data-dismiss="modal" type="button" value="取消">
                </div>
            </div>
        </div>
    </div>
    <!------ 同意 over------>
</div>

<!-- 协议详情modal-->
<div class="modal fade" id="contractDetail" role="dialog" aria-labelledby="gridSystemModalLabel" data-backdrop="static"></div>


<script type="text/javascript">

	$(function(){
		var oTable = new tableInit();
        oTable.Init();


	});


	var tableInit = function(){
		var oTableInit = new Object();
		//初始化table
		oTableInit.Init = function(){
			$("#tb_pendingContract").bootstrapTable({
				url : "${ctx}/contract/queryContractByPageType.do",
				method : "POST",
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
                        title: "操作",
                        align: "center",
                        valign: "middle",
                        sortable: false,
                        formatter: function (value, row, index) {
                            return '<a href="#" data-toggle="modal" onclick="showEditContract(\'' + row.id + '\');">编辑</a> ' +
									'<a href="#" data-toggle="modal" onclick="showAgreeModal(\'' + row.id + '\',\''+row.contractStatus+'\')">同意</a> '+
                            '<a href="#" data-toggle="modal" onclick="operateContract(\'refuse\',\'' + row.id + '\',\''+row.contractStatus+'\');">拒绝</a>';
                        }
                    }
                ]


			});
		};

        //得到查询的参数
        oTableInit.queryParams = function(params) {
            var temp = {
                pageType : "pending",
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

	//查询
	function queryPendingContract(){
        var pageSize =  $("#tb_pendingContract").bootstrapTable("getOptions").pageSize;
		$.ajax({
			url : "${ctx}/contract/queryContractByPageType.do?pageNo=0&pageSize="+pageSize,
			type : "post",
			dataType : "json",
			data: {
                mmbId : $("#mmbId").val(),
                pageType : "pending",
                name : $("#name").val(),
                contractType : $("#contractType option:selected").val()
			},
            cache : false,
			error : function(){
				alert("系统异常！");
			},
            success : function(data){
				$("#tb_pendingContract").bootstrapTable("load",data);
			}

		});

	}

	//跳转到编辑合作协议页面
	function showEditContract(id){
        //检查自己是否配置了银行账号和收发货地址 若没配置提示
        $.ajax({
            url : "${ctx}/contract/checkBankAndWarehouseOfSelf.do",
            type : "post",
            dataType : "json",
            cache : false,
            error : function(){
                alert("系统异常！");
                $("#tb_pendingContract").bootstrapTable("refresh");

            },
            success : function(data){
                if(data.checkStatus == "success"){
                    var contractType = $("#contractType option:selected").val();
                    window.location.href = "${ctx}/contract/toUpdateContractPage.do?id="+id+"&contractType="+contractType;
                }else{
                    if(data.msg != null && $.trim(data.msg) != ''){
                        alert(data.msg);
                    }
                }
            }

        })


	}

	// 拒绝 合作协议
	function operateContract(operateType,id,currentStatus){

		$.ajax({
			url : "${ctx}/contract/operateContract.do",
			type : "post",
			dataType : "json",
			cache : false,
			data : {
				"contractType" : $("#contractType option:selected").val(),
				"operateType" : operateType,
				"id" : id,
				"currentStatus" :currentStatus
			},
			error : function(){
				alert("系统异常！");
                $("#tb_pendingContract").bootstrapTable("refresh");

			},
			success : function(data){
				if(data.msg!=null){
					alert(data.msg);
                    $("#tb_pendingContract").bootstrapTable("refresh");
				}
			}

        })
	}

	//显示同意模态框
	function showAgreeModal(id,currentStatus){

        $.ajax({
            url : "${ctx}/contract/showAgreeModal.do",
            type : "post",
            dataType : "json",
            cache : false,
            data : {
                "contractType" : $("#contractType option:selected").val(),
                "id" : id,
                "currentStatus" :currentStatus
            },
            error : function(){
                alert("系统异常！");
                $("#tb_pendingContract").bootstrapTable("refresh");

            },
            success : function(data){


				if(data != null ){

					$("#agreeForm").html("");

					$("#ctrId").val(data.ctrId);
					$("#type").val(data.type);
					$("#currentStatus").val(data.currentStatus);

					var addressList = data.addressList;
					var bankList  = data.bankList;

                    var addressName = data.addressName;
                    var bankAccountNo = data.bankAccountNo;

                    var addressFlag = false;
                    var accountFlag = false;

                    var checkMsg = null;

                    if(addressList.length != 0 && bankList.length != 0){
                        if(data.type != null && data.type == 1 && bankList.length > 0 && addressList.length > 0){
                            var content = '';
                            content +=	'    <div class="form-group">                                                          '
                            content +=  '        <label for="firstname" class="col-sm-2 control-label">付款账号：</label>      '
                            content +=  '        <div class="form-group col-lg-8  input-lg">                                   '
                            content +=  '            <select class="form-control validate[required]"  name="bankAccount" id="bankAccount">           '
                            for (var i = 0;i <bankList.length;i++ ){
                                if(bankAccountNo == bankList[i].accountno){
                                    content +=  '<option value="'+bankList[i].accountno+'" selected="selected">'+bankList[i].bankname+'</option>';
                                    accountFlag = true;
                                }
                                content +=  '<option value="'+bankList[i].accountno+'" >'+bankList[i].bankname+'</option>'
                            }
                            content +=  '            </select>                                                                 '
                            content +=  '        </div>                                                                        '
                            content +=  '    </div>                                                                            '
                            content +=  '    <div class="form-group">                                                          '
                            content +=  '        <label for="firstname" class="col-sm-2 control-label">收货地址：</label>      '
                            content +=  '        <div class="form-group col-lg-8  input-lg">                                   '
                            content +=  '            <select class="form-control validate[required]"  name="address" id="address">        '
                            for (var j = 0;j <addressList.length;j++ ){
                                if( addressName == addressList[j].address){
                                    content +=  '<option value="'+addressList[j].id+'" selected="selected>'+addressList[j].address+'</option>';
                                    addressFlag = true;
                                }
                                content +=  '<option value="'+addressList[j].id+'">'+addressList[j].address+'</option>';
                            }
                            content +=  '            </select>                                                                 '
                            content +=  '        </div>                                                                        '
                            content +=  '    </div> '
                        }else if(data.type != null && data.type == 2 && bankList.length > 0 && addressList.length > 0){
                            var content = '';
                            content +=	'    <div class="form-group">                                                          '
                            content +=  '        <label for="firstname" class="col-sm-2 control-label">收款账号：</label>      '
                            content +=  '        <div class="form-group col-lg-8  input-lg">                                   '
                            content +=  '            <select class="form-control validate[required]"   name="bankAccount" id="bankAccount">           '
                            for (var i = 0;i <bankList.length;i++ ){

                                if(bankAccountNo == bankList[i].accountno){
                                    content +=  '<option value="'+bankList[i].accountno+'" selected="selected">'+bankList[i].bankname+'</option>';
                                    accountFlag = true;
                                }
                                content +=  '<option value="'+bankList[i].accountno+'">'+bankList[i].bankname+'</option>'
                            }
                            content +=  '            </select>                                                                 '
                            content +=  '        </div>                                                                        '
                            content +=  '    </div>                                                                            '
                            content +=  '    <div class="form-group">                                                          '
                            content +=  '        <label for="firstname" class="col-sm-2 control-label">发货地址：</label>      '
                            content +=  '        <div class="form-group col-lg-8  input-lg">                                   '
                            content +=  '            <select class="form-control validate[required]"  name="address" id="address">        '
                            for (var j = 0;j <addressList.length;j++ ){

                                if( addressName == addressList[j].address){
                                    content +=  '<option value="'+addressList[j].id+'" selected="selected>'+addressList[j].address+'</option>';
                                    addressFlag = true;
                                }
                                content +=  '<option value="'+addressList[j].id+'">'+addressList[j].address+'</option>'
                            }
                            content +=  '            </select>                                                                 '
                            content +=  '        </div>                                                                        '
                            content +=  '    </div> '
                        }


                        $("#agreeForm").append(content);

                        $("#ctrId").val(id);

                        //如果当前协议已经有 收付款账号和地址 则同意模态框的下拉框不可选
                        if(accountFlag){
                            $("select[name='bankAccount']").prop("disabled","disabled");
                        }
                        if(addressFlag){
                            $("select[name='address']").prop("disabled","disabled");
                        }

                        $("#agreeModal").modal("show");
                    }
                    if(addressList.length == 0){
                        checkMsg = "请您创建收发货地址！";
                    }
                    if(bankList.length == 0){
                        checkMsg = "请您创建银行账号！";
                    }
                    if (addressList.length == 0 && bankList.length == 0){
                        checkMsg = "请您创建收发货地址和银行账号！";
                    }
                    if(checkMsg != null && checkMsg != ""){
                        alert(checkMsg);
                    }


				}


            }

        })
	}

	//同意
	function agreeContract() {

        $.ajax({
            url: "${ctx}/contract/agreeContract.do",
            type: "post",
            dataType: "json",
            cache: false,
            data: {
                "contractType": $("#contractType option:selected").val(),
                "id": $("#ctrId").val(),
                "address": $("#agreeForm select[name='address'] option:selected ").text(),
                "bankAccountCode": $("#agreeForm select[name='bankAccount'] option:selected ").val(),
                "bankAccountName": $("#agreeForm select[name='bankAccount'] option:selected ").text(),
            },
            error: function () {
                alert("系统异常！");

            },
            success: function (data) {
                if (data.msg != null) {
                    alert(data.msg);
                }
            }
        });
        $("#agreeModal").modal("hide");
        $("#tb_pendingContract").bootstrapTable("refresh");
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