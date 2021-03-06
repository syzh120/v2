package com.zllh.factoring.accreditation.service.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.sf.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.zllh.base.controller.BaseController;
import com.zllh.common.enums.PayTypeCode;
import com.zllh.factoring.accreditation.service.AccreditationMgService;
import com.zllh.factoring.common.dao.FacFinancingGuaranteeMapper;
import com.zllh.factoring.common.dao.FacFinancingMapper;
import com.zllh.factoring.common.dao.FacGuaranteeBillMapper;
import com.zllh.factoring.common.dao.FacMessageMapper;
import com.zllh.factoring.common.fac_enum.FinancingEnum;
import com.zllh.factoring.common.fac_enum.SameBank;
import com.zllh.factoring.common.fac_enum.TranFlag;
import com.zllh.factoring.common.fac_enum.TranType;
import com.zllh.factoring.common.interest.InterestConfig;
import com.zllh.factoring.common.model.FacFinancing;
import com.zllh.factoring.common.model.FacFinancingGuarantee;
import com.zllh.factoring.common.model.FacGuaranteeBill;
import com.zllh.factoring.common.model.message.common.CallBack;
import com.zllh.factoring.common.model.message.common.ForceTransferAction;
import com.zllh.factoring.common.model.message.common.OutAction;
import com.zllh.factoring.common.model.message.financingrefund.FinRefundList;
import com.zllh.factoring.common.model.message.financingrefund.FinanRefundMessage;
import com.zllh.factoring.common.model.model_extend.FacFinancingExtendBean;
import com.zllh.factoring.common.model.model_extend.FacFinancingGuaranteeExtendBean;
import com.zllh.payment.server.service.FactoringMsgService;
import com.zllh.utils.base.Utils;

/**
 * @ClassName: AccreditationMgServiceImpl
 * @Description: 融资保理认可管理ServiceImpl
 * @author JW
 * @date 2015-12-18 下午3:28:11
 */
@Service
public class AccreditationMgServiceImpl implements AccreditationMgService {
	
	//融资单
	@Autowired
	private FacFinancingMapper financingMapper;
	
	//担保单
	@Autowired
	private FacGuaranteeBillMapper guaranteeBillMapper;
	
	//融资借款单
	@Autowired
	private FacFinancingGuaranteeMapper facFinancingGuaranteeMapper;
	
	@Autowired
	private FactoringMsgService factoringMsgService;
	
	@Autowired
	private FacMessageMapper facMessageMapper;
	
	private final Logger logger = LoggerFactory.getLogger(BaseController.class); 
	
	private final String userName = "zhonglianlianhe";
	
	/** 根据融资单号查询订单行和担保信息明细 */
	@Override
	public FacFinancingExtendBean findFinancingDetailById(String id) {

		Map<String, Object> map = new HashMap<String, Object>();
		map.put("orderDetails", "订单行查询结果集");
		map.put("guaranteeDetails", "担保单查询结果集");
		FacFinancingExtendBean finGuas = financingMapper.findFinancingAndGuaranteeByFinId(id);
		return finGuas;
	}

