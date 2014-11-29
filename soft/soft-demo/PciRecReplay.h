#if !defined(AFX_PCIRECREPLAY_H__785B7B0A_1FAB_4692_8025_42ABCCD38214__INCLUDED_)
#define AFX_PCIRECREPLAY_H__785B7B0A_1FAB_4692_8025_42ABCCD38214__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// PciRecReplay.h : header file
//
#define RDMABLOCKSIZE       256
/////////////////////////////////////////////////////////////////////////////
// CPciRecReplay dialog

class CPciRecReplay : public CDialog
{
// Construction
public:
	CString str;
	UINT pos;
	float alpay;
	HANDLE hf,heve;
	CPciRecReplay(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CPciRecReplay)
	enum { IDD = IDD_PCIEREPLAYBACK };
	CProgressCtrl	m_jindu;
	CButton	m_recstopplay;
	CButton	m_recstartplay;
	CString	m_num;
	CString	m_name;
	CString	m_size;
	UINT	m_replaysize;
	CString	m_speed;
	CString	m_location;
	CString	m_time;
	UINT	m_start;
	CButton	m_realplay;
	float	m_upspeed;
	float	m_aupload;
	CString	m_rectype;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPciRecReplay)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CPciRecReplay)
	afx_msg void OnStart();
	virtual BOOL OnInitDialog();
	afx_msg void OnStop();
	virtual void OnCancel();
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	afx_msg LRESULT WaitForEndReply(WPARAM wParam, LPARAM lParam);
	afx_msg void OnClose();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PCIRECREPLAY_H__785B7B0A_1FAB_4692_8025_42ABCCD38214__INCLUDED_)
