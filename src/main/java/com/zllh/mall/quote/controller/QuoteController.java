package com.zllh.mall.quote.controller;

import java.io.IOException;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.zllh.base.controller.BaseController;
import com.zllh.common.common.model.model_extend.UserExtendBean;
import com.zllh.common.enums.BillsType;
import com.zllh.mall.common.model.BusAreaTree;
import com.zllh.mall.common.model.MtGroup;
import com.zllh.mall.common.model.MtMember;
import com.zllh.mall.common.model.MtMuser;
import com.zllh.mall.common.model.MtQuote;
import com.zllh.mall.common.model.MtQuoteScope;
import com.zllh.mall.group.service.IGroupService;
import com.zllh.mall.material.service.MaterialService;
import com.zllh.mall.mmbmmanage.service.IMMBService;
import com.zllh.mall.quote.service.AreaTreeService;
import com.zllh.mall.quote.service.QuoteRelationService;
import com.zllh.mall.quote.service.QuoteService;
import com.zllh.utils.base.Utils;
import com.zllh.utils.common.DateUtil;
import com.zllh.utils.common.DictionaryUtil;
import com.zllh.utils.common.Page;
import com.zllh.utils.common.UUIDCreater;
import com.zllh.utils.soleid.SoleIdUtil;



/** 
 * @ClassName: QuoteController 
 * @Description: 报价管理
 * @author zfy
 * 
 */
