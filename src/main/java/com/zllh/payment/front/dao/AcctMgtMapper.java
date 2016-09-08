package com.zllh.payment.front.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.zllh.payment.model.AcctMgt;

public interface AcctMgtMapper {
	int deleteByPrimaryKey(String bankAcct);

	int insert(AcctMgt record);

	int insertSelective(AcctMgt record);

	AcctMgt selectByPrimaryKey(String bankAcct);

	List<AcctMgt> selectAcctByCon(AcctMgt acctMgt);
	
	List<AcctMgt> selectAcctByCon2(AcctMgt acctMgt);
	
	int selectAcctCount(AcctMgt acctMgt);
	
	int selectAcctMsgCount(AcctMgt acctMgt);

	List<AcctMgt> selectAcctByAcctType(@Param("acctType") int acctType,@Param("bankId") String bankId);
	
	List<AcctMgt> selectAcctByBankAcct(@Param("bankAcct") String bankAcct);

	int updateByPrimaryKeySelective(AcctMgt record);

	int updateByPrimaryKey(AcctMgt record);

	List<AcctMgt> queryAccountInfoByCompanyName(String companyName);
	
	//一般户查询
	public List<AcctMgt> queryAccountListByParams(Map map);
}