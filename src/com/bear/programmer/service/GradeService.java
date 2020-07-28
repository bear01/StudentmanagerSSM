package com.bear.programmer.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.bear.programmer.entity.Grade;

/**
 * �꼶service
 * @author bear
 *
 */
@Service
public interface GradeService {
	public int add(Grade grade);
	public int edit(Grade grade);
	public int delete(String ids);
	public List<Grade> findList(Map<String,Object> queryMap);
	public List<Grade> findAll();
	public int getTotal(Map<String,Object> queryMap);
}