@Controller
@RequestMapping("/QuoteController")
public class QuoteController extends BaseController {
	@Autowired
	private QuoteService quoteService;
	@Autowired
	private QuoteRelationService quoteRelationService;// 报价范围表
	@Autowired
	private IMMBService mmbService;//会员
	@Autowired
	private AreaTreeService areaTreeService;//地域
	@Autowired
	private IGroupService groupService;//群组
	@Autowired
	private MaterialService malService;//资源
	//跳转页面
	@RequestMapping("/toshowPage")
	public String toshowPage(){
		logger.info("====toshowPage====");
		System.err.println("xczxczxczxc");
		return "mall/quote/quote_show";
	}
	//查询自己的报价（报价管理）
	@RequestMapping("/showQuote")
	@ResponseBody
	public Map<String,Object>showQuote (
			Model model,
			@RequestParam(value = "goodname", required = false, defaultValue = "") String goodname,
			@RequestParam(value = "startTime", required = false, defaultValue = "") String startTime,
			@RequestParam(value = "startEnd", required = false, defaultValue = "") String startEnd,
			@RequestParam(value = "createTime1", required = false, defaultValue = "") String createTime1,
			@RequestParam(value = "createTime2", required = false, defaultValue = "") String createTime2,
			@RequestParam(value = "pageNo", required = false) String pageNo1,
			@RequestParam(value = "pageSize", required = false) Integer pageSize,
			@RequestParam(value = "status", required = false) Integer status,//0受用1禁用2过期
			@RequestParam(value = "type", required = false) Integer type// 报价类型// 0采购// 1销售
	) {
		Long pageNo = StringUtils.isBlank(pageNo1) ? 1 : Long.valueOf(pageNo1);
		pageNo = pageNo<1?1:pageNo;
		pageSize = pageSize==null&&pageSize<1?2:pageSize;
		// 获取查询条件封装到Map
		logger.error("..........................报价查询");
		Map<String, Object> params = new HashMap<String, Object>();
		if (!StringUtils.isBlank(goodname.trim())) {
			params.put("goodname", goodname.trim());
		}
		;
		if (!StringUtils.isBlank(startTime)) {
			params.put("startTime", startTime);
		}
		;
		if (!StringUtils.isBlank(startEnd)) {
			params.put("startEnd",startEnd);
		}
		;
		if (!StringUtils.isBlank(createTime1)) {
			params.put("createTime1", createTime1);
		}
		;
		if (!StringUtils.isBlank(createTime2)) {
			params.put("createTime2", createTime2);
		}
		;
		if (status != null) {
			// 0 在使用 1 禁用 2已过期
			params.put("status", status);
		}
		;
		if (type != null) {
			// 0 销售 1 采购
			params.put("type", type);
		};
		UserExtendBean user = Utils.securityUtil.getUser();
		MtMuser mUser = user.getMuser();
		//登陆人所属的会员Id
		if (!StringUtils.isBlank(mUser.getMmbId())) {
			params.put("mmbIduser", mUser.getMmbId()); 
		};
		long totalCount = quoteService.searchQuoteCount(params);
		System.out.println("*************************============"+totalCount);
		// 当前页数不能超过总页数
		
		long totalPageCount = (totalCount + pageSize - 1)/pageSize;
		if(pageNo>totalPageCount){
			pageNo = totalPageCount;
		}
		params.put("startFirst", pageNo > 0 ? (pageNo - 1) * pageSize : 0);
		params.put("startEnd1", pageSize);
		List<MtQuote> quoteList = quoteService.searchQuote(params);
		Map<String, Object> returnmap = new HashMap<String, Object>();
		returnmap.put("qtCount",totalCount);
		returnmap.put("qtList",quoteList);
		//returnmap.put("prarms",params);
		return returnmap;
	}
	// 创建报价
	@RequestMapping("/createQuote")
	@ResponseBody
	public String createQuote(
			Model model,
			@RequestParam(value = "startTime1", required = false, defaultValue = "") String startTime,
			@RequestParam(value = "startEnd1", required = false, defaultValue = "") String startEnd,
			@RequestParam(value = "goodsId1", required = false, defaultValue = "") String goodsId,// 商品Id
			@RequestParam(value = "explan1", required = false, defaultValue = "") String explan,// 文字说明
			@RequestParam(value = "goodsName1", required = false, defaultValue = "") String goodsName,
			@RequestParam(value = "titlePic1", required = false, defaultValue = "") String titlePic,// 选择的图片
			@RequestParam(value = "imgPath1", required = false, defaultValue = "") String imgPath,
			@RequestParam(value = "unitPrice1", required = false, defaultValue = "") String unitPrice,// 价格单位
			@RequestParam(value = "minPrice1", required = false, defaultValue = "0") double minPrice,// 价格
			@RequestParam(value = "maxPrice1", required = false, defaultValue = "0") double maxPrice,
			@RequestParam(value = "num1", required = false) Double num,// 数量
			@RequestParam(value = "status1", required = false) Integer status,
			@RequestParam(value = "rangType1", required = false) Integer rangType,// 报价类型// 0公共报价// 1指定报价																							
			@RequestParam(value = "account1", required = false, defaultValue = "") String account,// 账户
			@RequestParam(value = "address1", required = false, defaultValue = "") String address,// 地址
			@RequestParam(value = "categoryId1", required = false, defaultValue = "") String categoryId,// 选择商品的品类Id
			@RequestParam(value = "type1", required = false) String type) {
		// 获取登陆人的操作员Id
		// 获取session中登陆的会员，封装到对象
		UserExtendBean user1 = Utils.securityUtil.getUser();
		MtMuser user = user1.getMuser();
		
		MtQuote qt = new MtQuote();
		//调用mmb service  通过mmbID查询出mmb  给地域赋值
		MtMember mmb = mmbService.queryMmbById(user.getMmbId());
		
		//获取会员所属的省级
		BusAreaTree bt = areaTreeService.getChild(mmb.getMmbAreaId());
		if(bt!=null){
			qt.setAreaId(bt.getId());
		}
		System.out.println(qt.getAreaId());
		// 获取前台填写的数据，包含报价类型，商品名称，数量
		// 单价上限，单价下限，有效期开始时间，有效期结束时间 说明，商品Id等字段
		qt.setMmbId(user.getMmbId());// 所属的组织Id（会员Id）
		qt.setUserId(user.getId());// 登录员Id
		//发布人名称
		qt.setMmbName(user.getName());
	    qt.setGoodsId(goodsId);
		qt.setGoodsName(goodsName.trim());
		qt.setRangType(rangType);
		qt.setType(Integer.parseInt(type));
		if (type == DictionaryUtil.GROUP_TYPE_BUY.toString()) {// 采购报价
			qt.setPdAccount(account.trim());
			qt.setReceiceAddress(address.trim());
		}
		if (type == DictionaryUtil.GROUP_TYPE_SELL.toString()) {// 销售报价
			qt.setSellAccount(account.trim());
			qt.setSendAddres(address.trim());
		}
		qt.setNum(num);
		qt.setStartTime(DateUtil.parseDate(startTime));
		qt.setStartEnd(DateUtil.parseDate(startEnd));
		qt.setUserId(user.getId());
		qt.setMaxPrice(maxPrice);
		qt.setMinPrice(minPrice);
		qt.setExplan(explan.trim());
		qt.setUnitPrice(unitPrice.trim());
		qt.setTitlePic(titlePic);
		qt.setImgPath(imgPath);
		// 设置Id，状态，当前时间 
		qt.setStatus(DictionaryUtil.QUOTE_STATUS_USING);// 0启用1禁用
		qt.setId(SoleIdUtil.getSoleIdSingletion().getIntSoleId(BillsType.QUOTATION.getValue()));
		qt.setCreateTime(DateUtil.getNowDate());
		qt.setCategoryId(categoryId);
		//设置创建人  发布人
		//qt.setcreateuserId(user.getId());
		qt.setPublishId(user.getId());
		qt.setCreateName(user.getName());
		qt.setPublishName(user.getName());
		
		boolean flag = true;
		// 调用报价service创建方法
		flag = quoteService.addQute(qt);
		// 判断操作是否成功，成功调用显示页面，否则跳转到失败页面
		if (flag) {
			return "0";
		}
		//创建失败
		return "1";

	}