	/** 认可 */
	//认可方法，传进来融资单号(financingOrder),融资流程（financingProcess），认可状态（acceptStatus）
	@Override
	public String executeAccept(String[] ids,String lockFinjJson) {
		
		/** 通过融资单号查询出对象(担保单融资单及关系一起查询出来),判断融资单Id锁及乐观锁  **/
		List<FacFinancingExtendBean> fins = financingMapper.findFinancingAndGuaranteeListByFinIds(ids);
		HashMap<String, Object> resMap = new HashMap<String, Object>();
		
		List<HashMap<String, Object>> finRefundListMap = new ArrayList<HashMap<String, Object>>();
		FinRefundList finRefund = null;
		
		try{
			//判断融资单Id锁及乐观锁
			resMap = Utils.lock.lockByFins(fins, lockFinjJson);
			
			//锁成功的融资单
			@SuppressWarnings("unchecked")
			List<FacFinancingExtendBean> lockFin = (List<FacFinancingExtendBean>) resMap.get("success");
			if(lockFin==null||lockFin.size()<0) return "认可失败,请稍后重试！";
			
			for(FacFinancingExtendBean fin : lockFin){
				/**  生成认可转账报文  **/
				finRefund = getTransferMassage(fin);
				finRefundListMap.add(Utils.objUtil.beanToMap(finRefund));
			}
			
			//判断是否需要处理的报文
			if(finRefundListMap!=null&&finRefundListMap.size()>0){
				//发送支付报文
				String serialID = Utils.commonUtil.getSerialNumber();
				boolean bool = sendMessage(finRefundListMap, "part", Utils.securityUtil.getUserDetails().getUsername(),serialID);
				if(!bool) {
					logger.error("支付处理失败！");
					return "认可提交失败,请稍后重试！";
				}else{
					/****  更新状态为 待放款、认可人、认可时间。。。     ***/
					
					/**  查询融资单状态，如果状态为待放款，则不修改，返回失败；如果状态为待认可  修改状态为待放款**/
					
					for(int i = 0;i<lockFin.size();i++){
						if(lockFin.get(i).getStatus() == 1){
							FacFinancing fac = new FacFinancing();
							fac.setId(lockFin.get(i).getId());
							fac.setStatus(FinancingEnum.WAITING_LOAN.getValue());
							fac.setAcceptDate(new Date());
							fac.setAcceptOperatorId(Utils.securityUtil.getUser().getUserId());
							fac.setAcceptOperatorName(Utils.securityUtil.getUser().getUserName());
							fac.setAcceptBankId(serialID);//认可报文流水号
							financingMapper.updateByPrimaryKeySelective(fac);
						}
					}
					
//					for(FacFinancingExtendBean fac_fin : lockFin){
//						FacFinancing fac = new FacFinancing();
//						fac.setId(fac_fin.getId());
//						fac.setStatus(FinancingEnum.WAITING_LOAN.getValue());
//						fac.setAcceptDate(new Date());
//						fac.setAcceptOperatorId(Utils.securityUtil.getUser().getUserId());
//						fac.setAcceptOperatorName(Utils.securityUtil.getUser().getUserName());
//						financingMapper.updateByPrimaryKey(fac);
//					}
				}
			}
			
			Utils.lock.deblocking(ids);
			
		}catch(Exception e){
			e.printStackTrace();
			Utils.lock.deblocking(ids);
			throw new RuntimeException();
		}

		return "认可提交成功！！";
	}
	
	
public String executeAccept2(String[] ids,String lockFinjJson) {
		
		/** 通过融资单号查询出对象(担保单融资单及关系一起查询出来),判断融资单Id锁及乐观锁  **/
		List<FacFinancingExtendBean> fins = financingMapper.findFinancingAndGuaranteeListByFinIds(ids);
		HashMap<String, Object> resMap = new HashMap<String, Object>();
		
		List<HashMap<String, Object>> finRefundListMap = new ArrayList<HashMap<String, Object>>();
		FinRefundList finRefund = null;
		
		String describe="";
		
		try{
			//判断融资单Id锁及乐观锁
			resMap = Utils.lock.lockByFins(fins, lockFinjJson);
			
			//锁成功的融资单
			@SuppressWarnings("unchecked")
			List<FacFinancingExtendBean> lockFin = (List<FacFinancingExtendBean>) resMap.get("success");
			if(lockFin==null||lockFin.size()<0) return null;
			
			for(FacFinancingExtendBean fin : lockFin){
				/**  生成认可转账报文  **/
				finRefund = getTransferMassage(fin);
				finRefundListMap.add(Utils.objUtil.beanToMap(finRefund));
				
				//判断是否需要处理的报文
				if(finRefundListMap!=null&&finRefundListMap.size()>0){
					//发送支付报文
					String serialID = Utils.commonUtil.getSerialNumber();
					FinanRefundMessage mess = sendMessage2(finRefundListMap, "part", Utils.securityUtil.getUserDetails().getUsername(),serialID);
					
					String json = JSONObject.fromObject(Utils.objUtil.beanToMap(mess)).toString();
					logger.info(json);
						
					//创建 FacMessage 对象
//					FacMessage facMessage = new FacMessage();
//					
//					facMessage.setId(Utils.commonUtil.createVersionId());
//					facMessage.setCreatetime(new Date());
//					facMessage.setMessage(json);
//					facMessage.setOperator(Utils.securityUtil.getUser().getUserName());
//					facMessage.setOperatorId(Utils.securityUtil.getUser().getUserId());
//					facMessage.setSource(DisburseEnum.ACCEPT.getValue());
//					facMessage.setStatus(0);
//					facMessage.setSerialNo(serialID);
					
					//生成描述信息
					describe ="融资单号："+fin.getFinancingId()+","+"主账号："+fin.getBlocAccount()+","
							+fin.getAcctName()+"："+fin.getMemberAccount()+
							"到"+fin.getDistributorName()+"："+fin.getDistributorTheoreticalBank()+
							"强制转账：￥"+String.format("%.2f", fin.getWaitPayTotal().doubleValue())+
							","+ fin.getDistributorName()+"："+fin.getDistributorTheoreticalBank()+
							"到"+fin.getAcctName()+"："+fin.getMemberAccount()+
							"强制转账：￥"+String.format("%.2f", fin.getWaitPayTotal().multiply(new BigDecimal(InterestConfig.SERVICE_FEE)).doubleValue())+
							","+ fin.getDistributorName()+"："+fin.getDistributorTheoreticalBank()+
							"到"+fin.getDistributorName()+"："+fin.getDistributorGeneralBank()+
							"强制出金：￥"+String.format("%.2f", fin.getWaitPayTotal().subtract(fin.getWaitPayTotal().multiply(new BigDecimal(InterestConfig.SERVICE_FEE).setScale(2, BigDecimal.ROUND_HALF_UP))).doubleValue());
					
					
//					facMessage.setRefunddescription(describe);//描述
//					
//					int i = facMessageMapper.insertSelective(facMessage);
					
//					if(i>0){
						//保存成功  修改融资单信息（状态设置为待放款，认可信息）
//						if(fin.getStatus() == 1){
//							FacFinancing fac = new FacFinancing();
//							fac.setId(fin.getId());
//							fac.setStatus(FinancingEnum.WAITING_LOAN.getValue());
//							fac.setAcceptDate(new Date());
//							fac.setAcceptOperatorId(Utils.securityUtil.getUser().getUserId());
//							fac.setAcceptOperatorName(Utils.securityUtil.getUser().getUserName());
//							fac.setAcceptBankId(serialID);//认可报文流水号
//							financingMapper.updateByPrimaryKeySelective(fac);
//						}
					}else{
						return null;
					}
				}
//			}
			Utils.lock.deblocking(ids);
			
		}catch(Exception e){
			e.printStackTrace();
			Utils.lock.deblocking(ids);
			throw new RuntimeException();
		}

		return describe;
	}

