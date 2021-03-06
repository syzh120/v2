
package com.zllh.factoring.repayment.service.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.zllh.base.mybatis.Page;
import com.zllh.common.common.model.model_extend.UserExtendBean;
import com.zllh.common.enums.PayTypeCode;
import com.zllh.factoring.accreditation.service.AccreditationMgService;
import com.zllh.factoring.common.dao.FacFinancingGuaranteeMapper;
import com.zllh.factoring.common.dao.FacFinancingMapper;
import com.zllh.factoring.common.dao.FacFinancingRefundMapper;
import com.zllh.factoring.common.dao.FacGuaranteeBillMapper;
import com.zllh.factoring.common.dao.FacGuaranteeRefundInterestMapper;
import com.zllh.factoring.common.dao.FacGuaranteeRefundMapper;
import com.zllh.factoring.common.dao.FacMessageMapper;
import com.zllh.factoring.common.dao.FacMessageStatusMapper;
import com.zllh.factoring.common.dao.FacRefundMapper;
import com.zllh.factoring.common.fac_enum.FinancingEnum;
import com.zllh.factoring.common.fac_enum.FinancingGuaranteeEnum;
import com.zllh.factoring.common.fac_enum.MessageStatus;
import com.zllh.factoring.common.fac_enum.RefundEnum;
import com.zllh.factoring.common.fac_enum.SameBank;
import com.zllh.factoring.common.fac_enum.SourceEnum;
import com.zllh.factoring.common.fac_enum.TranFlag;
import com.zllh.factoring.common.fac_enum.TranType;
import com.zllh.factoring.common.model.FacFinancing;
import com.zllh.factoring.common.model.FacFinancingGuarantee;
import com.zllh.factoring.common.model.FacFinancingRefund;
import com.zllh.factoring.common.model.FacGuaranteeBill;
import com.zllh.factoring.common.model.FacGuaranteeRefund;
import com.zllh.factoring.common.model.FacGuaranteeRefundInterest;
import com.zllh.factoring.common.model.FacMessageStatus;
import com.zllh.factoring.common.model.FacRefund;
import com.zllh.factoring.common.model.message.common.CallBack;
import com.zllh.factoring.common.model.message.common.ForceTransferAction;
import com.zllh.factoring.common.model.message.common.OutAction;
import com.zllh.factoring.common.model.message.common.PayMentCallBack;
import com.zllh.factoring.common.model.message.financingrefund.FinRefundList;
import com.zllh.factoring.common.model.message.financingrefund.FinanRefundMessage;
import com.zllh.factoring.common.model.message.guaranteerefund.GuaranteeRefund;
import com.zllh.factoring.common.model.message.guaranteerefund.ResponseMessage;
import com.zllh.factoring.common.model.model_extend.FacFinancingExtendBean;
import com.zllh.factoring.common.model.model_extend.FacFinancingGuaranteeExtendBean;
import com.zllh.factoring.common.model.model_extend.FacGuaranteeBillExtend;
import com.zllh.factoring.common.repayment.RepaymentCalculate;
import com.zllh.factoring.repayment.service.RefundMgService;
import com.zllh.payment.front.service.AcctMgtService;
import com.zllh.payment.server.service.FactoringMsgService;
import com.zllh.utils.base.Utils;
import com.zllh.utils.redis.base.BaseRedisDaoImpl;

/**
 * @ClassName: RefundMgServiceImpl
 * @Description: 还款管理
 * @author JW
 * @date 2015-12-21 上午10:52:45
 */
@Service
public class RefundMgServiceImpl implements RefundMgService {

	@Autowired
	private FacFinancingMapper financingMapper;
	
	@Autowired
	private FacRefundMapper refundMapper;
	
	@Autowired
	private RepaymentCalculate repaymentCalculate;
	
	@Autowired
	private FacFinancingRefundMapper financingRefundMapper;
	
	@Autowired
	private FacFinancingGuaranteeMapper financingGuaranteeMapper;
	
	@Autowired
	private FacGuaranteeBillMapper guaranteeBillMapper;
	
	@Autowired
	private FacGuaranteeRefundMapper guaranteeRefundMapper;
	
	@Autowired
	private FacGuaranteeRefundInterestMapper guaranteeRefundInterestMapper;
	
	@Autowired
	private FacMessageStatusMapper facMessageStatusMapper;
	
	@Autowired
	private FacMessageMapper facMessageMapper;
	
	@Autowired
	private FactoringMsgService factoringMsgService;
	
	@Autowired
	private AccreditationMgService accreditationMgService;
	
	@Autowired
	private AcctMgtService acctMgtService;
	
	@Autowired
	private BaseRedisDaoImpl<String, HashMap<String, Object>> baseRedisDaoImpl;
	
	private final Logger logger = LoggerFactory.getLogger(RefundMgServiceImpl.class); 
	
	@Override
	public Page<FacFinancingExtendBean> selectFinancingRepaymen(String refundDate, String financingId, String refundSource, String status, Integer nowPage) {
		
		Page<FacFinancingExtendBean> page = new Page<FacFinancingExtendBean>();
		page.setNowPage(nowPage);
		UserExtendBean user1 = Utils.securityUtil.getUser();
		String menberId = user1.getMuser().getMmbId();
		HashMap<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("refundStartDate", !"".equals(refundDate)?refundDate.substring(0, 10):"");
		paramMap.put("refundEndDate", !"".equals(refundDate)?refundDate.substring(13, 23):"");
		paramMap.put("financingId", financingId);
		paramMap.put("refundSource", refundSource);
		paramMap.put("status", status);
		paramMap.put("waitingLoan", FinancingEnum.WAITING_LOAN.getValue());
		paramMap.put("accepted", FinancingEnum.ACCEPTED.getValue());
		paramMap.put("facRefunded", FinancingEnum.FAC_REFUNDED.getValue());
		paramMap.put("applyOrganizationId", menberId);
		//查询总条数用于计算页数
		int totalCount = financingMapper.selectFinancingRepaymenCount(paramMap);
		page.setTotalCount(totalCount);
		paramMap.put("beginIndex", page.getBeginIndex());
		paramMap.put("pageSize", page.getPageSize());
		//查询列表信息
		List<FacFinancingExtendBean> finList = financingMapper.selectFinancingRepaymen(paramMap);
		page.setTotalCount(totalCount);
		page.setResult(finList);
		return page;
	}
	
	@Override
	public FacFinancingExtendBean selectFinancingRepaymenByFinId(String financingId){
	    return financingMapper.selectFinancingRepaymenByFinId(financingId);
	}
	
	@Override
	public List<FacGuaranteeBillExtend> selectFinancingRepaymenByGuaId(String guaId){
	    return guaranteeBillMapper.selectlGuaranteeBillAndFinancingByIds(new String[]{guaId});
	}
	
	@Override
	public Page<FacRefund> findRepaymentByFinancingId(String financingId, Integer nowPage) {
		
		Page<FacRefund> page = new Page<FacRefund>();
		page.setNowPage(nowPage);
		HashMap<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("financingId", financingId);
		//查询总条数用于计算页数
		int totalCount = refundMapper.findRepaymentCountByFinancingId(paramMap);
		page.setTotalCount(totalCount);
		paramMap.put("beginIndex", page.getBeginIndex());
		paramMap.put("pageSize", page.getPageSize());
		//查询列表信息
		List<FacRefund> refuList = refundMapper.findRepaymentByFinancingId(paramMap);
		page.setTotalCount(totalCount);
		page.setResult(refuList);
		return page;
	}
	
	/**
	 * 担保还款
	 */
	@Override
	public void disposeGuaranteeRefund(String json) {
		
		//保存报文
		FacMessageStatus mess = new FacMessageStatus();
		mess.setId(Utils.commonUtil.getUUID());
		mess.setMessage(json);
		mess.setCreatetime(new Date());
		mess.setStatus(MessageStatus.ERR.getValue());
		
		facMessageStatusMapper.insertSelective(mess);
		executeGuaranteeRefund(mess);
	}
	