	// 跳转编辑页面
	@RequestMapping("/toPageEdit")
	@ResponseBody
	public MtQuote toPageEdit(Model model,
			@RequestParam(value = "quoteId", required = false, defaultValue = "") String quoteId) {
		// 通过选中的报价Id，查找到报价对象
		MtQuote mt = quoteService.searchQuoteById(quoteId);
		// 将对象传递到前台页面
		model.addAttribute("quote", mt);
		// 跳转到编辑页面
		return mt;

	}

	// 编辑报价
	@RequestMapping("/editQuote")
	@ResponseBody
	public String editQuote(
			Model model,
			@RequestParam(value = "id2", required = false, defaultValue = "") String id,
			@RequestParam(value = "startTime2", required = false, defaultValue = "") String startTime,
			@RequestParam(value = "startEnd2", required = false, defaultValue = "") String startEnd,
			@RequestParam(value = "goodsId2", required = false, defaultValue = "") String goodsId,// 商品Id
			@RequestParam(value = "explan2", required = false, defaultValue = "") String explan,// 文字说明
			@RequestParam(value = "titlePic2", required = false, defaultValue = "") String titlePic,// 选择的图片
			@RequestParam(value = "imgPath2", required = false, defaultValue = "") String imgPath,
			@RequestParam(value = "unitPrice2", required = false, defaultValue = "") String unitPrice,// 价格单位
			@RequestParam(value = "minPrice2", required = false, defaultValue = "0") double minPrice,// 价格
			@RequestParam(value = "maxPrice2", required = false, defaultValue = "0") double maxPrice,
			@RequestParam(value = "status2",required = false) Integer status,
			//报价类型//0公共报价//1指定报价
			//@RequestParam(value = "rangType2",required = false) Integer rangType,
			@RequestParam(value = "account2", required = false, defaultValue = "") String account,// 销售账户
			@RequestParam(value = "address2", required = false, defaultValue = "") String address,// 发货地址
			@RequestParam(value = "categoryId2", required = false, defaultValue = "") String categoryId,// 选择商品的品类Id
			@RequestParam(value = "type2", required = false) Integer type) {
		// 获取编辑的参数以及编辑对象Id 封装到报价对象
		UserExtendBean user1 = Utils.securityUtil.getUser();
		MtMuser user = user1.getMuser();
		MtQuote qt = new MtQuote();
		
		
		
		//调用mmb service  通过mmbID查询出mmb  给地域赋值
		MtMember mmb = mmbService.queryMmbById(user.getMmbId());
		//获取会员所属的省级
		BusAreaTree bt = areaTreeService.getChild(mmb.getMmbAreaId());
		if(bt!=null){
			qt.setAreaId(bt.getId());
		}
		// 获取前台填写的数据，包含报价类型，商品名称，数量
		// 单价上限，单价下限，有效期开始时间，有效期结束时间 说明，商品Id等字段
		qt.setId(id);
		qt.setMmbId(user.getMmbId());// 所属的组织Id（会员Id）
		qt.setUserId(user.getId());// 登录员Id
		
		// qt.setMmbName(user.getMmbName);

		qt.setId(id);
		qt.setGoodsId(goodsId);	
		//qt.setRangType(rangType);
		qt.setType(type);
		qt.setCategoryId(categoryId);
		if (type == DictionaryUtil.GROUP_TYPE_BUY) {// 采购报价
			qt.setPdAccount(account.trim());
			qt.setReceiceAddress(address.trim());
		}
		if (type == DictionaryUtil.GROUP_TYPE_SELL) {// 销售报价
			qt.setSellAccount(account.trim());
			qt.setSendAddres(address.trim());
		}
		System.out.println(qt.getNum());
		qt.setStartTime(DateUtil.parseDate(startTime));
		qt.setStartEnd(DateUtil.parseDate(startEnd));
		qt.setUserId(user.getId());
		qt.setMaxPrice(maxPrice);
		qt.setMinPrice(minPrice);
		qt.setExplan(explan.trim());
		qt.setUnitPrice(unitPrice.trim());
		qt.setTitlePic(titlePic);
		qt.setImgPath(imgPath);
		// 设置Id，状态，当前时间
		qt.setStatus(DictionaryUtil.QUOTE_STATUS_USING);// 0启用1禁用
		qt.setCreateTime(DateUtil.getNowDate());
		//设置创建人  发布人
		qt.setPublishId(user.getId());
		qt.setPublishName(user.getName());
		// 调用service修改方法
		boolean flag = true;
		flag = quoteService.editQuto(qt);
		// 判断是否修改成功，返回显示页面提示
		if (flag) {
			return "0";
		}
		//编辑失败
		return "1";
	}
	//修改rangType状态
	@RequestMapping("/updateRangTypeByQuoteId")
	@ResponseBody
	public String updateRangTypeByQuoteId(Model model,
			@RequestParam(value = "rangType", required = false) Integer rangType,
			@RequestParam(value = "quoteId", required = false, defaultValue = "") String quoteId) {
		// 创建报价对象，获取选中的报价Id
		MtQuote qt = new MtQuote();
		qt.setId(quoteId);
		qt.setRangType(rangType);
		// 调用service修改方法
		boolean flag = true;
		flag = quoteService.editQuto(qt);
		// 判断是否成功
		String json ="";
		if (flag) {
			// 成功，重定向到显示页面
			json ="0";
		} else {
			// 失败，返回前台提示
			json ="1";
		}
		return json;

	}
	// 暂停报价
	@RequestMapping("/paseQuote")
	@ResponseBody
	public String paseQuote(Model model,
			@RequestParam(value = "quoteId", required = false, defaultValue = "") String quoteId) {
		// 创建报价对象，获取选中的报价Id
		// 获取对象Id 封装到Map 将报价状态改为暂停 1
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("id", quoteId);
		params.put("status", DictionaryUtil.QUOTE_STATUS_FORBID);
		// 调用service修改方法
		boolean flag = true;
		flag = quoteService.editQutoByQuoteID(params);
		// 判断是否成功
		String json ="";
		if (flag) {
			// 成功，重定向到显示页面
			json ="0";
		} else {
			// 失败，返回前台提示
			json ="1";
		}
		return json;
	}

