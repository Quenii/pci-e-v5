// PCIEProjectDlg.h : header file
//

#if !defined(AFX_PCIEPROJECTDLG_H__BF8992A8_F2AF_40F7_9C77_01CACF1FD9C9__INCLUDED_)
#define AFX_PCIEPROJECTDLG_H__BF8992A8_F2AF_40F7_9C77_01CACF1FD9C9__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CPCIEProjectDlg dialog
//#include "ListVwEx.h"
#include "PCI_E.H"
class CPCIEProjectDlg : public CDialog
{
// Construction

public:
	CPCIEProjectDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CPCIEProjectDlg)
	enum { IDD = IDD_PCIEPROJECT_DIALOG };
	CButton	m_btnrecdelet;
	CButton	m_btnrecalldelet;
	CButton	m_btnpciecheck;
	CButton	m_btnreplay;
	CListCtrl	m_listShow;
	CString	m_recindex;
	CString	m_reclocation;
	CString	m_recname;
	CString	m_recsize;
	CString	m_recdate;
	CString	m_recspace;
	CString	m_rectype;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CPCIEProjectDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
public:
	UINT GetDiscFreeSpace(char *disc);
	void DeleteChain();
	void ShowListInfor();
	BOOL DealRecFromFile(void *pdata);
	BOOL ReadRecInfor();
	HANDLE hrec,htemrec;
	BOOL AddRecInfor(void *pdata);
	pcie pci_e;
	CString	m_recspeed;
	void ShowRecInfor();
//	CListViewEx m_RecListCtrl;
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CPCIEProjectDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnPcieCheck();
	afx_msg LRESULT RefreshList(WPARAM wParam, LPARAM lParam);//消息处理函数----用于记录后刷新显示列表的处理
	afx_msg LRESULT FirstListShow(WPARAM wParam, LPARAM lParam);//启动界面后界面信息第一次更新显示的消息处理
	afx_msg void OnRecording();
	afx_msg void OnReplayBack();
	afx_msg void OnSelectItem(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnLocrefresh();
	afx_msg void OnRecdelete();
	afx_msg void OnRecalldelet();
	afx_msg void OnClose();
	virtual void OnCancel();
	afx_msg void OnFileadd();
	afx_msg void OnChainini();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
typedef struct __RecordInfor 
{
	UINT recindex;
	char recname[60];
	struct  
	{
		UINT year;
		UINT mouth;
		UINT day;
		UINT hour;
		UINT minute;
		UINT second;
	}rectime;
	float recsize;
	float recspeed;
	char reclocation[10];
	UINT freespace;
	 struct __RecordInfor *Pnext;
	char rectype[20];

}RecordInfor;

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_PCIEPROJECTDLG_H__BF8992A8_F2AF_40F7_9C77_01CACF1FD9C9__INCLUDED_)
