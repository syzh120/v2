<%@ page language="java" import="java.util.*"
	contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
   <link rel="stylesheet" href="${pageContext.request.contextPath}/mall/ccss/bootstrap.min.css">
   <link href="${pageContext.request.contextPath}/mall/ccss/theme.css" rel="stylesheet">
   <script src="${pageContext.request.contextPath}/mall/cjs/jquery.js"></script>
   <script src="${pageContext.request.contextPath}/mall/cjs/jquery.min.js"></script>
   <script src="${pageContext.request.contextPath}/mall/cjs/bootstrap.min.js"></script>
   <!--文件树插件-->
   <link rel="stylesheet" href="${pageContext.request.contextPath}/mall/css/demo.css" type="text/css">
   <link rel="stylesheet" href="${pageContext.request.contextPath}/mall/css/zTreeStyle/zTreeStyle.css" type="text/css">
   <script type="text/javascript" src="${pageContext.request.contextPath}/mall/js/jquery.ztree.core-3.5.js"></script>  
   <script type="text/javascript" src="${pageContext.request.contextPath}/mall/js/jquery.ztree.excheck-3.5.js"></script>  
   <script type="text/javascript" src="${pageContext.request.contextPath}/mall/js/jquery.ztree.exedit-3.5.js"></script> 
   
   <script language="JavaScript">  
	var setting = {
				check: {
					enable: true
				},
				data: {
					simpleData: {
						enable: true
					}
				}
			};
	
			var zNodes =[
				{ id:1, pId:0, name:"随意勾选 1", open:true},
				{ id:11, pId:1, name:"随意勾选 1-1", open:true},
				{ id:111, pId:11, name:"随意勾选 1-1-1"},
				{ id:112, pId:11, name:"随意勾选 1-1-2"},
				{ id:12, pId:1, name:"随意勾选 1-2", open:true},
				{ id:121, pId:12, name:"随意勾选 1-2-1"},
				{ id:122, pId:12, name:"随意勾选 1-2-2"},
				{ id:2, pId:0, name:"随意勾选 2", checked:true, open:true},
				{ id:21, pId:2, name:"随意勾选 2-1"},
				{ id:22, pId:2, name:"随意勾选 2-2", open:true},
				{ id:221, pId:22, name:"随意勾选 2-2-1", checked:true},
				{ id:222, pId:22, name:"随意勾选 2-2-2"},
				{ id:23, pId:2, name:"随意勾选 2-3"}
			];
			
			
			$(document).ready(function(){
				$.fn.zTree.init($("#tree"), setting, zNodes);
			}); 
	</script>
<title>资源库管理</title>
</head>

<body>
<div class="container-fluid"  >
    <div class="row-fluid" >
        <!-- col-sm-12 -->
        <div class="col-sm-12 ">
        	<div class="panel panel-default article-bj">
                <div class="panel-heading box-shodm">
                资源库管理
                </div>
        			<div class="row wrapper form-margin">
       					 <div class="col-md-4">
        					<div class="input-group">
       							 <div class="input-group-btn">
       							 	<h5 class="h5-margin">资源库名称:</h5>
       							 <!--   <button class="btn" type="button"></button> -->
       							 </div>
       							 <input type="text" placeholder="" class="form-control" name="input1-group3" id="input1-group3">
        					</div>
        				</div>
                        <div class="col-md-4">
        					<div class="input-group">
       							 <div class="input-group-btn">
       							 	<h5 class="h5-margin">资源库类型:</h5>
       							 <!--   <button class="btn" type="button"></button> -->
       							 </div>
       							 <select name="selecter_basic" tabindex="-1"class="form-control">
                                    <option value="1">个人</option>
                                    <option value="2">共享</option>
                                 </select>
        					</div>
        				</div>
       					<a class="btn btn-info" href="#">查询</a>
       				 </div>
                    <div class="table-responsive panel-table-body ">
                        <table class="table table-striped table-hover ">
                            <thead>
                                <tr>
                                    <th>序号</th>
                                    <th>资源库名称</th>
                                    <th>资源库类别</th>
                                    <th>说明</th>
                                    <th>操作</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>1</td>
                                    <td><a data-toggle="modal" data-target="#name">共享库</a></td>
                                    <td>共享</td>
                                    <td>1</td>
                                    <td><a href="#">删除</a></td>
                                </tr>
                            </tbody>
                        </table>
                    </div> 
                    <footer class="panel-footer text-right bg-light lter">
                    <button type="button" class="btn btn-success "  data-toggle="modal" data-target="#add">新增</button>
                    <button type="button" class="btn btn-warning " data-dismiss="modal">返回</button>
                    </footer>
        		</div>
       		 </div>
        </div>
    </div> 