	// 重启报价
	@RequestMapping("/enabledQuote")
	@ResponseBody
	public String enabledQuote(Model model,
			@RequestParam(value = "quoteId", required = false, defaultValue = "") String quoteId) {
		// 创建报价对象，获取选中的报价Id
		// 获取对象Id 封装到Map 将报价状态改为启用 0
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("id", quoteId);
		params.put("status", DictionaryUtil.QUOTE_STATUS_USING);
		// 调用service修改方法
		boolean flag = true;
		flag = quoteService.editQutoByQuoteID(params);
		
		// 判断是否成功
		String json ="";
		if (flag) {
			// 成功，重定向到显示页面
			json ="0";
		} else {
			// 失败，返回前台提示
			json ="1";
		}
		return json;
	}
	//根据报价Id，查询出报价相关的群组对象集合
	@RequestMapping("/getGroup")
	@ResponseBody
	public List<MtGroup> getGroup(Model model,
			@RequestParam(value = "quoteId", required = false, defaultValue = "") String quoteId){
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("quoteId",quoteId);
		params.put("type",DictionaryUtil.RELA_QUOTE_TYPE_GROUP);
		List<MtGroup> mglist = groupService.queryGroupsByCondition(params);
		System.out.println(params.toString());
		return mglist;
	}
	//通过报价Id，查询出报价相关的合作会员对象
	@RequestMapping("/getMmb")
	@ResponseBody
	public List<MtMember> getMmb(Model model,
			@RequestParam(value = "quoteId", required = false, defaultValue = "") String quoteId){
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("quoteId",quoteId);
		params.put("type",DictionaryUtil.RELA_QUOTE_TYPE_OMMB);
		List<MtMember> mtlist = mmbService.queryMmbsInfoByQuoteId(params);
		return mtlist;
	}
	//通过地域Id，返回地域的名称
	@RequestMapping("/getAreaName")
	@ResponseBody
	public String getAreaName(Model model,
			@RequestParam(value = "quoteId", required = false, defaultValue = "") String quoteId){
			MtQuote mt = quoteService.searchQuoteById(quoteId);
			System.out.println(mt.getAreaId());
			BusAreaTree bt = areaTreeService.searchTreeByID(mt.getAreaId());
			String name = "";
			if(bt!=null){
				System.out.println(bt.getAreaName());
				name=bt.getAreaName();
			}
			if("1000".equals(mt.getAreaId())){
				name="中国";
			}
			
			
			
		return name;
	}
	//查询群组  通过会员Id以及类型  查询出与他相关联的群组对象集合
	@RequestMapping("/showGroup")
	@ResponseBody
	public Map<String, Object> showGroup(Model model,
			@RequestParam(value = "pageNo", required = false) String pageNo1,
			@RequestParam(value = "pageSize", required = false) Integer pageSize,
			@RequestParam(value = "type", required = false) Integer type,
			@RequestParam(value = "groupName", required = false) String groupName,
			@RequestParam(value = "mmbId", required = false, defaultValue = "") String mmbId){
		
		//分页
		Long pageNo = StringUtils.isBlank(pageNo1) ? 1 : Long.valueOf(pageNo1);
		pageNo = pageNo<1?1:pageNo;
		pageSize = pageSize==null&&pageSize<1?2:pageSize;
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("mmbId",mmbId);
		params.put("type",type);
		if(!StringUtils.isBlank(groupName)){
			params.put("groupName", groupName);
		}
		System.out.println(params.toString());
		//查询数量
		int totalCount = groupService.countQueryGroupsByMmbId(params);
		params.put("startFirst", pageNo > 0 ? (pageNo - 1) * pageSize : 0);
		params.put("startEnd", pageSize);
		//查询分页集合
		List<MtGroup> groupList = groupService.queryGroupsByMmbId(params);
		Map<String, Object> returnmap = new HashMap<String, Object>();
		returnmap.put("groupCount",totalCount);
		returnmap.put("groupList",groupList);
		return returnmap;
	}
	//查询会员 通过会员Id以及类型  查询出与他相关联的会员对象集合
	@RequestMapping("/showMmb")
	@ResponseBody
	public Map<String, Object> showMmb(Model model,
			@RequestParam(value = "mmbSname", required = false) String mmbSname,
			@RequestParam(value = "pageNo", required = false) String pageNo1,
			@RequestParam(value = "pageSize", required = false) Integer pageSize,
			@RequestParam(value = "type", required = false) Integer type,
			@RequestParam(value = "mmbId", required = false, defaultValue = "") String mmbId){
		
		//分页
		Long pageNo = StringUtils.isBlank(pageNo1) ? 1 : Long.valueOf(pageNo1);
		pageNo = pageNo<1?1:pageNo;
		pageSize = pageSize==null&&pageSize<1?2:pageSize;
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("mmbId",mmbId);
		params.put("type",type);
		if(!StringUtils.isBlank(mmbSname)){
			params.put("mmbSname", mmbSname);
		}
		//查询数量
		int totalCount = mmbService.countMmbsByQuoteType(params);
		params.put("startFirst", pageNo > 0 ? (pageNo - 1) * pageSize : 0);
		params.put("startEnd", pageSize);
		//查询分页集合
		List<MtMember> mmbList = mmbService.queryMmbsByQuoteType(params);
		Map<String, Object> returnmap = new HashMap<String, Object>();
		returnmap.put("mmbCount",totalCount);
		returnmap.put("mmbList",mmbList);
		return returnmap;
	}
	//会员确定按钮  添加会员关系
	@RequestMapping("/addMmbIds")
	@ResponseBody
	public Map<String, Object> addMmbIds(Model model,
			@RequestParam(value = "mmbIds", required = false) String mmbIds,
			@RequestParam(value = "quoteId", required = false) String quoteId,
			@RequestParam(value = "rangType", required = false) Integer rangType){
		Map<String, Object> map = new HashMap<String, Object>();
		map = quoteRelationService.addMmbIds(quoteId, mmbIds, rangType);
		return map;	
	}
	//群组确定按钮  添加群组关系
		@RequestMapping("/addGroupIds")
		@ResponseBody
		public Map<String, Object> addGroupIds(Model model,
				@RequestParam(value = "groupIds", required = false) String groupIds,
				@RequestParam(value = "quoteId", required = false) String quoteId,
				@RequestParam(value = "rangType", required = false) Integer rangType){
			Map<String, Object> map = new HashMap<String, Object>();
			map = quoteRelationService.addGroupIds(quoteId, groupIds, rangType);
			return map;	
		}
	//删除按钮 通过scopeId和quoteId删除数据  scopeId
		@RequestMapping("/deleteScopeId")
		public void deleteScopeId(Model model,
				@RequestParam(value = "scopeId", required = false) String scopeId,
				@RequestParam(value = "quoteId", required = false) String quoteId){
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("quoteId", quoteId);
			map.put("scopeId", scopeId);
			boolean flag = true;
			flag = quoteRelationService.deleteQutoRalation(map);
			if(flag){
				outJson("0");
			}else{
				outJson("1");
			}
		}
	
