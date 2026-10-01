<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Redirect to login or dashboard depending on session
    if (session.getAttribute("user") != null) {
        response.sendRedirect("dashboard.jsp");
    } else {
        response.sendRedirect("login.jsp");
    }
%>