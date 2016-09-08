package com.zllh.base.security.handler;

import java.io.IOException;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;

import com.alibaba.fastjson.JSON;
import com.zllh.common.authority.service.UserService;
import com.zllh.common.common.model.model_extend.UserExtendBean;
import com.zllh.utils.base.Utils;

/**
 * @ClassName: LoginSuccessHandler
 * @Description: 登录成功处理
 * @author JW
 * @date 2015-11-26 下午5:03:23
 */
public class LoginSuccessHandler extends SavedRequestAwareAuthenticationSuccessHandler {

	private UserService userService;
//	private RequestCache requestCache = new HttpSessionRequestCache();

	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws ServletException, IOException {
	   
	    UserExtendBean user = Utils.securityUtil.getUser();
        request.getSession().setAttribute("user", user);
        String loginCode = request.getParameter("loginCode");
        if("mall".equals(loginCode)){
            String json = JSON.toJSONString(user);
            response.setContentType("text/html;charset=utf-8");
            response.getWriter().write(json);
            response.getWriter().flush();
            response.getWriter().close();
        }else if("backMg".equals(loginCode)){
            request.getSession().getAttribute("ru");
            Object mbcode = request.getSession().getAttribute("mbcode");
            if(mbcode!=null&&mbcode.equals("Y")){
                String ru = request.getSession().getAttribute("ru").toString();
                request.getSession().removeAttribute("ru");  
                if(ru!=null&&!"".equals(ru)){  
                    getRedirectStrategy().sendRedirect(request, response, ru.substring(ru.indexOf("v2")+"v2".length(), ru.length())); 
                    return;
                }else{  
                    getRedirectStrategy().sendRedirect(request, response, "/userController/toHome.do"); 
                    return;
                }  
            }else{
                getRedirectStrategy().sendRedirect(request, response, "/userController/toHome.do");
                return;
            }
        }else if("app".equals(loginCode)){
            HashMap<String, Object> reMap = new HashMap<String, Object>();
            HashMap<String, Object> objMap = new HashMap<String, Object>();
            objMap.put("sessionId", request.getSession().getId());
            objMap.put("userId", user.getUserId());
            objMap.put("userName", user.getUserName());
            objMap.put("mmbId", user.getMuser().getMmbId());
            objMap.put("mmbName", user.getMuser().getMmbName());
            reMap.put("obj", objMap);
            reMap.put("success", true);
            reMap.put("msg", "登录成功！");
            String json = JSON.toJSONString(reMap);
            response.setContentType("text/html;charset=utf-8");
            response.getWriter().write(json);
            response.getWriter().flush();
            response.getWriter().close();
        }
		
//		SavedRequest savedRequest = requestCache.getRequest(request, response);
//		if (savedRequest == null) {
//			super.onAuthenticationSuccess(request, response, authentication);
//			saveLog(request);
//			return;
//		}
//		if (isAlwaysUseDefaultTargetUrl() || StringUtils.hasText(request.getParameter(getTargetUrlParameter()))) {
//			this.requestCache.removeRequest(request, response);
//			super.onAuthenticationSuccess(request, response, authentication);
//			saveLog(request);
//			return;
//		}
//		clearAuthenticationAttributes(request);
//		String targetUrl = savedRequest.getRedirectUrl();
//		saveLog(request);
	}

	public void saveLog(HttpServletRequest request) {
		UserDetails userDetails = (UserDetails)SecurityContextHolder.getContext().getAuthentication().getPrincipal() ;
		request.getSession().setAttribute("user", userDetails);
	}

//	private String getIpAddr(HttpServletRequest request) {
//		String ip = request.getHeader("x-forwarded-for");
//		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
//			ip = request.getHeader("Proxy-Client-IP");
//		}
//		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
//			ip = request.getHeader("WL-Proxy-Client-IP");
//		}
//		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
//			ip = request.getRemoteAddr();
//		}
//		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
//			ip = request.getHeader("http_client_ip");
//		}
//		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
//			ip = request.getHeader("HTTP_X_FORWARDED_FOR");
//		}
//		// 如果是多级代理，那么取第一个ip为客户ip
//		if (ip != null && ip.indexOf(",") != -1) {
//			ip = ip.substring(ip.lastIndexOf(",") + 1, ip.length()).trim();
//		}
//		return ip;
//	}

	public UserService getUserService() {
		return userService;
	}

	public void setUserService(UserService userService) {
		this.userService = userService;
	}
}
