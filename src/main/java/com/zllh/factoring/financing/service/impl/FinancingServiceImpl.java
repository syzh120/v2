package com.zllh.factoring.financing.service.impl;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.zllh.common.common.model.model_extend.UserExtendBean;
import com.zllh.common.enums.BillsType;
import com.zllh.factoring.common.dao.FacFinancingMapper;
import com.zllh.factoring.common.interest.InterestConfig;
import com.zllh.factoring.common.model.FacFinancing;
import com.zllh.factoring.common.model.FacFinancingGuarantee;
import com.zllh.factoring.common.model.FacGuaranteeBill;
import com.zllh.factoring.financing.service.FinancingService;
import com.zllh.utils.base.Utils;
import com.zllh.utils.soleid.SoleIdUtil;

@Service
public class FinancingServiceImpl implements FinancingService {
	
	@Autowired
	private FacFinancingMapper facFinancingMapper;

	@Override
	public void updateAssureMoney() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public List<Map<String, Object>> getTypeById() {
		// TODO Auto-generated method stub
		return null;
	}
	
	public List<FacFinancing> getAllFinancing(Map<String,Object> map){ 
		UserExtendBean user1 = Utils.securityUtil.getUser();
		String menberId = user1.getMuser().getMmbId();
		map.put("memberId", menberId);
		List<FacFinancing> list = facFinancingMapper.getAllFinancing(map);
		return list;
	}

	@SuppressWarnings("unchecked")
	@Override
	public int saveFinancing(Map<String,Object> map) {
		// TODO Auto-generated method stub
		FacFinancing  fac = (FacFinancing) map.get("fac");
		
		/**
		 * 保存融资数据
		 */
		int i = facFinancingMapper.insertSelective(fac);
		
		if(i>0){
			/**
			 * 保存成功，循环页面所选担保数据，获取融资担保数据
			 */
			for(FacGuaranteeBill fg : (List<FacGuaranteeBill>)map.get("fglist_page")){
				
				/**
				 * 获取融资担保数据
				 */
				FacFinancingGuarantee ffg = getFacFinancingGuarantee(fg);
				ffg.setFinancingId(fac.getFinancingId());
				
				/**
				 * 保存融资担保数据
				 */
				i = facFinancingMapper.saveFacFinancingGuarantee(ffg);
				if(i==0){
					/**
					 * 如果融资数据保存失败，删除保存的融资数据，及改融资单所对应的所有融资担保信息
					 */
					facFinancingMapper.deleteByPrimaryKey(fac.getId());
					
					facFinancingMapper.deleteFinancingGuaranteeByFinancingId(fac.getFinancingId());
					
					break;
				}
			}
		}
		return i;
	}

	/**
	 * 生成融资单号、担保单号、还款单号等
	 */
	public String getMaxFinancingId(){
		int begin = 10000;
		String financingId;
		Integer finId = facFinancingMapper.getMaxFinancingId();
		
		if(finId==null){
			financingId = String.valueOf(begin + 1);
		}else{
			financingId = String.valueOf(finId + 1);
		}
		
		return financingId;
	}
	
	/**
	 * 获取融资担保数据
	 */
	public FacFinancingGuarantee getFacFinancingGuarantee(FacGuaranteeBill fg){
		FacFinancingGuarantee ffg = new FacFinancingGuarantee();
		
		ffg.setId(Utils.commonUtil.getUUID());
		ffg.setGuaranteeId(fg.getGuaranteeId());
		
	    BigDecimal percent = new BigDecimal(InterestConfig.PERCENT).setScale(2,java.math.BigDecimal.ROUND_HALF_UP);
		
//		ffg.setFreezeAmount(fg.getUsableAmount().divide(percent).setScale(2 ,java.math.BigDecimal.ROUND_HALF_UP));
//0830		ffg.setPaymentsAmount(fg.getUsableAmount().setScale(2 ,java.math.BigDecimal.ROUND_HALF_UP));
//0830		ffg.setLockAmount(fg.getUsableAmount().divide(percent).setScale(2 ,java.math.BigDecimal.ROUND_HALF_UP));
	    ffg.setLockAmount(fg.getUsableAmount().setScale(2 ,java.math.BigDecimal.ROUND_HALF_UP));
	    ffg.setPaymentsAmount(fg.getUsableAmount().multiply(percent).setScale(2 ,java.math.BigDecimal.ROUND_HALF_UP));
//		ffg.setSurplusFreezeAmount(fg.getUsableAmount().setScale(2 ,java.math.BigDecimal.ROUND_HALF_UP));
		ffg.setSurplusPaymentsAmount(fg.getUsableAmount().setScale(2 ,java.math.BigDecimal.ROUND_HALF_UP));
		
		return ffg;
	}
	
	/**
	 * 获取长度
	 */
	public int getAllLength(Map<String,Object> map){
		int i = Integer.parseInt(facFinancingMapper.getAllLength(map));
		return i;
	}
	
}