	/**
	 * @Title: executeGuaranteeRefund 
	 * @author JW
	 * @Description: 担保还款
	 * @param xml
	 * @return HashMap<String,Object>
	 * @throws
	 */
	@Override
	@SuppressWarnings("unchecked")
	public void executeGuaranteeRefund(FacMessageStatus mess) {
		
		//JSON转化成实体
		ResponseMessage reMess = Utils.objUtil.JSONToObj(mess.getMessage(), ResponseMessage.class);
		if(reMess==null) return;
		
		//key:担保单Id, value: 还款金额
		HashMap<String, BigDecimal> refundMap = new HashMap<String, BigDecimal>();
		//本次还款总额
		BigDecimal refundTotal = BigDecimal.ZERO;
		String[] dbIds = new String[reMess.getList().size()];
		for(int i=0;i<reMess.getList().size();i++){
			GuaranteeRefund re = reMess.getList().get(i);
			dbIds[i] = re.getGuaranteereId();
			refundTotal = refundTotal.add(re.getRefundAmount());
			if((re.getRefundAmount().compareTo(BigDecimal.ZERO)==1)){
				refundMap.put(re.getGuaranteereId(), re.getRefundAmount());
			}else{
				logger.info("担保单【"+re.getGuaranteereId()+"】还款金额错误:为0或者小于0!");
				return;
			}
		}
		
		//根据担保单ID查询出 担保单，所被使用的融资单及关联信息
		List<FacGuaranteeBillExtend> facgs = guaranteeBillMapper.selectlGuaranteeBillAndFinancingByIds(dbIds);
		
		//校验担保单融资单id锁
		Set<String> ids = getIds(facgs);
		String[] fingIds = new String[ids.size()];
		for(int i=0;i<ids.size();i++){
			fingIds[i] = ids.iterator().next();
		}
		
		//判断是否有错误的单号
		if(facgs==null||facgs.size()!=dbIds.length){
			String err = "";
			if(facgs==null){
				for(String errId : dbIds){
					err += "【"+errId+"】";
				}
			}else{
				for(String errId : dbIds){
					if(!ids.contains(errId)){
						err += "【"+errId+"】";
					}
				}
			}
			logger.error("结款单"+err+"不存在!");
		}
		
		boolean bool = Utils.lock.thingLockByIds(fingIds);
		if(!bool) return;
		
		//还款单Id
		String refundId = Utils.commonUtil.getUUID();
		//创建还款流水号
//		String serialNumber = Utils.commonUtil.getSerialNumber();
		
		//有融资单未还的单子
		List<FacGuaranteeBillExtend> nofacList = new ArrayList<FacGuaranteeBillExtend>();
		//没有融资或者融资单已全部还清的单子
		List<FacGuaranteeBillExtend> facList = new ArrayList<FacGuaranteeBillExtend>();
		//循环担保单
		for(FacGuaranteeBillExtend facgua : facgs){
			//担保单融资单关系
			List<FacFinancingGuaranteeExtendBean> fings = facgua.getFings();
			//如果关系为null那么说明该担保单没被融资过
			if(fings!=null&&fings.size()>0){
				boolean boolfac = true;
				//循环担保融资关系
				for(FacFinancingGuaranteeExtendBean fing :fings){
					//如果其中有一个关系是给付金额不等于还款金额说明该担保单还有未还款的融资单否则就是已经全部还清了
					if(fing.getPaymentsAmount()!=fing.getRefundAmount()) boolfac = false;
				}
				if(boolfac){
					facList.add(facgua);
				}else{
					nofacList.add(facgua);
				}
			}else{
				facList.add(facgua);
			}
		}
		
		boolean bo = true;
		//组织报文所用的实体
		List<HashMap<String, Object>> finRefundListMap = new ArrayList<HashMap<String, Object>>();
		HashMap<String, Object> paramMap = new HashMap<String, Object>();
		try{
			
			if(nofacList.size()>0){
				HashMap<String, Object> reMap = executeGuaranteeRefund(finRefundListMap, nofacList, refundMap, refundId);
				if(reMap!=null&&reMap.size()>0){
					finRefundListMap = (List<HashMap<String, Object>>) reMap.get("finRefundListMap");
					paramMap = (HashMap<String, Object>) reMap.get("paramMap");
				}
			}
			
			if(facList.size()>0){
				List<HashMap<String, Object>> actionList = new ArrayList<HashMap<String,Object>>();
				FinRefundList finRefund = null;
				for(FacGuaranteeBillExtend guaBill : facList){
					
					BigDecimal redecimal = refundMap.get(guaBill.getGuaranteeId());
					finRefund = refundGuaMessage(guaBill, redecimal, actionList);
					if(finRefund!=null){
						finRefundListMap.add(Utils.objUtil.beanToMap(finRefund));
						FacGuaranteeBill bill = new FacGuaranteeBill();
						bill.setGuaranteeId(guaBill.getGuaranteeId());
						bill.setPaymentAmount(guaBill.getPaymentAmount().add(redecimal));
						bill.setNonPayAmount(guaBill.getNonPayAmount().subtract(redecimal));
						bill.setUsableAmount(guaBill.getUsableAmount().subtract(redecimal));
						bill.setLock(guaBill.getLock());
						//更新担保单的可用金额， 已支付金额等
						if(paramMap.size()>0){
							List<FacGuaranteeBill> facGuaranteeBills = (List<FacGuaranteeBill>) paramMap.get("FacGuaranteeBill");
							facGuaranteeBills.add(bill);
							paramMap.put("FacGuaranteeBill", facGuaranteeBills);
						}else{
							List<FacGuaranteeBill> facGuaranteeBills = new ArrayList<FacGuaranteeBill>();
							facGuaranteeBills.add(bill);
							paramMap.put("FacGuaranteeBill", facGuaranteeBills);
						}
					}
				}
			}
			
			//移除ID锁
			Utils.lock.deblocking(fingIds);
			
		}catch(Exception e){
			e.printStackTrace();
			bo = false;
			throw new RuntimeException();
		}finally{
			//移除ID锁
			Utils.lock.deblocking(fingIds);
		}
		
		if(bo){
//			//判断是否需要处理的报文
//			if(finRefundListMap!=null&&finRefundListMap.size()>0){
//				//发送支付报文
//				boolean resultBool = sendMessage(finRefundListMap, "all", "system", serialNumber);
//				if(!resultBool) {
//					logger.error("担保还款支付处理失败！");
//					throw new RuntimeException("担保还款支付处理失败！");
//				}else{
//					
//					//往redis插入计算的结果用于支付回调保存到数据库
//					baseRedisDaoImpl.addMap(serialNumber, paramMap);
//					//保存还款单
//					saveFacRefund(refundTotal, refundId, "system", "system", SourceEnum.MALL.getValue(), serialNumber);
//					//更新报文状态
//					mess.setStatus(MessageStatus.SUCC.getValue());
//					facMessageStatusMapper.updateByPrimaryKeySelective(mess);
//				}
//			}
		}
	}
	
	/**
     * @Title: executeGuaranteeRefund 
     * @author JW
     * @Description: 担保还款(财务版)
     * @param xml
     * @return HashMap<String,Object>
     * @throws
     */
    @SuppressWarnings("unchecked")
    public HashMap<String, Object> executeGuaranteeRefund(String guaranteereId, String refundAmount) {
        
        //key:担保单Id, value: 还款金额
        HashMap<String, BigDecimal> refundMap = new HashMap<String, BigDecimal>();
        refundMap.put(guaranteereId, new BigDecimal(refundAmount));
        
        //本次还款总额
        BigDecimal refundTotal = new BigDecimal(refundAmount);
        String[] dbIds = new String[]{guaranteereId};
        
        //根据担保单ID查询出 担保单，所被使用的融资单及关联信息
        List<FacGuaranteeBillExtend> facgs = guaranteeBillMapper.selectlGuaranteeBillAndFinancingByIds(dbIds);
        
        //校验担保单融资单id锁
        Set<String> ids = getIds(facgs);
        String[] fingIds = new String[ids.size()];
        for(int i=0;i<ids.size();i++){
            fingIds[i] = ids.iterator().next();
        }
        
        //判断是否有错误的单号
        if(facgs==null||facgs.size()!=dbIds.length){
            String err = "";
            if(facgs==null){
                for(String errId : dbIds){
                    err += "【"+errId+"】";
                }
            }else{
                for(String errId : dbIds){
                    if(!ids.contains(errId)){
                        err += "【"+errId+"】";
                    }
                }
            }
            logger.error("结款单"+err+"不存在!");
        }
        
        boolean bool = Utils.lock.thingLockByIds(fingIds);
        if(!bool) return null;
        
        //还款单Id
        String refundId = Utils.commonUtil.getUUID();
        //创建还款流水号
        String serialNumber = Utils.commonUtil.getSerialNumber();
        
        //有融资单未还的单子
        List<FacGuaranteeBillExtend> nofacList = new ArrayList<FacGuaranteeBillExtend>();
        //没有融资或者融资单已全部还清的单子
        List<FacGuaranteeBillExtend> facList = new ArrayList<FacGuaranteeBillExtend>();
        //循环担保单
        for(FacGuaranteeBillExtend facgua : facgs){
            //担保单融资单关系
            List<FacFinancingGuaranteeExtendBean> fings = facgua.getFings();
            //如果关系为null那么说明该担保单没被融资过
            if(fings!=null&&fings.size()>0){
                boolean boolfac = true;
                //循环担保融资关系
                for(FacFinancingGuaranteeExtendBean fing :fings){
                    //如果其中有一个关系是给付金额不等于还款金额说明该担保单还有未还款的融资单否则就是已经全部还清了
                    if(fing.getPaymentsAmount()!=fing.getRefundAmount()) boolfac = false;
                }
                if(boolfac){
                    facList.add(facgua);
                }else{
                    nofacList.add(facgua);
                }
            }else{
                facList.add(facgua);
            }
        }
        
        //组织报文所用的实体
        List<HashMap<String, Object>> finRefundListMap = new ArrayList<HashMap<String, Object>>();
        HashMap<String, Object> paramMap = new HashMap<String, Object>();
        try{
            
            if(nofacList.size()>0){
                HashMap<String, Object> reMap = executeGuaranteeRefund(finRefundListMap, nofacList, refundMap, refundId);
                if(reMap!=null&&reMap.size()>0){
                    finRefundListMap = (List<HashMap<String, Object>>) reMap.get("finRefundListMap");
                    paramMap = (HashMap<String, Object>) reMap.get("paramMap");
                }
            }
            
            if(facList.size()>0){
                List<HashMap<String, Object>> actionList = new ArrayList<HashMap<String,Object>>();
                FinRefundList finRefund = null;
                for(FacGuaranteeBillExtend guaBill : facList){
                    
                    BigDecimal redecimal = refundMap.get(guaBill.getGuaranteeId());
                    finRefund = refundGuaMessage(guaBill, redecimal, actionList);
                    if(finRefund!=null){
                        finRefundListMap.add(Utils.objUtil.beanToMap(finRefund));
                        FacGuaranteeBill bill = new FacGuaranteeBill();
                        bill.setGuaranteeId(guaBill.getGuaranteeId());
                        bill.setPaymentAmount(guaBill.getPaymentAmount().add(redecimal));
                        bill.setNonPayAmount(guaBill.getNonPayAmount().subtract(redecimal));
                        bill.setUsableAmount(guaBill.getUsableAmount().subtract(redecimal));
                        bill.setLock(guaBill.getLock());
                        //更新担保单的可用金额， 已支付金额等
                        if(paramMap.size()>0){
                            List<FacGuaranteeBill> facGuaranteeBills = (List<FacGuaranteeBill>) paramMap.get("FacGuaranteeBill");
                            facGuaranteeBills.add(bill);
                            paramMap.put("FacGuaranteeBill", facGuaranteeBills);
                        }else{
                            List<FacGuaranteeBill> facGuaranteeBills = new ArrayList<FacGuaranteeBill>();
                            facGuaranteeBills.add(bill);
                            paramMap.put("FacGuaranteeBill", facGuaranteeBills);
                        }
                    }
                }
            }
            
            //移除ID锁
            Utils.lock.deblocking(fingIds);
            
        }catch(Exception e){
            e.printStackTrace();
            throw new RuntimeException();
        }finally{
            //移除ID锁
            Utils.lock.deblocking(fingIds);
        }
        
        HashMap<String, Object> reMap = new HashMap<String, Object>();
        //判断是否需要处理的报文
        if(finRefundListMap!=null&&finRefundListMap.size()>0){
            
            FacRefund refund = saveFacRefund(refundTotal, refundId, "system", "system", SourceEnum.MALL.getValue(), serialNumber);
            //发送支付报文
            String rel = sendMessage(finRefundListMap, "all", "system", serialNumber);
            //插入还款单表
            
            reMap.put("refund", refund);
            reMap.put("paraMap", paramMap);
            reMap.put("rel", rel);
        }
        
        return reMap;
    }

	/**
	 * @Title: lockFinsAndDbTran 
	 * @author JW
	 * @Description: 获取Ids
	 * @param facgs
	 * @return List<String>
	 * @throws
	 */
	public Set<String> getIds(List<FacGuaranteeBillExtend> facgs){
		
		Set<String> idset = new HashSet<String>();
		
		//担保单融资单Id
		for(FacGuaranteeBillExtend gua : facgs){
			idset.add(gua.getGuaranteeId());
			List<FacFinancingGuaranteeExtendBean> fings = gua.getFings();
			FacFinancingExtendBean fin = null;
			for(FacFinancingGuaranteeExtendBean guaFinc : fings){
			    fin = guaFinc.getFacFinancing();
			    if(fin!=null) idset.add(fin.getFinancingId());
			}
		}

		return idset;
	}
	