	/**
	 * 获取报文
	 */
	public FinRefundList getTransferMassage(FacFinancingExtendBean fin){
		
		/*** 获取报文中action数据   **/
		List<HashMap<String, Object>> actionList = getActionList(fin);;

		FinRefundList finRefund = new FinRefundList();
		String acceptBackId = Utils.commonUtil.getSerialNumber();
		
		/** 保存流水号到融资表  **/
		
		
		finRefund.setFlowID(acceptBackId);
		finRefund.setAction(actionList);
		
		return finRefund;
	}
	
	/**
	 * 生成报文中action数据
	 */
	public List<HashMap<String, Object>> getActionList(FacFinancingExtendBean fin){
		
		/*** 生成转账报文  （出入金到小b虚拟户）   **/
		List<HashMap<String, Object>> actionList = new ArrayList<HashMap<String,Object>>();
		ForceTransferAction forceTransferAction = new ForceTransferAction();
		forceTransferAction.setCode(PayTypeCode.ZLMDTFER.getValue());
		forceTransferAction.setUserName(userName);
		forceTransferAction.setClientID(Utils.commonUtil.getSerialNumber());
		forceTransferAction.setAccountNo(fin.getBlocAccount());//主账号
		forceTransferAction.setPayAccNo(fin.getMemberAccount());//付款方账号（出入金账号）
		forceTransferAction.setTranType(TranType.BF.getValue());
		forceTransferAction.setRecvAccNo(fin.getDistributorTheoreticalBank());//小b虚拟户
		forceTransferAction.setRecvAccNm(fin.getDistributorName());//小b商户名
		forceTransferAction.setTranAmt(String.format("%.2f", fin.getWaitPayTotal().doubleValue()));
		forceTransferAction.setAccNoCon("");
		forceTransferAction.setAccAmtCon(String.format("%.2f", fin.getWaitPayTotal().doubleValue()));
		forceTransferAction.setFreezeNo("");
		forceTransferAction.setMemo("出入金到小b虚拟户转账");
		forceTransferAction.setTranFlag(TranFlag.YIBU.getValue());
		
		
		/**  服务费（小b虚拟户到平台服务费（出入金））  **/
		ForceTransferAction forceTransferAction_fwf = new ForceTransferAction();
		forceTransferAction_fwf.setCode(PayTypeCode.ZLMDTFER.getValue());
		forceTransferAction_fwf.setUserName(userName);
		forceTransferAction_fwf.setClientID(Utils.commonUtil.getSerialNumber());
		forceTransferAction_fwf.setAccountNo(fin.getBlocAccount());//主账号
		forceTransferAction_fwf.setPayAccNo(fin.getDistributorTheoreticalBank());//小b虚拟户
		forceTransferAction_fwf.setTranType(TranType.BF.getValue()); 
		forceTransferAction_fwf.setRecvAccNo(fin.getMemberAccount());//付款方账号（出入金账号）
		forceTransferAction_fwf.setRecvAccNm(fin.getAcctName());//商户名
		forceTransferAction_fwf.setTranAmt(String.format("%.2f", fin.getWaitPayTotal().multiply(new BigDecimal("0.01")).doubleValue()));
		forceTransferAction_fwf.setAccNoCon("");
		forceTransferAction_fwf.setAccAmtCon(String.format("%.2f", fin.getWaitPayTotal().multiply(new BigDecimal("0.01")).doubleValue()));
		forceTransferAction_fwf.setFreezeNo("");
		forceTransferAction_fwf.setMemo("小b虚拟户到平台服务费（出入金）转账");
		forceTransferAction_fwf.setTranFlag(TranFlag.YIBU.getValue());
		
		/**   小b虚拟户到小b一般户 （出金）       **/
		OutAction outAction = new OutAction();
		outAction.setCode(PayTypeCode.ZLFNDOUT.getValue());
		outAction.setUserName(userName);
		outAction.setClientID(Utils.commonUtil.getSerialNumber());
		outAction.setAccountNo(fin.getBlocAccount());//主账号
		outAction.setPayAccNo(fin.getDistributorTheoreticalBank());//小b虚拟户账号
		outAction.setRecvAccNo(fin.getDistributorGeneralBank());//小b一般户
		outAction.setRecvAccNm(fin.getDistributorName());//小b商户名   
		outAction.setTranAmt(String.format("%.2f", fin.getWaitPayTotal().subtract(fin.getWaitPayTotal().multiply(new BigDecimal("0.01").setScale(2, BigDecimal.ROUND_HALF_UP))).doubleValue()));//交易金额
		outAction.setSameBank(SameBank.BENHANG.getValue());
		outAction.setRecvTgfi("");
		outAction.setRecvBankNm("");
		outAction.setMemo("小b虚拟户到小b一般户 （出金） ");
		outAction.setPreFlg('0');
		outAction.setPreDate('0');
		outAction.setPreTime('0');
		
		actionList.add(Utils.objUtil.beanToMap(forceTransferAction));
		actionList.add(Utils.objUtil.beanToMap(forceTransferAction_fwf));
		actionList.add(Utils.objUtil.beanToMap(outAction));
		
		return actionList;
	}
	
	
/** ********************************************  **/