</div>
<!--新增弹出层-->
<div class="modal fade" id="add" role="dialog" aria-labelledby="gridSystemModalLabel">
	<div class="modal-dialog s-tanchu-box" role="document"> 
        <div class="container-fluid" >
            <div class="row-fluid">
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading box-shodm">
                        新增资源库
                        </div>
                            <div class="row wrapper form-margin">
                                 <div class="col-md-12">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">资源库名称:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" placeholder="" class="form-control" name="input1-group3" id="input1-group3">
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">资源库类别:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <select name="selecter_basic" tabindex="-1"class="form-control">
                                            <option value="1">个人</option>
                                            <option value="2">共享</option>
                                         </select>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">资源库说明:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <textarea style="width:100%"></textarea>
                                    </div>
                                </div>
                            </div>
                            <footer class="panel-footer text-right bg-light lter">
                            <button type="button" class="btn btn-success " >保存</button>
                    		<button type="button" class="btn btn-warning " data-dismiss="modal">返回</button>
                            </footer>
                        </div>
                     </div>        	
                </div>
            </div> 
        </div>
	</div>
</div>
<!--新增弹出层结束-->
<!--资源库目录-->
<div class="modal fade" id="name" role="dialog" aria-labelledby="gridSystemModalLabel">
	<div class="modal-dialog b-tanchu-box" role="document"> 
        <div class="container-fluid"  >
            <div class="row-fluid" >
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading box-shodm">
                        资源库信息
                        </div>
                        
                        <div class="panel-body">
                           <!---------------------------------------nav start--------------------------------------------------------------->
                            <div id="nav" style=" float:left;width:14%">
                                <ul id="tree" class="ztree"></ul>  
                                <div id="opreate" style="margin-top:13px; margin-left:8px;">
                                <a class="btn btn-success btn-sm" href="#" data-toggle="modal" data-target="#addCatalogue">新增</a>
                                <a class="btn btn-info btn-sm" href="#" data-toggle="modal" data-target="#editCatalogue">修改</a>
                                <a class="btn btn-danger btn-sm" href="#" data-toggle="modal" data-target="#deleteCatalogue">删除</a>
                                <a class="btn btn-warning btn-sm" href="#">资源库管理</a>
                                </div>
                            </div>
                            <!---------------------------------------nav end--------------------------------------------------------------->
                            <!--商品信息-->
                            <div class="container-fluid" style="float:left; width:85%">
                                <div class="row-fluid">
                                    <div class="col-sm-12 ">
                                        <div class="panel panel-default ">
                                            <div class="panel-heading">
                                                商品信息
                                            </div>
                                            <div class="row wrapper form-margin">
                                                <div class="col-md-4">
                                                    <div class="input-group">
                                                         <div class="input-group-btn">
                                                            <h5 class="h5-margin">资源名称:</h5>
                                                         <!--   <button class="btn" type="button"></button> -->
                                                         </div>
                                                         <input type="text" placeholder="" class="form-control" name="input1-group3" id="input1-group3">
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="input-group">
                                                         <div class="input-group-btn">
                                                            <h5 class="h5-margin">资源类型:</h5>
                                                         <!--   <button class="btn" type="button"></button> -->
                                                         </div>
                                                         <select name="selecter_basic" tabindex="-1"class="form-control">
                                                            <option value="1">图片</option>
                                                            <option value="2">文字</option>
                                                         </select>
                                                    </div>
                                                </div>
                                                <a class="btn btn-info" href="#" data-toggle="modal" data-target="#upload">上传</a>
                                            </div>
                                            <div class="table-responsive panel-table-body ">
                                                <table class="table table-striped table-hover">
                                                    <thead>
                                                        <tr>
                                                            <th>资源序号</th>
                                                            <th>缩略图</th>
                                                            <th>资源名称</th>
                                                            <th>资源类型</th>
                                                            <th>资源描述</th>
                                                            <th>操作</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <tr>
                                                            <td style="vertical-align:middle">1</td>
                                                            <td><img src="images/contentp.png" style="height:50px; width:50px;"></td>
                                                            <td style="vertical-align:middle">contentp.png</td>
                                                            <td style="vertical-align:middle">图片</td>
                                                            <td style="vertical-align:middle">图片</td>
                                                            <td style="vertical-align:middle">
                                                            <a href="#" data-toggle="modal"; data-target="#edit" >预览</a>
                                                            <a href="#" >删除</a>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="vertical-align:middle">2</td>
                                                            <td><img src="images/contentp.png" style="height:50px; width:50px;"></td>
                                                            <td style="vertical-align:middle">contentp.png</td>
                                                            <td style="vertical-align:middle">图片</td>
                                                            <td style="vertical-align:middle">图片</td>
                                                            <td style="vertical-align:middle">
                                                            <a href="#" data-toggle="modal"; data-target="#edit" >预览</a>
                                                            <a href="#" >删除</a>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td style="vertical-align:middle">3</td>
                                                            <td><img src="images/contentp.png" style="height:50px; width:50px;"></td>
                                                            <td style="vertical-align:middle">contentp.png</td>
                                                            <td style="vertical-align:middle">图片</td>
                                                            <td style="vertical-align:middle">图片</td>
                                                            <td style="vertical-align:middle">
                                                            <a href="#" data-toggle="modal"; data-target="#edit" >预览</a>
                                                            <a href="#" >删除</a>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div> 
                                            <footer class="panel-footer text-right bg-light lter">
                                            <ul class="pagination">
                                              <li><a href="#">&laquo;</a></li>
                                              <li><a href="#">1</a></li>
                                              <li><a href="#">2</a></li>
                                              <li><a href="#">3</a></li>
                                              <li><a href="#">4</a></li>
                                              <li><a href="#">5</a></li>
                                              <li><a href="#">&raquo;</a></li>
                                            </ul>
                                            </footer>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!--商品信息结束-->
                        </div>
                    </div>
                </div>
            </div>
        </div>
	</div>