	// 选择群组
	@RequestMapping("/group")
	public void group(String groupId, String quoteId) {
		// 通过报价Id判断是否存在群组类型关系
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("quoteId", quoteId);
		params.put("type", DictionaryUtil.RELA_QUOTE_TYPE_GROUP);
		// 若存在则调用删除群组关系方法
		boolean flag = true;
		flag = quoteRelationService.serachQuoteRalation(params);
		if (flag) {
			deleteArea(DictionaryUtil.RELA_QUOTE_TYPE_GROUP, quoteId);
		}
		// 调用创建群组关系方法
		flag = addGroup(groupId, quoteId);
		// 判断是否成功
		// 判断是否成功
		if (flag) {
			// 成功，返回前台该组织名称
			outJson("0");
		} else {
			// 不成功，返回js相应提示
			outJson("1");
		}
	}

	// 选择会员
	
	public void user(String mmbId, String quoteId) {
		// 通过报价Id判断是否存在会员类型关系
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("quoteId", quoteId);
		params.put("type", DictionaryUtil.RELA_QUOTE_TYPE_OMMB);
		boolean flag = true;
		flag = quoteRelationService.serachQuoteRalation(params);
		// 若存在则调用删除会员关系方法
		if (flag) {
			deleteArea(DictionaryUtil.RELA_QUOTE_TYPE_OMMB, quoteId);
		}
		// 调用创建会员关系方法
		flag = addMmb(mmbId, quoteId);
		// 判断是否成功
		if (flag) {
			// 成功，返回前台该会员名称
			outJson("0");
		} else {
			// 不成功，返回js相应提示
			outJson("1");
		}
	}