	/** 待放款处理方法*/
	@Override
	public String Loan_Processing(String financing_Order ,int status) {
		
		//通过传进来的融资单号查询对象
		FacFinancing facFinancing=financingMapper.selectByPrimaryKey(financing_Order);
		//通过对象判断状态，
		//判断状态是不是待放款状态，
		if(status==FinancingEnum.WAITING_LOAN.getValue()){
			//是的话生成支付报文，
			
			//否则记录异常。
		}
		//返回处理结果

		return "ok";
	}
	

	/** 支付回调*/
	//支付系统回调payCAllback()方法,参数为融资单号、执行状态
	@Override
	public String payCAllback(String financingID, int status) {
		
		//根据融资单号取融资单对象
		FacFinancing facFinancing=financingMapper.selectByPrimaryKey(financingID);
		//如果执行状态是失败
		if(status==1){
			//融资单状态设为待认可
			facFinancing.setAssureType(3);
			financingMapper.updateByPrimaryKey(facFinancing);
		}
		//如果是成功
		if(status==2){
			//根据融资单号，查询所有融资 -担保单集合
			//融资总额
			//担保总额
			List<FacFinancingGuarantee> facFinancingGuarantee =  facFinancingGuaranteeMapper.selectByPrimaryKey2(financingID);
			//循环所有融资-担保单集合
			for(FacFinancingGuarantee d1:facFinancingGuarantee){
				
				//将预锁金额复制到冻结金额
				//预锁金额
				BigDecimal ysje = d1.getLockAmount();
				//锁定金额
				d1.setFreezeAmount(ysje);
				
				//预锁金额清零
				d1.setLockAmount(null);
				//修改
				facFinancingGuaranteeMapper.updateByPrimaryKeys(d1);
			}
			//修改融资单状态为已认可
			facFinancing.setStatus(3);
			financingMapper.updateByPrimaryKey(facFinancing);
		}

		return "***";
	}
	
