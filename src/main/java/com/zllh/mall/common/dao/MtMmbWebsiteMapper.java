package com.zllh.mall.common.dao;

import java.util.Map;

import com.zllh.mall.common.model.MtMmbWebsite;



public interface MtMmbWebsiteMapper {
    int insert(MtMmbWebsite record);

    int insertSelective(MtMmbWebsite record);
    
    int updateBymmbId(MtMmbWebsite record);
    MtMmbWebsite searchBymmbId(String mmbId);
    int updateSelective(MtMmbWebsite record);
}