</div>
<!--资源库目录-->
<!--新增目录弹出层开始-->
<div class="modal fade" id="addCatalogue" role="dialog" aria-labelledby="gridSystemModalLabel">
	<div class="modal-dialog xs-tanchu-box" role="document"> 
        <div class="container-fluid" >
            <div class="row-fluid">
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading ">
                        新增目录
                        </div>
                            <div class="row wrapper form-margin">
                                 <div class="col-md-12">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">图片目录名称:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" placeholder="" class="form-control" name="input1-group3" id="input1-group3">
                                    </div>
                                </div>
                            </div>
                            <footer class="panel-footer text-right bg-light lter">
                            <button type="button" class="btn btn-success btn-sm" >保存</button>
                    		<button type="button" class="btn btn-warning btn-sm" data-dismiss="modal">返回</button>
                            </footer>
                        </div>
                     </div>        	
                </div>
            </div> 
        </div>
	</div>
</div>
<!--新增目录弹出层结束-->
<!--修改目录弹出层开始-->
<div class="modal fade" id="editCatalogue" role="dialog" aria-labelledby="gridSystemModalLabel">
	<div class="modal-dialog xs-tanchu-box" role="document"> 
        <div class="container-fluid" >
            <div class="row-fluid">
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading ">
                        修改目录
                        </div>
                            <div class="row wrapper form-margin">
                                 <div class="col-md-12">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">图片目录名称:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" placeholder="" class="form-control" name="input1-group3" id="input1-group3">
                                    </div>
                                </div>
                            </div>
                            <footer class="panel-footer text-right bg-light lter">
                            <button type="button" class="btn btn-success btn-sm" >修改</button>
                    		<button type="button" class="btn btn-warning btn-sm" data-dismiss="modal">返回</button>
                            </footer>
                        </div>
                     </div>        	
                </div>
            </div> 
        </div>
	</div>
</div>
<!--修改目录弹出层结束-->
<!--删除目录弹出层开始-->
<div class="modal fade" id="deleteCatalogue" role="dialog" aria-labelledby="gridSystemModalLabel">
	<div class="modal-dialog xs-tanchu-box" role="document"> 
        <div class="container-fluid" >
            <div class="row-fluid">
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading ">
                        删除目录
                        </div>
                            <div class="row wrapper form-margin">
                                 <div class="col-md-12">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 >确定要删除该目录吗？</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                    </div>
                                </div>
                            </div>
                            <footer class="panel-footer text-right bg-light lter">
                            <button type="button" class="btn btn-success btn-sm" >确定</button>
                    		<button type="button" class="btn btn-warning btn-sm" data-dismiss="modal">取消</button>
                            </footer>
                        </div>
                     </div>        	
                </div>
            </div> 
        </div>
	</div>
</div>
<!--删除目录弹出层结束-->
<!--上传弹出层开始-->
<div class="modal fade" id="upload" role="dialog" aria-labelledby="gridSystemModalLabel">
	<div class="modal-dialog s-tanchu-box" role="document"> 
        <div class="container-fluid" >
            <div class="row-fluid">
                <!-- col-sm-12 -->
                <div class="col-sm-12 ">
                    <div class="panel panel-default article-bj">
                        <div class="panel-heading box-shodm">
                        资源上传
                        </div>
                            <div class="row wrapper form-margin">
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">描述:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <input type="text" placeholder="" class="form-control" name="input1-group3" id="input1-group3">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="input-group">
                                         <div class="input-group-btn">
                                            <h5 class="h5-margin">资源类型:</h5>
                                         <!--   <button class="btn" type="button"></button> -->
                                         </div>
                                         <select class="form-control">
                                            <option value="1">图片</option>
                                            <option value="2">文字</option>
                                         </select>
                                    </div>
                                </div>
                            </div>
                            <div class="table-responsive panel-table-body ">
                                <table class="table table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th>文件名</th>
                                            <th>大小</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td style="vertical-align:middle">文件1</td>
                                            <td>123K</td>
                                        </tr>
                                        <tr>
                                            <td style="vertical-align:middle">文件2</td>
                                            <td>246K</td>
                                        </tr>
                                        <tr>
                                            <td style="vertical-align:middle">文件3</td>
                                            <td>512K</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            <footer class="panel-footer text-right bg-light lter">
                            <button type="button" class="btn btn-success " >新增文件</button>
                            <button type="button" class="btn btn-info " >开始上传</button>
                            <button type="button" class="btn btn-warning " >重新上传</button>
                            </footer>
                        </div>
                     </div>        	
                </div>
            </div> 
        </div>
	</div>
</div>
<!--上传弹出层结束-->
</body>
</html>
