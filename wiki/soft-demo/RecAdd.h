#if !defined(AFX_RECADD_H__8794A0C7_DD62_4DD1_B04E_4B886A23F495__INCLUDED_)
#define AFX_RECADD_H__8794A0C7_DD62_4DD1_B04E_4B886A23F495__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// RecAdd.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CRecAdd dialog

class CRecAdd : public CDialog
{
// Construction
public:
	BOOL needshow;
	CRecAdd(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CRecAdd)
	enum { IDD = IDD_RECADD };
	CString	m_edit2;
	CString	m_edit1;
	CString	m_information;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CRecAdd)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CRecAdd)
	virtual void OnOK();
	virtual void OnCancel();
	afx_msg void OnClose();
	afx_msg void OnLiulan();
	virtual BOOL OnInitDialog();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_RECADD_H__8794A0C7_DD62_4DD1_B04E_4B886A23F495__INCLUDED_)
