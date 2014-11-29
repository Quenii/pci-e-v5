// RecordDlg.cpp : implementation file
//

#include "stdafx.h"
#include "PCIEProject.h"
#include "RecordDlg.h"
#include "PCIEProjectDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CRecordDlg dialog
extern CPCIEProjectDlg *pPcieProject;
extern RecordInfor *pfirst;
CRecordDlg *precdlg;
CRecordDlg::CRecordDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CRecordDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CRecordDlg)
	m_recname = _T("");
	m_recname = _T("");
	m_recsize = 0;
	m_discsize = _T("");
	m_atimes = _T("");
	m_arecsize = _T("");
	m_avspeed = 0.0f;
	//}}AFX_DATA_INIT

}
void CRecordDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CRecordDlg)
	DDX_Control(pDX, IDC_PROGRESS1, m_progress);
	DDX_Control(pDX, IDC_PROGRESS1, m_progress);
	DDX_Control(pDX, IDC_LOCATION, m_reclocation);
	DDX_Control(pDX, IDC_RECSTOP, m_recstop);
	DDX_Control(pDX, IDOK, m_recstart);
	DDX_Text(pDX, IDC_NAME, m_recname);
	DDX_Text(pDX, IDC_PRESIZE, m_recsize);
	DDX_Text(pDX, IDC_DISCFREESPACE, m_discsize);
	DDX_Text(pDX, IDC_TIMES, m_atimes);
	DDX_Text(pDX, IDC_RECSIZE, m_arecsize);
	DDX_Control(pDX, IDC_RADIO1, m_realrec);
	DDX_Text(pDX, IDC_AVSPEED, m_avspeed);
	//}}AFX_DATA_MAP

}
BEGIN_MESSAGE_MAP(CRecordDlg, CDialog)
	//{{AFX_MSG_MAP(CRecordDlg)
	ON_BN_CLICKED(IDOK, OnStartRecord)
	ON_CBN_SELCHANGE(IDC_LOCATION, OnSelchangeLocation)
	ON_BN_CLICKED(IDC_RECSTOP, OnRecstop)
	ON_MESSAGE(WAITFORENDREC,WaitForEndRec)
	ON_WM_TIMER()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CRecordDlg message handlers