	/**
	 * @Title: executeGuaranteeRefund 
	 * @author JW
	 * @Description: 担保还款处理
	 * @param finRefundListMap
	 * @param facgs
	 * @param refundMap
	 * @param refundId
	 * @return List<HashMap<String,Object>>
	 * @throws
	 */
	@SuppressWarnings("unchecked")
	public HashMap<String, Object> executeGuaranteeRefund(List<HashMap<String, Object>> finRefundListMap, List<FacGuaranteeBillExtend> facgs, 
			HashMap<String, BigDecimal> refundMap, String refundId){
		
		HashMap<String, Object> resultMap = new HashMap<String, Object>();
		HashMap<String, Object> paramMap = new HashMap<String, Object>();
		//更新融资单实体集合
		List<FacFinancing> fins = new ArrayList<FacFinancing>();
		//更新担保单实体集合
		List<FacGuaranteeBill> facGuaranteeBills = new ArrayList<FacGuaranteeBill>();
		//更新担保还款实体集合
		List<FacGuaranteeRefund> facGuaranteeRefunds = new ArrayList<FacGuaranteeRefund>();
		//更新担保单担保金额的实体集合
		List<FacFinancingGuarantee> financingGuaranteeList = new ArrayList<FacFinancingGuarantee>();
		//担保还款利息实体集合
		List<FacGuaranteeRefundInterest> guaranteeRefundInterestList = new ArrayList<FacGuaranteeRefundInterest>();

		for(FacGuaranteeBillExtend facg : facgs){

			//此次此担保单还款总金额
			BigDecimal redecimal = refundMap.get(facg.getGuaranteeId());
			
			//本次该担保单还本总额
			BigDecimal principalAll = BigDecimal.ZERO;
			//本次该担保单还息总额
			BigDecimal interestAll = BigDecimal.ZERO;
			
			//担保单还款实体
			FacGuaranteeRefund guaRe = new FacGuaranteeRefund();
			String guaranteeRefundId = Utils.commonUtil.getUUID();
			guaRe.setGuaranteeRefundId(guaranteeRefundId);
			
			//担保单实体(用于更新可用金额，已支付金额，未支付金额)
			FacGuaranteeBill guab = new FacGuaranteeBill();
			guab.setGuaranteeId(facg.getGuaranteeId());
			guab.setPaymentAmount(facg.getPaymentAmount().add(redecimal));
			guab.setNonPayAmount(facg.getNonPayAmount().subtract(redecimal));
			
			//本次还款释放的冻结金额
			BigDecimal usableAmount = BigDecimal.ZERO;

			//报文action节点集合
			List<HashMap<String, Object>> actionList = new ArrayList<HashMap<String,Object>>();
			
			//循环当前担保单所担保的融资单关联信息
			for(FacFinancingGuaranteeExtendBean finGua : facg.getFings()){
				
				//处理单个融资单
				//融资单
				FacFinancingExtendBean fin = finGua.getFacFinancing();
				
				//还款只还【待放款】【和已认可的融资单】
				if(fin.getStatus()!=FinancingEnum.ACCEPTED.getValue()&&fin.getStatus()!=FinancingEnum.WAITING_LOAN.getValue()) continue;
				
				//还本金额(算出本次还款金额里用多少来还本金)
				BigDecimal principal = repaymentCalculate.repaymentCalculate(redecimal, fin.getAcceptDate(), fin.getExpireRate());
				
				//根据给付金额计算利息
				BigDecimal lixi = repaymentCalculate.guaranteeInterest(finGua.getSurplusPaymentsAmount(), fin.getAcceptDate(), fin.getExpireRate(), fin.getExtendRate());
				
				//本息(当前融资单所用担保单的本金及截止日期的利息)
				BigDecimal benxi = finGua.getSurplusPaymentsAmount().add(lixi);
				
				BigDecimal dongjie = finGua.getSurplusFreezeAmount();
				
				//如果待还金额大于冻结金额（意味着拖欠太久，意外累计利息太高） 此担保-融资关系表记录上记下超出部分，写到超欠字段  跳过此融资项目不处理(type:1正常还款, 2:超欠还款)
				if((benxi.compareTo(dongjie)==1||benxi.compareTo(dongjie)==0)) {
					//超欠处理(当前融资单)
					overtopArrearage(finGua);
					continue;
				}
				
				//如果剩余给付金额为0 说明已经还过则处理下一条
				if(finGua.getSurplusPaymentsAmount().compareTo(BigDecimal.ZERO)==0) continue;
				
				//当前还本金额
				BigDecimal ben = BigDecimal.ZERO;
				//当前还息金额
				BigDecimal xi = BigDecimal.ZERO;
				
				//更新融资单所用实体
				FacFinancing fac = new FacFinancing();
				
				//剩余给付金额
				BigDecimal jifu = finGua.getSurplusPaymentsAmount();
				//如果还款金额(还本金额)大于或等于待还款金额(还息金额)则能还完全部待还金额
				if(principal.compareTo(jifu)==1||principal.compareTo(jifu)==0){
					FacFinancingGuarantee financingGuarantee = new FacFinancingGuarantee();
					financingGuarantee.setId(finGua.getId());
					financingGuarantee.setRefundAmount(finGua.getRefundAmount().add(jifu));
					financingGuarantee.setSurplusPaymentsAmount(jifu.subtract(jifu));
					//还款后剩余所需的冻结金额
					BigDecimal freezeAmount = repaymentCalculate.calculateFreezeAmount(jifu.subtract(jifu));
					//本次还款后释放的冻结金额
					usableAmount =  usableAmount.add(finGua.getSurplusFreezeAmount().subtract(freezeAmount));
					financingGuarantee.setSurplusFreezeAmount(freezeAmount);
					financingGuaranteeList.add(financingGuarantee);
					
					//计算还本总额
					principalAll = principalAll.add(jifu);
					//计算还息总额
					interestAll = interestAll.add(lixi);
					//本次的还本
					ben = jifu;
					//本次还息
					xi = lixi;
					//扣除的金额(包含利息)
					redecimal = redecimal.subtract(benxi);
					//还款金额大于融资金额说明能还完该融资单修改状态为已还款
					fac.setStatus(FinancingEnum.FAC_REFUNDED.getValue());
					
				}else{
					
					FacFinancingGuarantee financingGuarantee = new FacFinancingGuarantee();
					financingGuarantee.setId(finGua.getId());
					financingGuarantee.setRefundAmount(finGua.getRefundAmount().add(principal));
					financingGuarantee.setSurplusPaymentsAmount(jifu.subtract(principal));
					//还款后剩余所需的冻结金额
					BigDecimal freezeAmount = repaymentCalculate.calculateFreezeAmount(jifu.subtract(principal));
					//本次还款后释放的冻结金额
					usableAmount =  usableAmount.add(finGua.getSurplusFreezeAmount().subtract(freezeAmount));
					financingGuarantee.setSurplusFreezeAmount(freezeAmount);
					financingGuaranteeList.add(financingGuarantee);
					
					//计算还本总额
					principalAll = principalAll.add(principal);
					//计算还息总额
					interestAll = interestAll.add(repaymentCalculate.repaymentInterest(redecimal, fin.getAcceptDate(), fin.getExpireRate()));
					//本次的还本
					ben = principal;
					//本次还息
					xi = repaymentCalculate.repaymentInterest(redecimal, fin.getAcceptDate(), fin.getExpireRate());
					redecimal = redecimal.subtract(redecimal);
				}
					
				FacGuaranteeRefundInterest guaReIn = new FacGuaranteeRefundInterest();
				guaReIn.setId(Utils.commonUtil.getUUID());
				guaReIn.setFinancingId(fin.getFinancingId());
				guaReIn.setGuaranteeId(finGua.getGuaranteeId());
				guaReIn.setGuaranteeRefundId(guaranteeRefundId);
				guaReIn.setRefundInterest(xi);
				guaReIn.setRefundPrincipal(ben);
				guaranteeRefundInterestList.add(guaReIn);
				
				fac.setId(fin.getId());
				fac.setLock(fin.getLock());
				fac.setSttLastRefundId(refundId);
				fac.setSttLastRefundData(new Date());
				fins.add(fac);
				//生成还本还息报文
				actionList = refundGuaBenXiMessage(fin, ben, xi, actionList);
				
				if(redecimal.compareTo(BigDecimal.ZERO)==0) break;
			}
			
			//超欠还款
			if(redecimal.compareTo(BigDecimal.ZERO)==1){
				
				HashMap<String, Object> reMap = exceedRefundCalculate(facg.getPayeeId(), redecimal, usableAmount, financingGuaranteeList, principalAll, interestAll, actionList,
						guaRe.getGuaranteeRefundId(), guaranteeRefundInterestList, fins, refundId);
				
				if(reMap!=null&&reMap.size()>0){
					redecimal = (BigDecimal) reMap.get("redecimal");
					usableAmount = (BigDecimal) reMap.get("usableAmount");
					financingGuaranteeList = (List<FacFinancingGuarantee>) reMap.get("financingGuaranteeList");
					principalAll = (BigDecimal) reMap.get("principalAll");
					interestAll = (BigDecimal) reMap.get("interestAll");
					actionList = (List<HashMap<String, Object>>) reMap.get("actionList");
					guaranteeRefundInterestList = (List<FacGuaranteeRefundInterest>) reMap.get("guaranteeRefundInterestList");
					fins = (List<FacFinancing>) reMap.get("fins");
				}
			}
			
			//拼接报文
			FinRefundList finRefundList = refundGuaMessage(facg, redecimal, actionList);
			
			//如果finRefundList报文集合为null说明没有还款的操作不用做数据库操作,处理下一条结款单
			if(finRefundList==null) continue;
			
			finRefundListMap.add(Utils.objUtil.beanToMap(finRefundList));
			
			guaRe.setRefundId(refundId);
			guaRe.setGuaranteeId(facg.getGuaranteeId());
			guaRe.setGuaranteeRefundAmount(refundMap.get(facg.getGuaranteeId()));
			guaRe.setRefundBalance(redecimal);
			guaRe.setRefundDate(new Date());
			guaRe.setRefundPrincipalTotal(principalAll);
			guaRe.setRefundInterestTotal(interestAll);
			
			//插入担保还款
			facGuaranteeRefunds.add(guaRe);
			//更新担保单乐观锁
			guab.setLock(facg.getLock());
			guab.setUsableAmount(facg.getUsableAmount().add(usableAmount));
			facGuaranteeBills.add(guab);
			
		}
		
		paramMap.put("FacFinancing", fins);
		paramMap.put("FacGuaranteeBill", facGuaranteeBills);
		paramMap.put("FacGuaranteeRefund", facGuaranteeRefunds);
		paramMap.put("FacFinancingGuarantee", financingGuaranteeList);
		paramMap.put("FacGuaranteeRefundInterest", guaranteeRefundInterestList);
		resultMap.put("finRefundListMap", finRefundListMap);
		resultMap.put("paramMap", paramMap);
		
		return resultMap;
	}
	
