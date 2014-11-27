// PciRecReplay.cpp : implementation file
//

#include "stdafx.h"
#include "PCIEProject.h"
#include "PciRecReplay.h"
#include "PCIEProjectDlg.h"
#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif
extern CPCIEProjectDlg *pPcieProject;
/////////////////////////////////////////////////////////////////////////////
// CPciRecReplay dialog
CPciRecReplay *preplay;

CPciRecReplay::CPciRecReplay(CWnd* pParent /*=NULL*/)
	: CDialog(CPciRecReplay::IDD, pParent)
{
	//{{AFX_DATA_INIT(CPciRecReplay)
	m_num = _T("");
	m_name = _T("");
	m_size = _T("");
	m_replaysize = 0;
	m_speed = _T("");
	m_location = _T("");
	m_time = _T("");
	m_start = 0;
	m_upspeed = 0.0f;
	m_aupload = 0.0f;
	m_rectype = _T("");
	//}}AFX_DATA_INIT
}
BOOL CPciRecReplay::OnInitDialog() 
{
	CDialog::OnInitDialog();
	preplay=this;
	m_realplay.SetCheck(1);
	m_recstopplay.EnableWindow(FALSE);
	m_num=pPcieProject->m_recindex;
	m_name=pPcieProject->m_recname;
	m_size=pPcieProject->m_recsize;
	m_speed=pPcieProject->m_recspeed;
	m_location=pPcieProject->m_reclocation;
	m_time=pPcieProject->m_recdate;
	m_replaysize=atoi(m_size);
	m_rectype=pPcieProject->m_rectype;
	m_start=0;
	m_jindu.SetRange(0,100);
	UpdateData(FALSE);
	
	// TODO: Add extra initialization here
	
	return TRUE;  // return TRUE unless you set the focus to a control
	// EXCEPTION: OCX Property Pages should return FALSE
}


void CPciRecReplay::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CPciRecReplay)
	DDX_Control(pDX, IDC_JINDU, m_jindu);
	DDX_Control(pDX, IDC_STOP, m_recstopplay);
	DDX_Control(pDX, IDOK, m_recstartplay);
	DDX_Text(pDX, IDC_NUM, m_num);
	DDX_Text(pDX, IDC_NAME, m_name);
	DDX_Text(pDX, IDC_RECSIZE, m_size);
	DDX_Text(pDX, IDC_REPLAYSIZE, m_replaysize);
	DDX_Text(pDX, IDC_SPEED, m_speed);
	DDX_Text(pDX, IDC_LOCATION, m_location);
	DDX_Text(pDX, IDC_TIMES, m_time);
	DDX_Text(pDX, IDC_START, m_start);
	DDX_Control(pDX, IDC_REAL, m_realplay);
	DDX_Text(pDX, IDC_UPSPEED, m_upspeed);
	DDX_Text(pDX, IDC_AUPLOAD, m_aupload);
	DDX_Text(pDX, IDC_RECTYPE, m_rectype);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CPciRecReplay, CDialog)
	//{{AFX_MSG_MAP(CPciRecReplay)
	ON_BN_CLICKED(IDOK, OnStart)
	ON_BN_CLICKED(IDC_STOP, OnStop)
	ON_WM_TIMER()
	ON_MESSAGE(WAITFORENDREPLAY,WaitForEndReply)
	ON_WM_CLOSE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CPciRecReplay message handlers
