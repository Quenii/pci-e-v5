#if !defined(AFX_RECORDDLG_H__441B85B1_648A_43B2_841E_46DE904BCDB5__INCLUDED_)
#define AFX_RECORDDLG_H__441B85B1_648A_43B2_841E_46DE904BCDB5__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// RecordDlg.h : header file
//
#include "PCIEProjectDlg.h"
/////////////////////////////////////////////////////////////////////////////
// CRecordDlg dialog
#define WDMABLOCKSIZE       256


class CRecordDlg : public CDialog
{
// Construction
public:
	RecordInfor recInfor;

	UINT pgress;
	CTime starttime;
	CString filename,recdis;
	BOOL isNeedShow;
	HANDLE hf,heve;//ÊÂ¼þµÈ´ý¾ä±ú;

	CRecordDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CRecordDlg)
	enum { IDD = IDD_PCIERECORDING };
	CProgressCtrl	m_progress;
	CComboBox	m_reclocation;
	CButton	m_recstop;
	CButton	m_recstart;
	CString	m_recname;
	UINT	m_recsize;
	CString	m_discsize;
	CString	m_atimes;
	CString	m_arecsize;
	CButton	m_realrec;
	float	m_avspeed;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CRecordDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CRecordDlg)
	afx_msg void OnStartRecord();
	virtual BOOL OnInitDialog();
	afx_msg void OnSelchangeLocation();
	afx_msg void OnRecstop();
	virtual void OnCancel();
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	afx_msg LRESULT WaitForEndRec(WPARAM wParam, LPARAM lParam);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_RECORDDLG_H__441B85B1_648A_43B2_841E_46DE904BCDB5__INCLUDED_)
