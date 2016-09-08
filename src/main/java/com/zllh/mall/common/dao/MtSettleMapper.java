package com.zllh.mall.common.dao;

import java.util.List;
import java.util.Map;

import com.zllh.mall.common.model.MtSettle;

public interface MtSettleMapper {
	
    int deleteByPrimaryKey(String id);

    int insert(MtSettle record);

    int insertSelective(MtSettle record);

    MtSettle selectByPrimaryKey(String id);
    
    List<MtSettle> searchPendingSettle(Map<String,Object> map);

    List<MtSettle> searchPendingSettleForApp(Map<String,Object> map);

    List<MtSettle> searchMyPendingSettle(Map<String,Object> map);
    
    List<MtSettle> searchSettleManage(Map<String,Object> map);
    
    List<MtSettle> searchSettleSignature(Map<String,Object> map);
    
    List<MtSettle> searchSettleRegist(Map<String,Object> map);

    int updateByPrimaryKeySelective(MtSettle record);

    int updateByPrimaryKey(MtSettle record);

    MtSettle findSettleByCode(String settleCode);
}