	/**
	 * @Title: exceedRefundCalculate 
	 * @author JW
	 * @Description: 超欠计算
	 * @param payeeId
	 * @param redecimal
	 * @param usableAmount
	 * @param financingGuaranteeList
	 * @param principalAll
	 * @param interestAll
	 * @param actionList
	 * @param guaranteeRefundId
	 * @param guaranteeRefundInterestList
	 * @param fins
	 * @return HashMap<String,Object>
	 * @throws
	 */
	public HashMap<String, Object> exceedRefundCalculate(String payeeId, BigDecimal redecimal, BigDecimal usableAmount, 
			List<FacFinancingGuarantee> financingGuaranteeList, BigDecimal principalAll, BigDecimal interestAll, List<HashMap<String, Object>> actionList,
			String guaranteeRefundId, List<FacGuaranteeRefundInterest> guaranteeRefundInterestList, List<FacFinancing> fins, String refundId){
		
		HashMap<String, Object> resMap = new HashMap<String, Object>();
		HashMap<String, Object> paraMap = new HashMap<String, Object>();
		paraMap.put("payeeId", payeeId);
		paraMap.put("status", FinancingGuaranteeEnum.CHAOQIAN.getValue());
		
		List<FacFinancingGuaranteeExtendBean> finGugas = financingGuaranteeMapper.selectFinGuaByPayeeId(paraMap);
		
		if(finGugas==null||finGugas.size()==0) return null;
		
		//循环当前担保单所担保的融资单关联信息
		for(FacFinancingGuaranteeExtendBean finGua : finGugas){
			
			//融资单
			FacFinancingExtendBean fin = finGua.getFacFinancing();
			
			//还款只还【待放款】【和已认可的融资单】
			if(fin.getStatus()!=FinancingEnum.ACCEPTED.getValue()&&fin.getStatus()!=FinancingEnum.WAITING_LOAN.getValue()) continue;
			
			//还本金额(算出本次还款金额里用多少来还本金)
			BigDecimal principal = repaymentCalculate.repaymentCalculate(redecimal, fin.getAcceptDate(), fin.getExpireRate());
			
			//根据给付金额计算利息
			BigDecimal lixi = repaymentCalculate.guaranteeInterest(finGua.getSurplusPaymentsAmount(), fin.getAcceptDate(), fin.getExpireRate(), fin.getExtendRate());
			
			//本息(当前融资单所用担保单的本金及截止日期的利息)
			BigDecimal benxi = finGua.getSurplusPaymentsAmount().add(lixi);
			
			//如果剩余给付金额为0 说明已经还过则处理下一条
			if(finGua.getSurplusPaymentsAmount().compareTo(BigDecimal.ZERO)==0) continue;
			
			//当前还本金额
			BigDecimal ben = BigDecimal.ZERO;
			//当前还息金额
			BigDecimal xi = BigDecimal.ZERO;
			
			//更新融资单所用实体
			FacFinancing fac = new FacFinancing();
			
			//剩余给付金额
			BigDecimal jifu = finGua.getSurplusPaymentsAmount();
			//如果还款金额(还本金额)大于或等于待还款金额(还息金额)则能还完全部待还金额
			if(principal.compareTo(jifu)==1||principal.compareTo(jifu)==0){
				FacFinancingGuarantee financingGuarantee = new FacFinancingGuarantee();
				financingGuarantee.setId(finGua.getId());
				financingGuarantee.setRefundAmount(finGua.getRefundAmount().add(jifu));
				financingGuarantee.setSurplusPaymentsAmount(jifu.subtract(jifu));
				//还款后剩余所需的冻结金额
				BigDecimal freezeAmount = repaymentCalculate.calculateFreezeAmount(jifu.subtract(jifu));
				//本次还款后释放的冻结金额
				usableAmount =  usableAmount.add(finGua.getSurplusFreezeAmount().subtract(freezeAmount));
				financingGuarantee.setSurplusFreezeAmount(freezeAmount);
				financingGuaranteeList.add(financingGuarantee);
				
				//计算还本总额
				principalAll = principalAll.add(jifu);
				//计算还息总额
				interestAll = interestAll.add(lixi);
				//本次的还本
				ben = jifu;
				//本次还息
				xi = lixi;
				//扣除的金额(包含利息)
				redecimal = redecimal.subtract(benxi);
				//还款金额大于融资金额说明能还完该融资单修改状态为已还款
				fac.setStatus(FinancingEnum.FAC_REFUNDED.getValue());
				
			}else{
				
				FacFinancingGuarantee financingGuarantee = new FacFinancingGuarantee();
				financingGuarantee.setId(finGua.getId());
				financingGuarantee.setRefundAmount(finGua.getRefundAmount().add(principal));
				financingGuarantee.setSurplusPaymentsAmount(jifu.subtract(principal));
				//还款后剩余所需的冻结金额
				BigDecimal freezeAmount = repaymentCalculate.calculateFreezeAmount(jifu.subtract(principal));
				//本次还款后释放的冻结金额
				usableAmount =  usableAmount.add(finGua.getSurplusFreezeAmount().subtract(freezeAmount));
				financingGuarantee.setSurplusFreezeAmount(freezeAmount);
				financingGuaranteeList.add(financingGuarantee);
				
				//计算还本总额
				principalAll = principalAll.add(principal);
				//计算还息总额
				interestAll = interestAll.add(repaymentCalculate.repaymentInterest(redecimal, fin.getAcceptDate(), fin.getExpireRate()));
				//本次的还本
				ben = principal;
				//本次还息
				xi = repaymentCalculate.repaymentInterest(redecimal, fin.getAcceptDate(), fin.getExpireRate());
				redecimal = redecimal.subtract(redecimal);
			}
				
			FacGuaranteeRefundInterest guaReIn = new FacGuaranteeRefundInterest();
			guaReIn.setId(Utils.commonUtil.getUUID());
			guaReIn.setFinancingId(fin.getFinancingId());
			guaReIn.setGuaranteeId(finGua.getGuaranteeId());
			guaReIn.setGuaranteeRefundId(guaranteeRefundId);
			guaReIn.setRefundInterest(xi);
			guaReIn.setRefundPrincipal(ben);
			guaranteeRefundInterestList.add(guaReIn);
			
			fac.setId(fin.getId());
			fac.setSttLastRefundId(refundId);
			fac.setSttLastRefundData(new Date());
			fins.add(fac);
			//生成还本还息报文
			actionList = refundGuaBenXiMessage(fin, ben, xi, actionList);
			
			if(redecimal.compareTo(BigDecimal.ZERO)==0) break;
		}
		
		resMap.put("redecimal", redecimal);
		resMap.put("usableAmount", usableAmount);
		resMap.put("financingGuaranteeList", financingGuaranteeList);
		resMap.put("principalAll", principalAll);
		resMap.put("interestAll", interestAll);
		resMap.put("actionList", actionList);
		resMap.put("guaranteeRefundInterestList", guaranteeRefundInterestList);
		resMap.put("fins", fins);
		
		return resMap;
	}
	
	/**
	 * @Title: refundGuaMessage 
	 * @author JW
	 * @Description: 担保还款余款退回报文
	 * @param facg
	 * @param recont
	 * @param actionList
	 * @return FinRefundList
	 * @throws
	 */
	public FinRefundList refundGuaMessage(FacGuaranteeBillExtend facg , BigDecimal recont, List<HashMap<String, Object>> actionList){
		//如果还款还剩余额则退回给供应商一般户
		if(recont.compareTo(BigDecimal.ZERO)==1){
			OutAction outAction = new OutAction();
			outAction.setCode(PayTypeCode.ZLFNDOUT.getValue());
			outAction.setUserName("zhonglianlianhe");
			outAction.setClientID(Utils.commonUtil.getSerialNumber());
			outAction.setAccountNo(facg.getBlocAccount());
			outAction.setPayAccNo(facg.getDistributorTheoreticalBank());
			outAction.setRecvAccNo(facg.getDistributorGeneralBank());
			outAction.setRecvAccNm(facg.getDistributorName());
			outAction.setTranAmt(String.format("%.2f", recont.doubleValue()));
			outAction.setSameBank(SameBank.BENHANG.getValue());
			outAction.setRecvTgfi("");
			outAction.setRecvBankNm("");
			outAction.setMemo("融资还款余款退回");
			outAction.setPreFlg('0');
			outAction.setPreDate('0');
			outAction.setPreTime('0');
			actionList.add(Utils.objUtil.beanToMap(outAction));
		}
		
		FinRefundList finRefund = null;
		if(actionList!=null&&actionList.size()>0){
			finRefund = new FinRefundList();
			finRefund.setFlowID(Utils.commonUtil.getSerialNumber());
			finRefund.setAction(actionList);
		}
		
		return finRefund;
	}
	
	/**
	 * @Title: refundGuaMessage 
	 * @author JW
	 * @Description: 生成担保还款本息还款报文
	 * @param facFinancingExtendBean
	 * @param ben
	 * @param xi
	 * @param actionList
	 * @return List<HashMap<String,Object>>
	 * @throws
	 */
	public List<HashMap<String, Object>> refundGuaBenXiMessage(FacFinancingExtendBean facFinancingExtendBean, 
			BigDecimal ben, BigDecimal xi, List<HashMap<String, Object>> actionList){
		
		List<HashMap<String, Object>> actionListto = benXiMessageEntity(facFinancingExtendBean, ben, xi);
		for(HashMap<String, Object> actionMap : actionListto){
			actionList.add(actionMap);
		}
		
		return actionList;
	}
	
	/**
	 * @Title: saveFacRefund 
	 * @author JW
	 * @Description: 保存还款信息
	 * @param refund void
	 * @throws
	 */
	private FacRefund saveFacRefund(BigDecimal refundTotal, String refundId, String userId, String userName, String source, String serialNumber) {
		
		FacRefund refund = new FacRefund();
		refund.setRefundId(refundId);
		refund.setRefundOrderNum(serialNumber);
		refund.setRefundAmount(refundTotal);
		refund.setRefundSource(source);
		refund.setRefundAccount("还款账号");
		refund.setRefundPerson("还款人");
		refund.setRefundDate(new Date());
		refund.setPayeeId("");
		refund.setPayeeName("");
		refund.setPayeeAccount("");
		refund.setPayerId("融资申请方id");
		refund.setPayerName("融资申请方名称");
		refund.setPaymentAccount("融资申请方账号");
		refund.setOperatorId(userId);
		refund.setOperatorName(userName);
		refund.setStatus(RefundEnum.WAITING_BALANCE.getValue());
		
//		refundMapper.insertSelective(refund);
		
		return refund;
	}	

