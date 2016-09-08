<#assign sec=JspTaglibs["/WEB-INF/security.tld"] />   <#-- 引入security.tld标签-->
<#assign ctx = request.contextPath/>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="save" content="history">
    <title>创建订单</title>


    <link href="${ctx}/mall/css/bootstrap.min.css" rel="stylesheet" type="text/css">
    <link href="${ctx}/mall/css/theme.css" rel="stylesheet" type="text/css">
    <link href="${ctx}/mall/css/pulic.css" rel="stylesheet" type="text/css">
    <link href="${ctx}/mall/css/SimpleTree.css" rel="stylesheet" type="text/css">


    <script src="${ctx}/mall/js/jquery.js"></script>
    <script src="${ctx}/mall/js/common/common.js"></script>
    <script src="${ctx}/mall/js/extendPagination.js" type="text/javascript"></script>
    <!-- 创建订单导入开始 -->
    <link href="${ctx}/mall/css/bootstrap-table.css" rel="stylesheet">
    <link href="${ctx}/mall/css/bootstrap-datetimepicker.css" rel="stylesheet">
    <script src="${ctx}/mall/js/bootstrap.min.js"></script>
    <script src="${ctx}/mall/js/bootstrap-table.js"></script>
    <script src="${ctx}/mall/js/bootstrap-table-zh-CN.js"></script>

    <script src="${ctx}/mall/js/SimpleTree.js" type="text/javascript"></script>
    <script src="${ctx}/mall/js/bootstrap-treeview.js"></script>
    <script src="${ctx}/mall/js/moment-with-locales.js"></script>
    <script src="${ctx}/mall/js/bootstrap-datetimepicker.js"></script>
    <script src="${ctx}/mall/js/serializeJson.js"></script>
    <script src="${ctx}/mall/js/createOrder.js"></script>

    <script src="${ctx}/common/jqueryValidation/js/jquery.validationEngine-zh_CN.js"></script>
    <script src="${ctx}/common/jqueryValidation/js/jquery.validationEngine.min.js"></script>
    <link rel="stylesheet" href="${ctx}/common/jqueryValidation/css/validationEngine.jquery.css"/>


    <script type="text/javascript">
        $(function () {

            var orderInitData;
            $(".st_tree").SimpleTree({
                click: function (a) {
                    if (!$(a).attr("hasChild"))
                        alert($(a).attr("ref"));
                }
            });
            //用户品类树
            $.ajax({
                url: '${ctx}/GoodController/getUserCategoryByCtrId.do',// 跳转到 action
                type: 'POST',
                cache: false,
                data: {
                    sellMmbId: $("#secondMmbId").val(),
                    ctrId: $("#mtCtrId").val()
                },
                dataType: 'json',
                success: function (data) {
                    if (data != "" && data.length > 0) {
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
                        //点击事件
                        $('#tree').on('nodeSelected', function (event, data) {
                            var goodsflag = true;
                            if (data.nodes == null || data.nodes == "") {
                                //赋值
                                $('#goodsTable').children("tbody").find("tr:not(first)").each(function (i, element) {
                                    if ($(element).children().find("[name=goods]").val() == data.id) {
                                        alert("已存在的商品，请勿重复提交！");
                                        goodsflag = false;
                                    }
                                })
                                if (goodsflag == true) {
                                    var row2 = document.getElementById("goodsTable").insertRow(goodsTable.rows.length);
                                    row2.insertCell(0).innerHTML = '<td><input type="text" hidden = "hidden "name ="goods"  value=' + data.id + ' />' + data.text + '</td>';
                                    row2.insertCell(1).innerHTML = '<td><a href="#" onclick="deleteCurrentRow(this)">删除</a></td>';
                                }
                            }
                        })
                    }
                },
                error: function () {
                    alert("异常！");
                }
            });

            $("#workerTime").val(new Date().toLocaleString());
        });

        function deleteCurrentRow(obj) {
            var tr = obj.parentNode.parentNode;
            var rowIndex = tr.rowIndex;
            document.getElementById("goodsTable").deleteRow(rowIndex);
        }


    </script>

</head>