UINT ThreadStartPlay(LPVOID lpara)
{
	WaitForSingleObject(preplay->heve,INFINITE);
	preplay->PostMessage(WAITFORENDREPLAY,0,0);
	return 0;
}
LRESULT CPciRecReplay::WaitForEndReply(WPARAM wParam, LPARAM lParam)
{
	KillTimer(0);
	CloseHandle(hf);
	CloseHandle(heve);	
	m_recstartplay.EnableWindow(TRUE);
	m_recstopplay.EnableWindow(FALSE);
	OnTimer(0);
	if (m_aupload!=m_replaysize)
	{
		return 0;
	}	
	MessageBox("回放完毕！","提示");

	return 1;
}
void CPciRecReplay::OnStart() 
{
	
	LARGE_INTEGER li;
	CString filename,tempstr;
	char err[1024];
	UINT tansbock;   
	UpdateData(TRUE);
	if ((m_start>(UINT)atoi(m_size))||(m_replaysize<0)||(m_replaysize+m_start>(UINT)atoi(m_size)))
	{
		MessageBox("回放参数设置错误：越界！请从新设置","提示");
		return ;
	}
	filename=m_location+m_name;
	hf=CreateFile(filename,GENERIC_READ,0,0,OPEN_ALWAYS,0,0);
	if (	hf==INVALID_HANDLE_VALUE)
	{
		MessageBox("文件打开错误，请检查文件路径！","提示");
		return ;
	}
	li.QuadPart=m_start;
	li.QuadPart=li.QuadPart*1024*1024;
	SetFilePointer(hf,li.LowPart,(long *)&li.HighPart,FILE_BEGIN);

	if (!pPcieProject->pci_e.OpenDevice(0x10ee,7))
	{
		MessageBox("设备打开失败!","错误信息");
		CloseHandle(hf);
		return ;
	}
	if(!pPcieProject->pci_e.DMAReadMenAlloc(4,RDMABLOCKSIZE*1024))	
	{
		MessageBox("内存分配/映射失败","错误提示");//分配内存
		CloseHandle(hf);
		return;
	}
	tansbock=m_replaysize;//回放大小
	tansbock=(tansbock*1024)/RDMABLOCKSIZE;
	pPcieProject->pci_e.SetTransBlkNum(tansbock);//设置传输块数
	heve=CreateEvent(NULL,FALSE,FALSE,NULL);
	//光纤记录------------------------------------------------------------------
	if (m_realplay.GetCheck()==1)//实际回放
	{
		if(!pPcieProject->pci_e.StartDMA(FALSE,hf,TRUE,heve))
		{
			CloseHandle(heve);
			CloseHandle(hf);
			pPcieProject->pci_e.GetLastInfo(err);
			tempstr=err;
			MessageBox(tempstr,"错误提示");
			CloseHandle(hf);
			return;
		}
	}
	//模拟记录-------------------------------------------------------------------
	else
	{
		if(!pPcieProject->pci_e.StartDMA(FALSE,hf,FALSE,heve))
		{
			
			CloseHandle(heve);
			CloseHandle(hf);
			pPcieProject->pci_e.GetLastInfo(err);
			tempstr=err;
			MessageBox(tempstr,"错误提示");
			CloseHandle(hf);
			return;
		}
	}
	//工作结束
	m_recstartplay.EnableWindow(FALSE);
	m_recstopplay.EnableWindow(TRUE);
	m_jindu.SetPos(0);
	SetTimer(0,1000,NULL);
	AfxBeginThread(ThreadStartPlay,NULL);
	// TODO: Add your control notification handler code here
	
}


void CPciRecReplay::OnStop() 
{
	// TODO: Add your control notification handler code here
	pPcieProject->pci_e.StopDMA();
}

void CPciRecReplay::OnCancel() 
{
	// TODO: Add extra cleanup here
	if (m_recstartplay.IsWindowEnabled()!=TRUE)
	{
		MessageBox("请先停止回放后重试！","提示");
		return ;
	}
	pPcieProject->pci_e.StopDMA();
	CDialog::OnCancel();
}

void CPciRecReplay::OnTimer(UINT nIDEvent) 
{
	// TODO: Add your message handler code here and/or call default
    float times;
	alpay=(float)pPcieProject->pci_e.GetTransBlock();
	m_aupload=(alpay*RDMABLOCKSIZE)/1024;
	times=(float)pPcieProject->pci_e.GetTimes();
	if (times==0)
	{
		times=1;
	}
	m_upspeed=m_aupload/times;
	m_upspeed*=1.048576;
	alpay=(m_aupload/m_replaysize)*100;
	pos=(UINT)alpay;
	m_jindu.SetPos(pos);
	UpdateData(FALSE);
	CDialog::OnTimer(nIDEvent);
}

void CPciRecReplay::OnClose() 
{
	// TODO: Add your message handler code here and/or call default
	// TODO: Add extra cleanup here
	if (m_recstartplay.IsWindowEnabled()!=TRUE)
	{
		MessageBox("请先停止回放后重试！","提示");
		return ;
	}
	pPcieProject->pci_e.StopDMA();
	CDialog::OnClose();
}