	/**
	 * 融资还款
	 * 计算过程(单个融资单):
	 * 融资金额: 100		             担保金额(利息)； 60(10) 40(8) 
	 * 本次还款: 100
	 * 计算还本金额(4:1) : 80    还息金额:20
	 * 对比还本金额和担保金额: 80 > 60      可以全部还: 100-(60+10)=30    本次的还本是60，还息是10  
	 * 拿30重新计算还本还息金额(4:1):  还本: 24  还息:6
	 * 对比还本金额和担保金额: 30<40            只能部分还: 40-24=16                      本次的还本是24，还息是6, 未还:16  
	 */
//	@Override
//	public HashMap<String, Object> executeFinancingRefund(String financingId,  String lockFinjJson, String lockGuajJson, String repaymentJson) {
//		
//		//前台选择的融资单id
//		String[] financingIds = financingId.trim().split(",");
//		//返回信息Map
//		HashMap<String, Object> resMap = new HashMap<String, Object>();
//		//前台融资还款金额
//		JSONObject jsons = JSONObject.fromObject(repaymentJson);
//		
//		//通过融资单号查询出对象(担保单融资单及关系一起查询出来)
//		List<FacFinancingExtendBean> fins = financingMapper.findFinancingAndGuaranteeListByFinIds(financingIds);
//		
//		if(fins==null||fins.size()==0){
//			for(String finId : financingIds){
//				resMap.put(finId, "融资还款失败！");
//			}
//			logger.error("融资单不存在！");
//			return resMap;
//		}
//		
//		//更新融资单实体集合
//		List<FacFinancing> facFinancingList = new ArrayList<FacFinancing>();
//		//更新担保单实体集合
//		List<FacGuaranteeBill> facGuaranteeBillList = new ArrayList<FacGuaranteeBill>();
//		//更新担保还款实体集合
//		List<FacFinancingRefund> facFinancingRefundList = new ArrayList<FacFinancingRefund>();
//		//更新担保单担保金额的实体集合
//		List<FacFinancingGuarantee> financingGuaranteeList = new ArrayList<FacFinancingGuarantee>();
//		//创建还款流水号
//		String serialNumber = Utils.commonUtil.getSerialNumber();
//		//创建还款id
//		String refundId = Utils.commonUtil.getUUID();
//		//本次还款总额
//		BigDecimal totalRefund = BigDecimal.ZERO;
//		//本次还款还本总额
//		BigDecimal totalPrincipal = BigDecimal.ZERO;
//		//本次还款还息总额
//		BigDecimal totalInterest = BigDecimal.ZERO;
//		
//		//组织报文所用的实体
//		List<HashMap<String, Object>> finRefundListMap = new ArrayList<HashMap<String, Object>>();
//		//redis存储数据库操作的信息Map用于支付回调处理数据库
//		HashMap<String, Object> paraMap = new HashMap<String, Object>();
//		
//		FinRefundList finRefund = null;
//		for(FacFinancingExtendBean facFinancingExtendBean : fins){
//
//			try{
//				//判断融资单Id锁及乐观锁
//				boolean bool = Utils.lock.lockByFin(facFinancingExtendBean, lockFinjJson, lockGuajJson);
//				
//				if(!bool){
//					resMap.put(facFinancingExtendBean.getFinancingId(), "系统繁忙请稍后再试！");
//					logger.error("融资单【"+facFinancingExtendBean.getFinancingId()+"】锁失败！");
//					continue;
//				}
//				
//				//当前融资单总还款金额
//				BigDecimal recont = new BigDecimal(Double.parseDouble(jsons.get(facFinancingExtendBean.getFinancingId()).toString()));
//				
//				//还款金额不正确:为0或者小于0
//				if(!(recont.compareTo(BigDecimal.ZERO)==1)){
//					resMap.put(facFinancingExtendBean.getFinancingId(), "请填写正确的还款金额！");
//					logger.error("融资单【"+facFinancingExtendBean.getFinancingId()+"】还款金额不正确:为0或者小于0！");
//					continue;
//				}
//				
//				//累加本次还款的总金额
//				totalRefund = totalRefund.add(recont);
//				
//				//本次本融资单还款所用总金额
//				BigDecimal repay = BigDecimal.ZERO;
//				//本次本融资单总还本金额
//				BigDecimal ben = BigDecimal.ZERO;
//				//本次本融资单总还息金额
//				BigDecimal xi = BigDecimal.ZERO;
//				
//				//如果还款金额为0则处理下一条融资单
//				if(recont.compareTo(new BigDecimal(0))==0) continue;
//
//				//用于判断该融资单是否能完全还完
//				boolean boole = false;
//				FacGuaranteeBill  facg = null;
//				FacFinancingGuarantee facFinancingGuarantee = null;
//				//当前融资单所用的担保单关系表信息
//				List<FacFinancingGuaranteeExtendBean> finGuas = facFinancingExtendBean.getFacFinancingGuarantees();
//				
//				for(int i=0;i<finGuas.size();i++){
//					
//					FacFinancingGuaranteeExtendBean finGua = finGuas.get(i);
//					
//					// 如果当前担保单给付金额已还完则处理下一条
//					if(finGua.getSurplusPaymentsAmount().compareTo(BigDecimal.ZERO)==0) continue;
//					
//					//担保单实体(用于更新乐观锁和金额变化)
//					facg = new FacGuaranteeBill();
//					facg.setGuaranteeId(finGua.getGuaranteeId());
//					//计算本次还本金额(即计算拿多少钱来还本金)
//					BigDecimal principal = repaymentCalculate.repaymentCalculate(recont, facFinancingExtendBean.getAcceptDate(), facFinancingExtendBean.getExpireRate());
//					//计算本次还息金额(即计算拿多少钱来还利息)
//					BigDecimal interest = repaymentCalculate.repaymentInterest(recont, facFinancingExtendBean.getAcceptDate(), facFinancingExtendBean.getExpireRate());
//					
//					//根据给付金额计算利息
//					BigDecimal lixi = repaymentCalculate.guaranteeInterest(finGua.getSurplusPaymentsAmount(), facFinancingExtendBean.getAcceptDate(), facFinancingExtendBean.getExpireRate(), facFinancingExtendBean.getExtendRate());
//					
//					//计算需要还的本息
//					BigDecimal benxi = finGua.getSurplusPaymentsAmount().add(lixi);
//					
//					//当前给付金额
//					BigDecimal surplusPaymentsAmount = finGua.getSurplusPaymentsAmount();
//					//本次还款释放的冻结金额
//					//本次还款金额等于或大于担保单剩余给付金额则全部还完此担保单(减少当前的还本金额（principal）还息金额（interest）, 更新融资和结款单的关联表  )
//					if(principal.compareTo(surplusPaymentsAmount)==1||principal.compareTo(surplusPaymentsAmount)==0){
//						//担保单和融资单关系实体， 计算还款金额和释放冻结金额
//						facFinancingGuarantee = new FacFinancingGuarantee();
//						facFinancingGuarantee.setId(finGua.getId());
//						facFinancingGuarantee.setRefundAmount(finGua.getRefundAmount().add(surplusPaymentsAmount));
//						facFinancingGuarantee.setSurplusPaymentsAmount(finGua.getSurplusPaymentsAmount().subtract(surplusPaymentsAmount));
//						BigDecimal freezeAmount = repaymentCalculate.calculateFreezeAmount(finGua.getSurplusPaymentsAmount().subtract(surplusPaymentsAmount));
//						//本次还款释放的冻结金额
//						BigDecimal usableAmount = finGua.getSurplusFreezeAmount().subtract(freezeAmount);
//						facFinancingGuarantee.setSurplusFreezeAmount(freezeAmount);
//						financingGuaranteeList.add(facFinancingGuarantee);
//						
//						//减扣本次总还款金额
//						recont = recont.subtract(benxi);
//						//计算本次本融资单总共还了多少钱
//						repay = repay.add(benxi);
//						//计算本次本融资单所还了多少本金(每个担保单还本的总额)
//						ben = ben.add(surplusPaymentsAmount);
//						//计算本次本融资单当前担保单所还的利息(每个担保单还息的总额 )
//						xi = xi.add(lixi);
//						//计算本次还款总共还了多少本金
//						totalPrincipal = totalPrincipal.add(surplusPaymentsAmount);
//						//计算本次还款总共还多少利息
//						totalInterest = totalInterest.add(lixi);
//						
//						facg.setUsableAmount(finGua.getFacGuaranteeBill().getUsableAmount().add(usableAmount));
//						facg.setLock(finGua.getFacGuaranteeBill().getLock());
//						facGuaranteeBillList.add(facg);
//						
//						//如果处理最后一个担保单也是全额还的话说明该融资单已经全部还完了
//						if(i==finGuas.size()) boole = true;
//						
//						//如果是本次还款金额等于给付金额， 本次还款金额则为0跳出循环
//						if(principal.compareTo(surplusPaymentsAmount)==0) break;
//						
//					}else{
//						
//						facFinancingGuarantee = new FacFinancingGuarantee();
//						facFinancingGuarantee.setId(finGua.getId());
//						facFinancingGuarantee.setRefundAmount(finGua.getRefundAmount().add(principal));
//						facFinancingGuarantee.setSurplusPaymentsAmount(finGua.getSurplusPaymentsAmount().subtract(principal));
//						BigDecimal freezeAmount = repaymentCalculate.calculateFreezeAmount(finGua.getSurplusPaymentsAmount().subtract(principal));
//						//本次还款释放的冻结金额
//						BigDecimal usableAmount = finGua.getSurplusFreezeAmount().subtract(freezeAmount);
//						facFinancingGuarantee.setSurplusFreezeAmount(freezeAmount);
//						financingGuaranteeList.add(facFinancingGuarantee);
//						
//						//计算本次本融资单总共还了多少钱
//						repay = repay.add(recont);
//						//减扣本次总还款金额
//						recont = recont.subtract(recont);
//						//计算本次本融资单所还了多少本金(每个担保单还本的总额)
//						ben = ben.add(principal);
//						//计算本次本融资单当前担保单所还的利息(每个担保单还息的总额 )
//						xi = xi.add(interest);
//						//计算本次还款总共还了多少本金
//						totalPrincipal = totalPrincipal.add(principal);
//						//计算本次还款总共还多少利息
//						totalInterest = totalInterest.add(interest);
//						
//						facg.setUsableAmount(finGua.getFacGuaranteeBill().getUsableAmount().add(usableAmount));
//						facg.setLock(finGua.getFacGuaranteeBill().getLock());
//						facGuaranteeBillList.add(facg);
//						
//						//本次还款金额小于给付金额则用完本次全部的还款金额 则可以跳出此循环
//						break;
//					} 
//				}
//				
//				//还款和融资单关系表
//				FacFinancingRefund finRe = new FacFinancingRefund();
//				finRe.setId(Utils.commonUtil.getUUID());
//				finRe.setRefundId(refundId);
//				finRe.setFinancingId(facFinancingExtendBean.getFinancingId());
//				finRe.setRefundDate(new Date());
//				finRe.setRefundPrincipal(ben);
//				finRe.setRefundInterest(xi);
//				facFinancingRefundList.add(finRe);
//				//更新融资单的乐观锁
//				FacFinancing fac = new FacFinancing();
//				fac.setId(facFinancingExtendBean.getId());
//				fac.setLock(facFinancingExtendBean.getLock());
//				fac.setSttLastRefundId(finRe.getRefundId());
//				fac.setSttLastRefundData(new Date());
//				//如果融资单全部还完则更新融资单状态
//				if(boole) fac.setStatus(FinancingEnum.FAC_REFUNDED.getValue());
//				facFinancingList.add(fac);
//				
//				//释放ID锁
//				removeLock(facFinancingExtendBean);
//				
//				//生成报文
//				finRefund = refundFinMessage(facFinancingExtendBean, recont, ben, xi);
//				
//				//说明没有还款报文
//				if(finRefund==null) continue;
//				
//				finRefundListMap.add(Utils.objUtil.beanToMap(finRefund));
//				resMap.put(facFinancingExtendBean.getFinancingId(), "处理成功！");
//				
//			}catch(Exception e){
//				
//				resMap.put(facFinancingExtendBean.getFinancingId(), "处理失败！");
//				logger.error("融资单【"+facFinancingExtendBean.getFinancingId()+ "】异常:" + e.getMessage());
//			}finally{
//				//异常时移除ID锁
//				removeLock(facFinancingExtendBean);
//			}
//		}
//			
//		//判断是否需要处理的报文
//		if(finRefundListMap!=null&&finRefundListMap.size()>0){
//			
//			paraMap.put("FacFinancing", facFinancingList);
//			paraMap.put("FacGuaranteeBill", facGuaranteeBillList);
//			paraMap.put("FacFinancingRefund", facFinancingRefundList);
//			paraMap.put("FacFinancingGuarantee", financingGuaranteeList);
//			
//			//发送支付报文
//			boolean bool = sendMessage(finRefundListMap, "part", Utils.securityUtil.getUserDetails().getUsername(), serialNumber);
//			if(!bool) {
//				for(String finId : financingIds){
//					resMap.put(finId, "支付处理失败,请稍后再试!");
//				}
//				logger.error("支付处理失败！");
//				throw new RuntimeException("支付处理失败！");
//			}else{
//				
//				//往redis插入计算的结果用于支付回调保存到数据库
//				baseRedisDaoImpl.addMap(serialNumber, paraMap);
//				//插入还款单表
//				saveFacRefund(totalRefund, refundId, Utils.securityUtil.getUser().getUserId(),
//						Utils.securityUtil.getUser().getUsername(), SourceEnum.FACTORING.getValue(), serialNumber);
//			}
//		}
//		
//		return resMap;
//	}
	