	// 删除关系（多个）
	
	public boolean deleteArea(Integer type, String quoteId) {
		// 获取范围类型：type 1 地域 2会员3群组 
		// 获取前台选中的报价Id
		// 封装类型 条件
		Map<String, Object> params = new HashMap<String, Object>();
		if (!StringUtils.isBlank(quoteId)) {
			params.put("quoteId", quoteId);
		}
		;
		if (type != null) {
			params.put("type", type);;
		}
		;

		// 调用报价范围的service删除方法
		boolean flag = true;
		flag = quoteRelationService.deleteQutoRalation(params);
		// 判断是否删除成功
		return flag;
	}

	
	// 添加合作会员关系
	
	public boolean addMmb(String mmbIds, String quoteId) {
		boolean flag = false;
		if (!StringUtils.isBlank(mmbIds)) {
			if (mmbIds.contains(",")) {
				List<String> areaList = java.util.Arrays.asList(mmbIds
						.split(","));
				for (String mmbId : areaList) {
					// 创建范围对象，设置添加的范围类型：合作会员
					// 获取前台选中的合作会员Id，封装到范围对象，创建新的对象的UUID，并封装
					MtQuoteScope qr = new MtQuoteScope();
					qr.setQuoteId(quoteId);
					qr.setScopeId(mmbId);
					qr.setType(DictionaryUtil.RELA_QUOTE_TYPE_OMMB);
					qr.setId(UUIDCreater.getUUID());
					// 调用报价范围的service创建
					flag = quoteRelationService.addQutoRalation(qr);
					// 判断是否创建成功
					if (!flag) {
						break;
					}
				}
			}
		}
		// 判断是否创建成功
		return flag;
	}

