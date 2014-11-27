// Chainini.cpp : implementation file
//

#include "stdafx.h"
#include "PCIEProject.h"
#include "Chainini.h"
#include "PCIEProjectDlg.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif
extern CPCIEProjectDlg *pPcieProject;
/////////////////////////////////////////////////////////////////////////////
// CChainini dialog


CChainini::CChainini(CWnd* pParent /*=NULL*/)
	: CDialog(CChainini::IDD, pParent)
{
	//{{AFX_DATA_INIT(CChainini)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CChainini::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CChainini)
	DDX_Control(pDX, IDC_STATIC1, m_result);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CChainini, CDialog)
	//{{AFX_MSG_MAP(CChainini)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CChainini message handlers

void CChainini::OnOK() 
{
	CString str;
	// TODO: Add extra validation here
	m_result.SetWindowText("正在初始化中，请稍等...");
	for (int i=0;i<5;i++)
	{
		if (pPcieProject->pci_e.ChainIniCheck())
		{
			m_result.SetWindowText("成功");
			return ;
		}
		str.Format("%d",i+1);
		m_result.SetWindowText("正在尝试第"+str+"次初始化..");


	}
   
	m_result.SetWindowText("失败");
//	CDialog::OnOK();
}