	/**
	 * 财务版自还款
	 */
	@Override
	public HashMap<String, Object> executeFinancingRefund(String financingId,  String lockFinjJson, String lockGuajJson, String repaymentJson) {
        
        //前台选择的融资单id
        String[] financingIds = financingId.trim().split(",");
        //返回信息Map
        HashMap<String, Object> resMap = new HashMap<String, Object>();
        //前台融资还款金额
        JSONObject jsons = JSONObject.fromObject(repaymentJson);
        
        //通过融资单号查询出对象(担保单融资单及关系一起查询出来)
        List<FacFinancingExtendBean> fins = financingMapper.findFinancingAndGuaranteeListByFinIds(financingIds);
        
        if(fins==null||fins.size()==0){
            logger.error("融资单不存在！");
        }
        
        //更新融资单实体集合
        List<FacFinancing> facFinancingList = new ArrayList<FacFinancing>();
        //更新担保单实体集合
        List<FacGuaranteeBill> facGuaranteeBillList = new ArrayList<FacGuaranteeBill>();
        //更新担保还款实体集合
        List<FacFinancingRefund> facFinancingRefundList = new ArrayList<FacFinancingRefund>();
        //更新担保单担保金额的实体集合
        List<FacFinancingGuarantee> financingGuaranteeList = new ArrayList<FacFinancingGuarantee>();
        //创建还款流水号
        String serialNumber = Utils.commonUtil.getSerialNumber();
        //创建还款id
        String refundId = Utils.commonUtil.getUUID();
        //本次还款总额
        BigDecimal totalRefund = BigDecimal.ZERO;
        //本次还款还本总额
        BigDecimal totalPrincipal = BigDecimal.ZERO;
        //本次还款还息总额
        BigDecimal totalInterest = BigDecimal.ZERO;
        
        //组织报文所用的实体
        List<HashMap<String, Object>> finRefundListMap = new ArrayList<HashMap<String, Object>>();
        //redis存储数据库操作的信息Map用于支付回调处理数据库
        HashMap<String, Object> paraMap = new HashMap<String, Object>();
        
        FinRefundList finRefund = null;
        
        //财务版只能单个操作  其实就是一次循环
        for(FacFinancingExtendBean facFinancingExtendBean : fins){

            try{
                //判断融资单Id锁及乐观锁
                boolean bool = Utils.lock.lockByFin(facFinancingExtendBean, lockFinjJson, lockGuajJson);
                
                if(!bool){
                    resMap.put(facFinancingExtendBean.getFinancingId(), "系统繁忙请稍后再试！");
                    logger.error("融资单【"+facFinancingExtendBean.getFinancingId()+"】锁失败！");
                    throw new RuntimeException("融资单【"+facFinancingExtendBean.getFinancingId()+"】锁失败！");
                }
                
                //当前融资单总还款金额
                BigDecimal recont = new BigDecimal(Double.parseDouble(jsons.get(facFinancingExtendBean.getFinancingId()).toString()));
                
                //还款金额不正确:为0或者小于0
                if(!(recont.compareTo(BigDecimal.ZERO)==1)){
                    resMap.put(facFinancingExtendBean.getFinancingId(), "请填写正确的还款金额！");
                    logger.error("融资单【"+facFinancingExtendBean.getFinancingId()+"】还款金额不正确:为0或者小于0！");
                    throw new RuntimeException("融资单【"+facFinancingExtendBean.getFinancingId()+"】还款金额不正确:为0或者小于0！");
                }
                
                //累加本次还款的总金额
                totalRefund = totalRefund.add(recont);
                
                //本次本融资单还款所用总金额
                BigDecimal repay = BigDecimal.ZERO;
                //本次本融资单总还本金额
                BigDecimal ben = BigDecimal.ZERO;
                //本次本融资单总还息金额
                BigDecimal xi = BigDecimal.ZERO;
                
                //如果还款金额为0则处理下一条融资单
                if(recont.compareTo(new BigDecimal(0))==0) continue;

                //用于判断该融资单是否能完全还完
                boolean boole = false;
                FacGuaranteeBill  facg = null;
                FacFinancingGuarantee facFinancingGuarantee = null;
                //当前融资单所用的担保单关系表信息
                List<FacFinancingGuaranteeExtendBean> finGuas = facFinancingExtendBean.getFacFinancingGuarantees();
                
                for(int i=0;i<finGuas.size();i++){
                    
                    FacFinancingGuaranteeExtendBean finGua = finGuas.get(i);
                    
                    // 如果当前担保单给付金额已还完则处理下一条
                    if(finGua.getSurplusPaymentsAmount().compareTo(BigDecimal.ZERO)==0) continue;
                    
                    //担保单实体(用于更新乐观锁和金额变化)
                    facg = new FacGuaranteeBill();
                    facg.setGuaranteeId(finGua.getGuaranteeId());
                    //计算本次还本金额(即计算拿多少钱来还本金)
                    BigDecimal principal = repaymentCalculate.repaymentCalculate(recont, facFinancingExtendBean.getAcceptDate(), facFinancingExtendBean.getExpireRate());
                    //计算本次还息金额(即计算拿多少钱来还利息)
                    BigDecimal interest = repaymentCalculate.repaymentInterest(recont, facFinancingExtendBean.getAcceptDate(), facFinancingExtendBean.getExpireRate());
                    
                    //根据给付金额计算利息
                    BigDecimal lixi = repaymentCalculate.guaranteeInterest(finGua.getSurplusPaymentsAmount(), facFinancingExtendBean.getAcceptDate(), facFinancingExtendBean.getExpireRate(), facFinancingExtendBean.getExtendRate());
                    
                    //计算需要还的本息
                    BigDecimal benxi = finGua.getSurplusPaymentsAmount().add(lixi);
                    
                    //当前给付金额
                    BigDecimal surplusPaymentsAmount = finGua.getSurplusPaymentsAmount();
                    //本次还款释放的冻结金额
                    //本次还款金额等于或大于担保单剩余给付金额则全部还完此担保单(减少当前的还本金额（principal）还息金额（interest）, 更新融资和结款单的关联表  )
                    if(principal.compareTo(surplusPaymentsAmount)==1||principal.compareTo(surplusPaymentsAmount)==0){
                        //担保单和融资单关系实体， 计算还款金额和释放冻结金额
                        facFinancingGuarantee = new FacFinancingGuarantee();
                        facFinancingGuarantee.setId(finGua.getId());
                        facFinancingGuarantee.setRefundAmount(finGua.getRefundAmount().add(surplusPaymentsAmount));
                        facFinancingGuarantee.setSurplusPaymentsAmount(finGua.getSurplusPaymentsAmount().subtract(surplusPaymentsAmount));
                        BigDecimal freezeAmount = repaymentCalculate.calculateFreezeAmount(finGua.getSurplusPaymentsAmount().subtract(surplusPaymentsAmount));
                        //本次还款释放的冻结金额
                        BigDecimal usableAmount = finGua.getSurplusFreezeAmount().subtract(freezeAmount);
                        facFinancingGuarantee.setSurplusFreezeAmount(freezeAmount);
                        financingGuaranteeList.add(facFinancingGuarantee);
                        
                        //减扣本次总还款金额
                        recont = recont.subtract(benxi);
                        //计算本次本融资单总共还了多少钱
                        repay = repay.add(benxi);
                        //计算本次本融资单所还了多少本金(每个担保单还本的总额)
                        ben = ben.add(surplusPaymentsAmount);
                        //计算本次本融资单当前担保单所还的利息(每个担保单还息的总额 )
                        xi = xi.add(lixi);
                        //计算本次还款总共还了多少本金
                        totalPrincipal = totalPrincipal.add(surplusPaymentsAmount);
                        //计算本次还款总共还多少利息
                        totalInterest = totalInterest.add(lixi);
                        
                        facg.setUsableAmount(finGua.getFacGuaranteeBill().getUsableAmount().add(usableAmount));
                        facg.setLock(finGua.getFacGuaranteeBill().getLock());
                        facGuaranteeBillList.add(facg);
                        
                        //如果处理最后一个担保单也是全额还的话说明该融资单已经全部还完了
                        if(i==finGuas.size()) boole = true;
                        
                        //如果是本次还款金额等于给付金额， 本次还款金额则为0跳出循环
                        if(principal.compareTo(surplusPaymentsAmount)==0) break;
                        
                    }else{
                        
                        facFinancingGuarantee = new FacFinancingGuarantee();
                        facFinancingGuarantee.setId(finGua.getId());
                        facFinancingGuarantee.setRefundAmount(finGua.getRefundAmount().add(principal));
                        facFinancingGuarantee.setSurplusPaymentsAmount(finGua.getSurplusPaymentsAmount().subtract(principal));
                        BigDecimal freezeAmount = repaymentCalculate.calculateFreezeAmount(finGua.getSurplusPaymentsAmount().subtract(principal));
                        //本次还款释放的冻结金额
                        BigDecimal usableAmount = finGua.getSurplusFreezeAmount().subtract(freezeAmount);
                        facFinancingGuarantee.setSurplusFreezeAmount(freezeAmount);
                        financingGuaranteeList.add(facFinancingGuarantee);
                        
                        //计算本次本融资单总共还了多少钱
                        repay = repay.add(recont);
                        //减扣本次总还款金额
                        recont = recont.subtract(recont);
                        //计算本次本融资单所还了多少本金(每个担保单还本的总额)
                        ben = ben.add(principal);
                        //计算本次本融资单当前担保单所还的利息(每个担保单还息的总额 )
                        xi = xi.add(interest);
                        //计算本次还款总共还了多少本金
                        totalPrincipal = totalPrincipal.add(principal);
                        //计算本次还款总共还多少利息
                        totalInterest = totalInterest.add(interest);
                        
                        facg.setUsableAmount(finGua.getFacGuaranteeBill().getUsableAmount().add(usableAmount));
                        facg.setLock(finGua.getFacGuaranteeBill().getLock());
                        facGuaranteeBillList.add(facg);
                        
                        //本次还款金额小于给付金额则用完本次全部的还款金额 则可以跳出此循环
                        break;
                    } 
                }
                
                //还款和融资单关系表
                FacFinancingRefund finRe = new FacFinancingRefund();
                finRe.setId(Utils.commonUtil.getUUID());
                finRe.setRefundId(refundId);
                finRe.setFinancingId(facFinancingExtendBean.getFinancingId());
                finRe.setRefundDate(new Date());
                finRe.setRefundPrincipal(ben);
                finRe.setRefundInterest(xi);
                facFinancingRefundList.add(finRe);
                //更新融资单的乐观锁
                FacFinancing fac = new FacFinancing();
                fac.setId(facFinancingExtendBean.getId());
                fac.setLock(facFinancingExtendBean.getLock());
                fac.setSttLastRefundId(finRe.getRefundId());
                fac.setSttLastRefundData(new Date());
                //如果融资单全部还完则更新融资单状态
                if(boole) fac.setStatus(FinancingEnum.FAC_REFUNDED.getValue());
                facFinancingList.add(fac);
                
                //释放ID锁
                removeLock(facFinancingExtendBean);
                
                //生成报文
                finRefund = refundFinMessage(facFinancingExtendBean, recont, ben, xi);
                
                //说明没有还款报文
                if(finRefund==null) continue;
                
                finRefundListMap.add(Utils.objUtil.beanToMap(finRefund));
                resMap.put(facFinancingExtendBean.getFinancingId(), "处理成功！");
                
            }catch(Exception e){
                
                resMap.put(facFinancingExtendBean.getFinancingId(), "处理失败！");
                logger.error("融资单【"+facFinancingExtendBean.getFinancingId()+ "】异常:" + e.getMessage());
                throw new RuntimeException(e.getMessage());
            }finally{
                //异常时移除ID锁
                removeLock(facFinancingExtendBean);
            }
        }
        
        HashMap<String, Object> reMap = new HashMap<String, Object>();
        
        //判断是否需要处理的报文
        if(finRefundListMap!=null&&finRefundListMap.size()>0){
            
            FacRefund refund = saveFacRefund(totalRefund, refundId, Utils.securityUtil.getUser().getUserId(),
                    Utils.securityUtil.getUser().getUsername(), SourceEnum.FACTORING.getValue(), serialNumber);
            paraMap.put("refund", refund);
            paraMap.put("FacFinancing", facFinancingList);
            paraMap.put("FacGuaranteeBill", facGuaranteeBillList);
            paraMap.put("FacFinancingRefund", facFinancingRefundList);
            paraMap.put("FacFinancingGuarantee", financingGuaranteeList);
            //发送支付报文
            String rel = sendMessage(finRefundListMap, "part", Utils.securityUtil.getUserDetails().getUsername(), serialNumber);
            //插入还款单表
            
            reMap.put("refund", refund);
            reMap.put("paraMap", paraMap);
            reMap.put("rel", rel);
        }
        
        return reMap;
    }
	