	/** 否决*/
	@Override
	public String executeVeto(String[] ids, String lockFinjJson) {
		
		//通过融资单号查询出对象(担保单融资单及关系一起查询出来)
		List<FacFinancingExtendBean> fins = financingMapper.findFinancingAndGuaranteeListByFinIds(ids);
		
		//判断融资单Id锁及乐观锁
		HashMap<String, Object> resMap = Utils.lock.lockByFins(fins, lockFinjJson);
		
		StringBuffer result = new StringBuffer();
		
		try{
		
			//锁成功的融资单
			@SuppressWarnings("unchecked")
			List<FacFinancingExtendBean> lockFin = (List<FacFinancingExtendBean>) resMap.get("success");
			if(lockFin==null||lockFin.size()<0) return "否决失败,请稍后重试！";
			
			
			//处理锁成功的融资单
			FacFinancing financing = null;
			for(FacFinancingExtendBean fin : lockFin){
				
				//判断融资单状态是否是待认可 如果不是待认可则不处理
				if(fin.getStatus()!=FinancingEnum.WAITING_ACCEPT.getValue()) {
					result.append((result.length()!=0? "/n/r" : "") +"融资单【"+fin.getFinancingId()+"】否决失败:只能对状态为"+FinancingEnum.WAITING_ACCEPT.getText()+"进行否决 ");
					continue;
				}
				for(FacFinancingExtendBean fina:fins){
					//更新融资单状态为已否决
					financing = new FacFinancing();
//					financing.setStatus(FinancingEnum.REJECTED.getValue());
//					financing.setId(fina.getId());
					financingMapper.deleteByPrimaryKey(fina.getId());
				}
				
				//处理所用担保单
				List<FacFinancingGuaranteeExtendBean> facFinancingGuarantees = fin.getFacFinancingGuarantees();
				for(FacFinancingGuaranteeExtendBean finGuatee : facFinancingGuarantees){
					
					//获取担保单的信息，并删除融资担保关联表数据
					FacGuaranteeBill guaBill = finGuatee.getFacGuaranteeBill();
					guaBill.setGuaranteeId(finGuatee.getGuaranteeId());
					BigDecimal sum = guaBill.getUsableAmount().add(finGuatee.getLockAmount());
					guaBill.setUsableAmount(sum);
					guaranteeBillMapper.updateByPrimaryKeySelective(guaBill);
					
					FacFinancingGuarantee fin_gua = new FacFinancingGuarantee();
					fin_gua.setFinancingId(finGuatee.getFinancingId());
					fin_gua.setGuaranteeId(finGuatee.getGuaranteeId());
					facFinancingGuaranteeMapper.deleteByForeignKey(fin_gua);
				}
				
 			}
			
			Utils.lock.deblocking(ids);
		
		}catch(Exception e){
			e.printStackTrace();
			Utils.lock.deblocking(ids);
			throw new RuntimeException();
		}

		return result.toString();
	}
	
	
	/** 列表查询*/
	@Override
	public List<FacFinancing> selectAccept(HashMap<String, Object> param) {
		return financingMapper.selectAccept(param);
	}