UINT ThreadWaitEnd(PVOID lpara)
{
	WaitForSingleObject(precdlg->heve,INFINITE);
	precdlg->PostMessage(WAITFORENDREC,0,0);

	return 0;
}
void CRecordDlg::OnStartRecord() 
{
	char err[1024];
	CString tempstr;
	RecordInfor *temp;
	UpdateData(TRUE);
	UINT tansbock;
	pgress=0;
	if (m_recname=="")
	{
		MessageBox("文件名为空,请填写文件名!","提示");
		return;
	}
	if (m_recsize<10)
	{
		MessageBox("当前磁盘空间不足12MB,请将文件路径转换到其它磁盘分区去(大于12MB的磁盘分区)!","提示");
		return;
	}
	m_reclocation.GetWindowText(filename);
	recdis=filename;
	temp=pfirst;
	while (temp)
	{
		if ((strcmp(temp->reclocation,recdis.GetBuffer(0))==0)&&(strcmp(temp->recname,m_recname.GetBuffer(0))==0))
		{
			MessageBox("该文件已存在，不可添加","提示");
			return ;
		}
		temp=temp->Pnext;
	}
	filename=filename+m_recname;
	hf=CreateFile(filename,GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,0,0);
	if (hf==INVALID_HANDLE_VALUE)
	{
		MessageBox("文件创建失败!","提示");
		return;
	}	
	pPcieProject->pci_e.CloseDevice();//先清除一切
	if (!pPcieProject->pci_e.OpenDevice(0x10ee,7))
	{
		MessageBox("设备打开失败!","错误信息");
		CloseHandle(hf);
		return ;
	}
	//开始工作
	//光纤记录------------------------------------------------------------------
	if(!pPcieProject->pci_e.DMAWriteMenAlloc(4,WDMABLOCKSIZE*1024))	
	{
		MessageBox("内存分配/映射失败","错误提示");//分配内存
		return;
	}
	tansbock=m_recsize-10;
	tansbock=(tansbock*1024)/WDMABLOCKSIZE;
	pPcieProject->pci_e.SetTransBlkNum(tansbock);//设置传输块数
	heve=CreateEvent(NULL,FALSE,FALSE,NULL);
	if (m_realrec.GetCheck()==1)
	{
		if(!pPcieProject->pci_e.StartDMA(TRUE,hf,TRUE,heve))
		{
			CloseHandle(heve);
			CloseHandle(hf);
			pPcieProject->pci_e.GetLastInfo(err);
			tempstr=err;
			MessageBox(tempstr,"错误提示");
			CloseHandle(hf);
			return;
		}
		starttime=CTime::GetCurrentTime();
		strcpy(recInfor.rectype,"光纤记录");
	}
	//模拟记录-------------------------------------------------------------------
	else
	{
		if(!pPcieProject->pci_e.StartDMA(TRUE,hf,FALSE,heve))
		{
			CloseHandle(heve);
			CloseHandle(hf);
			pPcieProject->pci_e.GetLastInfo(err);
			tempstr=err;
			MessageBox(tempstr,"错误提示");
			CloseHandle(hf);
			return;
		}
		starttime=CTime::GetCurrentTime();
		strcpy(recInfor.rectype,"模拟记录");
	}
	//工作结束
	m_progress.SetRange(0,100);
	m_progress.SetPos(0);
	SetTimer(0,1000,NULL);
	m_recstart.EnableWindow(FALSE);
	m_recstop.EnableWindow(TRUE);
	AfxBeginThread(ThreadWaitEnd,NULL);

	
}
LRESULT CRecordDlg::WaitForEndRec(WPARAM wParam, LPARAM lParam)
{
	KillTimer(0);
	LARGE_INTEGER li;
	li.LowPart=GetFileSize(hf,(unsigned long *)&li.HighPart);
	CloseHandle(hf);
	if (li.QuadPart<=(1024*1024))
	{
		DeleteFile(filename.GetBuffer(0) );  // pointer to name of file to delete
	}
	else
	{
		strcpy(recInfor.reclocation,recdis.GetBuffer(0));
		strcpy(recInfor.recname,m_recname.GetBuffer(0));
		recInfor.rectime.day=starttime.GetDay();
		recInfor.rectime.hour=starttime.GetHour();
		recInfor.rectime.minute=starttime.GetMinute();
		recInfor.rectime.second=starttime.GetSecond();
		recInfor.rectime.year=starttime.GetYear();
		recInfor.rectime.mouth=starttime.GetMonth();
		recInfor.recsize=(float)pPcieProject->pci_e.GetTransBlock();
		recInfor.recsize=WDMABLOCKSIZE*recInfor.recsize/(1024);
		recInfor.recspeed=recInfor.recsize/pPcieProject->pci_e.GetTimes();
		recInfor.freespace=pPcieProject->GetDiscFreeSpace(recInfor.reclocation);
		recInfor.Pnext=NULL;
		//处理链表,然后设置通知主界面更新显示的变量
		pPcieProject->AddRecInfor(&recInfor);
		isNeedShow=TRUE;
		m_discsize.Format("%d",pPcieProject->GetDiscFreeSpace(recdis.GetBuffer(0)));
		UpdateData(FALSE);
		
	}
	m_discsize.Format("%d",pPcieProject->GetDiscFreeSpace(recInfor.reclocation));
	m_recstart.EnableWindow(TRUE);
	m_recstop.EnableWindow(FALSE);
	UpdateData(FALSE);

	return 1;
}
void CRecordDlg::OnRecstop() 
{
	pPcieProject->pci_e.StopDMA();
	
	m_recstart.EnableWindow(TRUE);
	m_recstop.EnableWindow(FALSE);
//	UpdateData(FALSE);
	// 在这里调用函数通知不需要记录了.
}
void CRecordDlg::OnCancel() 
{
	if(!m_recstart.IsWindowEnabled())
	{
		MessageBox("请先停止记录！","提示");
		return;
	};
	if (isNeedShow)
	pPcieProject->PostMessage(REFRESHLIST,0,0);//提示刷新列表显示信息
	CDialog::OnCancel();
}



