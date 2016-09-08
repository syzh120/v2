package com.zllh.common.authority.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.zllh.base.controller.BaseController;
import com.zllh.common.authority.service.CfcAkService;

@Controller
@RequestMapping("/cfcAkController")
public class CfcAkController extends BaseController{
    
    @Autowired
    private CfcAkService cfcAkService;
    
    @RequestMapping(value="/cfcakHandle_Auth", method=RequestMethod.POST)
    public @ResponseBody String cfcakHandle() throws Exception{
        
        //结款单号、主题、收款方、付款方、收款账号、付款账号、预计付款时间、预计付款金额 、收付款方标志、会员id、操作员id
        String signedContent = request.getParameter("signedContent");
        String signature = request.getParameter("signature");
        String opertion = request.getParameter("opertion");

        return cfcAkService.executeCfcakHandle(signedContent, signature, opertion);
    }
}
