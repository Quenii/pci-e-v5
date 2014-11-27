#if !defined(AFX_CHAININI_H__893CD9FA_AE7E_4282_90C6_95E4A05C3F23__INCLUDED_)
#define AFX_CHAININI_H__893CD9FA_AE7E_4282_90C6_95E4A05C3F23__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Chainini.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CChainini dialog

class CChainini : public CDialog
{
// Construction
public:
	CChainini(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CChainini)
	enum { IDD = IDD_CHAININI };
	CStatic	m_result;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CChainini)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CChainini)
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CHAININI_H__893CD9FA_AE7E_4282_90C6_95E4A05C3F23__INCLUDED_)
