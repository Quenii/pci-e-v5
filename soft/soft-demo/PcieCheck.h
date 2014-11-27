#if !defined(AFX_PCIECHECK_H__D858E2BA_23CA_441F_946B_760719AD99AD__INCLUDED_)
#define AFX_PCIECHECK_H__D858E2BA_23CA_441F_946B_760719AD99AD__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// PcieCheck.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CPcieCheck dialog

class CPcieCheck : public CDialog
{
// Construction
public:
	CPcieCheck(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CPcieCheck)
	enum { IDD = IDD_PCIECHECK };
	CStatic	m_infor;
	CString	m_chaininidone;
	CString	m_chainspeed;
	CString	m_chainstate;
	CString	m_chainwidth;
	CString	m_ddr2inidone;
	CString	m_deviceid;
	CString	m_srioinidone;
	CString	m_venderid;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPcieCheck)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CPcieCheck)
	afx_msg void OnStartCheck();
	virtual BOOL OnInitDialog();
	virtual void OnCancel();
	afx_msg void OnClose();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PCIECHECK_H__D858E2BA_23CA_441F_946B_760719AD99AD__INCLUDED_)