	/**
	 * @Title: removeLock 
	 * @Description: 释放ID锁
	 * @throws
	 */
	public void removeLock(FacFinancingExtendBean fin){
		
		/** 释放融资单ID锁  */
		if(fin!=null){
			
			Utils.lock.deblockingbById(fin.getFinancingId());
			
			List<FacFinancingGuaranteeExtendBean> facFinancingGuarantees = fin.getFacFinancingGuarantees();
			
			/** 释放担保单ID锁  */
			if(facFinancingGuarantees!=null&&facFinancingGuarantees.size()>0){
				//担保单IDS
				String[] dbIds = new String[facFinancingGuarantees.size()];
				for(int i=0;i<facFinancingGuarantees.size();i++){
					dbIds[i] = facFinancingGuarantees.get(i).getGuaranteeId();
				}
				Utils.lock.deblocking(dbIds);
			}
		}
	}
	
	
	/**
	 * @Title: sendMessage 
	 * @Description: 发送支付报文
	 * @param finRefundListMap
	 * @return Boolean
	 * @throws
	 */
	public Boolean sendMessage(List<HashMap<String, Object>> finRefundListMap, String integrity, String userName,String serialID){
		
		//如果msgLis为0或者null说明没有可执行的支付报文
		boolean bool = false;
		if(finRefundListMap!=null&&finRefundListMap.size()>0){
			CallBack call = new CallBack();
			call.setFactoringUrl("accreditationMgController/factoringCallback.do");
			call.setMallUrl("");
			FinanRefundMessage mess = new FinanRefundMessage();
			mess.setIntegrity(integrity);
			mess.setOperator(userName);
			mess.setList(finRefundListMap);
			mess.setCallBack(call);
			mess.setSerialID(serialID);
			String json = JSONObject.fromObject(Utils.objUtil.beanToMap(mess)).toString();
			logger.info(json);
		    bool = factoringMsgService.handleFactoringMsg(json);
		}
		return bool;
	}
	
	public FinanRefundMessage sendMessage2(List<HashMap<String, Object>> finRefundListMap, String integrity, String userName,String serialID){
		
		FinanRefundMessage mess = new FinanRefundMessage();
		
		if(finRefundListMap!=null&&finRefundListMap.size()>0){
			CallBack call = new CallBack();
			call.setFactoringUrl("accreditationMgController/factoringCallback.do");
			call.setMallUrl("");
			mess.setIntegrity(integrity);
			mess.setOperator(userName);
			mess.setList(finRefundListMap);
			mess.setCallBack(call);
			mess.setSerialID(serialID);
		}
		return mess;
	}
	
	
	public void executeAccept_update(String[] ids){
		
//		StringBuffer result = new StringBuffer();
		
		/**  1、锁担保资源  **/
		Utils.lock.thingLockByIds(ids);
		
		List<String> list_ids = Arrays.asList(ids);
		
		for(String id : list_ids){
			FacFinancingExtendBean facFin = financingMapper.findFinancingAndGuaranteeByFinId(id);
			
//			if(facFin == null) {
//				result.append("融资单："+id+"不存在，修改数据失败！！");
//				continue;
//			}else{
//				if(facFin.getStatus() != FinancingEnum.WAITING_LOAN.getValue()){
//					result.append("融资单："+facFin.getFinancingId()+"修改数据失败！！");
//				}else{
				
					/***   修改融资担保关联表数据      ***/
					
					for(FacFinancingGuarantee gua : facFin.getFacFinancingGuarantees()){
						FacFinancingGuarantee fin_gua = new FacFinancingGuarantee();
						fin_gua.setLockAmount(BigDecimal.ZERO);
						fin_gua.setFreezeAmount(gua.getFreezeAmount().add(gua.getLockAmount()).setScale(2, BigDecimal.ROUND_HALF_UP));
						fin_gua.setSurplusFreezeAmount(gua.getFreezeAmount().add(gua.getLockAmount()).setScale(2, BigDecimal.ROUND_HALF_UP));
						fin_gua.setSurplusPaymentsAmount(gua.getPaymentsAmount());
						fin_gua.setId(gua.getId());
						facFinancingGuaranteeMapper.updateByPrimaryKeySelective(fin_gua);
					}
					
					/**  修改融资单状态为  已认可  **/
					FacFinancing fac = new FacFinancing();
					fac.setStatus(FinancingEnum.ACCEPTED.getValue());
					fac.setAcceptDate(new Date());
					fac.setAcceptOperatorId(Utils.securityUtil.getUser().getUserId());
					fac.setAcceptOperatorName(Utils.securityUtil.getUser().getAcountName());
					fac.setId(facFin.getId());
					financingMapper.updateByPrimaryKeySelective(fac);
//				}
//			}
		}
		
		/**  解锁    **/
		Utils.lock.deblocking(ids);
		
//		return result.toString();
	}

	
}