	// 添加群组关系
	
	public boolean addGroup(String groupIds, String quoteId) {
		boolean flag = false;
		if (!StringUtils.isBlank(groupIds)) {
			if (groupIds.contains(",")) {
				List<String> areaList = java.util.Arrays.asList(groupIds
						.split(","));
				for (String groupId : areaList) {
					// 创建范围对象，设置添加的范围类型：群组
					// 获取前台选中的群组Id，封装到范围对象，创建新的对象的UUID，并封装
					MtQuoteScope qr = new MtQuoteScope();
					qr.setQuoteId(quoteId);
					qr.setScopeId(groupId);
					qr.setType(DictionaryUtil.RELA_QUOTE_TYPE_GROUP);
					qr.setId(UUIDCreater.getUUID());
					// 调用报价范围的service创建
					flag = quoteRelationService.addQutoRalation(qr);
					// 判断是否创建成功
					if (!flag) {
						break;
					}
				}
			}
		}
		return flag;
	}

	//商城主页搜索
	// 登陆人查看报价
	/**
	 * 
	 * @param model
	 * @param mmbId
	 *            操作员所属的会员Id
	 * @param pageSize
	 * @param quote
	 * @param Userid
	 * @param id
	 * @return
	 */
	@RequestMapping("/serachQuote")
	@ResponseBody
	public Map<String,Object> serachQuote(
			Model model,
			@RequestParam(value = "goodname", required = false) String goodname,
			@RequestParam(value = "startTime", required = false) String startTime,
			@RequestParam(value = "startEnd", required = false) String startEnd,
			@RequestParam(value = "createTime1", required = false) String createTime1,
			@RequestParam(value = "createTime2", required = false) String createTime2,
			
			@RequestParam(value = "checkBoxId", required = false) String checkBoxId,// 选择的群组的字符串
			@RequestParam(value = "pageNo", required = false, defaultValue = "1") String pageNo1,
			@RequestParam(value = "pageSize", required = false, defaultValue = "") Integer pageSize,
			@RequestParam(value = "categoryId", required = false) String categoryId,// 商品的品类Id
			@RequestParam(value = "type", required = false, defaultValue = "") Integer type// 报价类型
																							// 0采购
																							// 1销售
	) {
		// 获取查询条件封装到Map
		// 报价类型，状态，有效期开始以及结束，发布时间范围，商品名称
		// 判断是否为空，将非空条件放入Map中以及会员Id 报价类型为 0 采购 1 销售
		logger.error("..........................报价查询");
		Map<String, Object> params = new HashMap<String, Object>();
		if (!StringUtils.isBlank(goodname.trim())) {
			params.put("goodname", goodname.trim());
		};
		if (!StringUtils.isBlank(startTime)) {
			params.put("startTime", startTime);
		};
		if (!StringUtils.isBlank(startEnd)) {
			params.put("startEnd",startEnd);
		};
		if (!StringUtils.isBlank(createTime1)) {
			params.put("createTime1", createTime1);
		};
		if (!StringUtils.isBlank(createTime2)) {
			params.put("createTime2", createTime2);
		};
		
		// 0 在使用 1 已禁用 2已过期
		params.put("status", DictionaryUtil.QUOTE_STATUS_USING );
		if (type != null) {
			// 0 销售 1 采购
			params.put("type", type);
		};
		//默认查询销售报价
		if(type==null){
			params.put("type", DictionaryUtil.GROUP_TYPE_SELL);
		}
		// 获取登陆人对象
		UserExtendBean user = Utils.securityUtil.getUser();
		MtMuser mUser = user.getMuser();
		//不查询自己报价
		params.put("mmbId", mUser.getMmbId());
		//匹配品类
		if (!StringUtils.isBlank(categoryId)) {
			// 选择商品种类
			params.put("categoryId", categoryId);
		}
		//checkBoxId
		List<String> arr =java.util.Arrays.asList(checkBoxId.split(","));
		System.out.println(arr.contains("0"));
		if(arr.contains(DictionaryUtil.SHOP_QUOTE_AREA)){
			//公开报价  areaId
			//通过mmbId查询出mmb对象
			MtMember mmb = mmbService.queryMmbById(mUser.getMmbId());
			//公开报价
			params.put("areaId", mmb.getMmbAreaId());
			System.out.println( mmb.getMmbAreaId());
		}
		if(arr.contains(DictionaryUtil.SHOP_QUOTE_ACTIOM)){
			//关注会员   showMmbId!=null
			params.put("actionMal", DictionaryUtil.SHOP_QUOTE_ACTIOM);
		}
		if(arr.contains(DictionaryUtil.SHOP_QUOTE_MMB)){
			//合作会员 mmbType==2
			params.put("mmbType", DictionaryUtil.SHOP_QUOTE_MMB);
		}
		if(arr.contains(DictionaryUtil.SHOP_QUOTE_GROUP)){
			//群组关系  ==3
			params.put("groupType", DictionaryUtil.SHOP_QUOTE_GROUP);
		}
		
		
		
		Long pageNo = StringUtils.isBlank(pageNo1) ? 1 : Long.valueOf(pageNo1);
		pageNo = pageNo<1?1:pageNo;
		pageSize = pageSize==null&&pageSize<1?2:pageSize;
		long totalCount = quoteService.searchShopCount(params);
		System.out.println("*************************============"+totalCount);
		// 当前页数不能超过总页数
		
		long totalPageCount = (totalCount + pageSize - 1)/pageSize;
		if(pageNo>totalPageCount){
			pageNo = totalPageCount;
		}
		params.put("startFirst", pageNo > 0 ? (pageNo - 1) * pageSize : 0);
		params.put("startEnd1", pageSize);
		List<MtQuote> quoteList = quoteService.searchShop(params);
		Map<String, Object> returnmap = new HashMap<String, Object>();
		returnmap.put("qtCount",totalCount);
		returnmap.put("qtList",quoteList);
		//returnmap.put("prarms",params);
		return returnmap;	
	}