BOOL CRecordDlg::OnInitDialog() 
{
	CDialog::OnInitDialog();
	precdlg=this;
	m_realrec.SetCheck(1);
	m_recstop.EnableWindow(FALSE);
	DWORD temp;
	DWORD discs;
	ULARGE_INTEGER FreeBytesAvailableToCaller;
	ULARGE_INTEGER TotalNumberOfBytes;
	ULARGE_INTEGER TotalNumberOfFreeBytes;
	discs=GetLogicalDrives();
	char a =65;
	CString str;

	while(discs)
	{
		temp=discs>>1;
		if (discs!=temp*2)
		{

			str.Format("%c:\\",a);
			if (GetDriveType(str)!=DRIVE_CDROM)
			{
				m_reclocation.AddString(str);
			}

		}
		discs=discs>>1;
		a++;
	}
	m_reclocation.SetCurSel(0);
	m_reclocation.GetWindowText(str);
	GetDiskFreeSpaceEx(
		str.GetBuffer(0),                 // pointer to the directory name
		&FreeBytesAvailableToCaller, // receives the number of bytes on
		// disk available to the caller
		&TotalNumberOfBytes,    // receives the number of bytes on disk
		&TotalNumberOfFreeBytes // receives the free bytes on disk
);
	TotalNumberOfFreeBytes.QuadPart=TotalNumberOfFreeBytes.QuadPart/(1024*1024);
	str.Format("%d",TotalNumberOfFreeBytes.LowPart);
	m_discsize=str;
	m_recsize=TotalNumberOfFreeBytes.LowPart;
	//设置盘符选择寻找和盘符选择;
	isNeedShow=FALSE;


	// TODO: Add extra initialization here
	UpdateData(FALSE);
	
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

void CRecordDlg::OnSelchangeLocation() 
{
	UpdateData();
	ULARGE_INTEGER FreeBytesAvailableToCaller;
	ULARGE_INTEGER TotalNumberOfBytes;
	ULARGE_INTEGER TotalNumberOfFreeBytes;
	int index;
	CString str;
	char disc[10];
	index=m_reclocation.GetCurSel();
	m_reclocation.GetLBText( index, disc );// TODO: Add your control notification handler code here
	str=disc;
	GetDiskFreeSpaceEx(
		disc,                 // pointer to the directory name
		&FreeBytesAvailableToCaller, // receives the number of bytes on
		// disk available to the caller
		&TotalNumberOfBytes,    // receives the number of bytes on disk
		&TotalNumberOfFreeBytes // receives the free bytes on disk
		);
	TotalNumberOfFreeBytes.QuadPart=TotalNumberOfFreeBytes.QuadPart/(1024*1024);
	str.Format("%d",TotalNumberOfFreeBytes.LowPart);
	m_discsize=str;
	m_recsize=TotalNumberOfFreeBytes.LowPart;
	UpdateData(FALSE);	
}



void CRecordDlg::OnTimer(UINT_PTR nIDEvent) 
{
	// TODO: Add your message handler code here and/or call default
	UINT times;
	float blocks;
	times=pPcieProject->pci_e.GetTimes();
	blocks=(float)pPcieProject->pci_e.GetTransBlock();
	blocks=blocks*WDMABLOCKSIZE/(1024);
	m_avspeed=blocks/times;
	m_avspeed*=1.048576;
	m_atimes.Format("%d",times);
	m_arecsize.Format("%.2f",blocks);
	blocks/=m_recsize;
	blocks*=100;
	times=(UINT)blocks;
	m_progress.SetPos(times);	
	UpdateData(FALSE);
	CDialog::OnTimer(nIDEvent);
}