<body>
<div class="panel panel-default"
     style="margin-top:10px; box-shadow:3px 3px 8px rgba(0,0,0,0.1); margin-right:1%; height:auto;">
    <!---------------------------------------con top  start-------------------------------------------------------------->
    <div class="con_top">
        <p>创建订单

            <!-- 采购方ID-->
            <input type="hidden" id="firstMmbId" value="${mtCtr.firstMmbId!}" name="firstMmbId"/>
            <!--销售方ID-->
            <input type="hidden" id="secondMmbId" value="${mtCtr.secondMmbId!}" name="secondMmbId"/>

            <input type="hidden" id="type" value="${type!}" name="type"/>

            <input type="hidden" id="mtCtrId" value="${mtCtr.id!}" name="mtCtrId"/>
        </p>
    </div>
    <!---------------------------------------con top  over--------------------------------------------------------------->
    <div class="A_b_3_in_title" style=" height:30px; background-color:#418bca;  padding-left:50px;">
        <p>业务类型：<#if (type!'')=='1'>采购<#elseif (type!'')=='2'>销售</#if> </p>

        <p>采购方：${mmb.mmbFname!}</p>

        <p>供货方：${mmb1.mmbFname!}</p>

    </div>
    <div class="clear"></div>
    <div style="padding-left:20px; width:60%; float:left; ">
        <form class="form-horizontal" role="form" id="updateContractForm">

            <div class="container-fluid" style="margin-top:15px;">
                <div class="row-fluid">
                    <div class="col-sm-12 ">
                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">操作人:</h5>

                                </div>

                                <input type="text" class="form-control" value="${workerName!}" readonly="readonly"
                                       id="firstname"/>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">操作时间:</h5>

                                </div>
                                <input type="text" class="form-control" id="workerTime" readonly="readonly"/>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">标题:</h5>

                                </div>
                                <input type="text" class="form-control validate[required,maxSize[100]]"
                                       readonly="readonly"
                                       id="contractTitle" value="${mtCtr.contractTitle!}"/>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">有效时间:</h5>

                                </div>
                                <input type="text" class="form-control validate[required]" readonly="readonly"
                                       value="${userTime!}"
                                       id="userTime" style="behavior:url(#default#savehistory)"/>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">结款规则:</h5>

                                </div>

                                <select class="form-control validate[required]" id="payType" name="payType"
                                        disabled="disabled">
                                    <option value="0" <#if (mtCtr.payType!'')==0>selected="selected"</#if>>每月</option>
                                    <option value="1" <#if (mtCtr.payType!'')==1>selected="selected"</#if>>每季</option>
                                    <option value="2" <#if (mtCtr.payType!'')==2>selected="selected"</#if>>6个月</option>
                                    <option value="3" <#if (mtCtr.payType!'')==3>selected="selected"</#if>>每年</option>
                                    <option value="4" <#if (mtCtr.payType!'')==4>selected="selected"</#if>>其他</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">发货规则:</h5>
                                </div>
                                <select class="form-control validate[required]" id="flowType" name="flowType"
                                        disabled="disabled">
                                    <option value="0" <#if (mtCtr.flowType!'')==0>selected="selected"</#if>>自取</option>
                                    <option value="1" <#if (mtCtr.flowType!'')==1>selected="selected"</#if>>免费配送
                                    </option>
                                    <option value="2" <#if (mtCtr.flowType!'')==2>selected="selected"</#if>>有偿配送（1%）
                                    </option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">运输方式:</h5>
                                </div>
                                <select class="form-control validate[required]" id="sendgoodsType" name="sendgoodsType"
                                        disabled="disabled">
                                    <option value="0" <#if (mtCtr.sendgoodsType!'')==0>selected="selected"</#if>>行运
                                    </option>
                                    <option value="1" <#if (mtCtr.sendgoodsType!'')==1>selected="selected"</#if>>空运
                                    </option>
                                </select>
                            </div>
                        </div>

                    <#if (type!'')== "1">
                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">付款账号:</h5>
                                </div>
                                <select class="form-control validate[required]" id="payerCode" disabled="disabled">
                                    <#if bankList ??>
                                        <#list bankList as bk>
                                            <option value="${bk.accountno}"
                                                    <#if (mtCtr.payerCode!'')==bk.accountno>selected="selected"</#if>>${bk.bankname}</option>
                                        </#list>
                                    </#if>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">收货地址:</h5>
                                </div>
                                <select class="form-control validate[required]" id="getgoodsAddress"
                                        disabled="disabled">
                                    <#if addressList ??>
                                        <#list addressList as hc>
                                            <option value="${hc.id}"
                                                    <#if (mtCtr.getgoodsAddress!'')==hc.address>selected="selected"</#if>>${hc.address}</option>
                                        </#list>
                                    </#if>
                                </select>
                            </div>
                        </div>


                    <#elseif (type!"")== "2">


                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">收款账号:</h5>
                                </div>
                                <select class="form-control validate[required]" id="getmoneyCode" disabled="disabled">
                                    <#if bankList ??>
                                        <#list bankList as bk>
                                            <option value="${bk.accountno}"
                                                    <#if mtCtr.getmoneyCode==bk.accountno>selected="selected"</#if>>${bk.bankname}</option>
                                        </#list>
                                    </#if>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">发货地址:</h5>
                                </div>
                                <select class="form-control validate[required]" id="sendgoodsAddress"
                                        disabled="disabled">
                                    <#if addressList ??>
                                        <#list addressList as hc>
                                            <option value="${hc.id}" <#if mtCtr.sendgoodsAddress==hc.address>
                                                    selected="selected" </#if>>${hc.address}</option>
                                        </#list>
                                    </#if>
                                </select>
                            </div>
                        </div>
                    </#if>


                        <div class="col-md-12">
                            <div class="input-group">
                                <div class="input-group-btn">
                                    <h5 class="h5-margin">备注:</h5>
                                </div>
                                <textarea class="form-control" rows="3" id="beizhu"
                                          readonly="readonly">${mtCtr.beizhu!}</textarea>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
        <div class="clear"></div>
    </div>
    <div class="A_b_3_in_right" style="width:40%;float:left;">

        <!--ztree start-->
        <div style="width:30%; height:450px; float:left; margin-right:6%;margin-top: 23px;">
            <p style="font-size: 16px;">协议商品品类列表：</p>

            <div id="tree"></div>
        </div>
        <!--ztree over-->
        <div id="goodsDvi" style="float:left;">
            <form id="goodsForm">
                <table id="goodsTable" style="behavior:url(#default#savehistory)">
                    <tbody>
                    <tr>
                        <td name="goods" id="0">已选商品列表:</td>
                        &nbsp;&nbsp;</tr>

                    </tbody>
                </table>
            </form>
        </div>
    </div>
    <div class="clear"></div>
    <div style="margin-left:40%; margin-bottom:22px;">
        <button type="button" class="btn btn-primary" style=" margin-right:20px; width:100px;"
                onclick="showCreateOrder()">下订单
        </button>
        <a href="javaScript:history.go(-1);">
            <button type="button" class="btn btn-primary" style=" margin-right:20px; width:100px;">返回上一级</button>
        </a>
    </div>

    <!--    订单信息表 -->
    <div class="modal fade" id="changeChar" role="dialog" aria-labelledby="gridSystemModalLabel"></div>