	/**
	 * @Title: sendMessage 
	 * @author JW
	 * @Description: 发送支付报文
	 * @param finRefundListMap
	 * @return Boolean
	 * @throws
	 */
//	public Boolean sendMessage(List<HashMap<String, Object>> finRefundListMap, String integrity, String userName, String serialNumber){
//		
//		//如果msgLis为0或者null说明没有可执行的支付报文
//		boolean bool = false;
//		if(finRefundListMap!=null&&finRefundListMap.size()>0){
//			CallBack call = new CallBack();
//			call.setFactoringUrl("refundMgController/factoringCallback.do");
//			call.setMallUrl("");
//			FinanRefundMessage mess = new FinanRefundMessage();
//			mess.setIntegrity(integrity);
//			mess.setOperator(userName);
//			mess.setList(finRefundListMap);
//			mess.setCallBack(call);
//			mess.setSerialID(serialNumber);
//			String json = JSONObject.fromObject(Utils.objUtil.beanToMap(mess)).toString();
//			logger.info(json);
//			//调用支付系统
//			bool = factoringMsgService.handleFactoringMsg(json);
//		}
//		return bool;
//	}
	
	/**
     * @Title: sendMessage 
     * @author JW
     * @Description: 发送支付报文
     * @param finRefundListMap
     * @return Boolean
     * @throws
     */
	public String sendMessage(List<HashMap<String, Object>> finRefundListMap, String integrity, String userName, String serialNumber){
        
        //如果msgLis为0或者null说明没有可执行的支付报文
        String json = "";
        if(finRefundListMap!=null&&finRefundListMap.size()>0){
            CallBack call = new CallBack();
            call.setFactoringUrl("refundMgController/factoringCallback.do");
            call.setMallUrl("");
            FinanRefundMessage mess = new FinanRefundMessage();
            mess.setIntegrity(integrity);
            mess.setOperator(userName);
            mess.setList(finRefundListMap);
            mess.setCallBack(call);
            mess.setSerialID(serialNumber);
            json = JSONObject.fromObject(Utils.objUtil.beanToMap(mess)).toString();
            logger.info(json);
        }
        
        return description(json);
    }
	
	/**
	 * @Title: description 
	 * @Description: 还款描述
	 * @param @param json
	 * @param @return
	 * @return String
	 * @throws
	 */
	public String description(String json){
	    Map<String, Object> map = Utils.objUtil.parseJSON2Map(json);
        Object obj = map.get("list");
        JSONArray jsona = JSONArray.fromObject(obj);
        String message = "";
        int index = 1;
        for(Object ob : jsona){
            JSONArray js = JSONArray.fromObject(ob);
            if(index>1) message += ",";
            for(Object o : js){
                JSONObject jsobject = JSONObject.fromObject(o);
                JSONArray objs = JSONArray.fromObject(jsobject.get("action"));
                for(int i=0;i<objs.size();i++){
                    JSONObject jet = JSONObject.fromObject(objs.get(i));
                    String mess = jet.getString("memo")+":主账号:"+jet.get("accountNo")+
                            acctMgtService.queryAccountInfoByNo(jet.get("payAccNo").toString()).getAcctName()+":"+jet.get("payAccNo")+"到"+
                            jet.get("recvAccNm")+":"+jet.get("recvAccNo")+PayTypeCode.getText(jet.get("code").toString())+":￥"+jet.get("tranAmt");
                        if(i>0) message += ", ";
                        message += mess;
                }
            }
            index ++;
        }
	    return message;
	}
	
	/**
	 * @Title: refundMessage 
	 * @author JW
	 * @Description: 融资还款报文生成
	 * @param facFinancingExtendBean
	 * @param recont
	 * @param ben
	 * @param xi
	 * @return FinRefundList
	 * @throws
	 */
	public FinRefundList refundFinMessage(FacFinancingExtendBean facFinancingExtendBean, BigDecimal recont, BigDecimal ben, BigDecimal xi){
		List<HashMap<String, Object>> actionList = benXiMessageEntity(facFinancingExtendBean, ben, xi);
		//如果还款还剩余额则退回给供应商一般户
		if(recont.compareTo(BigDecimal.ZERO)==1){
			OutAction outAction = outAction(facFinancingExtendBean, recont);
			actionList.add(Utils.objUtil.beanToMap(outAction));
		}
		
		FinRefundList finRefund = null;
		if(actionList!=null&&actionList.size()>0){
			finRefund = new FinRefundList();
			finRefund.setFlowID(Utils.commonUtil.getSerialNumber());
			finRefund.setAction(actionList);
		}
		
		return finRefund;
	}
	
	/**
	 * @Title: message 
	 * @author JW
	 * @Description: 生成还款报文实体
	 * @param facFinancingExtendBean
	 * @param recont
	 * @param repay
	 * @return FinRefundList
	 * @throws
	 */
	public List<HashMap<String, Object>> benXiMessageEntity(FacFinancingExtendBean facFinancingExtendBean, BigDecimal ben, BigDecimal xi){
		
		//生成报文
		//还本报文
		List<HashMap<String, Object>> actionList = new ArrayList<HashMap<String,Object>>();
		if(ben.compareTo(BigDecimal.ZERO)==1){
			ForceTransferAction forceTransferAction = new ForceTransferAction();
			forceTransferAction.setCode(PayTypeCode.ZLMDTFER.getValue());
			forceTransferAction.setUserName("zhonglianlianhe");
			forceTransferAction.setClientID(Utils.commonUtil.getSerialNumber());
			forceTransferAction.setAccountNo(facFinancingExtendBean.getBlocAccount());
			forceTransferAction.setPayAccNo(facFinancingExtendBean.getDistributorTheoreticalBank());
			forceTransferAction.setTranType(TranType.BF.getValue());
			forceTransferAction.setRecvAccNo(facFinancingExtendBean.getMemberAccount());
			forceTransferAction.setRecvAccNm(facFinancingExtendBean.getAcctName());
			forceTransferAction.setTranAmt(String.format("%.2f", ben.doubleValue()));
			forceTransferAction.setAccNoCon("");
			forceTransferAction.setAccAmtCon(String.format("%.2f", ben.doubleValue()));
			forceTransferAction.setFreezeNo("");
			forceTransferAction.setMemo("融资还款还本转账");
			forceTransferAction.setTranFlag(TranFlag.YIBU.getValue());
			actionList.add(Utils.objUtil.beanToMap(forceTransferAction));
		}
		
		//还息报文
		if(xi.compareTo(BigDecimal.ZERO)==1){
			ForceTransferAction forceTransferActionXi = new ForceTransferAction();
			forceTransferActionXi.setCode(PayTypeCode.ZLMDTFER.getValue());
			forceTransferActionXi.setUserName("zhonglianlianhe");
			forceTransferActionXi.setClientID(Utils.commonUtil.getSerialNumber());
			forceTransferActionXi.setAccountNo(facFinancingExtendBean.getBlocAccount());
			forceTransferActionXi.setPayAccNo(facFinancingExtendBean.getDistributorTheoreticalBank());
			forceTransferActionXi.setTranType(TranType.BF.getValue());
			forceTransferActionXi.setRecvAccNo(facFinancingExtendBean.getMemberAccount());
			forceTransferActionXi.setRecvAccNm(facFinancingExtendBean.getAcctName());
			forceTransferActionXi.setTranAmt(String.format("%.2f", xi.doubleValue()));
			forceTransferActionXi.setAccNoCon("");
			forceTransferActionXi.setAccAmtCon(String.format("%.2f", xi.doubleValue()));
			forceTransferActionXi.setFreezeNo("");
			forceTransferActionXi.setMemo("融资还款还息转账");
			forceTransferActionXi.setTranFlag(TranFlag.YIBU.getValue());
			actionList.add(Utils.objUtil.beanToMap(forceTransferActionXi));
		}
		return actionList;
	}
	