	// 判断商品价格
	@RequestMapping("/priceGood")
	public void priceGood(String price, String qutoId) {
		// 获取选中的报价Id
		// 调用报价service查询出报价内容
		// 通过报价的商品Id，查询出商品信息
		// 判断price是否在商品的价格范围内
		// 返回前台js响应
		
	}

	// 确认商品（采购报价）
	@RequestMapping("/affirmQuotePush")
	public void affirmQuotePush(String goodId) {
		// 查询处选中的该类商品的详细信息
		// 将选中的商品Id添加到报价单中
		// 调用service修改方法
		// 返回js提示
	}
	
	
	
	//跳转商城主页
		@RequestMapping("/toshowShopRedirectBefore")
		public String toshowShop(){
			logger.info("====toshowShop====");
			request.setAttribute("type", DictionaryUtil.GROUP_TYPE_BUY);
			return "mall/quote/show_shop";
		}
	
	
	
	
	@RequestMapping("/toshowShop1RedirectBefore")
	public String toshowShop1(){
		logger.info("====toshowShop====");
		request.setAttribute("type", DictionaryUtil.GROUP_TYPE_SELL);
		return "mall/quote/show_shop";
	}
	
	
	//报价详情页面
	@RequestMapping("/quoteDetail")
	public String quoteDetail(Model model,
			@RequestParam(value = "quoteId", required = false) String quoteId){
		logger.info("====quoteDetail====");
		request.setAttribute("quoteId", quoteId);
		return "mall/quote/quote_detail";
	}
	//报价详情
	@RequestMapping("/detailQuote")
	@ResponseBody
	public Map<String, Object> detailQuote(Model model,
			@RequestParam(value = "quoteId", required = false) String quoteId){
		//查询报价
		MtQuote mq = quoteService.searchQuoteById(quoteId);
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("mq", mq);
		//查询地域
		String areaName ="";
		if(mq.getAreaId()!=""){
			BusAreaTree bs =areaTreeService.searchTreeByID(mq.getAreaId());
			areaName = bs.getAreaName();
		}
		//地域
		map.put("areaName", areaName);
		//轮播图
		List<String> pathlist = malService.searchMalByGood(mq.getGoodsId());
		map.put("pathlist", pathlist);
		return map;
		
	}
	
}