</div>

<script type="text/javascript">
    /*----------------------------------------------------创建订单js开始----------------------------------------------------------*/
    var createOrder;

    $(function () {
        createOrder = new createOrder("changeChar", '${mmbId!}', '${ctx}/', "");
    });

    var orderData = null;
    //处理页面业务逻辑，页面自己写
    function showCreateOrder() {

        //商品不能为空
        var goodsNums = $("#goodsForm input[name='goods']").length;
        if (goodsNums == null || goodsNums == 0) {
            alert("请选择商品!");
            return;
        }

        var dataaa = null;

        $.ajax({
            url: '${ctx}/contract/getGoodsData.do',
            dataType: "JSON",
            type: "POST",
            data: $("#goodsForm").serialize() + "&mtCtrId=" + $("#mtCtrId").val() + "&contractType=" + $("#type").val(),
            success: function (data) {

                //订单详细数据格式参考
                dataaa = {
                    "buyersAddressList": data.getGoodsAddressList,
                    "sellersAddressList": data.sendGoodsAddressList,
                    "buyersAccountList": data.payMoneyBankList,
                    "sellersAccountList": data.getMoneyBankList,
                    "total": data.total,
                    "data": data.list,
                    "ordertitle": {
                        "buyersId": data.buyMmb_.id,
                        "buyersName": data.buyMmb_.mmbFname,
                        "sellersId": data.sellMmb_.id,
                        "sellersName": data.sellMmb_.mmbFname,
                        "totalMoney": 0,
                        "payBank": data.payMoneyBank.bankname,
                        "payAccount": data.payMoneyBank.accountno,
                        "getBank": data.getMoneyBank.bankname,
                        "getAccount": data.getMoneyBank.accountno,
                        "sellersAddressId": data.sellersAddressId,
                        "buyersAddressId": data.buyersAddressId
                    },
                };
                console.info(dataaa);
                createOrder.initOrder(dataaa);
                $("#changeChar").modal("show");
            }
        })
    }
    /*----------------------------------------------------创建订单js结束----------------------------------------------------------*/
</script>

</body>


</html>