	/**
	 * @Title: OutAction 
	 * @author JW
	 * @Description: 出金报文实体
	 * @param facFinancingExtendBean
	 * @param recont
	 * @return OutAction
	 * @throws
	 */
	public OutAction outAction(FacFinancingExtendBean facFinancingExtendBean, BigDecimal recont){
		OutAction outAction = new OutAction();
		outAction.setCode(PayTypeCode.ZLFNDOUT.getValue());
		outAction.setUserName("zhonglianlianhe");
		outAction.setClientID(Utils.commonUtil.getSerialNumber());
		outAction.setAccountNo(facFinancingExtendBean.getBlocAccount());
		outAction.setPayAccNo(facFinancingExtendBean.getDistributorTheoreticalBank());
		outAction.setRecvAccNo(facFinancingExtendBean.getDistributorGeneralBank());
		outAction.setRecvAccNm(facFinancingExtendBean.getDistributorName());
		outAction.setTranAmt(String.format("%.2f", recont.doubleValue()));
		outAction.setSameBank(SameBank.BENHANG.getValue());
		outAction.setRecvTgfi("");
		outAction.setRecvBankNm("");
		outAction.setMemo("融资还款余款退回");
		outAction.setPreFlg('0');
		outAction.setPreDate('0');
		outAction.setPreTime('0');
		return outAction;
	}
	
	/**
	 * @Title: removeLock 
	 * @author JW
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
	 * @Title: overtopArrearage 
	 * @author JW
	 * @Description: 超欠处理
	 * @param rzId void
	 * @throws
	 */
	public void overtopArrearage(FacFinancingGuaranteeExtendBean finGua){
		
		FacFinancingGuarantee facFinGua = new FacFinancingGuarantee();
		facFinGua.setId(finGua.getId());
		facFinGua.setStatus(FinancingGuaranteeEnum.CHAOQIAN.getValue());
		financingGuaranteeMapper.updateByPrimaryKeySelective(facFinGua);
	}
	
	public String payMentCallBack(PayMentCallBack payMentCallBack){
		
		return "200";
	}
	
	@Override
	@SuppressWarnings("unchecked")
	public String disposeFacRefundCallback(JSONObject json) {
		//更新融资单实体集合
		List<FacFinancing> facFinancingList = new ArrayList<FacFinancing>();
		//更新担保单实体集合
		List<FacGuaranteeBill> facGuaranteeBillList = new ArrayList<FacGuaranteeBill>();
		//更新担保还款实体集合
		List<FacGuaranteeRefund> facGuaranteeRefundList = new ArrayList<FacGuaranteeRefund>();
		//更新担保还款实体集合
		List<FacFinancingRefund> facFinancingRefundList = new ArrayList<FacFinancingRefund>();
		//更新担保单担保金额的实体集合
		List<FacFinancingGuarantee> financingGuaranteeList = new ArrayList<FacFinancingGuarantee>();
		//担保还款利息实体集合
		List<FacGuaranteeRefundInterest> guaranteeRefundInterestList = new ArrayList<FacGuaranteeRefundInterest>();
		
		String reralt = "200";
		try{
			
			PayMentCallBack payMentCallBack = (PayMentCallBack) JSONObject.toBean(json, PayMentCallBack.class);
			if("200".equals(payMentCallBack.getStatus())){
    
    	       if(payMentCallBack.getFactoringUrl().equals("accreditationMgController/factoringCallback.do")){
                  
                  /**  根据流水号获取融资单id  **/
                  List<FacFinancing> fin1 = financingMapper.getFinanaingIdByAcceptBankId(payMentCallBack.getSerialID());
                  String[] ids = new String[fin1.size()];
                  for(int i =0;i<fin1.size();i++){
                      ids[i]=fin1.get(i).getFinancingId();
                  }
                          
                  accreditationMgService.executeAccept_update(ids);
                  
              }else{
                
                    //根据流水号从redis获取需要操作数据库的信息
                    HashMap<String, Object> reMap = baseRedisDaoImpl.getObjectByKey(payMentCallBack.getSerialID());
                    HashMap<String, Object> param = new HashMap<String, Object>();
                    param.put("refundOrderNum", payMentCallBack.getSerialID());
                    param.put("status", RefundEnum.WAITING_BALANCE.getValue());
                    //判断是否已经处理过了 如果处理过了则不重复处理
                    int count = refundMapper.selectByRefundOrderNum(param);
                    if(count == 0) return reralt;
                    if(reMap!=null&&reMap.size()>0){
                        for(String key : reMap.keySet()){
                            switch (key) {
                            case "FacFinancing":
                                facFinancingList = (List<FacFinancing>) reMap.get(key);
                                break;
                            case "FacGuaranteeBill":
                                facGuaranteeBillList = (List<FacGuaranteeBill>) reMap.get(key);     
                                break;
                            case "FacGuaranteeRefund":
                                facGuaranteeRefundList = (List<FacGuaranteeRefund>) reMap.get(key);
                                break;
                            case "FacFinancingGuarantee":
                                financingGuaranteeList = (List<FacFinancingGuarantee>) reMap.get(key);
                                break;
                            case "FacGuaranteeRefundInterest":
                                guaranteeRefundInterestList = (List<FacGuaranteeRefundInterest>) reMap.get(key);
                                break;
                            case "FacFinancingRefund":
                                facFinancingRefundList = (List<FacFinancingRefund>) reMap.get(key);
                                break;
                            default:
                                break;
                            }
                        }
                        
                        if(facFinancingList.size()>0) financingMapper.updateFinancingByList(facFinancingList);
                        if(facGuaranteeBillList.size()>0) guaranteeBillMapper.updateGuaranteeBillByList(facGuaranteeBillList);
                        if(facGuaranteeRefundList.size()>0) guaranteeRefundMapper.insertGuaranteeRefundByList(facGuaranteeRefundList);
                        if(facFinancingRefundList.size()>0) financingRefundMapper.insertFinancingRefundByList(facFinancingRefundList);
                        if(financingGuaranteeList.size()>0) financingGuaranteeMapper.updateFinancingGuarantee(financingGuaranteeList);
                        if(guaranteeRefundInterestList.size()>0) guaranteeRefundInterestMapper.insertguaranteeRefundInterestByList(guaranteeRefundInterestList);
                        FacRefund refund = new FacRefund();
                        refund.setStatus(RefundEnum.BALANCE.getValue());
                        refundMapper.updateByPrimaryKeySelective(refund);
                        baseRedisDaoImpl.deletByKey(payMentCallBack.getSerialID());
                    }
                }
			}
			
		}catch(Exception e){
			e.printStackTrace();
			reralt = "400";
			throw new RuntimeException(e.getMessage());
		}
		
		return reralt;
	}
	
	
	@Override
    @SuppressWarnings("unchecked")
    public void disposeFacRefundFinancialCallback(HashMap<String, Object> map, String id, String lockFinJson, String lockGuaJson, String repaymentJson, Integer type) {
	    
	    boolean bool = true;
	    
	    if(type.equals(1)){
    	    List<FacFinancingExtendBean> fins = financingMapper.findFinancingAndGuaranteeListByFinIds(new String[]{id});
    	    bool = Utils.lock.lockByFint(fins.get(0), lockFinJson, lockGuaJson);
	    }else{
	        FacGuaranteeBillExtend finGua = guaranteeBillMapper.selectlGuaranteeBillAndFinancingByIds(new String[]{id}).get(0);
	        bool = Utils.lock.lockFinsAndDb(finGua, lockFinJson, lockGuaJson);
	    }
	    
	    if(!bool) throw new RuntimeException("判断乐观锁失败请重新操作！");
	    
	    HashMap<String, Object> resMap = (HashMap<String, Object>) map.get("paraMap");
	   
	    FacRefund refund = (FacRefund) map.get("refund");
        //更新融资单实体集合
        List<FacFinancing> facFinancingList = (List<FacFinancing>) resMap.get("FacFinancing");
        //更新担保单实体集合
        List<FacGuaranteeBill> facGuaranteeBillList = (List<FacGuaranteeBill>) resMap.get("FacGuaranteeBill");
        //更新担保还款实体集合
        List<FacGuaranteeRefund> facGuaranteeRefundList = (List<FacGuaranteeRefund>) resMap.get("FacGuaranteeRefund");
        //更新担保还款实体集合
        List<FacFinancingRefund> facFinancingRefundList = (List<FacFinancingRefund>) resMap.get("FacFinancingRefund");
        //更新担保单担保金额的实体集合
        List<FacFinancingGuarantee> financingGuaranteeList = (List<FacFinancingGuarantee>) resMap.get("FacFinancingGuarantee");
        //担保还款利息实体集合
        List<FacGuaranteeRefundInterest> guaranteeRefundInterestList = (List<FacGuaranteeRefundInterest>) resMap.get("FacGuaranteeRefundInterest");
            
        if(facFinancingList!=null&&facFinancingList.size()>0) financingMapper.updateFinancingByList(facFinancingList);
        if(facGuaranteeBillList!=null&&facGuaranteeBillList.size()>0) guaranteeBillMapper.updateGuaranteeBillByList(facGuaranteeBillList);
        if(facGuaranteeRefundList!=null&&facGuaranteeRefundList.size()>0) guaranteeRefundMapper.insertGuaranteeRefundByList(facGuaranteeRefundList);
        if(facFinancingRefundList!=null&&facFinancingRefundList.size()>0) financingRefundMapper.insertFinancingRefundByList(facFinancingRefundList);
        if(financingGuaranteeList!=null&&financingGuaranteeList.size()>0) financingGuaranteeMapper.updateFinancingGuarantee(financingGuaranteeList);
        if(guaranteeRefundInterestList!=null&&guaranteeRefundInterestList.size()>0) guaranteeRefundInterestMapper.insertguaranteeRefundInterestByList(guaranteeRefundInterestList);
        refund.setStatus(RefundEnum.BALANCE.getValue());
        refundMapper.updateByPrimaryKeySelective(refund);
    }
}
