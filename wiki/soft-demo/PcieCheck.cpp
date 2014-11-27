// PcieCheck.cpp : implementation file
//

#include "stdafx.h"
#include "PCIEProject.h"
#include "PcieCheck.h"
#include "PCIEProjectDlg.h"
#include "PCI_E.H"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CPcieCheck dialog

extern CPCIEProjectDlg *pPcieProject;
CPcieCheck::CPcieCheck(CWnd* pParent /*=NULL*/)
	: CDialog(CPcieCheck::IDD, pParent)
{
	//{{AFX_DATA_INIT(CPcieCheck)
	m_chaininidone = _T("");
	m_chainspeed = _T("");
	m_chainstate = _T("");
	m_chainwidth = _T("");
	m_ddr2inidone = _T("");
	m_deviceid = _T("");
	m_srioinidone = _T("");
	m_venderid = _T("");
	//}}AFX_DATA_INIT
}


void CPcieCheck::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CPcieCheck)
	DDX_Control(pDX, IDC_INFOR, m_infor);
	DDX_Text(pDX, IDC_CHAININIDONE, m_chaininidone);
	DDX_Text(pDX, IDC_CHAINSPEED, m_chainspeed);
	DDX_Text(pDX, IDC_CHAINSTATE, m_chainstate);
	DDX_Text(pDX, IDC_CHAINWIDTH, m_chainwidth);
	DDX_Text(pDX, IDC_DDR2INIDONE, m_ddr2inidone);
	DDX_Text(pDX, IDC_DEVICEID, m_deviceid);
	DDX_Text(pDX, IDC_SRIOINIDONE, m_srioinidone);
	DDX_Text(pDX, IDC_VENDORID, m_venderid);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CPcieCheck, CDialog)
	//{{AFX_MSG_MAP(CPcieCheck)
	ON_BN_CLICKED(IDOK, OnStartCheck)
	ON_WM_CLOSE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPcieCheck message handlers


//PCIE开始检测函数
void CPcieCheck::OnStartCheck() 
{
	char inf[1024];
	UINT data32,temp;
	CString str;
	m_infor.SetWindowText("正在检测中,请稍等...");
	// TODO: Add your control notification handler code here
	if(!pPcieProject->pci_e.ReadCfg(VENDORID,&temp,2))
	{
		pPcieProject->pci_e.GetLastInfo(inf);
		MessageBox("读取配置空间信息失败，原因是："+str,"提示");
		return ;
	}		
	m_venderid.Format("0x%0x",temp);//厂商号
	pPcieProject->pci_e.ReadCfg(DEVICEID,&temp,2);
	m_deviceid.Format("0x%0x",temp);//设备号
	pPcieProject->pci_e.ReadBAR0(0x3c,&data32,4);
	temp=data32&0x0000000f;
	if (temp==1)
		m_chainspeed="2.5Gbps";
	else
		m_chainspeed="未定义";
	temp=data32&0x000003f0;
	temp=temp>>4;
	if (temp>=1&&temp<=32)
	{
		m_chainwidth.Format("x%d",temp);
	}
	else
	{
		m_chainwidth="未知";
	}
	temp=data32&0x38000;
	temp=temp>>15;
	if (temp==6)
		m_chainstate="L0";
	else if(temp==5)
		m_chainstate="L0s";
	else if(temp==3)
		m_chainstate="L1";
	else if(temp==7)
		m_chainstate="in transition";
	else if(temp==7)
		m_chainstate="未定义";
	//pPcieProject->pci_e.ReadBAR0(0x44,&data32,4);
	pPcieProject->pci_e.ReadBAR0(0x38,&data32,4);
	//temp=data32&0x80000000;
	temp=data32&0x00010000;
	//if(temp==0x80000000)
	if(temp==0x00010000)
		m_chaininidone="链路连接正常";
	else
		m_chaininidone="链路未连接";
	//temp=data32&0x40000000;
	temp=data32&0x00020000;
	//if(temp==0x40000000)
	if(temp==0x00020000)
		m_ddr2inidone="链路连接正常";
	else
		m_ddr2inidone="链路未连接";
	//temp=data32&0x20000000;
	temp=data32&0x00040000;
	//if(temp==0x20000000)
	if(temp==0x00040000)
		m_srioinidone="链路连接正常";
	else
		m_srioinidone="链路未连接";

	UpdateData(FALSE);

	m_infor.SetWindowText("检测完毕");
	
}


BOOL CPcieCheck::OnInitDialog() 
{
	CDialog::OnInitDialog();
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void CPcieCheck::OnCancel() 
{
	// TODO: Add extra cleanup here
	pPcieProject->pci_e.CloseDevice();
	CDialog::OnCancel();
}

void CPcieCheck::OnClose() 
{
	// TODO: Add your message handler code here and/or call default
	pPcieProject->pci_e.CloseDevice();
	CDialog::OnClose();
}
